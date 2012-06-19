module CaptureTools::Api::Application
  # requires creator key and secret
  def create_app(arguments={})
      required_arg(arguments, :domain)
      optional_arg(arguments, :description)
      api_call(arguments, 'applications/create')
  end

  def delete_app(arguments={})
    required_arg(arguments, :client_id)
    api_call(arguments, 'applications/delete')
  end

  def list_apps(arguments={})
      api_call(arguments, 'applications/list')
    end

  # captureui apps in apid
  def find_ui_app(arguments={})
    api_call(arguments, 'applications/ui/find')
  end

  def list_ui_apps(arguments={})
    api_call(arguments, 'applications/ui/list')
  end

  def add_ui_app(arguments={})
    required_arg(arguments, :json)
    api_call(arguments, 'applications/ui/add')
  end

  def delete_ui_app(arguments={})
    required_arg(arguments, :domain)
    api_call(arguments, 'applications/ui/delete')
  end

  def update_ui_app(arguments={})
    required_arg(arguments, :domain)
    required_arg(arguments, :json)
    api_call(arguments, 'applications/ui/update')
  end

end
