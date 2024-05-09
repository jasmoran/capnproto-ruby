# typed: strong

################################
## File: lib/minitest/spec.rb ##
################################

require "minitest/test"

class Module
  sig do
    params(
      meth: Symbol,
      new_name: Symbol,
      dont_flip: T.nilable(T::Boolean)
    ).void
  end
  def infect_an_assertion(meth, new_name, dont_flip = false); end
end

Minitest::Expectation = Struct.new :target, :ctx

module Kernel
  sig do
    params(
      desc: T.untyped,
      additional_desc: T.untyped,
      block: T.proc.void
    ).returns(Minitest::Spec)
  end
  private def describe(desc, *additional_desc, &block); end
end

class Minitest::Spec < Minitest::Test
  sig { returns(T.nilable(Thread)) }
  def self.current; end

  sig { params(name: String).void }
  def initialize(name); end

  extend Minitest::Spec::DSL

  TYPES = Minitest::Spec::DSL::TYPES
end

module Minitest::Spec::DSL
  TYPES = T.let([], T::Array[[T.untyped, T.class_of(Minitest::Spec::DSL)]])

  sig { params(arg: T.untyped, block: T.nilable(T.proc.params(desc: String).returns(T::Boolean))).void }
  def register_spec_type(*arg, &block); end

  sig { params(desc: String, additional: T.untyped).returns(T.class_of(Minitest::Spec::DSL)) }
  def spec_type(desc, *additional); end

  sig { returns(T::Array[T.class_of(Minitest::Spec::DSL)]) }
  def describe_stack; end

  sig { returns(T::Array[T.class_of(Minitest::Spec::DSL)]) }
  def children; end

  sig { void }
  def nuke_test_methods!; end

  sig { params(_type: T.untyped, block: T.proc.void).void }
  def before(_type = nil, &block); end

  sig { params(_type: T.untyped, block: T.proc.void).void }
  def after(_type = nil, &block); end

  sig { params(desc: String, block: T.proc.void).returns(String) }
  def it(desc = "anonymous", &block); end

  sig { params(desc: String, block: T.proc.void).returns(String) }
  def specify(desc = "anonymous", &block); end

  sig { params(name: T.any(String, Symbol), block: T.proc.returns(T.anything)).void }
  def let(name, &block); end

  sig { params(block: T.proc.returns(T.anything)).void }
  def subject(&block); end

  sig { params(name: String, desc: String).returns(T.class_of(Minitest::Spec::DSL)) }
  def create(name, desc); end

  sig { returns(String) }
  def name; end

  sig { returns(String) }
  def to_s; end

  sig { returns(String) }
  def desc; end

  sig { params(obj: T.untyped).void }
  def self.extended(obj); end
end

module Minitest::Spec::DSL::InstanceMethods
  sig { params(value: T.anything, block: T.nilable(T.proc.void)).returns(Minitest::Expectation) }
  def _(value = nil, &block); end

  sig { params(value: T.anything, block: T.nilable(T.proc.void)).returns(Minitest::Expectation) }
  def value(value = nil, &block); end

  sig { params(value: T.anything, block: T.nilable(T.proc.void)).returns(Minitest::Expectation) }
  def expect(value = nil, &block); end

  sig { void }
  def before_setup; end
end

class Object
  include Minitest::Expectations
end


########################################
## File: lib/minitest/expectations.rb ##
########################################

module Minitest::Expectations
  sig { params(msg: T.nilable(String)).returns(TrueClass) }
  def must_be_empty(msg = nil); end

  sig do
    params(
      exp: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_equal(exp, msg = nil); end

  sig do
    params(
      exp: BasicObject,
      delta: Float,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_be_close_to(exp, delta = 0.001, msg = nil); end

  sig do
    params(
      exp: BasicObject,
      delta: Float,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_be_within_delta(exp, delta = 0.001, msg = nil); end

  sig do
    params(
      exp: BasicObject,
      epsilon: Float,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_be_within_epsilon(exp, epsilon = 0.001, msg = nil); end

  sig do
    params(
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_include(obj, msg = nil); end

  sig do
    params(
      cls: T::Class[T.untyped],
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_be_instance_of(cls, msg = nil); end

  sig do
    params(
      cls: T::Class[T.untyped],
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_be_kind_of(cls, msg = nil); end

  sig do
    params(
      matcher: T.any(String, Regexp),
      msg: T.nilable(String)
    ).returns(T.nilable(MatchData))
  end
  def must_match(matcher, msg = nil); end

  sig do
    params(
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_be_nil(msg = nil); end

  sig do
    params(
      op: Symbol,
      o2: T.nilable(BasicObject),
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_be(op, o2 = nil, msg = nil); end

  sig do
    params(
      stdout: T.any(NilClass, String, Regexp),
      stderr: T.any(NilClass, String, Regexp),
    ).returns(TrueClass)
  end
  def must_output(stdout = nil, stderr = nil); end

  sig { returns(TrueClass) }
  def must_pattern_match; end

  sig { params(exp: T.untyped).returns(StandardError) }
  def must_raise(*exp); end

  sig do
    params(
      meth: Symbol,
      msg: T.nilable(String),
      include_all: T::Boolean
    ).returns(TrueClass)
  end
  def must_respond_to(meth, msg = nil, include_all: false); end

  sig do
    params(
      exp: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_be_same_as(exp, msg = nil); end

  sig { returns(TrueClass) }
  def must_be_silent; end

  sig do
    params(
      sym: Symbol,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def must_throw(sym, msg = nil); end

  sig do
    params(
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def path_must_exist(msg = nil); end

  sig do
    params(
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def path_wont_exist(msg = nil); end

  sig { params(msg: T.nilable(String)).returns(TrueClass) }
  def wont_be_empty(msg = nil); end

  sig do
    params(
      exp: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def wont_equal(exp, msg = nil); end

  sig do
    params(
      exp: BasicObject,
      delta: Float,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def wont_be_close_to(exp, delta = 0.001, msg = nil); end

  sig do
    params(
      exp: BasicObject,
      delta: Float,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def wont_be_within_delta(exp, delta = 0.001, msg = nil); end

  sig do
    params(
      exp: BasicObject,
      epsilon: Float,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def wont_be_within_epsilon(exp, epsilon = 0.001, msg = nil); end

  sig do
    params(
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def wont_include(obj, msg = nil); end

  sig do
    params(
      cls: T::Class[T.untyped],
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def wont_be_instance_of(cls, msg = nil); end

  sig do
    params(
      cls: T::Class[T.untyped],
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def wont_be_kind_of(cls, msg = nil); end

  sig do
    params(
      matcher: T.any(String, Regexp),
      msg: T.nilable(String)
    ).returns(T.nilable(MatchData))
  end
  def wont_match(matcher, msg = nil); end

  sig do
    params(
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def wont_be_nil(msg = nil); end

  sig do
    params(
      op: Symbol,
      o2: T.nilable(BasicObject),
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def wont_be(op, o2 = nil, msg = nil); end

  sig { returns(TrueClass) }
  def wont_pattern_match; end

  sig do
    params(
      meth: Symbol,
      msg: T.nilable(String),
      include_all: T::Boolean
    ).returns(TrueClass)
  end
  def wont_respond_to(meth, msg = nil, include_all: false); end

  sig do
    params(
      exp: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def wont_be_same_as(exp, msg = nil); end
end
