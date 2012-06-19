module CaptureTools::Api::EntityAuth
  # OAuth API Endpoints

  # For client_id and secrets (root) with grant priviledges
  # DA
  def get_access_token(arguments={})
    required_arg(arguments, :for_client_id)
    optional_json_arg(arguments, :transaction_state)
    api_call(arguments, 'access/getAccessToken')
  end

  # For client_id and secrets (root) with grant priviledges
  def get_authorization_code(arguments={})
    required_arg(arguments, :redirect_uri)
    required_arg(arguments, :for_client_id)
    optional_arg(arguments, :lifetime)
    optional_json_arg(arguments, :transaction_state)
    api_call(arguments, 'access/getAuthorizationCode')
  end

  # DA
  def get_verification_code(arguments={})
    require_id(arguments)
    required_arg(arguments, :attribute_name)
    optional_arg(arguments, :lifetime)
    optional_arg(arguments, :allow_plural)
    api_call(arguments, 'access/getVerificationCode')
  end

  # DA
  def get_creation_token(argument={})
    optional_arg(argument, :lifetime)
    api_call(argument, 'access/getCreationToken')
  end

  # DA
  def use_verification_code(arguments={})
    required_arg(arguments, :verification_code)
    api_call(arguments, 'access/useVerificationCode')
  end

  def refresh_token(arguments={})
    required_arg(arguments, :refresh_token)
    arguments[:grant_type] = 'refresh_token'
    api_call(arguments, 'oauth/token')
  end

  def code_for_token(arguments={})
    required_arg(arguments, :redirect_uri)
    required_arg(arguments, :code)
    arguments[:grant_type] = 'authorization_code'
    api_call(arguments, 'oauth/token')
  end
end
