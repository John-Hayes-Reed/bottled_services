# A class that represents the outcome response of a BottledService service
#   object.
class BottledServiceResponse
  attr_reader :response_success

  # Instantiates a new response object.
  #
  # @param success [true, false] true if the response represents a successful
  #   execution, false if a failed execution.
  # @param options [Hash] All attributes of the response object.
  #
  # @return [void]
  def initialize(success, **options)
    @response_success = success
    @attribute_keys = options.keys
    options.each do |option_key, option_val|
      singleton_class.send :attr_reader, option_key
      instance_variable_set :"@#{option_key}", option_val
    end
  end

  # Shows if the response represents a successful execution.
  #
  # @return [true, false]
  def success?
    @response_success
  end

  # Shows if the response represents a failed execution.
  #
  # @return [true, false]
  def fail?
    !success?
  end

  # Outputs all attributes that the Response object holds.
  #
  # @return [Hash]
  def attributes
    {}.tap do |attributes_hash|
      @attribute_keys.each do |key|
        attributes_hash[key] = send(key)
      end
    end
  end

  # Outputs the keys for all available attributes.
  #
  # @return [Array]
  def keys
    @attribute_keys
  end

  # Outputs all available attribute values.
  #
  # @return [Array]
  def values
    attributes.values
  end
end