class BottledService
  def self.att(att_key, type=nil)
    unless type.nil?
      define_method "#{att_key}=" do |value|
        raise IllegalTypeError unless value.is_a?(type)
        instance_variable_set "@#{att_key}", value
      end
    else
      define_method "#{att_key}=" do |value|
        instance_variable_set "@#{att_key}", value
      end
    end
    define_method att_key do
      instance_variable_get "@#{att_key}"
    end
  end

  def self.call(**atts)
    if block_given?
      new(**atts).(&Proc.new)
    else
      new(**atts)
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
