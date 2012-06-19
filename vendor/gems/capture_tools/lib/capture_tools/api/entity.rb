# Entity API Endpoints
module CaptureTools::Api::Entity
  # DA
  def entity_create(arguments={})
    required_json_arg(arguments, :attributes)
    api_call(arguments, 'entity.create')
  end

  # DA
  def entity_delete(arguments={})
    require_id(arguments)
    optional_arg(arguments, :attribute_name) #for deleting elements in a plural
    api_call(arguments, 'entity.delete')
  end

  # DA
  def entity_count(arguments={})
    optional_arg(arguments, :filter)
    api_call(arguments, 'entity.count')
  end

  # DA
  def entity(arguments={})
    require_id(arguments)
    api_call(arguments, 'entity')
  end

  def entity_with_access(token, arguments={})
    headers = { 'Authorization' => "OAuth #{token}" }
    api_call(arguments, 'entity', headers)
  end

  # DA
  def entity_find(arguments={})
    optional_arg(arguments, :filter)
    optional_arg(arguments, :first_result)
    optional_arg(arguments, :max_results)
    optional_arg(arguments, :sort_on)
    api_call(arguments, 'entity.find')
  end

  # DA
  def entity_update(arguments={})
    required_json_arg(arguments, :attributes)
    require_id(arguments)
    api_call(arguments, 'entity.update')
  end

  # DA
  def entity_replace(arguments={})
    api_call(arguments, 'entity.replace')
  end

  def entity_update_with_access(arguments={})
    required_json_arg(arguments, :attributes)
    token = required_arg(arguments, :token)
    headers = { 'Authorization' => "OAuth #{token}" }
    api_call(arguments, 'entity.update', headers)
  end

  def entity_history(arguments={})
    required_arg(arguments, :uuid)
    arguments[:max_results] = optional_arg(arguments, :max_results, 10)
    api_call(arguments, 'versions/entity.list')
  end

  def entity_past_value(arguments={})
    required_arg(arguments, :uuid)
    arguments[:include_schema] = optional_arg(arguments, :include_schema, true)
    arguments[:timestamp] = optional_arg(arguments, :timestamp, 'now')
    api_call(arguments, 'versions/entity')
  end

  def entity_attribute_values(arguments={})
    required_arg(arguments, :attribute_path)
    optional_arg(arguments, :max_results)
    optional_arg(arguments, :first_result)
    api_call(arguments, "entity.attributeValues")
  end
end

