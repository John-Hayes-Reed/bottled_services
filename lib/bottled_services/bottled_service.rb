# A module that when included will provide features to create Service Objects.
#
# @note Bottled Services follow the single responsibility pattern and allow for
#   only a single public instance method: #call. This is where all business
#   logic should be handled. The definition of any other public instance methods
#   will result in an error raise.
#
# @note Bottled Services provide a class ::att method to be used in the Service
#   Object, this method should be used to define what attributes a Service
#   Object may receive.
#   @see ::att for more information.
#
# @note As of version 1.0.0 all Bottled Services will return a ServiceResponse
#   object. This is to create a consistency in what is expected from service
#   objects and create a convention for all Service Objects to abide why. Before
#   1.0.0 the returned response could be anything from an object to a boolean,
#   but this inconsistency lead to purposefully having to look inside the class
#   to know what would come back, using a ServiceResponse removes this ambiguity
#   and makes the Service Objects easier to use through predictable behaviour.
#
# @note A Bottled Service should always return using either the #success or
#   #failure methods, which will build an appropriate BottledServiceResponse
#   object.
#
# @example A Basic Service Object.
#   class PersistUser
#     include BottledService
#
#     att :user, type: :user, required: true
#     att :params
#
#     def call
#       user.attributes = params if params.present?
#       fail user: user unless user.save

#       # notify BottledObservers of successful save.
#       user.modified
#       user.publish
#
#       success user: user
#     end
#   end
module BottledService
  # Sets up a Bottled Service class on inclusion.
  #
  # @param base [*]
  #
  # @raise [BottledServiceError::IllegalMethodDefined] if any public
  #   instance method other than #call is defined.
  # @return [void]
  def self.included(base)
    base.extend(ClassMethods)

    class << base
      attr_accessor :required_arguments
      # @!method required_arguments
      #   Gets a list of required arguments for a given Service Object.
      define_method :required_arguments do
        @required_arguments ||= []
      end
    end
    attr_accessor :required_arguments

    raise BottledServiceError::IllegalMethodDefined if
      base.instance_methods(false).any? { |method| method != :call }
  end

  # The class methods made available to all Bottled Services.
  module ClassMethods
    # Defines an attributes that is added to the Bottled Service attributes
    #   white list, allowing it to be passed when a Bottled Service is called.
    #
    # @note passing parameters to a Bottled Service that have not been defined
    #   using this method will result in an error being raised.
    #
    # @param attribute_key [Symbol] Key for a given attribute.
    # @param options [Hash] Optional requirements for a given attribute.
    # @option options [*] :type Strict type for the attribute.
    # @option options [True, False] :required Boolean flag representing
    #   requirement.
    #
    # @return [void]
    def att(attribute_key, **options)
      send :attr_accessor, attribute_key
      send :private, attribute_key
      send :private, :"#{attribute_key}="

      required_arguments if @required_arguments.nil?
      @required_arguments << attribute_key if options[:required]

      return if options[:type].nil?
      define_method "#{attribute_key}=" do |value|
        if value.is_a?(options[:type])
          instance_variable_set "@#{attribute_key}", value
        else
          raise BottledServiceError::IllegalTypeError,
                "#{attribute_key} should be a #{options[:type]}"
        end
      end
      send :private, :"#{attribute_key}="
    end

    # Initializes a new Service Object and executes its business logic.
    #
    # @param attribute_list [Hash] Attributes to pass to the Service Object.
    #
    # @return [ServiceResponse] @see #sucess, #fail
    def call(**attribute_list)
      if block_given?
        new(**attribute_list).call(&Proc.new)
      else
        new(**attribute_list).call
      end
    end
  end

  private

  # Instantiates a new Service Object
  #
  # @param attribute_list [Hash]
  #
  # @raise [BottledServiceError::RequiredArgumentNotFound]
  #   @see #verify_required_arguments
  # @return [*] A new Service Object instance.
  def initialize(**attribute_list)
    @required_arguments = self.class.required_arguments
    verify_required_arguments(*attribute_list.keys)

    attribute_list.each do |key, value|
      send(:"#{key}=", value)
    end
  end

  # Verifies that all required arguments have been passed to the Service Object.
  #
  # @example With missing arguments.
  #   @required_arguments #=> [:user, :params]
  #   verify_required_arguments :user
  #   #=> BottledServiceError::RequiredArgumentNotFound
  #
  # @example With all required keys.
  #   @required_arguments #=> [:user, :params]
  #   verify_required_arguments :user, :params
  #   #=> nil
  #
  # @example With no required arguments defined.
  #   @required_arguments #=> []
  #   verify_required_arguments :user, :params
  #   #=> nil
  #
  # @param keys [Array<Symbol>] The keys of arguments passed to Service Object.
  #
  # @raise [BottledServiceError::RequiredArgumentNotFound]
  # @return [void]
  def verify_required_arguments(*keys)
    return if @required_arguments.empty?

    required_missing = false
    required_missing = true if keys.empty? && !@required_arguments.empty?

    @required_arguments.each do |arg|
      required_missing = true unless keys.include? arg
    end

    return unless required_missing
    raise BottledServiceError::RequiredArgumentNotFound
  end

  # Creates a response that represents a successful execution of the Service
  #   Object.
  #
  # @param args [Hash]
  #
  # @return [BottledServiceResponse]
  def success(**args)
    BottledServiceResponse.new true, args
  end

  # Creates a response that represents a failed execution of the Service Object.
  #
  # @param args [Hash]
  #
  # @return [BottledServiceResponse]
  def failure(**args)
    BottledServiceResponse.new false, args
  end
end
