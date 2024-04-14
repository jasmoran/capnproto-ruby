#!/usr/bin/env ruby
# typed: strict

require 'pp'
require_relative 'test.capnp'

IO::Buffer.for(STDIN.read) do |buffer|
  message = CapnProto::Message.new(buffer)

  root = message.root
  exit if root.nil?

  sp = Test::Person.new(root, 0)
  pp sp.to_h
end
