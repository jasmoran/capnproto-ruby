# typed: strict

require 'sorbet-runtime'
require_relative 'list'

class CapnProto::Data < CapnProto::BufferList
  Elem = type_member {{fixed: Integer}}

  sig { returns(String) }
  def value = @data.read_string(0, @length, Encoding::BINARY)

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_integer(ix, false, 8)
  end
end
