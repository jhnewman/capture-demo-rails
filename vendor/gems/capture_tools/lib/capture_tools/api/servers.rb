module CaptureTools::Api::Servers
  # requires creator key and secret
  def list_servers(arguments={})
    # This call returns some info that I don't feel safe passing to the consuming application.
    # Since APID doesn't support stripping it out, going to make this gem do it.
    data = api_call(arguments, "servers/list")
    data['results'] = data['results'].keys
  end
end