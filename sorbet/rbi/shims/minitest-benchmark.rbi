# typed: strong

#####################################
## File: lib/minitest/benchmark.rb ##
#####################################

class Minitest::Benchmark < Minitest::Test
  sig { returns(IO) }
  def self.io; end

  sig { returns(IO) }
  def io; end

  sig do
    params(
      min: Integer,
      max: Integer,
      base: Integer
    ).returns(T::Array[Integer])
  end
  def self.bench_exp(min, max, base = 10); end

  sig do
    params(
      min: Integer,
      max: Integer,
      step: Integer
    ).returns(T::Array[Integer])
  end
  def self.bench_linear(min, max, step = 10); end

  sig { returns(T::Array[Integer]) }
  def self.bench_range; end

  sig do
    params(
      validation: T.proc.params(
        range: T::Array[Integer],
        times: T::Array[Float]
      ).returns(T::Boolean),
      work: T.proc.params(n: Integer).returns(T.untyped)
    ).returns(T.untyped)
  end
  def assert_performance(validation, &work); end

  sig do
    params(
      threshold: Float,
      work: T.proc.params(n: Integer).returns(T.untyped)
    ).returns(T.untyped)
  end
  def assert_performance_constant(threshold = 0.99, &work); end

  sig do
    params(
      threshold: Float,
      work: T.proc.params(n: Integer).returns(T.untyped)
    ).returns(T.untyped)
  end
  def assert_performance_exponential(threshold = 0.99, &work); end

  sig do
    params(
      threshold: Float,
      work: T.proc.params(n: Integer).returns(T.untyped)
    ).returns(T.untyped)
  end
  def assert_performance_logarithmic(threshold = 0.99, &work); end

  sig do
    params(
      threshold: Float,
      work: T.proc.params(n: Integer).returns(T.untyped)
    ).returns(T.untyped)
  end
  def assert_performance_linear(threshold = 0.99, &work); end

  sig do
    params(
      threshold: Float,
      work: T.proc.params(n: Integer).returns(T.untyped)
    ).returns(T.untyped)
  end
  def assert_performance_power(threshold = 0.99, &work); end

  sig { params(xys: T::Array[[Integer, Integer]]).returns(Numeric) }
  def fit_error(xys); end

  sig do
    params(
      xs: T::Array[Integer],
      ys: T::Array[Integer]
    ).returns([Numeric, Numeric, Numeric])
  end
  def fit_exponential(xs, ys); end

  sig do
    params(
      xs: T::Array[Integer],
      ys: T::Array[Integer]
    ).returns([Numeric, Numeric, Numeric])
  end
  def fit_logarithmic(xs, ys); end

  sig do
    params(
      xs: T::Array[Integer],
      ys: T::Array[Integer]
    ).returns([Numeric, Numeric, Numeric])
  end
  def fit_linear(xs, ys); end

  sig do
    params(
      xs: T::Array[Integer],
      ys: T::Array[Integer]
    ).returns([Numeric, Numeric, Numeric])
  end
  def fit_power(xs, ys); end

  sig do
    params(
      enum: T::Enumerable[Numeric],
      block: T.proc.params(sum: Numeric, n: Integer).returns(Numeric)
    ).returns(Numeric)
  end
  def sigma(enum, &block); end

  sig do
    params(
      msg: Symbol,
      threshold: Numeric
    ).returns([Numeric, Numeric, Numeric])
  end
  def validation_for_fit(msg, threshold); end
end

class Minitest::BenchSpec < Minitest::Benchmark
  extend Minitest::Spec::DSL

  sig do
    params(
      name: String,
      block: T.proc.void
    ).void
  end
  def self.bench(name, &block); end

  sig { params(block: T.proc.void).void }
  def self.bench_range(&block); end

  sig do
    params(
      name: String,
      threshold: Float,
      work: T.proc.params(n: Integer).void
    ).void
  end
  def self.bench_performance_linear(name, threshold = 0.99, &work); end

  sig do
    params(
      name: String,
      threshold: Float,
      work: T.proc.params(n: Integer).void
    ).void
  end
  def self.bench_performance_constant(name, threshold = 0.99, &work); end

  sig do
    params(
      name: String,
      threshold: Float,
      work: T.proc.params(n: Integer).void
    ).void
  end
  def self.bench_performance_exponential(name, threshold = 0.99, &work); end

  sig do
    params(
      name: String,
      threshold: Float,
      work: T.proc.params(n: Integer).void
    ).void
  end
  def self.bench_performance_logarithmic(name, threshold = 0.99, &work); end

  sig do
    params(
      name: String,
      threshold: Float,
      work: T.proc.params(n: Integer).void
    ).void
  end
  def self.bench_performance_power(name, threshold = 0.99, &work); end
end
