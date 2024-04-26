# typed: strict

require "sorbet-runtime"
require_relative "list"

class CapnProto::StructList < CapnProto::BufferList
  abstract!

  Elem = type_member { {upper: CapnProto::Struct} }

  sig { abstract.returns(T::Class[Elem]) }
  def element_class
  end

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    case @element_type
      # Void type elements
    when 0 then element_class.new(CapnProto::Reference::EMPTY, CapnProto::Reference::EMPTY)

      # Bit type elements
    when 1 then raise "Bit lists may not be decoded as structs"

      # Integer type elements
    when 2, 3, 4, 5
      data_offset = ix * @element_size
      element_class.new(@data.apply_offset(data_offset, @element_size), CapnProto::Reference::EMPTY)

      # Pointer type elements
    when 6
      data_offset = ix * @element_size
      element_class.new(CapnProto::Reference::EMPTY, @data.apply_offset(data_offset, @element_size))

      # Composite type elements
    else
      data_offset = ix * @element_size
      data_size = @data_words * CapnProto::WORD_SIZE
      data_ref = @data.apply_offset(data_offset, data_size)
      pointer_ref = @data.apply_offset(data_offset + data_size, @pointer_words * CapnProto::WORD_SIZE)
      element_class.new(data_ref, pointer_ref)
    end
  end

  sig { override.returns(Object) }
  def to_obj = map(&:to_obj)
end
