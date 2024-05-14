# typed: strict

require "sorbet-runtime"
require_relative "list"
require_relative "../string"

class CapnProto::BufferString < CapnProto::BufferList
  include CapnProto::String

  Elem = type_member { {fixed: String} }

  sig { override.returns(String) }
  def to_s = @data.read_string(0, @length - 1)

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_string(ix, 1)
  end
end
