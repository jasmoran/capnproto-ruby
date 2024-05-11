# typed: strong
# frozen_string_literal: true

require "capnproto"
require "minitest/autorun"

module Minitest
  class Spec
    module DSL
      alias_method :context, :describe
    end
  end
end
