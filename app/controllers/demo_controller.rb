require 'uri'
require 'net/http'
require 'json'
require 'yaml'
require 'capture_tools'

class Hash
  def select_keys(*keys)
    self.select {|key, val| keys.include? key }
  end
end

# http://blog.moertel.com/articles/2006/04/07/composing-functions-in-ruby
class Proc
  def self.compose(f, g)
    lambda { |*args| f[g[*args]] }
  end
  def *(g)
    Proc.compose(self, g)
  end
end

class DemoController < ApplicationController


  include Settings  
  include SessionHelper

  layout "demo"

  @@debug = true

  before_filter :screen_name

  def screen_name 
    @screen_name ||= params[:screen_name]
  end

  before_filter :my_addr

#  before_filter :require_login, :only => [:profile, :edit_profile, :foo, :bar, :change_password]

#  before_filter :backplane
#  before_filter :sso

  before_filter :nav, :except => [:list_apps, :view_session, :view_settings, :view_user_entity]

  private

  def nav
    @apps = app_configs.keys
    @signin_uri = screen_uri(api_args.select_keys("client_id", "redirect_uri", "response_type"), "signin")
    @debug = @@debug
    if signed_in?
      @username = user_entity.fetch("displayName")
    end
  end

  # initializes data used in _sso.html.erb
  def sso
    #@client_id = settings["client_id"]
    #@sso_server = settings["sso_server"]
    @use_sso = @sso_server != nil
  end

  # initializes data used in _backplane.html.erb
  def backplane
    @use_backplane = app.backplane_server && app.backplane_bus && app.backplane_version
    
    @serverBaseURL = "https://#{app.backplane_server}/#{app.backplane_version}/"

    @busName = app.backplane_bus
  end

  def require_login
    if !signed_in?
      render :layout => "demo", :text => "You must sign in to view this page."
      return false
    else
      return true
    end
  end

  def my_addr
     @my_addr ||= "#{request.protocol}#{request.host}:#{request.port}" 
  end

  # api_args, are args that can be used
  # to construct queries in screen uris
  def api_args
    return @api_args unless @api_args.blank?
    
    @api_args = settings.select_keys("client_id", "client_secret")

    @api_args["response_type"] = "code"

    uri = URI(my_addr)
    uri.path = "/#{app.name}/authCallback" 
    @api_args["redirect_uri"] = uri.to_s

    
    @api_args["token"] = access_token if signed_in?

    @api_args["id"] = user_entity["id"].to_s if signed_in?

    return @api_args
  end

  # constructs a uri for a capture screen with the necesary params and embeds 
  # it in an iframe in the page. 
  def embed_screen(params = {})
    @iframe_src = screen_uri(params)
    render "iframe"
  end

  # constructs the uri of a capture_screen from params
  def screen_uri(params = {}, sn = screen_name)
    uri = URI("https://" + app.captureui_addr)
    uri.path = "/oauth/#{sn}"
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  public

#  def client_id
#    render :text => api_args["client_id"]
#  end

  def view_api_args
    render :json => api_args
  end

  def redirect_uri
    render :text => api_args["redirect_uri"]
  end

  def index 
    #render :text => "#{session.key?(:capture_session)}....#{session.fetch("capture_session")}" 
    render :text => my_addr
    #render :text => @signin_uri
    #render :text => params["name"]
    #render :json => settings
  end

  # these actions are for development
  def list_apps
    render :text => app_configs.keys
  end

  def view_session
    render :json => session.fetch("capture_sessions")
  end

  def view_settings
    render :json => app.settings
  end

  def view_user_entity
    render :json => user_entity
  end  

  # not capture screens, but used for this app.

  def logout
    sign_out
    redirect_to "#{my_addr}/#{app.name}/home"
  end

  def home
    render :home, :layout => true
  end

  # required as described in documentation
  def xdcomm
    render :layout => false
  end

  # handles oauth callback stuff from signin
  def authCallback
    begin
      auth_code = params.fetch("code")
    rescue KeyError
      raise "error: no code param provided"
    end

    from_sso = params.fetch("from_sso", "0") == "1" 
    origin = params["origin"]
    
    redirect_uri_sso = URI(api_args["redirect_uri"])
    redirect_uri_sso.query = URI.encode_www_form(params.select{|k, v| ["from_sso", "origin"].include? k})

    redirect_uri = from_sso ? redirect_uri_sso.to_s : api_args["redirect_uri"]

    password_reset = sign_in(auth_code, redirect_uri)

    if from_sso
      # we got here from sso, redirect to origin(the page where user entered 
      # the site)
      redirect_to origin
    elsif password_reset
      # we got here from email password reset, redirect to change password
      redirect_to "/#{app.name}/profile_change_password"
    else
      # since we are in an iframe, reload the parent, not the current window,
      # otherwise we will get nesting.
      render :text => "<script>window.parent.location.reload()</script>"
    end 
  end 
  
  # dispatcher is the action that get called for /:app/:screen routes.
  # Turns screen into an action, and calls it. If it can't find an action
  # it will remove suffixes until it can, or until it decides to call 
  # a generic handler.
  # 
  #im so meta
  def dispatcher
    screen = screen_name
    # continuosly remove tokens seperated by '_', starting from the end
    # until there are no more tokens, or we find one that we respond to
    begin
      if self.respond_to?(screen.to_sym) 
        self.method(screen).call
        return
      end
      tokens = screen.split("_")
      screen = tokens.take(tokens.length - 1).join("_")
    end while screen != ""
    generic_screen
  end

  def generic_screen
    #render :text => "unknown screen", :layout => true
    embed_screen
  end

  # these are shils for capture screens. they embed capture screens within an
  # iframe in the page.
  def signin
    embed_screen api_args.select_keys("redirect_uri", "client_id", "response_type")
  end

  def public_profile
    embed_screen api_args.select_keys("id") 
  end
 
#  def finish_third_party
#    embed_screen api_args.select_keys("redirect_uri", "client_id", "token", "response_type")
#  end

  def profile_change_password
    embed_screen api_args.select_keys("token")
  end

  def recover_password
    embed_screen api_args.select_keys("redirect_uri", "client_id", "response_type")
  end

  def legacy_register
    embed_screen api_args.select_keys("redirect_uri", "client_id", "response_type").merge("flags" => "stay_in_window")
  end

  def profile
    embed_screen api_args.select_keys("token")
  end

  # unviewable screens
  def add_signin
    render :unviewable
  end
  def account_exists
    render :unviewable
  end
  def token_url_2
    render :unviewable
  end
  def finish_third_party
    render :unviewable
  end

 
end

