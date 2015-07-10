raw_config = File.read("#{Rails.root}/config/vision_config.yml")
CONFIG = YAML.load(raw_config)[Rails.env].deep_symbolize_keys