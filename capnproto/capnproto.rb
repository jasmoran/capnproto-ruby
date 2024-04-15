# typed: strict

require 'sorbet-runtime'

module CapnProto
  extend T::Sig

  WORD_SIZE = 8

  sig { params(message: ::String, block: T.proc.returns(T::Boolean)).void }
  def self.assert(message = '', &block)
    Kernel.raise "Assertion failed: #{message}" unless yield
  end
end
