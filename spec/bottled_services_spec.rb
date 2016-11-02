require "spec_helper"

describe BottledService do
  subject(:service) { BottledService.new }
  describe "::att" do
    before { service.singleton_class.att :test_string, String }
    before { service.singleton_class.att :test_array, Array }
    it "responds to att set methods" do
      expect(service).to respond_to(:test_string, :test_array, :test_string=, :test_array=)
      expect(service).not_to respond_to(:a_non_set_method)
    end
  end
  subject(:service_class){ BottledService }
  describe("#initialize") do
    before { service_class.att :test_string, String }
    before { service_class.att :test_array, Array }
    before { service_class.att :test_type_agnostic }
    before { service_class.att :test_type_agnostic_two }
    it "sets attributes with variables of the correct type" do
      expect(service_class.new({test_string: "Test String", test_array: [1,2,3]})).to be_a(BottledService)
    end

    it "sets type agnostic attributes with any type variabe" do
      expect(service_class.new({test_type_agnostic: "Test String", test_type_agnostic_two: [1,2,3]})).to be_a(BottledService)
    end

    it "throws an IllegalTypeError when setting an attibutes with a variable of an incorrect type" do
      expect{service_class.new({test_string: [1,2,3], test_array: "Test String"})}.to raise_error(BottledService::IllegalTypeError)
    end
  end

end

describe BottledServices do
  it "has a version number" do
    expect(BottledServices::VERSION).not_to be nil
  end
end
