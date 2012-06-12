
# handles signed in state, session, and capture api calls
module SessionHelper

  include Settings

  public 
  
  def sign_in(auth_code, redirect_uri)
    # exchange authorization code for access token json result, and store 
    # in session. This session key is how we track users login state.
    res = capture.code_for_token({
      :code => auth_code,
      :redirect_uri => redirect_uri
    })

    capture_sessions[params[:name]] = res

    # return true if this is a password recover flow, false otherwise
    begin
      return res["transaction_state"]["capture"]["password_recover"] == 1
    rescue KeyError
      return false
    end     
  end

  # there isn't even a runtime exception if you try to read an instance
  # variable that doesn't exist, nil is returned... This is why it makes more 
  # sense to wrap these things in functions, because that will raise an 
  # exception

  def sign_out
    capture_sessions.delete(params[:name])
  end

  def capture_settings
    @capture_settings ||= capture.items()["result"]
  end

  # user_entity is currently the only place that uses the access_token,
  # besides (view|edit)_profile_uri, this is why we handle token refresh here
  # even though it seems sort of arbitrary and would go somewhere more general 
  # in a real site, for instance, in a before_filter.
  def user_entity
    require_signin
    begin
      @user_entity ||= capture.entity_with_access( access_token )["result"]
      return @user_entity
    rescue CaptureTools::Errors::AccessTokenExpiredError      
      # refresh the token
      refresh_token()
      # and try again
      return user_entity
    end
  end

  def signed_in?
    capture_sessions.key?(params[:name])
  end

  private

  # a capture apid abstraction defined in capture_tools
  def capture
    @capture ||= CaptureTools::Api.new({
      #:base_url => settings.fetch("capture_addr"), 
      :base_url => "https://" + settings.fetch("captureui_addr"), # both should be the same in most cases.
      :client_id => settings.fetch("client_id"),
      :client_secret => settings.fetch("client_secret"),
      :app_id => settings.fetch("app_id")
    })
  end



  def require_signin
    if !signed_in?
      raise "Must sign in to do this."
    end
  end

  def access_token
    require_signin
    capture_session.fetch("access_token")
  end

  def capture_sessions
    session[:capture_sessions] ||= {}
  end

  def capture_session
    capture_sessions[params[:name]]
  end

  def refresh_token
    capture_sessions[params[:name]] = capture.refresh_token({
      :refresh_token => capture_session["refresh_token"]
    })
  end

  #def token_expired?
  #  raise session[:capture_session].to_s
  #  Time.now.to_i > session[:capture_session]["expiration_time"]
  #end

 # def refresh_wrapper(action)
 #   begin
 #     # attempty to do api call
 #     return action.call
 #   rescue CaptureTools::Errors::AccessTokenExpiredError      
 #     # refresh the token
 #     set_capture_session(refresh_token())
 #     # and try again
 #     return action.call
 #   end
 # end

end
