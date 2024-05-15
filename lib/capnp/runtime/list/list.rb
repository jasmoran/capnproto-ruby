# typed: strict

require "sorbet-runtime"

module Capnp::List
  include Kernel
  include Enumerable
  extend T::Sig
  extend T::Generic
  extend T::Helpers

  abstract!

  Elem = type_member(:out)

  sig { abstract.returns(Integer) }
  def length
  end

  # Get a single element at the given index
  # THE INDEX MUST BE IN RANGE.
  sig { abstract.params(ix: Integer).returns(Elem) }
  private def get(ix)
  end

  sig { params(ix: Integer).returns(T.nilable(Elem)) }
  def [](ix)
    return if ix < 0 || ix >= length
    get(ix)
  end

  sig { override.params(blk: T.proc.params(arg0: Elem).returns(BasicObject)).void }
  def each(&blk)
    length.times do |ix|
      blk.call(get(ix))
    end
  end

  sig { abstract.returns(Object) }
  def to_obj
  end
end
