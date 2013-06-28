require 'spec_helper'

describe 'Curbala::Service' do
  describe 'invoke and no/nil logger input' do
    before(:each) { @mocked_config = { 'test' => {'simulate' => true, 'url' => 'service url segment'} } }
    
    it 'should use associated model logger to invoke new on proper Curbala::Action class with expected arguments, and return the action instance when no logger input and associated model has a logger' do
      @mocked_model = mock(:logger => 'model logger')
      verify_invoked_with 'model logger'
    end
    
    describe 'and associated model does not have a logger' do
      before(:each) { @mocked_model = mock(:logger => nil) }
    
      it 'should use Rails logger when in a Rails environment' do
        unless defined?(Rails) # is this beggin for trouble?
          class Rails; end
        end
        Rails.should_receive(:logger).and_return('rails logger')
        verify_invoked_with 'rails logger'
      end
      
      it 'should create a new Logger to STDOUT when not in a Rails environment' do
        verify_invoked_with_new_logger
      end
    end
    
    describe 'and config file has url specified at top-level' do
      before(:each) { @mocked_config = {'url' => 'top level config service url segment'} }
      
      it 'should use top-level url and not simulate when config file does not have a block for Rails.env (test)' do
        @expected_config = {'simulate' => false, 'url' => 'top level config service url segment'}
        verify_invoked_with_new_logger
      end
      
      it 'should use environment-specific url when specified in environment block of config file' do
        @mocked_config['test'] = {'simulate' => true, 'url' => 'service url segment'}
        verify_invoked_with_new_logger
      end
    end
    
    def verify_invoked_with_new_logger
      Logger.should_receive(:new).with(STDOUT).and_return('new logger')
      verify_invoked_with 'new logger'
    end
    
    def verify_invoked_with(logger)
      @expected_config ||= @mocked_config['test']
      File.should_receive(:open).with("./config/test curbala config file.yml").and_return('mocked open file') # TODO : Rails.root + 
      YAML.should_receive(:load).with('mocked open file').and_return(@mocked_config)
      TestCurbalaActionClass::SomeAction.should_receive(:new).with('test_curbala_service_url_segment', @expected_config, 'args_hash', logger, 200, nil, nil).and_return('test service response')
      TestCurbala::Service.invoke(:some_action, 'args_hash', @mocked_model).should == 'test service response'
    end
  end
end

module TestCurbalaActionClass
  class SomeAction < Curbala::Action
  end
end

module TestCurbala
  class Service < Curbala::Service
    def self.service_url_segment(business)
      "test_curbala_service_url_segment"
    end

    def self.service_qualifier
      'TestCurbalaActionClass'
    end
    
    def self.config_file
      'test curbala config file.yml'
    end
  end
end
