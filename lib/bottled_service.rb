require "bottled_service/version"

class BottledService
  def self.attr(attr_key, type=nil)
    unless type.nil?
      define_method "#{attr_key}=" do |value|
        raise IllegalTypeError unless value.is_a?(type)
        instance_variable_set "@#{attr_key}", value
      end
    else
      define_method "#{attr_key}=" do |value|
        instance_variable_set "@#{attr_key}", value
      end
    end
    define_method attr_key do
      instance_variable_get "@#{attr_key}"
    end
  end

  def self.call(**attrs)
    if block_given?
      new(**attrs).(&Proc.new)
    else
      new(**attrs)
    end
  end

  def initialize(**attrs)
    attrs.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  class BottledServiceError < StandardError; end
  class IllegalTypeError < BottledServiceError; end
end
