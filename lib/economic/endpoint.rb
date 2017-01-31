# Economic::Endpoint models the actual SOAP endpoint at E-conomic.
#
# This is where all knowledge of SOAP actions and requests exists.
class Economic::Endpoint
  extend Forwardable

  def_delegator "client.globals", :logger, :logger=
  def_delegator "client.globals", :log_level, :log_level=
  def_delegator "client.globals", :log, :log=

  # Invokes soap_action on the API endpoint with the given data.
  #
  # Returns a Hash with the resulting response from the endpoint as a Hash.
  #
  # If you need access to more details from the unparsed SOAP response, supply
  # a block to `call`. A Savon::Response will be yielded to the block.
  def call(soap_action, data = nil, cookies = nil)
    response = request(soap_action, data, cookies)

    if block_given?
      yield response
    else
      extract_result_from_response(response, soap_action)
    end
  end

  # Returns a Savon::Client to connect to the e-conomic endpoint
  #
  # Cached on class-level to avoid loading the big WSDL file more than once (can
  # take several hundred megabytes of RAM after a while...)
  #
  def client
    wsdl_file = File.expand_path(File.join(File.dirname(__FILE__), "economic.wsdl"))

    @@client ||= Savon.client(
      wsdl: wsdl_file,
      log: false,
      log_level: :debug,
      headers: { 'X-EconomicAppIdentifier' => app_identifier }
    )
  end

  # Returns the E-conomic API action name to call
  def soap_action_name(entity_class, action)
    [
      class_name_without_modules(entity_class),
      action.to_s
    ].collect(&:snakecase).join("_").intern
  end

  private

  def class_name_without_modules(entity_class)
    class_name = entity_class.to_s
    class_name.split('::').last
  end

  def extract_result_from_response(response, soap_action)
    response = response.to_hash

    response_key = "#{soap_action}_response".intern
    result_key = "#{soap_action}_result".intern

    if response[response_key] && response[response_key][result_key]
      response[response_key][result_key]
    else
      {}
    end
  end

  def request(soap_action, data, cookies)
    options = {}
    options[:message] = data if data && !data.empty?
    options[:cookies] = cookies if cookies && !cookies.empty?

    client.call(soap_action, options)
  end

  def app_identifier
    "Aging Rconomic Fork/#{::Rconomic::VERSION} (https://www.github.com/lokalebasen/rconomic) | udviklere@lokalebasen.dk"
  end
end
