# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"
require_relative "capnproto/version"
require_relative "capnproto/runtime"

module CapnProto
  extend T::Sig

  WORD_SIZE = 8

  class Error < StandardError; end
end
