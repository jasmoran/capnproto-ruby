# typed: strict

require 'sorbet-runtime'
require_relative 'capnproto'

class CapnProto::StructPointer
  extend T::Sig

  sig { params(segment: CapnProto::Segment, offset: Integer).void }
  def initialize(segment, offset)
    @segment = segment
    @offset = offset

    # Check the type of the pointer
    offset_part = @segment.read_integer(@offset, :u32)
    CapnProto::assert { offset_part & 0b11 == 0 }

    # Extract offset of data section
    offset_from_pointer = (offset_part & 0xFFFFFFFC) * 2
    @data_offset = T.let(@offset + offset_from_pointer + CapnProto::WORD_SIZE, Integer)

    # Extract size of data and pointer sections
    @data_size = T.let(@segment.read_integer(@offset + 4, :u16) * CapnProto::WORD_SIZE, Integer)
    @pointer_size = T.let(@segment.read_integer(@offset + 6, :u16) * CapnProto::WORD_SIZE, Integer)

    # Calculate offset of pointer section
    @pointer_offset = T.let(@data_offset + @data_size, Integer)
  end

  sig { params(offset: Integer, size: Integer, encoding: Encoding).returns(String) }
  def read_string(offset, size, encoding) = @segment.read_string(@data_offset + offset, size, encoding)

  sig { params(offset: Integer, type: Symbol).returns(Integer) }
  def read_integer(offset, type) = @segment.read_integer(@data_offset + offset, type)

  sig { params(ix: Integer).returns(Integer) }
  def pointer_offset(ix) = @pointer_offset + ix * CapnProto::WORD_SIZE
end
