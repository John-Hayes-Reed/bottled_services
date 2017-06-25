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

describe BottledServiceResponse do
  let(:atts) { { att1: :val1, att2: :val2 } }

  describe '#initialize' do
    subject { BottledServiceResponse.new success, atts }
    context 'for success' do
      let(:success) { true }
      let(:atts) { { att1: :val1, att2: :val2 } }
      it { is_expected.to be_a BottledServiceResponse }
      it { expect(subject.response_success).to be_truthy }
      it { is_expected.to respond_to :att1, :att2 }
    end

    context 'for fail' do
      let(:success) { false }
      it { is_expected.to be_a BottledServiceResponse }
      it { expect(subject.response_success).to be_falsey }
      it { is_expected.to respond_to :att1, :att2 }
    end
  end

  describe '#success?' do
    subject { BottledServiceResponse.new(success, atts).success? }
    context 'for success' do
      let(:success) { true }
      it { is_expected.to be_truthy }
    end

    context 'for fail' do
      let(:success) { false }
      it { is_expected.to be_falsey }
    end
  end

  describe '#fail?' do
    subject { BottledServiceResponse.new(success, atts).fail? }
    context 'for success' do
      let(:success) { true }
      it { is_expected.to be_falsey }
    end

    context 'for fail' do
      let(:success) { false }
      it { is_expected.to be_truthy }
    end
  end

  describe '#attributes' do
    subject { BottledServiceResponse.new(success, atts).attributes }
    context 'for success with normal attributes' do
      let(:success) { true }
      it { is_expected.to be_a Hash }
      it { expect(subject.keys).to include :att1 }
      it { expect(subject.keys).to include :att2 }
      it { expect(subject.values).to include :val1 }
      it { expect(subject.values).to include :val2 }
    end

    context 'for fail with normal attributes' do
      let(:success) { false }
      it { is_expected.to be_a Hash }
      it { expect(subject.keys).to include :att1 }
      it { expect(subject.keys).to include :att2 }
      it { expect(subject.values).to include :val1 }
      it { expect(subject.values).to include :val2 }
    end

    context 'with no attributes' do
      let(:atts) { {} }
      let(:success) { true }
      it { is_expected.to be_a Hash }
      it { expect(subject.keys).to be_empty }
      it { expect(subject.values).to be_empty }
    end
  end

  describe '#keys' do
    subject { BottledServiceResponse.new(success, atts).keys }
    context 'for success with normal attributes' do
      let(:success) { true }
      it { is_expected.to be_a Array }
      it { is_expected.to include :att1 }
      it { is_expected.to include :att2 }
    end

    context 'for fail with normal attributes' do
      let(:success) { false }
      it { is_expected.to be_a Array }
      it { is_expected.to include :att1 }
      it { is_expected.to include :att2 }
    end

    context 'with no attributes' do
      let(:atts) { {} }
      let(:success) { true }
      it { is_expected.to be_a Array }
      it { is_expected.to be_empty }
    end
  end

  describe '#values' do
    subject { BottledServiceResponse.new(success, atts).values }
    context 'for success with normal attributes' do
      let(:success) { true }
      it { is_expected.to be_a Array }
      it { is_expected.to include :val1 }
      it { is_expected.to include :val2 }
    end

    context 'for fail with normal attributes' do
      let(:success) { false }
      it { is_expected.to be_a Array }
      it { is_expected.to include :val1 }
      it { is_expected.to include :val2 }
    end

    context 'with no attributes' do
      let(:atts) { {} }
      let(:success) { true }
      it { is_expected.to be_a Array }
      it { is_expected.to be_empty }
    end
  end
end

describe BottledServices do
  it "has a version number" do
    expect(BottledServices::VERSION).not_to be nil
  end
end
