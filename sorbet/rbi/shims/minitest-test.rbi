# typed: strong

################################
## File: lib/minitest/test.rb ##
################################

class Minitest::Test < Minitest::Runnable
  include Minitest::Assertions
  include Minitest::Reportable

  sig { returns(String) }
  def class_name; end

  PASSTHROUGH_EXCEPTIONS = T.let([], T::Array[Exception])
  SETUP_METHODS = T.let([], T::Array[String])
  TEARDOWN_METHODS = T.let([], T::Array[String])

  sig { returns(Mutex) }
  def self.io_lock; end

  sig { params(val: Mutex).void }
  def self.io_lock=(val); end

  sig { returns(Symbol) }
  def self.test_order; end

  sig { void }
  def self.i_suck_and_my_tests_are_order_dependent!; end

  sig { void }
  def self.make_my_diffs_pretty!; end

  sig { void }
  def self.parallelize_me!; end

  sig { returns(T::Array[String]) }
  def self.runnable_methods; end

  sig { returns(Minitest::Result) }
  def run; end

  sig { params(block: T.proc.void).void }
  def capture_exceptions(&block); end

  sig { params(e: Exception).returns(Exception) }
  def sanitize_exception(e); end

  sig { params(e: Exception).returns(Exception) }
  def neuter_exception(e); end

  sig do
    params(
      klass: T::Class[Exception],
      msg: String,
      bt: T::Array[String],
      kill: T::Boolean
    ).returns(Exception)
  end
  def new_exception(klass, msg, bt, kill = false); end

  sig { params(block: T.proc.void).returns(T.untyped) }
  def with_info_handler(&block); end

  include Minitest::Test::LifecycleHooks
  include Minitest::Guard
  extend Minitest::Guard
end

module Minitest::Test::LifecycleHooks
  sig { void }
  def before_setup; end

  sig { void }
  def setup; end

  sig { void }
  def after_setup; end

  sig { void }
  def before_teardown; end

  sig { void }
  def teardown; end

  sig { void }
  def after_teardown; end
end


######################################
## File: lib/minitest/assertions.rb ##
######################################

module Minitest::Assertions
  UNDEFINED = T.let(T.unsafe(nil), Object)

  sig { returns(String) }
  def self.diff; end

  sig { params(o: String).void }
  def self.diff=(o); end

  sig { params(exp: String, act: String).returns(T.nilable(String)) }
  def diff(exp, act); end

  sig do
    params(
      exp: BasicObject,
      act: BasicObject
    ).returns([T.nilable(String), T.nilable(String)])
  end
  def things_to_diff(exp, act); end

  sig { params(obj: BasicObject).returns(String) }
  def mu_pp(obj); end

  sig { params(obj: BasicObject).returns(String) }
  def mu_pp_for_diff(obj); end

  sig { params(test: T.untyped, msg: T.nilable(String)).returns(TrueClass) }
  def assert(test, msg = nil); end

  sig { params(blk: T.proc.void).void }
  def _synchronize(&blk); end

  sig do
    params(
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_empty(obj, msg = nil); end

  sig { void }
  def _where; end

  E = T.let("", String)

  sig do
    params(
      exp: BasicObject,
      act: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_equal(exp, act, msg = nil); end

  sig do
    params(
      exp: BasicObject,
      act: BasicObject,
      delta: Float,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_in_delta(exp, act, delta = 0.001, msg = nil); end

  sig do
    params(
      exp: BasicObject,
      act: BasicObject,
      epsilon: Float,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_in_epsilon(exp, act, epsilon = 0.001, msg = nil); end

  sig do
    params(
      collection: T::Enumerable[T.untyped],
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_includes(collection, obj, msg = nil); end

  sig do
    params(
      cls: T::Class[T.untyped],
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_instance_of(cls, obj, msg = nil); end

  sig do
    params(
      cls: T::Class[T.untyped],
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_kind_of(cls, obj, msg = nil); end

  sig do
    params(
      matcher: T.any(String, Regexp),
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(T.nilable(MatchData))
  end
  def assert_match(matcher, obj, msg = nil); end

  sig do
    params(
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_nil(obj, msg = nil); end

  sig do
    params(
      o1: BasicObject,
      op: Symbol,
      o2: T.nilable(BasicObject),
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_operator(o1, op, o2 = nil, msg = nil); end

  sig do
    params(
      stdout: T.any(NilClass, String, Regexp),
      stderr: T.any(NilClass, String, Regexp),
      blk: T.proc.void
    ).returns(TrueClass)
  end
  def assert_output(stdout = nil, stderr = nil, &blk); end

  sig do
    params(
      path: String,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_path_exists(path, msg = nil); end

  sig do
    params(
      blk: T.proc.void
    ).returns(TrueClass)
  end
  def assert_pattern(&blk); end

  sig do
    params(
      o1: BasicObject,
      op: Symbol,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_predicate(o1, op, msg = nil); end

  sig do
    params(
      exp: T.untyped,
      blk: T.proc.void
    ).returns(StandardError)
  end
  def assert_raises(*exp, &blk); end

  sig do
    params(
      obj: BasicObject,
      meth: Symbol,
      msg: T.nilable(String),
      include_all: T::Boolean
    ).returns(TrueClass)
  end
  def assert_respond_to(obj, meth, msg = nil, include_all: false); end

  sig do
    params(
      exp: BasicObject,
      act: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_same(exp, act, msg = nil); end

  sig do
    params(
      send_ary: T::Array[BasicObject],
      m: T.nilable(String)
    ).returns(TrueClass)
  end
  def assert_send(send_ary, m = nil); end

  sig do
    params(
      blk: T.proc.void
    ).returns(TrueClass)
  end
  def assert_silent(&blk); end

  sig do
    params(
      sym: Symbol,
      msg: T.nilable(String),
      blk: T.proc.void
    ).returns(TrueClass)
  end
  def assert_throws(sym, msg = nil, &blk); end

  sig { params(blk: T.proc.void).returns([String, String]) }
  def capture_io(&blk); end

  sig { params(blk: T.proc.void).returns([String, String]) }
  def capture_subprocess_io(&blk); end

  sig { params(e: Exception, msg: String).returns(String) }
  def exception_details(e, msg); end

  sig do
    params(
      y: Integer,
      m: Integer,
      d: Integer,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def fail_after(y, m, d, msg = nil); end

  sig { params(msg: T.nilable(String)).returns(TrueClass) }
  def flunk(msg = nil); end

  sig do
    params(
      msg: T.nilable(String),
      ending: T.nilable(String),
      default: T.proc.void
    ).returns(T.proc.void)
  end
  def message(msg = nil, ending = nil, &default); end

  sig { params(_msg: T.nilable(String)).returns(TrueClass) }
  def pass(_msg = nil); end

  sig { params(test: T.untyped, msg: T.nilable(String)).returns(TrueClass) }
  def refute(test, msg = nil); end

  sig do
    params(
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_empty(obj, msg = nil); end

  sig do
    params(
      exp: BasicObject,
      act: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_equal(exp, act, msg = nil); end

  sig do
    params(
      exp: BasicObject,
      act: BasicObject,
      delta: Float,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_in_delta(exp, act, delta = nil, msg = nil); end

  sig do
    params(
      a: BasicObject,
      b: BasicObject,
      epsilon: Float,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_in_epsilon(a, b, epsilon = nil, msg = nil); end

  sig do
    params(
      collection: T::Enumerable[T.untyped],
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_includes(collection, obj, msg = nil); end

  sig do
    params(
      cls: T::Class[T.untyped],
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_instance_of(cls, obj, msg = nil); end

  sig do
    params(
      cls: T::Class[T.untyped],
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_kind_of(cls, obj, msg = nil); end

  sig do
    params(
      matcher: T.any(String, Regexp),
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(T.nilable(MatchData))
  end
  def refute_match(matcher, obj, msg = nil); end

  sig do
    params(
      obj: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_nil(obj, msg = nil); end

  sig do
    params(
      blk: T.proc.void
    ).returns(TrueClass)
  end
  def refute_pattern(&blk); end

  sig do
    params(
      o1: BasicObject,
      op: Symbol,
      o2: T.nilable(BasicObject),
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_operator(o1, op, o2 = nil, msg = nil); end

  sig do
    params(
      path: String,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_path_exists(path, msg = nil); end

  sig do
    params(
      o1: BasicObject,
      op: Symbol,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_predicate(o1, op, msg = nil); end

  sig do
    params(
      obj: BasicObject,
      meth: Symbol,
      msg: T.nilable(String),
      include_all: T::Boolean
    ).returns(TrueClass)
  end
  def refute_respond_to(obj, meth, msg = nil, include_all: false); end

  sig do
    params(
      exp: BasicObject,
      act: BasicObject,
      msg: T.nilable(String)
    ).returns(TrueClass)
  end
  def refute_same(exp, act, msg = nil); end

  sig do
    params(
      msg: T.nilable(String),
      _ignored: T.untyped
    ).returns(TrueClass)
  end
  def skip(msg = nil, _ignored = nil); end

  sig do
    params(
      y: Integer,
      m: Integer,
      d: Integer,
      msg: T.nilable(String)
    ).void
  end
  def skip_until(y, m, d, msg = nil); end

  sig { returns(T::Boolean) }
  def skipped?; end
end
