# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"

class CapnProto::Segment
  extend T::Sig

  include CapnProto::Buffer

  sig { params(message: CapnProto::Message, buffer: CapnProto::Buffer).void }
  def initialize(message, buffer)
    @message = message
    @buffer = buffer
  end

  sig { returns(CapnProto::Message) }
  attr_reader :message

  sig { override.params(offset: Integer, length: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, length, encoding)
    @buffer.read_string(offset, length, encoding)
  end

  sig { override.params(offset: Integer, signed: T::Boolean, number_bits: Integer).returns(Integer) }
  def read_integer(offset, signed, number_bits)
    @buffer.read_integer(offset, signed, number_bits)
  end

  sig { override.params(offset: Integer, number_bits: Integer).returns(Float) }
  def read_float(offset, number_bits)
    @buffer.read_float(offset, number_bits)
  end

  sig { override.params(pointer_ref: CapnProto::Reference).returns([CapnProto::Reference, T.nilable(CapnProto::Reference)]) }
  def dereference_pointer(pointer_ref)
    @message.dereference_pointer(pointer_ref)
  end

  sig { override.returns(Integer) }
  def size
    @buffer.size
  end

  sig { returns(CapnProto::Reference) }
  def to_reference
    CapnProto::Reference.new(self, 0, 0...size)
  end
end
