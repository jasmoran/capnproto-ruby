#!/usr/bin/env ruby
# typed: strict

require_relative "test.capnp"

begin
  message = CapnProto::Message.from_io(STDIN)
  person = Test::Person.from_pointer(message.root)
  pp person&.to_obj
rescue => e
  warn "#{e.class}: #{e.message}"
  e.backtrace.to_a.reject { |line| line.include?("/gems/sorbet-runtime-") }.each { |line| warn(line) }
end
