SETTINGS = YAML.load(ERB.new(File.read("#{Rails.root}/config/settings.yml.erb")).result)[Rails.env]