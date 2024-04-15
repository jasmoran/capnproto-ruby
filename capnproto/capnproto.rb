# typed: strict

require 'sorbet-runtime'

module CapnProto
  extend T::Sig

  WORD_SIZE = 8

  sig { params(block: T.proc.returns(T::Boolean)).void }
  def self.assert(&block)
    Kernel.raise 'Assertion failed' unless yield
  end

  class Segment
    extend T::Sig

    sig { params(message: Message, offset: Integer, size: Integer).void }
    def initialize(message, offset, size)
      @message = message
      @offset = offset
      @size = size
    end

    sig { params(offset: Integer, size: Integer, encoding: Encoding).returns(::String) }
    def read_string(offset, size, encoding) = ""

    sig { params(offset: Integer, type: Symbol).returns(Integer) }
    def read_integer(offset, type) = 0
  end
end
