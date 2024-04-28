# typed: false
# frozen_string_literal: true

RSpec.describe CapnProto do
  it "has a version number" do
    expect(CapnProto::VERSION).not_to be nil
  end

  it "specifies a word size in bytes" do
    expect(CapnProto::WORD_SIZE).to eq(8)
  end

  describe ".assert" do
    it "raises an error if the block returns false" do
      expect { CapnProto.assert { false } }.to raise_error(StandardError)
    end

    it "raises an error with the given message if the block returns false" do
      expect { CapnProto.assert("message") { false } }.to raise_error("Assertion failed: message")
    end

    it "raises a CapnProto::Error if the block returns false" do
      expect { CapnProto.assert { false } }.to raise_error(CapnProto::Error)
    end

    it "does not raise an error if the block returns true" do
      expect { CapnProto.assert { true } }.not_to raise_error
    end
  end
end
