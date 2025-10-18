# frozen_string_literal: true

require_relative "lib/literally/version"

Gem::Specification.new do |spec|
	spec.name = "literally"
	spec.version = Literally::VERSION
	spec.authors = ["Joel Drapper"]
	spec.email = ["joel@drapper.me"]

	spec.summary = "Literally type check your methods"
	spec.description = "A tiny pre-processor for ruby that adds runtime type checking to methods."
	spec.homepage = "https://github.com/yippee-fun/literally"
	spec.license = "MIT"
	spec.required_ruby_version = ">= 3.1"

	spec.metadata["homepage_uri"] = spec.homepage
	spec.metadata["source_code_uri"] = "https://github.com/yippee-fun/literally"
	spec.metadata["funding_uri"] = "https://github.com/sponsors/joeldrapper"

	spec.files = Dir[
		"README.md",
		"LICENSE.txt",
		"lib/**/*.rb"
	]

	spec.require_paths = ["lib"]

	spec.metadata["rubygems_mfa_required"] = "true"

	spec.add_dependency "require-hooks", "~> 0.2"
	spec.add_dependency "prism"
	spec.add_dependency "literal"
end
