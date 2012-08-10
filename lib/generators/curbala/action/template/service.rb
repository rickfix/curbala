class SERVICE_CLASS_NAME::Service < Curbala::Service
  
  def self.service_url_segment(associated_model)
    "/TODO__SPECIFY_ENVIRONMENT_INDEPENDENT_PORTION_OF_SERVICE_URL_IN___SERVICE_CLASS_NAME_Service__service_url_segment__method/"
  end

  def self.service_qualifier
    'SERVICE_CLASS_NAME'
  end
  
  def self.config_file # see self.env_service_config()
    'SERVICE_NAME_DOWNCASE.yml'
  end
  
  # def self.env_service_config
  #   # a default YAML-based implementation is provided :
  #   # YAML.load(File.open("#{Rails.root rescue '.'}/config/#{config_file}.yml"))
  #
  #   # if you prefer HAML/XML/... or don't need a config file,
  #   # override implementation with logic that meets your needs
  #   # and remove generated config/SERVICE_NAME_DOWNCASE.yml file.
  # end
  
end
