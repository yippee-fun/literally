# frozen_string_literal: true

if ENV["COVERAGE"] == "true"
	require "simplecov"

	SimpleCov.start do
		command_name "quickdraw"
		enable_coverage_for_eval
		enable_for_subprocesses true
		enable_coverage :branch
	end
end

Bundler.require :test

require "literally"

Literally.init(include: ["#{Dir.pwd}/**/*"], exclude: ["**/excluded.rb"])
