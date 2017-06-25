require 'spec_helper'

describe BottledService do
  describe '::att' do
    subject do
      class FirstServiceObject
        include BottledService

        att :test_string, type: String, required: true
        att :test_array, type: Array

        def call
          success
        end
      end
      FirstServiceObject.new test_string: 'String', test_array: %i[foo bar]
    end
    it 'responds to att set methods' do
      expect(subject.instance_eval { test_string }).to eq 'String'
      expect(subject.instance_eval { test_array }).to eq %i[foo bar]
      expect(subject.required_arguments).to include :test_string
      expect(subject).not_to respond_to(:a_non_set_method)
    end
  end

  describe('#initialize') do
    subject do
      class SecondServiceObject
        include BottledService

        att :test_string, type: String
        att :test_array, type: Array
        att :test_type_agnostic
        att :test_type_agnostic_two

        def call
          success
        end
      end
      SecondServiceObject
    end
    it 'sets attributes with variables of the correct type' do
      expect(subject.new(test_string: 'Test String', test_array: [1, 2, 3])
                    .class
                    .ancestors)
        .to include BottledService
    end

    it 'sets type agnostic attributes with any type variabe' do
      expect(subject.new(test_type_agnostic: 'Test String',
                         test_type_agnostic_two: [1, 2, 3]))
        .to be_a BottledService
    end

    it 'throws an IllegalTypeError when setting an attibutes with a variable of an incorrect type' do
      expect do
        subject.new(test_string: [1, 2, 3], test_array: 'Test String')
      end
        .to raise_error BottledServiceError::IllegalTypeError
    end
  end

  describe('#call') do
    subject do
      class ThirdServiceObject
        include BottledService

        att :test_string, type: String
        att :test_array, type: Array
        att :test_type_agnostic
        att :test_type_agnostic_two

        def call
          response = yield if block_given?

          response ||= @test_string if @test_string
          response ||= @test_type_agnostic if @test_type_agnostic

          response
        end
      end
      ThirdServiceObject
    end
    it 'sets attributes with variables of the correct type' do
      expect(subject.call(test_string: 'Test String', test_array: [1, 2, 3]))
        .to eq 'Test String'
    end

    it 'sets type agnostic attributes with any type variabe' do
      expect(subject.call(test_type_agnostic: 'Test String',
                          test_type_agnostic_two: [1, 2, 3]))
        .to eq 'Test String'
    end

    it 'throws an IllegalTypeError when setting an attibutes with a variable of an incorrect type' do
      expect do
        subject.call(test_string: [1, 2, 3], test_array: 'Test String')
      end
        .to raise_error BottledServiceError::IllegalTypeError
    end

    it 'correctly yields a passed block' do
      expect(subject.call(test_string: 'Test String') { @test_string = 'new' })
        .to eq 'new'
    end
  end

  describe '#verify_required_arguments' do
    subject do
      class FourthServiceObject
        include BottledService

        att :test_symbol, type: Symbol, required: true

        def call
          @test_symbol
        end
      end
      FourthServiceObject
    end

    it do
      expect(subject.call(test_symbol: :symbol))
        .to eq :symbol
    end

    it do
      expect { subject.call }
        .to raise_error BottledServiceError::RequiredArgumentNotFound
    end
  end

  describe '#success' do
    subject do
      class FifthServiceObject
        include BottledService

        att :test_symbol, type: Symbol, required: true

        def call
          success test_symbol: @test_symbol
        end
      end
      FifthServiceObject
    end
    it do
      expect(subject.call(test_symbol: :symbol)).to be_a BottledServiceResponse
    end
    it do
      expect(subject.call(test_symbol: :symbol).succeeded?).to be_truthy
    end
    it do
      expect(subject.call(test_symbol: :symbol).failed?).to be_falsey
    end
    it do
      expect(subject.call(test_symbol: :symbol).keys).to include(:test_symbol)
    end
    it do
      expect(subject.call(test_symbol: :symbol).values).to include(:symbol)
    end
    it do
      expect(subject.call(test_symbol: :symbol).test_symbol).to eq :symbol
    end
  end

  describe '#failure' do
    subject do
      class SixthServiceObject
        include BottledService

        att :test_symbol, type: Symbol, required: true

        def call
          failure test_symbol: @test_symbol
        end
      end
      SixthServiceObject
    end
    it do
      expect(subject.call(test_symbol: :symbol)).to be_a BottledServiceResponse
    end
    it do
      expect(subject.call(test_symbol: :symbol).succeeded?).to be_falsey
    end
    it do
      expect(subject.call(test_symbol: :symbol).failed?).to be_truthy
    end
    it do
      expect(subject.call(test_symbol: :symbol).keys).to include(:test_symbol)
    end
    it do
      expect(subject.call(test_symbol: :symbol).values).to include(:symbol)
    end
    it do
      expect(subject.call(test_symbol: :symbol).test_symbol).to eq :symbol
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

  describe '#succeeded?' do
    subject { BottledServiceResponse.new(success, atts).succeeded? }
    context 'for success' do
      let(:success) { true }
      it { is_expected.to be_truthy }
    end

    context 'for fail' do
      let(:success) { false }
      it { is_expected.to be_falsey }
    end
  end

  describe '#failed?' do
    subject { BottledServiceResponse.new(success, atts).failed? }
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
  it 'has a version number' do
    expect(BottledServices::VERSION).not_to be nil
  end
end
