# typed: strong

###########################
## File: lib/minitest.rb ##
###########################

module Minitest
  VERSION = T.let(T.unsafe(nil), String)

  sig { returns(Integer) }
  def self.seed; end

  sig { params(seed: Integer).void }
  def self.seed=(seed); end

  sig { returns(Minitest::Parallel::Executor) }
  def self.parallel_executor; end

  sig { params(pe: Minitest::Parallel::Executor).void }
  def self.parallel_executor=(pe); end

  sig { returns(Minitest::BacktraceFilter) }
  def self.backtrace_filter; end

  sig { params(filter: Minitest::BacktraceFilter).void }
  def self.backtrace_filter=(filter); end

  sig { returns(Minitest::AbstractReporter) }
  def self.reporter; end

  sig { params(reporter: Minitest::AbstractReporter).void }
  def self.reporter=(reporter); end

  sig { returns(T::Array[String]) }
  def self.extensions; end

  sig { params(extensions: T::Array[String]).void }
  def self.extensions=(extensions); end

  sig { returns(String) }
  def self.info_signal; end

  sig { params(info_signal: String).void }
  def self.info_signal=(info_signal); end

  sig { returns(T::Boolean) }
  def self.allow_fork; end

  sig { params(allow_fork: T::Boolean).void }
  def self.allow_fork=(allow_fork); end

  sig { void }
  def self.autorun; end

  sig { params(block: T.proc.void).void }
  def self.after_run(&block); end

  sig { params(options: T.untyped).void }
  def self.init_plugins(options); end

  sig { void }
  def self.load_plugins; end

  sig { params(args: T::Array[String]).returns(T.untyped) }
  def self.run(args = T.unsafe(nil)); end

  sig { params(options: T.untyped).void }
  def self.empty_run!(options); end

  sig do
    params(
      reporter: Minitest::AbstractReporter,
      options: T.untyped
    ).returns(T::Array[T.untyped])
  end
  def self.__run(reporter, options); end

  sig { params(args: T::Array[String]).returns(T::Hash[Symbol, T.untyped]) }
  def self.process_args(args = []); end

  sig { params(bt: T::Array[String]).returns(T::Array[String]) }
  def self.filter_backtrace(bt); end

  sig do
    params(
      klass: T::Class[T.untyped],
      method_name: T.any(String, Symbol)
    ).returns(T.untyped)
  end
  def self.run_one_method(klass, method_name); end

  sig { returns(T.any(Time, Float)) }
  def self.clock_time; end
end

class Minitest::Runnable
  abstract!

  sig { returns(Integer) }
  def assertions; end

  sig { params(val: Integer).void }
  def assertions=(val); end

  sig { returns(T::Array[Minitest::Assertion]) }
  def failures; end

  sig { params(val: T::Array[Minitest::Assertion]).void }
  def failures=(val); end

  sig { returns(T.nilable(Float)) }
  def time; end

  sig { params(val: Float).void }
  def time=(val); end

  sig { params(blk: T.proc.void).void }
  def time_it(&blk); end

  sig { returns(String) }
  def name; end

  sig { params(o: String).void }
  def name=(o); end

  sig { params(re: Regexp).returns(T::Array[String]) }
  def self.methods_matching(re); end

  sig { void }
  def self.reset; end

  sig do
    params(
      reporter: Minitest::AbstractReporter,
      options: T::Hash[T.untyped, T.untyped]
    ).returns(T::Array[T.untyped])
  end
  def self.run(reporter, options = {}); end

  sig do
    params(
      klass: T::Class[Minitest::Runnable],
      method_name: T.any(String, Symbol),
      reporter: Minitest::AbstractReporter
    ).returns(T::Array[Minitest::AbstractReporter])
  end
  def self.run_one_method(klass, method_name, reporter); end

  sig { returns(Symbol) }
  def self.test_order; end

  sig do
    params(
      reporter: Minitest::AbstractReporter,
      block: T.proc.void
    ).void
  end
  def self.with_info_handler(reporter, &block); end

  SIGNALS = T.let({}, T::Hash[String, Integer])

  sig do
    params(
      name: String,
      action: T.proc.void,
      block: T.proc.void
    ).returns(T.untyped)
  end
  def self.on_signal(name, action, &block); end

  sig { abstract.returns(T::Array[String]) }
  def self.runnable_methods; end

  sig { returns(T::Array[Minitest::Runnable]) }
  def self.runnables; end

  sig { returns(T::Array[T.untyped]) }
  def marshal_dump; end

  sig { params(ary: T::Array[T.untyped]).void }
  def marshal_load(ary); end

  sig { returns(T.nilable(Minitest::Assertion)) }
  def failure; end

  sig { params(name: String).void }
  def initialize(name); end

  sig { returns(T.untyped) }
  def metadata; end

  sig { params(val: T.untyped).void }
  def metadata=(val); end

  sig { returns(T::Boolean) }
  def metadata?; end

  sig { abstract.returns(Minitest::Result) }
  def run; end

  sig { abstract.returns(T::Boolean) }
  def passed?; end

  sig { abstract.returns(String) }
  def result_code; end

  sig { abstract.returns(T::Boolean) }
  def skipped?; end

  sig { params(klass: T::Class[T.untyped]).void }
  def self.inherited(klass); end
end

module Minitest::Reportable
  abstract!

  sig { returns(T::Boolean) }
  def passed?; end

  BASE_DIR = T.let("", String)

  sig { returns(String) }
  def location; end

  sig { abstract.returns(String) }
  def class_name; end

  sig { returns(String) }
  def result_code; end

  sig { returns(T::Boolean) }
  def skipped?; end

  sig { returns(T::Boolean) }
  def error?; end
end

class Minitest::Result < Minitest::Runnable
  include Minitest::Reportable

  sig { returns(String) }
  def klass; end

  sig { params(val: String).void }
  def klass=(val); end

  sig { returns([String, Integer]) }
  def source_location; end

  sig { params(val: [String, Integer]).void }
  def source_location=(val); end

  sig { params(runnable: Minitest::Runnable).returns(Minitest::Result) }
  def self.from(runnable); end

  sig { returns(String) }
  def class_name; end

  sig { returns(String) }
  def to_s; end

end

class Minitest::AbstractReporter
  abstract!

  sig { void }
  def initialize; end

  sig { void }
  def start; end

  sig { params(klass: T::Class[T.untyped], name: String).void }
  def prerecord(klass, name); end

  sig { params(result: Minitest::Result).void }
  def record(result); end

  sig { void }
  def report; end

  sig { returns(T::Boolean) }
  def passed?; end

  sig { params(block: T.proc.void).void }
  def synchronize(&block); end
end

class Minitest::Reporter < Minitest::AbstractReporter
  sig { returns(IO) }
  def io; end

  sig { params(val: IO).void }
  def io=(val); end

  sig { returns(T::Hash[T.untyped, T.untyped]) }
  def options; end

  sig { params(val: T::Hash[T.untyped, T.untyped]).void }
  def options=(val); end

  sig { params(io: IO, options: T::Hash[T.untyped, T.untyped]).void }
  def initialize(io = STDOUT, options = {}); end
end

class Minitest::ProgressReporter < Minitest::Reporter
end

class Minitest::StatisticsReporter < Minitest::Reporter
  sig { returns(T.nilable(Integer)) }
  def assertions; end

  sig { params(val: Integer).void }
  def assertions=(val); end

  sig { returns(Integer) }
  def count; end

  sig { params(val: Integer).void }
  def count=(val); end

  sig { returns(T::Array[Minitest::Result]) }
  def results; end

  sig { params(val: T::Array[Minitest::Result]).void }
  def results=(val); end

  sig { returns(T.any(Time, Float)) }
  def start_time; end

  sig { params(val: T.any(Time, Float)).void }
  def start_time=(val); end

  sig { returns(T.any(Time, Float)) }
  def total_time; end

  sig { params(val: T.any(Time, Float)).void }
  def total_time=(val); end

  sig { returns(T.nilable(Integer)) }
  def failures; end

  sig { params(val: Integer).void }
  def failures=(val); end

  sig { returns(T.nilable(Integer)) }
  def errors; end

  sig { params(val: Integer).void }
  def errors=(val); end

  sig { returns(T.nilable(Integer)) }
  def skips; end

  sig { params(val: Integer).void }
  def skips=(val); end
end

class Minitest::SummaryReporter < Minitest::StatisticsReporter
  sig { returns(T::Boolean) }
  def sync; end

  sig { params(val: T::Boolean).void }
  def sync=(val); end

  sig { returns(T::Boolean) }
  def old_sync; end

  sig { params(val: T::Boolean).void }
  def old_sync=(val); end

  sig { returns(String) }
  def statistics; end

  sig { params(io: IO).returns(IO) }
  def aggregated_results(io); end

  sig { returns(String) }
  def to_s; end

  sig { returns(String) }
  def summary; end
end

class Minitest::CompositeReporter < Minitest::AbstractReporter
  sig { returns(T::Array[Minitest::AbstractReporter]) }
  def reporters; end

  sig { params(val: T::Array[Minitest::AbstractReporter]).void }
  def reporters=(val); end

  sig { params(reporters: Minitest::AbstractReporter).void }
  def initialize(*reporters); end

  sig { returns(T.nilable(IO)) }
  def io; end

  sig { params(reporter: Minitest::AbstractReporter).void }
  def <<(reporter); end
end

class Minitest::Assertion < Exception
  RE = T.let(T.unsafe(nil), Regexp)

  sig { returns(T.self_type) }
  def error; end

  sig { returns(String) }
  def location; end

  sig { returns(String) }
  def result_code; end

  sig { returns(String) }
  def result_label; end
end

class Minitest::Skip < Minitest::Assertion
end

class Minitest::UnexpectedError < Minitest::Assertion
  include Minitest::Compress

  BASE_RE = T.let(T.unsafe(nil), Regexp)

  sig { params(error: StandardError).void }
  def initialize(error); end
end

module Minitest::Guard
  sig { params(platform: String).returns(T::Boolean) }
  def jruby?(platform = ""); end

  sig { params(platform: String).returns(T::Boolean) }
  def maglev?(platform = ""); end

  sig { params(platform: String).returns(T::Boolean) }
  def mri?(platform = ""); end

  sig { params(platform: String).returns(T::Boolean) }
  def osx?(platform = ""); end

  sig { params(platform: String).returns(T::Boolean) }
  def rubinius?(platform = ""); end

  sig { params(platform: String).returns(T::Boolean) }
  def windows?(platform = ""); end
end

class Minitest::BacktraceFilter
  MT_RE = T.let(T.unsafe(nil), Regexp)

  sig { returns(Regexp) }
  def regexp; end

  sig { params(val: Regexp).void }
  def regexp=(val); end

  sig { params(regexp: Regexp).void }
  def initialize(regexp); end

  sig { params(bt: T::Array[String]).returns(T::Array[String]) }
  def filter(bt); end
end


####################################
## File: lib/minitest/compress.rb ##
####################################

module Minitest::Compress
  sig { params(orig: T::Array[String]).returns(T::Array[String]) }
  def compress(orig); end
end


####################################
## File: lib/minitest/parallel.rb ##
####################################

module Minitest::Parallel
  class Executor
    sig { returns(Integer) }
    def size; end

    sig { params(size: Integer).void }
    def initialize(size); end

    sig { void }
    def start; end

    sig { params(work: T.untyped).void }
    def <<(work); end

    sig { void }
    def shutdown; end
  end

  module Test
    sig { params(blk: T.proc.void).void }
    def _synchronize(&blk); end

    module ClassMethods
      sig do
        params(
          klass: T::Class[T.untyped],
          method_name: String,
          reporter: Minitest::AbstractReporter
        ).void
      end
      def run_one_method(klass, method_name, reporter); end

      sig { returns(Symbol) }
      def test_order; end
    end
  end
end
