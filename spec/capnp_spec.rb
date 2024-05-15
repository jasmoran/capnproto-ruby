# typed: strong
# frozen_string_literal: true

require_relative "spec_helper"

describe Capnp, nil do
  it "has a version number" do
    expect(Capnp::VERSION).wont_be_nil
  end

  it "specifies a word size in bytes" do
    expect(Capnp::WORD_SIZE).must_equal(8)
  end
end
