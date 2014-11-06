require 'active_support/core_ext'
# require 'rexml/document' # TODO : needed?

module Curbala
  class Action
    attr_accessor :args_hash, :config, :curl, :exception, :http_status, :message, :payload, :raw_response_string, :response, :success, :url
  
    def initialize(service_url_segment, input_config, input_args_hash, logger, simulated_status=200, simulated_response="simulated response", timeout=nil)
      begin
        
        @payload, @args_hash, @config, @timeout = '', input_args_hash, input_config, (timeout || 10)
        @url = "#{@config['url']}#{service_url_segment}#{action_url_segment}"
        
        @config['simulate'] == true ?
          inject_status_and_response(simulated_status, simulated_response) :
          invoke_curl_action
        
      rescue Exception => @exception

        @success = false
        @message = "Service Not Available: #{@exception.message}" # : BACKTRACE: #{@exception.backtrace[0..500]}"
        logger.debug "Exception occurred: #{@exception.message}: BACKTRACE: #{@exception.backtrace}"
        @raw_response_string ||= 'exception occurred in action processing'
        @response ||= @raw_response_string
        @http_status ||= -1

      end
      
      self
      
    ensure
      
      logger.debug ''
      logger.debug("#{self.class.name}: #{url}")
      logger.debug("config:        #{config.inspect}")
      logger.debug("args_hash:     #{args_hash.inspect}")
      logger.debug("payload:       #{payload.inspect}") unless payload.nil? || payload.empty?
      logger.debug("http status:   #{http_status},   success: #{success},   message: #{message}")
      logger.debug("raw response string:")
      logger.debug(raw_response_string.strip)
      logger.debug("unpacked response:  #{response.class.name}")
      logger.debug(response.inspect)
      logger.debug ''
      
    end
    
    # any url utilities (for extending class implementations of action_url_segment()) ?
    
    # request utilities:
    def xml_request
      @curl.headers['Accept'] = 'application/xml'
      @curl.headers['Content-Type'] = 'application/xml'
    end

    def xml_payload(xml)
      xml_request
      @payload = xml
    end

    def xml_payload_from_args_hash(root) # APIs have different formatting/hygiene needs...
      xml_request
      @payload = @args_hash.to_xml(:root => root, :indent => 0) # .gsub(/(>[ \t\r\n]+<\/)/,"><\/").gsub(/[ \t\r\n]+^/,'')
    end
    
    # response utilities:
    def hash_from_xml_response
      @response = Hash.from_xml(@raw_response_string)
      @response ||= {}
    end

    def hash_from_json_response
      @response = (ActiveSupport::JSON.decode(@raw_response_string) rescue {})
    end
    
    protected

    def unpack_response
      # convention is a plain string response
      # usually it will be an XML or JSON response.
      # extending classes can/should implement their own unpack_response method to deal with
      # - unpacking response body xml/json usually to a hash or whatever is naturally consumable by invoker
      #   (see hash_from_xml_response)
      # - perform additional extraction/conversion,
      # - trigger response-specific work, ...
      @response = @raw_response_string
    end
  
    private
  
    def success_message
      "Successful (#{@http_status})"
    end
    
    def fail_message
      "Could not complete request : http response: #{@http_status}, response body : #{@raw_response_string[0..500]}"
    end

    def invoke_curl_action
      @curl = Curl::Easy.new(url) 
      curl.timeout = @timeout
      invoke_action
      @http_status = @curl.response_code
      @raw_response_string = @curl.body_str
      @raw_response_string ||= ''
      determine_status
      unpack_response
    end

    def inject_status_and_response(simulated_status, simulated_response)
      @http_status = simulated_status
      @raw_response_string = 'simulated'
      determine_status
      @response = simulated_response
      @response ||= @raw_response_string
    end
        
    def determine_status
      # enhancement : allow specification/injection of (list of) successful http responses
      @success = @http_status >= 200 && @http_status < 300
      @message = success ? success_message : fail_message
    end
  end
end
