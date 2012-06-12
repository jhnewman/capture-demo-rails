require 'uri'
require 'net/http'
require 'json'
require 'yaml'
require 'capture_tools'

class Hash
  def select_keys(keys)
    self.select {|key, val| keys.include? key }
  end
end

class DemoController < ApplicationController


  include Settings  
  include SessionHelper

  layout "demo"

  before_filter :name
  before_filter :action
  before_filter :my_addr

#  before_filter :require_login, :only => [:profile, :edit_profile, :foo, :bar, :change_password]
#  before_filter :backplane
#  before_filter :global_uris
#  before_filter :sso

  before_filter :nav, :except => [:list_apps, :view_session, :view_settings, :view_user_entity]

  private

  def nav
    @apps = app_configs.keys
    @screens = settings["screens"]
    if signed_in?
      @username = user_entity.fetch("displayName")
    end
  end

  # initializes data used in _sso.html.erb
  def sso
    @client_id = settings["client_id"]
    @sso_server = settings["sso_server"]
    @use_sso = @sso_server != nil
  end

  # initializes data used in _backplane.html.erb
  def backplane
    @use_backplane = capture_settings.key?("backplane_server") && capture_settings.key?("backplane_bus") && capture_settings.key?("backplane_version")
    
    @serverBaseURL = "https://#{capture_settings["backplane_server"]}/#{capture_settings["backplane_version"]}/"

    @busName = capture_settings["backplane_bus"] 
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

  # things, for lack of a better name, are parameters that can be used
  # to construct queries in screen uris
  def things
    return @things unless @things.blank?
    
    @things = settings.select_keys ["client_id", "client_secret"]

    uri = URI(my_addr)
    uri.path = "/#{name}/authCallback" 
    @things["redirect_uri"] = uri.to_s

    
    @things["token"] = access_token if signed_in?

    @things["id"] = user_entity["id"].to_s if signed_in?

    @things
  end
 
  # these uris are used in multiple views and actions.
  def global_uris
    #uri = URI(my_addr) #URI(settings["my_addr"]) #URI(["http://", @@my_addr].join())
    #uri.path = "/#{name}/authCallback"
    #@redirect_uri = uri.to_s

    #@xdcomm_uri = settings["my_addr"] + "/#{name}/xdcomm.html" 

    #uri = URI("#{settings.fetch("captureui_addr")}")
    #uri.path = "/oauth/signin"
    #uri.query = URI.encode_www_form({
    #  "client_id" => settings.fetch("client_id"),
    #  "response_type" => "code",
    #  "redirect_uri" => @redirect_uri,
    #  "xd_receiver" => @xdcomm_uri,
    #  "recover_password_callback" => "CAPTURE.recoverPasswordCallback"
    #})
    #@signin_uri = uri.to_s

    #@my_logout_uri = settings.fetch("my_addr") + "/#{name}/logout"
  end

  protected 

  def name
    @name ||= params[:name]
  end


  def action
    @action ||= params[:action]
  end

  # constructs a uri for a capture screen with the necesary params and embeds 
  # it in an iframe in the page. 
  def embed_screen(keys = [], other_params = {})
    @iframe_src = construct_uri(things.select_keys(keys).merge(other_params))
    render "iframe"
  end

  # constructs the uri of a capture_screen from params
  def construct_uri(params = {})
    uri = URI("https://" + settings.fetch("captureui_addr"))
    uri.path = "/oauth/#{action}"
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  public

  def view_redirect_uri
    render :text => things["redirect_uri"]
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
    render :json => settings
  end

  def view_user_entity
    render :json => user_entity
  end
i

 
  def logout
    sign_out
    redirect_to "/demo/home"
  end

  # this is for signing out
  def logout
    sign_out
    #render :text => ""
    redirect_to "#{my_addr}/#{name}/home"
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
    
    redirect_uri_sso = URI(things["redirect_uri"])
    redirect_uri_sso.query = URI.encode_www_form(params.select{|k, v| ["from_sso", "origin"].include? k})

    redirect_uri = from_sso ? redirect_uri_sso.to_s : things["redirect_uri"]

    password_reset = sign_in(auth_code, redirect_uri)

    if from_sso
      # we got here from sso, redirect to origin(the page where user entered 
      # the site)
      redirect_to origin
    elsif password_reset
      # we got here from email password reset, redirect to change password
      redirect_to "/#{name}/profile_change_password"
    else
      redirect_to "/#{name}/home"
    end 
  end 

  # these are shils for capture screens. they embed capture screens within an
  # iframe in the page.
  def legacy_register_mobile
    legacy_register
  end

  def post_login_confirmation_test
    embed_screen
  end

  def post_login_confirmation
    embed_screen
  end

  def signin
    embed_screen ["redirect_uri", "client_id"] , "response_type" => "code"
  end

  def signin_mobile
    signin
  end

  def public_profile
    embed_screen ["id"] 
  end
 
  def finish_third_party
    embed_screen ["redirect_uri", "client_id", "token"], "response_type" => "code"
  end

  def add_signin
    embed_screen ["redirect_uri"]
  end

  def profile_change_password
    embed_screen ["token"]
  end



# example request
#
# http://catfacts.dnsdynamic.com:5422/oauth/signin?
#   client_id=<something>&
#   response_type=code&
#   redirect_uri=http://catfacts.dnsdynamic.com:8001/demo/authCallback&
#   xd_receiver=http://catfacts.dnsdynamic.com:8001/demo/xdcomm.html&
#   recover_password_callback=CAPTURE.recoverPasswordCallback
  def recover_password
    embed_screen ["redirect_uri", "client_id"], "response_type" => "code"

    #"redirect_uri" => @redirect_uri, "client_id" => settings["client_id"], "response_type" => "code"
  end

  def js_token_url_1
    embed_screen ["client_id", "redirect_uri"], {"response_type" => "code", "flags" => "stay_in_window", "new_widget" => "true"}
  end

  def account_exists
    embed_screen "redirect_uri" => @redirect_uri
  end

# legacy_register?
#   client_id=<something>
#   flags=stay_in_window
#   redirect_uri=http%3A%2F%2Fcatfacts.dnsdynamic.com%3A8002%2Fdemo%2FauthCallback&response_type=code

  def legacy_register
    embed_screen ["redirect_uri", "client_id"], {"response_type" => "code", "flags" => "stay_in_window"}
  end

  def profile
    embed_screen ["token"]
  end

end
