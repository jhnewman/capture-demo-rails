module CaptureTools::Api::Client
    # Application Management

  def list_clients(arguments={})
      optional_arg(arguments, :application_id)
      optional_arg(arguments, :has_features)
      api_call(arguments, 'clients/list')
    end

  def set_client_features(arguments={})
      required_arg(arguments, :features)
      required_arg(arguments, :for_client_id)
      api_call(arguments, 'clients/set_features')
    end

  def set_client_description(arguments={})
      required_arg(arguments, :description)
      api_call(arguments, 'clients/set_description')
    end

    # DA
  def add_client(arguments={})
      optional_arg(arguments, :description)
      api_call(arguments, 'clients/add')
    end

  def delete_client(arguments={})
      required_arg(arguments, :client_id_for_deletion)
      api_call(arguments, 'clients/delete')
    end

end
