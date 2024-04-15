#!/usr/bin/env ruby
# typed: strict

require 'pp'
require_relative 'test.capnp'

message = CapnProto::Message.new(CapnProto::Buffer.from_io(STDIN))

root = message.root
exit if root.nil?

decoded = CapnProto::Struct.get_pointer_references(root)
exit if decoded.nil?

person = Test::Person.new(message, decoded[0], decoded[1])
pp person.to_h
