require 'yaml'

module Settings 

  public

  def scheme
    settings["use_ssl"] ? "https" : "http"
  end 

  def apps
    @apps ||= config.keys 
  end

  def app_configs 
    @config ||= load_config("config.yml")
  end

  def settings
    return @settings unless @settings.blank?

    begin 
      @settings = verify(defaults.merge(app_configs.fetch( params[:name] )))
    rescue KeyError
      raise "There is no configuration for and app named \'#{params[:name]}\'."
    end
    @settings
  end

  private

  def load_config(filename)
    if !File.exists?(filename)
      raise "Capture Demo configuration file \'#{filename}\' does not exist. Example can be found in \'example_#{filename}'."
    end
    YAML.load_file(filename)
  end 

  def defaults 
    {
      "my_addr" => "http://catfacts.dnsdynamic.com:8001",
      "backplane_settings" => { },
      "use_ssl" => true
    }
  end
 
  def verify(x)
    required = ["my_addr", "capture_addr", "captureui_addr", "app_id", "client_id", "client_secret", "backplane_settings", "use_ssl"]
    required.each{|field| 
      if !x.key?(field)
        raise "field \'#{field}\' not found in configuration. Did you set in?"
      end
    }
    return x 
  end 
end
