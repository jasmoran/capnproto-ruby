# typed: false
# frozen_string_literal: true

require_relative "lib/capnp/version"

Gem::Specification.new do |spec|
  spec.name = "capnp"
  spec.version = Capnp::VERSION
  spec.authors = ["Jack Moran"]
  spec.email = ["jack@earth.co.nz"]

  spec.summary = "Ruby support for the Cap'n Proto data interchange format"
  spec.homepage = "https://github.com/jasmoran/capnproto-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/jasmoran/capnproto-ruby/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0")
      .select { |f| f.start_with?("lib/", "bin/capnpc-ruby") }
      .reject { |f| f.end_with?(".capnp") }
  end

  spec.executables = spec.files.select { |f| f.start_with?("bin/") }.map { |f| File.basename(f) }

  spec.require_paths = ["lib"]

  spec.add_dependency "sorbet-runtime"

  spec.add_development_dependency "sorbet"
  spec.add_development_dependency "tapioca"
  spec.add_development_dependency "ruby-lsp"
  spec.add_development_dependency "minitest", "~> 5.22"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "standard", "~> 1.3"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-lcov", "~> 0.8.0"
end
