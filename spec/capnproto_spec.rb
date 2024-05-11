# typed: strong
# frozen_string_literal: true

require_relative "spec_helper"

describe CapnProto, nil do
  it "has a version number" do
    expect(CapnProto::VERSION).wont_be_nil
  end

  it "specifies a word size in bytes" do
    expect(CapnProto::WORD_SIZE).must_equal(8)
  end

  describe ".assert" do
    it "raises an error if the block returns false" do
      expect { CapnProto.assert { false } }.must_raise(CapnProto::Error)
    end

    it "raises an error with the given message if the block returns false" do
      expect { CapnProto.assert("message") { false } }.must_raise(CapnProto::Error, "Assertion failed: message")
    end
  end
end
