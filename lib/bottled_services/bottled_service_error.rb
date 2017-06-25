module BottledServiceError
  class IllegalMethodDefined < StandardError; end
  class RequiredArgumentNotFound < StandardError; end
  class IllegalTypeError < StandardError; end
end