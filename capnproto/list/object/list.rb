# typed: strict

require 'sorbet-runtime'
require_relative '../list'

class CapnProto::ObjectList
  include CapnProto::List
  extend T::Sig
  extend T::Generic

  Elem = type_member(:out)

  sig { params(array: T::Array[Elem]).void }
  def initialize(array)
    @array = array
  end

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix) = @array.fetch(ix)

  sig { override.returns(Integer) }
  def length = @array.length

  sig { override.returns(Object) }
  def to_obj = @array
end
