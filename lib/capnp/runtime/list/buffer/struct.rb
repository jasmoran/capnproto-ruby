# typed: strict

require "sorbet-runtime"
require_relative "list"

class Capnp::StructList < Capnp::BufferList
  abstract!

  Elem = type_member { {upper: Capnp::Struct} }

  sig { abstract.returns(T::Class[Elem]) }
  def element_class
  end

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    case @element_type
      # Void type elements
    when 0 then element_class.new(Capnp::Reference::EMPTY, 0, Capnp::Reference::EMPTY, 0)

      # Bit type elements
    when 1 then raise "Bit lists may not be decoded as structs"

      # Integer type elements
    when 2, 3, 4, 5
      data_offset = ix * @element_size
      element_class.new(@data.offset_position(data_offset), @element_size, Capnp::Reference::EMPTY, 0)

      # Pointer type elements
    when 6
      data_offset = ix * @element_size
      element_class.new(Capnp::Reference::EMPTY, 0, @data.offset_position(data_offset), @element_size)

      # Composite type elements
    else
      data_offset = ix * @element_size
      data_size = @data_words * Capnp::WORD_SIZE
      data_ref = @data.offset_position(data_offset)
      pointers_size = @pointer_words * Capnp::WORD_SIZE
      pointers_ref = @data.offset_position(data_offset + data_size)
      element_class.new(data_ref, data_size, pointers_ref, pointers_size)
    end
  end

  sig { override.returns(Object) }
  def to_obj = map(&:to_obj)
end
