# frozen_string_literal: true

class Literally::BaseProcessor < Prism::Visitor
	EVAL_METHODS = Set[:class_eval, :module_eval, :instance_eval, :eval].freeze

	#: (String) -> String
	def self.call(source)
		visitor = new
		visitor.visit(Prism.parse(source).value)
		buffer = source.dup
		annotations = visitor.annotations
		annotations.sort_by!(&:first)

		annotations.reverse_each do |offset, length, string|
			buffer[offset, length] = string
		end

		buffer
	end

	def initialize
		@annotations = []
	end

	#: Array[[Integer, String]]
	attr_reader :annotations
end
