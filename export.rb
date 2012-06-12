
require 'capture_app'
require 'capture_tools'
require 'yaml'

output_filename = ARGV.length == 1 ? ARGV[0] : "export_output.yml"

class String
  def normalize
    return self.downcase.gsub('[-_]', '')
  end
end

all_mods = ObjectSpace.each_object(Module).to_a.select {
  |m| !m.to_s.match(/:/)
}.to_set

name2mod = Hash[all_mods.map{ |mod| [mod.to_s.normalize, mod]}.to_a]

puts name2mod

goodie_bag = {}

CaptureApp.all_apps.map {|app|
  if name2mod.key? app.name.normalize
    capture_ui = "#{app.domain}:#{app.port}"
    capture = URI(app.server).domain == 'localhost' ? capture_ui : app.server

    goodie_bag[app.name.normalize] = {
      "client_id" => app.client_id,
      "client_secret" => app.client_secret,
      "app_id" => app.app_id,
      "captureui_addr" => capture_ui,
      "capture_addr" => capture,
      "screens" => name2mod[app.name.normalize].screens.keys.map{|x|x.to_s}
    }
  end
}

puts goodie_bag.to_yaml

File.open(output_filename, 'w') {|f| f.write(goodie_bag.to_yaml) }

