require 'uri'
require 'net/http'
require 'json'
require 'capture_tools'

class DemoController < ApplicationController
  
  include SessionHelper

  layout "demo"

  before_filter :require_login, :only => [:profile, :edit_profile, :foo, :bar, :change_password]
  before_filter :backplane
  before_filter :global_uris
  before_filter :sso
  before_filter :nav

  private

  def nav
    if signed_in?
      @username = user_entity["displayName"]
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

  # these uris are used in multiple views and actions.
  def global_uris
    uri = URI(settings["my_addr"]) #URI(["http://", @@my_addr].join())
    uri.path = "/demo/authCallback"
    @redirect_uri = uri.to_s

    @xdcomm_uri = settings["my_addr"] + "/demo/xdcomm.html" 

    uri = URI("#{scheme}://#{settings["captureui_addr"]}")
    uri.path = "/oauth/signin"
    uri.query = URI.encode_www_form({
      "client_id" => settings["client_id"],
      "response_type" => "code",
      "redirect_uri" => @redirect_uri,
      "xd_receiver" => @xdcomm_uri,
      "recover_password_callback" => "CAPTURE.recoverPasswordCallback"
    })
    @signin_uri = uri.to_s

    @my_logout_uri = settings["my_addr"] + "/demo/logout"
  end

  public

  # these three actions are for debugging
  def viewsession
    render :json => session[:capture_session]
  end 
  def foo
    render :json => settings
  end
  def bar
    render :json => user_entity
  end
  def login
    redirect_to signin_uri 
  end

  def logout
    sign_out
    redirect_to "/demo/home"
  end

  def xdcomm
    render :layout => false
  end

  def change_password
    if signed_in?
      uri = URI("http://" + captureui_addr)
      uri.path = "/oauth/profile_change_password"
      uri.query = URI.encode_www_form({
        "token"       => access_token,
        "callback"    => "CAPTURE.closeChangePassword",
        "xd_receiver" => @xdcomm_uri
      })
      @change_password_uri = uri.to_s
    end
  end

  def profile
    if signed_in?
      @view_profile_uri = "#{scheme}://#{settings["captureui_addr"]}/oauth/public_profile?id=#{user_entity["id"].to_s}"
    end
  end

  def edit_profile
   if signed_in?
      uri = URI("#{scheme}://#{settings["captureui_addr"]}")
      uri.path = "/oauth/profile"
      uri.query = URI.encode_www_form({
        "token" => access_token ,
        "callback" => "CAPTURE.profileEditCallback" ,
        "xd_receiver" => @xdcomm_uri
      })
      @edit_profile_uri = uri.to_s
    end
  end

  def authCallback
    begin
      auth_code = params["code"]
    rescue KeyError
      raise "error: no code param provided"
    end

    begin
      from_sso = params["from_sso"] == "1" 
      origin = params["origin"]
     #params.delete("code")
      #redirect_uri_sso.query = URI.encode_www_form(params)
    rescue KeyError
      from_sso = false
    end 
    
    redirect_uri_sso = URI(@redirect_uri) 
    redirect_uri_sso.query = URI.encode_www_form(params.select{|k, v| ["from_sso", "origin"].include? k})

    redirect_uri = from_sso ? redirect_uri_sso.to_s : @redirect_uri

    password_reset = sign_in(auth_code, redirect_uri)

    if from_sso
      # we got here from sso, redirect to origin(the page where user entered 
      # the site)
      redirect_to origin
    elsif password_reset
      # we got here from email password reset, redirect to change password
      redirect_to "/demo/change_password"
    else
      # we got here from returning from login initiated on this site
      if true
        # close the fancybox
        render :text => "<script>window.parent.location.reload()</script>"
      else
        redirect_to "/demo/home"
      end
    end 
  end 
end
