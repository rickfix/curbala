module Curbala
  class Service
    
    # enhancement : config specifies format of response, action base class supports xml and json config-based unpacking, keep unpack_response base class and extending class implementation
    # enhancement : config to specify unpack method.  altho at service-level, may want flexibility for each action to do its own thing.  there's a reasonable strategy somewhere...
    
    def self.invoke(action_name, args_hash={}, associated_model=nil, logger=nil, simulated_status=200, inject_response=nil, timeout=nil)
      logger ||= self.find_or_create_logger(associated_model)
      action = eval("#{service_qualifier}::#{action_name.to_s.camelize}.new(service_url_segment(associated_model), env_service_config, args_hash, logger, simulated_status, inject_response, timeout)")
    end

    private
    
    def self.env_service_config
      config_path     = "#{Rails.root rescue '.'}/config/#{config_file}"
      config_contents = File.open(config_path)
      config_yml      = YAML.load(config_contents)
      env             = (Rails.env rescue 'test')
      env_yml         = config_yml[env]
      env_yml       ||= {}
      env_yml['simulate'] ||= false
      env_yml['url']      ||= config_yml['url']
      env_yml
    end
    
    def self.find_or_create_logger(associated_model)
      logger   = (associated_model.logger rescue nil)
      logger ||= (Rails.logger rescue nil)
      logger ||= Logger.new(STDOUT)
    end
    
  end
end
