# frozen_string_literal: true

require "set"
require "prism"
require "securerandom"

require "literally/version"
require "literally/base_processor"
require "literally/processor"
require "literally/configuration"

require "require-hooks/setup"

module Literally
	EMPTY_ARRAY = [].freeze
	EVERYTHING = ["**/*"].freeze
	METHOD_METHOD = Module.instance_method(:method)

	CONFIG = Configuration.new

	TypedSignatureError = Class.new(StandardError)

	# Initializes Literally so that code loaded after this point will be
	# guarded against undefined instance variable reads. You can pass an array
	# of globs to `include:` and `exclude:`.
	#
	# ```ruby
	# Literally.init(
	#   include: ["#{Dir.pwd}/**/*"],
	#   exclude: ["#{Dir.pwd}/vendor/**/*"]
	# )
	# ```
	#: (include: Array[String], exclude: Array[String]) -> void
	def self.init(include: EMPTY_ARRAY, exclude: EMPTY_ARRAY)
		CONFIG.include(*include)
		CONFIG.exclude(*exclude)

		RequireHooks.source_transform(
			patterns: EVERYTHING,
			exclude_patterns: EMPTY_ARRAY
		) do |path, source|
			source ||= File.read(path)

			if CONFIG.match?(path)
				Processor.call(source)
			else
				BaseProcessor.call(source)
			end
		end
	end
end
