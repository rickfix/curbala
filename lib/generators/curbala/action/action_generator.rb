module Curbala
  module Generators
    class ActionGenerator < Rails::Generators::Base
      source_root File.expand_path('../template', __FILE__)

      def generate_action
        
        puts ""
        install_directory = ask("Enter path to directory where service/action should be installed [app/models] : ")
        install_directory = 'app/models' if install_directory.blank?
        
        puts ""
        service_name = ask("What is the service name for the new action?").downcase
        generate_and_remember_file("config.yml", "config/#{service_name}.yml")
        generate_and_remember_file("service.rb", "#{install_directory}/#{service_name}/service.rb")

        puts ""
        new_action_name = ask("What is the new action name?").downcase
        generate_and_remember_file("action.rb", "#{install_directory}/#{service_name}/#{new_action_name}.rb")

        puts ""
        if ask("Generate spec/models/#{service_name}/#{new_action_name}_spec.rb? [Yn]") == "Y"
          generate_and_remember_file("action_spec.rb", "spec/models/#{service_name}/#{new_action_name}_spec.rb")
        end

        @generated_files.each do |file_name|
          gsub_file file_name, "SERVICE_NAME_DOWNCASE", service_name
          gsub_file file_name, "SERVICE_CLASS_NAME", service_name.classify
          gsub_file file_name, "ACTION_CLASS_NAME", new_action_name.classify
        end
        
        # TODO : chmod's?
        
        puts ""
        
      end
      
      private
      
      def generate_and_remember_file(source, destination)
        copy_file source, destination
        @generated_files ||= []
        @generated_files << destination
      end
    end
  end
end
