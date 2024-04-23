# typed: strict

require 'sorbet-runtime'
require_relative 'list'

module CapnProto::String
  extend T::Sig
  extend T::Helpers

  interface!

  sig { abstract.returns(String) }
  def to_s; end
end

class CapnProto::BufferString < CapnProto::BufferList
  include CapnProto::String

  Elem = type_member {{fixed: String}}

  sig { override.returns(String) }
  def to_s = @data.read_string(0, @length - 1, Encoding::UTF_8)

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix)
    @data.read_string(ix, 1, Encoding::UTF_8)
  end
end
