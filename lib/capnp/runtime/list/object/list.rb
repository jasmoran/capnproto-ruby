# typed: strict

require "sorbet-runtime"
require_relative "../list"

class Capnp::ObjectList
  include Capnp::List
  extend T::Sig
  extend T::Generic

  Elem = type_member(:out)

  sig { params(array: T::Array[Elem]).void }
  def initialize(array)
    @array = array
  end

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @array.fetch(ix)
  end

  sig { override.returns(Integer) }
  def length
    @array.length
  end

  sig { override.returns(Object) }
  def to_obj
    @array
  end
end
