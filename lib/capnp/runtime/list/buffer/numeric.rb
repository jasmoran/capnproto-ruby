# typed: strict

require "sorbet-runtime"
require_relative "list"

class Capnp::NumericList < Capnp::BufferList
  abstract!

  Elem = type_member(:out)

  sig { override.returns(Object) }
  def to_obj = to_a
end

class Capnp::U8List < Capnp::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_u8(ix)
  end
end

class Capnp::U16List < Capnp::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_u16(ix * 2)
  end
end

class Capnp::U32List < Capnp::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_u32(ix * 4)
  end
end

class Capnp::U64List < Capnp::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_u64(ix * 8)
  end
end

class Capnp::S8List < Capnp::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_s8(ix)
  end
end

class Capnp::S16List < Capnp::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_s16(ix * 2)
  end
end

class Capnp::S32List < Capnp::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_s32(ix * 4)
  end
end

class Capnp::S64List < Capnp::NumericList
  Elem = type_member { {fixed: Integer} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_s64(ix * 8)
  end
end

class Capnp::F32List < Capnp::NumericList
  Elem = type_member { {fixed: Float} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_f32(ix * 4)
  end
end

class Capnp::F64List < Capnp::NumericList
  Elem = type_member { {fixed: Float} }

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_f64(ix * 8)
  end
end
