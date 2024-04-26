# typed: strict

require 'sorbet-runtime'
require_relative 'list'

class CapnProto::SignedIntegerList < CapnProto::BufferList
  Elem = type_member {{fixed: Integer}}

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_integer(ix * @element_size, true, @element_size * 8)
  end

  sig { override.returns(Object) }
  def to_obj = to_a
end

class CapnProto::UnsignedIntegerList < CapnProto::BufferList
  Elem = type_member {{fixed: Integer}}

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_integer(ix * @element_size, false, @element_size * 8)
  end

  sig { override.returns(Object) }
  def to_obj = to_a
end

class CapnProto::FloatList < CapnProto::BufferList
  Elem = type_member {{fixed: Float}}

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_float(ix * @element_size, @element_size * 8)
  end

  sig { override.returns(Object) }
  def to_obj = to_a
end
