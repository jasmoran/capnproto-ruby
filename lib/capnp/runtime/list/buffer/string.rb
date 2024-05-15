# typed: strict

require "sorbet-runtime"
require_relative "list"
require_relative "../string"

class Capnp::BufferString < Capnp::BufferList
  include Capnp::String

  Elem = type_member { {fixed: String} }

  sig { override.returns(String) }
  def to_s
    @data.read_string(0, @length - 1)
  end

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_string(ix, 1)
  end
end
