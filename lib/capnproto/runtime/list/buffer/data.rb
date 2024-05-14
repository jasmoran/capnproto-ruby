# typed: strict

require "sorbet-runtime"
require_relative "list"

class CapnProto::Data < CapnProto::BufferList
  Elem = type_member { {fixed: Integer} }

  sig { returns(String) }
  def value = @data.read_bytes(0, @length)

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_u8(ix)
  end

  sig { override.returns(Object) }
  def to_obj = value
end
