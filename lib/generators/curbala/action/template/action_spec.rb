require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'SERVICE_CLASS_NAME::ACTION_CLASS_NAME' do
  before(:each) do
    @config = {'simulate' => true, 'url' => 'http://base service url/'}
    (@logger = mock).should_receive(:debug).any_number_of_times
  end
  
  it "should source action_url_segment, success_message and simulated response from SERVICE_CLASS_NAME::ACTION_CLASS_NAME implementation when simulated" do
    Curl::Easy.should_receive(:new).never # simulated : invoke_action() is not invoked.
    @curbala_action_instance = SERVICE_CLASS_NAME::ACTION_CLASS_NAME.new('service url segment/', @config, {}, @logger)
    @curbala_action_instance.url.should == "http://base service url/service url segment/#{@curbala_action_instance.action_url_segment}"
    @curbala_action_instance.success.should be_true
    @curbala_action_instance.http_status.should == 200
    @curbala_action_instance.message.should == "Successful (200)"
    @curbala_action_instance.response.should == "simulated response"
  end
  
  describe 'invoke_action' do
    before(:each) do
      @args_hash = {}
      @config['simulate'] = false
      @expected_url = "http://base service url/service url segment/action url segment"
      @mocked_curl = mock # (:body_str => @mocked_response)
    end
    
    describe "and http response code is 200" do
      
      it "should indicate success" do
        # TODO1 : specify @args_hash data for test case
        
        # TODO2 : construct @mocked_response for test case
        @mocked_response = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><your-response-root-node>mocked test case response</your-response-root-node>"
        
        # TODO3 : expectations for work performed in invoke_action()
        
        # TODO4 : expectations for work done in unpack_response
        @expected_response_data = @mocked_response
        
        # Example:
        # when invoke_action() is implemented as:
        #   curl.http_put(Curl::PostField.content(:test_arg, args_hash['test_arg']).to_s)
        # then do something like:
        #   @args_hash['test_arg'] = 'test arg value'
        #   Curl::PostField.should_receive(:content).with(:test_arg, 'test arg value').and_return("whatever post field content returns")
        #   @mocked_curl.should_receive(:http_put).with("whatever post field content returns")
        
        @expected_message = 'Successful (200)'
        verify_curbala_action(SERVICE_CLASS_NAME::ACTION_CLASS_NAME, 200, be_true)
      end
    end
    
    # TODO : specs for different HTTP stati
    
    # describe "when http response code is 501" do
    # end
    
    def verify_curbala_action(class_under_test, forced_http_status, be_expected_condition)
      @mocked_curl.should_receive(:body_str).any_number_of_times.and_return(@mocked_response)
      Curl::Easy.should_receive(:new).with(@expected_url).and_return(@mocked_curl)
      @mocked_curl.should_receive(:timeout=).with(10)
      @mocked_curl.should_receive(:response_code).any_number_of_times.and_return(forced_http_status)
  
      @curbala_instance = class_under_test.new('service url segment/', @config, @args_hash, @logger)
      
      @curbala_instance.url.should == @expected_url
      @curbala_instance.message.should == @expected_message
      @curbala_instance.success.should be_expected_condition
      @curbala_instance.response.should == @expected_response_data
      @curbala_instance.http_status.should == forced_http_status
    end
    
  end
  
end
