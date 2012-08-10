class SERVICE_CLASS_NAME::ACTION_CLASS_NAME < Curbala::Action
  
  def action_url_segment
    # if this is a GET index, GET new or POST create action, probably blank.
    # for update, show, edit, delete, express id however service expects it (in URL or possibly in payload)
    
    # * data written/specified in this string must be appropriately url-encoded
    
    "construct action segment of SERVICE_CLASS_NAME ACTION_CLASS_NAME url in action_url_segment() method at #{__FILE__}:#{__LINE__}"
  end
  
  def invoke_action
    
    # this is where arguments from @args_hash are transformed into url parameters or request payload.
    # - see Curbala::Action.xml_payload_from_args_hash()
    # the proper http method is invoked
    
    # can set action-specific curl options:
    #   curl.timeout = 300
    #   set_payload # see Curbala::Action.set_payload()
    #   xml_request # see Curbala::Action.xml_request()
    
    # some examples:
    #   curl.http_get
    #   curl.http_post(Curl::PostField.content(:name, args_hash[:name]))
    #   curl.http_put(Curl::PostField.content(:_arg, args_hash[:_arg]))
    #   curl.http_delete

    # APIs have different formatting/hygiene/unpacking needs...
    # curbala is xml/json agnostic and does not induce any xml/json library bloat
    # pull in whatever you need to correctly format your request data (REXML, Nokogiri, JSON) from args_hash data
    # recommend an intermediate class for actions that are constructed and/or unpacked in a similar way

    # some half-hearted support is provided.
    # see xml_request(), xml_payload(xml) and xml_payload_from_args_hash(root) methods.
    
    send("implement invoke_action() method in #{__FILE__}:12")
  end
  
  # methods you may choose to implement and override default/base-class implementations:
  
  # def unpack_response
  #   # has a default implementation that just sets @response from @raw_response_string (no xml or json conversion)
  #
  #   # implementations of this method must transform @raw_response_string into @response
  #   # your service responses will most likely be xml or json
  #   # and need some unpacking into a hash for consumption by controllers, views and other models.
  #
  #   # @raw_response_string contains curl.body_str
  #
  #   # see hash_from_xml_response(),  hash_from_json_response() methods.
  # end
  
  # def success_message
  #   # has a default implementation : extending classes can override to suit app's needs
  # end
  
  # def fail_message
  #   # has a default implementation : extending classes can override to suit app's needs
  # end
  
end
