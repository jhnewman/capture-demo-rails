
# handles signed in state, session, and capture api calls
module SessionHelper

  include Settings

  public 
  
  def sign_in(auth_code, redirect_uri)
    # exchange authorization code for access token json result, and store 
    # in session. This session key is how we track users login state.
    res = app.api.code_for_token({
      :code => auth_code,
      :redirect_uri => redirect_uri
    })

    capture_sessions[app.name] = res

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
    capture_sessions.delete(app.name)
  end

  # user_entity is currently the only place that uses the access_token,
  # besides (view|edit)_profile_uri, this is why we handle token refresh here
  # even though it seems sort of arbitrary and would go somewhere more general 
  # in a real site, for instance, in a before_filter.
  def user_entity
    require_signin
    begin
      @user_entity ||= app.api.entity_with_access( access_token )["result"]
      return @user_entity
    rescue CaptureTools::Errors::AccessTokenExpiredError      
      # refresh the token
      refresh_token()
      # and try again
      return user_entity
    end
  end

  def signed_in?
    capture_sessions.key?(app.name)
  end

  private

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
    capture_sessions[app.name]
  end

  def refresh_token
    capture_sessions[app.name] = app.api.refresh_token({
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
