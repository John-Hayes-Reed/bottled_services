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
#   #fail methods, which will build an appropriate ServiceResponse object.
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

#       # notify BottledObservers of successful save
#       user.modified
#       user.publish
#       success user: user
#     end
#   end
module BottledService

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def att(att_key, **options)
      if options[:type].nil?
        define_method "#{att_key}=" do |value|
          instance_variable_set "@#{att_key}", value
        end
      else
        define_method "#{att_key}=" do |value|
          raise IllegalTypeError, "#{att_key} should be #{type} but is #{value.class}" unless value.is_a?(type)
          instance_variable_set "@#{att_key}", value
        end
      end
      define_method att_key do
        instance_variable_get "@#{att_key}"
      end
    end

    def call(**atts)
      if block_given?
        new(**atts).(&Proc.new)
      else
        new(**atts).()
      end
    end
  end

  def initialize(**atts)
    atts.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  class BottledServiceError < StandardError; end
  class IllegalTypeError < BottledServiceError; end
end
