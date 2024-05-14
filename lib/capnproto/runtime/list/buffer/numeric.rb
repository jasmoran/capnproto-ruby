# typed: strict

require "sorbet-runtime"
require_relative "list"

class CapnProto::NumericList < CapnProto::BufferList
  abstract!

  Elem = type_member(:out)

  sig { override.returns(Object) }
  def to_obj = to_a
end

class CapnProto::U8List < CapnProto::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_u8(ix)
  end
end

class CapnProto::U16List < CapnProto::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_u16(ix * 2)
  end
end

class CapnProto::U32List < CapnProto::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_u32(ix * 4)
  end
end

class CapnProto::U64List < CapnProto::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_u64(ix * 8)
  end
end

class CapnProto::S8List < CapnProto::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_s8(ix)
  end
end

class CapnProto::S16List < CapnProto::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_s16(ix * 2)
  end
end

class CapnProto::S32List < CapnProto::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_s32(ix * 4)
  end
end

class CapnProto::S64List < CapnProto::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_s64(ix * 8)
  end
end

class CapnProto::F32List < CapnProto::NumericList
  Elem = type_member { {fixed: Float} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_f32(ix * 4)
  end
end

class CapnProto::F64List < CapnProto::NumericList
  Elem = type_member { {fixed: Float} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_f64(ix * 8)
  end
end
