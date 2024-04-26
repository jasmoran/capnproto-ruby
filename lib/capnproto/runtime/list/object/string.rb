# typed: strict

require 'sorbet-runtime'
require_relative '../string'

class CapnProto::ObjectString
  include CapnProto::String
  extend T::Sig
  extend T::Generic

  Elem = type_member {{fixed: String}}

  sig { params(string: String).void }
  def initialize(string)
    @string = T.let(string.freeze, String)
  end

  sig { override.returns(String) }
  def to_s = @string

  sig { override.params(ix: Integer).returns(Elem) }
  private def get(ix) = T.must(@string[ix])

  sig { override.returns(Integer) }
  def length = @string.length
end
