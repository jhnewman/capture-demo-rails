
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

    session[:capture_session] = res

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
    session.delete(:capture_session)
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
    session.key?(:capture_session)
  end

  private

  # a capture apid abstraction defined in capture_tools
  def capture
    @capture ||= CaptureTools::Api.new({
      :base_url => "#{scheme}://#{settings["capture_addr"]}", 
      :client_id => settings["client_id"],
      :client_secret => settings["client_secret"],
      :app_id => settings["app_id"]
    })
  end



  def require_signin
    if !signed_in?
      raise "Must sign in to perform this query to capture."
    end
  end

  def access_token
    capture_session["access_token"]
  end

  def capture_session
    session[:capture_session]
  end

  def refresh_token
    session[:capture_session] = capture.refresh_token({
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
