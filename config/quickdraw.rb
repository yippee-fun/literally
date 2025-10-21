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

class Runner
	def initialize
		@failures = []
		@errors = []
		@successes = 0
	end

	attr_reader :failures, :successes, :errors

	def failure!(failure)
		@failures << failure
	end

	def success!(description)
		@successes += 1
	end

	def error!(error)
		@errors << error
	end
end

class Quickdraw::Test
	def assert_test(passes: 0, failures: 0, errors: 0, &block)
		runner = Runner.new

		Quickdraw::Test.new(description: nil, skip: false, block:).run(runner)

		assert_equal runner.successes, passes
		assert_equal runner.failures.size, failures
		assert_equal runner.errors.size, errors

		runner
	end
end

Literally.init(include: ["#{Dir.pwd}/**/*"], exclude: ["**/excluded.rb"])
