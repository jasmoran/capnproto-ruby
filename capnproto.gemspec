# typed: false
# frozen_string_literal: true

require_relative "lib/capnproto"

Gem::Specification.new do |spec|
  spec.name = "capnproto"
  spec.version = CapnProto::VERSION
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

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sorbet-runtime"

  spec.add_development_dependency "sorbet"
  spec.add_development_dependency "tapioca"
  spec.add_development_dependency "ruby-lsp"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "standard", "~> 1.3"
end
