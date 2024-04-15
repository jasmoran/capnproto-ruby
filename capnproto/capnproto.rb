# typed: strict

require 'sorbet-runtime'

module CapnProto
  extend T::Sig

  WORD_SIZE = 8

  sig { params(block: T.proc.returns(T::Boolean)).void }
  def self.assert(&block)
    Kernel.raise 'Assertion failed' unless yield
  end
end
