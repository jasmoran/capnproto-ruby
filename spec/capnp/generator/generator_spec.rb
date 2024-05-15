# typed: strong
# frozen_string_literal: true

require_relative "../../spec_helper"

describe Capnp::Generator, nil do
  it "generates expected schema.capnp.rb" do
    expected = File.read(File.join(Kernel.__dir__, "..", "..", "..", "lib", "capnp", "generator", "schema.capnp.rb"))
    generated = Capnp::Generator.new(
      Capnp::StreamMessage.new(
        Capnp::StringBuffer.new(
          File.read(
            File.join(Kernel.__dir__, "..", "..", "messages", "schema.capnp.bin"),
            mode: "rb"
          )
        )
      ).root
    ).generate_code

    expect(expected).must_equal(generated["lib/capnproto/generator/schema.capnp.rb"])
  end
end
