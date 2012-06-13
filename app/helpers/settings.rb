require 'yaml'

class Hash
  def require_keys(*keys)
    keys.each{|key| 
      if !self.key?(key)
        raise "field \'#{key}\' not found in configuration. Did you set in?"
      end
    }
    return self
  end
end

module Settings 

  public

  def scheme
    settings["use_ssl"] ? "https" : "http"
  end 

  def app_names
    app_config.keys 
  end

  def app_configs 
    @config ||= load_config("config.yml")
  end

  def settings
    app.settings
  end

  def app
    return @app unless @app.blank?
   
    name = params[:app_name]
    begin
      yaml_settings = app_configs.fetch(name)
    rescue KeyError
      raise "There is no configuration for and app named \'#{name}}\'."
    end 
 
    yaml_settings.require_keys("capture_addr", "captureui_addr", "app_id", "client_id", "client_secret")

    begin
      capture = CaptureTools::Api.new({
        :base_url => "https://" + yaml_settings.fetch("capture_addr"),
        :client_id => yaml_settings.fetch("client_id"),
        :client_secret => yaml_settings.fetch("client_secret"),
        :app_id => yaml_settings.fetch("app_id")
      })

      capture_settings = capture.items.fetch("result")    
    rescue KeyError, CaptureErrorRemote
      raise "failed getting application settings from capture api"
    end

    settings = capture_settings.merge(yaml_settings) 

    @app = OpenStruct.new(settings)
    @app.name = name
    @app.api = capture 
    @app.settings = settings

    return @app
  end

  private

  def load_config(filename)
    if !File.exists?(filename)
      raise "Capture Demo configuration file \'#{filename}\' does not exist. Example can be found in \'example_#{filename}'."
    end
    YAML.load_file(filename)
  end 

end
