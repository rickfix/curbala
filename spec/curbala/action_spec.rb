
require 'spec_helper'

describe 'Curbala::Action' do
  before(:each) do
    @args_hash = {:test_arg => 'test arg value'}
    @expected_url = 'test base service url/' + 'service url segment/action url segment'
    @expected_message = 'Successful (200)'
  end

	let(:mocked_response_xml) { "<?xml version='1.0' encoding='UTF-8'?><root>mocked response fields</root>" }

  describe 'initialize' do    
    describe 'and not simulated' do
      it 'should use base implementation of unpack_response when extending class does not implement unpack_response' do
        unsimulated_curbala_action(CurbalaActionTestClass, mocked_response_xml)
      end
    
      it 'should use implemented unpack_response method when extending class implements unpack_response' do
        @expected_message = 'success message (overriden)'
        unsimulated_curbala_action(CurbalaActionTestClassWithOverridenImplementations, {'root' => 'mocked response fields'})
      end
      
      it 'should indicate failure and include exception message in action message when exception occurs' do
        xmsg = 'message from exception'
        Curl::Easy.should_receive(:new).with(@expected_url).and_raise(RuntimeError.new(xmsg))
        @expected_message = "Service Not Available: #{xmsg}"
        it_should_do_expected_curbala_action_stuff(CurbalaActionTestClass, config(false), -1, 'exception occurred in action processing', be_false)
      end
    end

    [200, 299].each do |http_status|
      it "should indicate success when http response code is #{http_status}" do
        @expected_message = "Successful (#{http_status})"
        it_should_simulate_curbala_call(CurbalaActionTestClass, config, http_status, {'root' => 'simulated response fields'})
      end
    end

    [199, 300].each do |http_status|
      it "should indicate failure when http response code is #{http_status}" do
        @expected_message = "Could not complete request : http response: #{http_status}, response body : simulated"
        it_should_simulate_curbala_call(CurbalaActionTestClass, config, http_status, {'root' => 'simulated failure response fields'}, be_false)
      end
    end

    def it_should_simulate_curbala_call(class_under_test, config_hash, expected_response_code, expected_response_data, be_expected_condition = be_true)
      Curl::Easy.should_receive(:new).never
      Curl::PostField.should_receive(:content).never
      Hash.should_receive(:from_xml).never
      it_should_do_expected_curbala_action_stuff(class_under_test, config_hash, expected_response_code, expected_response_data, be_expected_condition)
    end    
  end

  # describe 'url construction utilities' do
  # end
  
  describe 'xml request utilities' do
    before(:each) { unsimulated_curbala_action(CurbalaActionTestClass, mocked_response_xml) }
    
    describe 'xml_request' do
      it 'should set curl header Accept and Content-Type values to application/xml' do
        @mocked_curl.headers['Accept'] = 'not application/xml'
        @mocked_curl.headers['Content-Type'] = 'not application/xml'
        @curbala_instance.xml_request
        @mocked_curl.headers['Accept'].should == 'application/xml'
        @mocked_curl.headers['Content-Type'].should == 'application/xml'
      end
    end

    describe 'xml_payload(xml)' do
      it 'should invoke xml_request and set payload from input payload' do
        @curbala_instance.should_receive(:xml_request)
        @curbala_instance.xml_payload('my xml payload')
        @curbala_instance.payload.should == 'my xml payload'
      end
    end

    describe 'xml_payload_from_args_hash(root)' do
      it 'should invoke xml_request and set payload from input payload' do
        @curbala_instance.should_receive(:xml_request)
        @curbala_instance.xml_payload_from_args_hash('my xml root')
        @curbala_instance.payload.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><my-xml-root><test-arg>test arg value</test-arg></my-xml-root>"
      end
    end
  end

	describe 'invoke_curl_action' do
		before do
			Curl::Easy.stub(:new).with(@expected_url).and_return(mocked_curl)
		end
		let(:mocked_curl) { double(:body_str => mocked_response_xml) }
		let(:timeout) { 2 }

		it "sets the timeout from initialization params" do
			mocked_curl.should_receive(:timeout=).with(timeout)
			curbala_action(CurbalaActionTestClass, config(false), 200, "", timeout)
		end
	end

  describe 'xml response utilities' do
    before(:each) { unsimulated_curbala_action(CurbalaActionTestClass, mocked_response_xml) }

    describe 'hash_from_xml_response' do
      it 'should set response to a hash representation of xml in raw_response_string' do
        @curbala_instance.raw_response_string = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response-root><response-object1><response-field1>test arg value</response-field1><response-field2>field2 value</response-field2></response-object1></response-root>"
        @curbala_instance.hash_from_xml_response
        @curbala_instance.response.should == { "response_root" => {"response_object1"=>{"response_field1"=>"test arg value", "response_field2"=>"field2 value"}} }
      end
    end

    describe 'hash_from_json_response' do
      it 'should set response to a hash representation of json in raw_response_string' do
        @curbala_instance.raw_response_string = '[{"sf": "HTTP", "lfs": [{"lf": "hypertext transfer protocol", "freq": 6, "since": 1995, "vars": [{"lf": "Hypertext Transfer Protocol", "freq": 3, "since": 1996}, {"lf": "hypertext transfer protocol", "freq": 3, "since": 1995}]}]}]'
        @curbala_instance.hash_from_json_response
        @curbala_instance.response.should == [{"sf"=>"HTTP", "lfs"=>[{"freq"=>6, "vars"=>[{"freq"=>3, "lf"=>"Hypertext Transfer Protocol", "since"=>1996}, {"freq"=>3, "lf"=>"hypertext transfer protocol", "since"=>1995}], "lf"=>"hypertext transfer protocol", "since"=>1995}]}]
      end
    end
  end
  
  def unsimulated_curbala_action(test_class, expected_response)
    @mocked_curl = mock(:body_str => mocked_response_xml)
    Curl::Easy.should_receive(:new).with(@expected_url).and_return(@mocked_curl)
    @mocked_curl.should_receive(:timeout=).with(10)
    Curl::PostField.should_receive(:content).with(:test_arg, 'test arg value').and_return('whatever post field content returns')
    @mocked_curl.should_receive(:http_put).with('whatever post field content returns')
    @mocked_curl.should_receive(:response_code).any_number_of_times.and_return(200)

    it_should_do_expected_curbala_action_stuff test_class, config(false), 200, expected_response

    headers = {}
    @mocked_curl.should_receive(:headers).any_number_of_times.and_return(headers)
    @curbala_instance.xml_payload_from_args_hash 'a root node'
    @curbala_instance.payload.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><a-root-node><test-arg>test arg value</test-arg></a-root-node>"
    headers.should == {"Content-Type"=>"application/xml", "Accept"=>"application/xml"}
  end

  def it_should_do_expected_curbala_action_stuff(class_under_test, config_hash, expected_response_code, expected_response_data, be_expected_condition = be_true)
    curbala_action(class_under_test, config_hash, expected_response_code, expected_response_data)
    @curbala_instance.url.should == @expected_url
    @curbala_instance.message.should == @expected_message
    @curbala_instance.success.should be_expected_condition
    @curbala_instance.response.should == expected_response_data
    @curbala_instance.http_status.should == expected_response_code
  end

  def curbala_action(class_under_test, config_hash, expected_response_code, expected_response_data, timeout=10)
    (logger = mock).should_receive(:debug).any_number_of_times # TODO : tighten this up?
    @curbala_instance = class_under_test.new('service url segment/', config_hash, @args_hash, logger, expected_response_code, expected_response_data, timeout)
  end
    
  def config(simulate = true)
    {'simulate' => simulate, 'url' => 'test base service url/'}
  end
  
end

class CurbalaActionTestClass < Curbala::Action
  def action_url_segment;     "action url segment";                                                     end
  def invoke_action;    curl.http_put(Curl::PostField.content(:test_arg, args_hash[:test_arg]));  end
end

class CurbalaActionTestClassWithOverridenImplementations < CurbalaActionTestClass
  def unpack_response
    hash_from_xml_response
  end

  def success_message
    "success message (overriden)"
  end

  def fail_message
    "fail message (overriden)"
  end
end
