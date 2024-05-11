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
end
