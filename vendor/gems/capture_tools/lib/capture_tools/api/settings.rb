# Key-Value settings store
# all are direct access only

module CaptureTools::Api::Settings
  def set(arguments={})
    required_arg(arguments, :for_client_id)
    required_arg(arguments, :key)
    required_arg(arguments, :value)
    api_call(arguments, 'settings/set')
  end

  def set_multi(arguments={})
    optional_arg(arguments, :for_client_id)
    required_json_arg(arguments, :items)
    api_call(arguments, 'settings/set_multi')
  end

  def set_default(arguments={})
    required_arg(arguments, :key)
    required_arg(arguments, :value)
    api_call(arguments, 'settings/set_default')
  end

  def settings_get_all(arguments={})
    optional_arg(arguments, :application_id)
    api_call(arguments, 'settings/get_all')
  end

  def get(arguments={})
    optional_arg(arguments, :for_client_id)
    required_arg(arguments, :key)
    api_call(arguments, 'settings/get')
  end

  def get_multi(arguments={})
    optional_arg(arguments, :for_client_id)
    required_json_arg(arguments, :keys) # should be an array
    api_call(arguments, 'settings/get_multi')
  end

  def get_default(arguments={})
    required_arg(arguments, :key)
    api_call(arguments, 'settings/get_default')
  end

  def delete(arguments={})
    required_arg(arguments, :key)
    optional_arg(arguments, :for_client_id)
    api_call(arguments, 'settings/delete')
  end

  def delete_default(arguments={})
    required_arg(arguments, :key)
    api_call(arguments, 'settings/delete_default')
  end

  def keys(arguments={})
    optional_arg(arguments, :for_client_id)
    api_call(arguments, 'settings/keys')
  end

  def default_keys(arguments={})
    api_call(arguments, 'settings/default_keys')
  end

  def client_keys(arguments={})
    api_call(arguments, 'settings/client_keys')
  end

  def items(arguments={})
    optional_arg(arguments, :for_client_id)
    api_call(arguments, 'settings/items')
  end

  def default_items(arguments={})
    api_call(arguments, 'settings/default_items')
  end

  def client_items(arguments={})
    optional_arg(arguments, :for_client_id)
    api_call(arguments, 'settings/client_items')
  end
end
