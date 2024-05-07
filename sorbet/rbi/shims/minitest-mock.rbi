# typed: strong

################################
## File: lib/minitest/mock.rb ##
################################

class Minitest::Mock
  sig { params(delegator: T.untyped).void }
  def initialize(delegator = nil)
    @delegator = delegator
    @expected_calls = Hash.new { |calls, name| calls[name] = [] }
    @actual_calls   = Hash.new { |calls, name| calls[name] = [] }
  end

  sig do
    params(
      name: Symbol,
      retval: T.untyped,
      args: T::Array[T.untyped],
      kwargs: T::Hash[T.untyped, T.untyped],
    ).returns(T.self_type)
  end
  sig do
    params(
      name: Symbol,
      retval: T.untyped,
      blk: T.nilable(T.proc.returns(T::Boolean))
    ).returns(T.self_type)
  end
  def expect(name, retval, args = [], **kwargs, &blk); end

  sig { returns(TrueClass) }
  def verify; end
end

module Minitest::Assertions
  sig { params(mock: Minitest::Mock).returns(TrueClass) }
  def assert_mock(mock); end
end

class Object
  sig do
    params(
      name: Symbol,
      val_or_callable: T.untyped,
      block_args: T.untyped,
      block_kwargs: T.untyped,
      block: T.proc.void
    ).void
  end
  def stub(name, val_or_callable, *block_args, **block_kwargs, &block); end
end
