# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::Buffer
  extend T::Sig

  sig { params(data: IO::Buffer).void }
  def initialize(data)
    @buffer = data
  end

  sig { params(data: String).returns(CapnProto::Buffer) }
  def self.from_string(data) = new(IO::Buffer.for(data))

  sig { params(data: IO).returns(CapnProto::Buffer) }
  def self.from_io(data) = new(IO::Buffer.for(data.read))

  sig { params(offset: Integer, length: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, length, encoding) = @buffer.get_string(offset, length, encoding)

  sig { params(offset: Integer, type: Symbol).returns(Integer) }
  def read_integer(offset, type) = T.cast(@buffer.get_value(type, offset), Integer)

  sig { params(offset: Integer, size: Integer).returns(CapnProto::Buffer) }
  def slice(offset, size) = CapnProto::Buffer.new(@buffer.slice(offset, size))
end