# frozen_string_literal: true

class Literally::Processor < Literally::BaseProcessor
	#: (Prism::DefNode) -> void
	def visit_def_node(node)
		return super unless node.equal_loc
		return super unless node in {
			body: {
				body: [
					Prism::CallNode[
						block: Prism::BlockNode[
							body: Prism::StatementsNode
						] => block
					] => call
				]
			}
		}

		if node.parameters&.requireds&.any?
			raise "Don’t use requireds!"
		elsif node.parameters&.rest&.any?
			raise "Don’t use rests!"
		elsif node.parameters&.posts&.any?
			raise "Don’t use posts, whatever they are."
		elsif node.parameters&.keyword_rest&.any?
			raise "Don’t use keyword rest."
		end

		signature = []

		if (optionals = node.parameters&.optionals)&.any?
			signature << optionals.map do |optional|
				case optional
				# Splat
				in { value: Prism::ArrayNode[elements: [type_node]] => value }
					if type_node in Prism::SplatNode
						type = type_node.expression.slice
					else
						type = "::Literal::_Array(#{type_node.slice})"
					end

					# Make the parameter a splat
					@annotations << [optional.name_loc.start_offset, 0, "*"]

					# Remove the type signature (the default value)
					@annotations << [optional.operator_loc.start_offset, value.closing_loc.end_offset - optional.operator_loc.start_offset, ""]
					next "#{optional.name}: #{type}"
				# With default
				in {
					value: Prism::CallNode[
						block: Prism::BlockNode[
							body: Prism::StatementsNode => default_node
						]
					] => call
				}
					default = "(#{default_node.slice})"

					type = if call.closing_loc
						node.slice[(call.start_offset)...(call.closing_loc.end_offset)]
					else
						call.name
					end
				# No default
				else
					default = "nil"
					type = optional.value.slice
				end

				value_location = optional.value.location
				@annotations << [value_location.start_offset, value_location.end_offset - value_location.start_offset, default]
				"#{optional.name}: #{type}"
			end.join(", ")
		end

		if (keywords = node.parameters&.keywords)&.any?
			signature << keywords.map do |keyword|
binding.irb
				case keyword
				# Splat
				in { value: Prism::HashNode[elements: [Prism::AssocNode[key: key_type_node, value: val_type_node]]] => value }
					type = "::Literal::_Hash(#{key_type_node.slice}, #{val_type_node.slice})"

					# Make the parameter a splat
					@annotations << [keyword.name_loc.start_offset, 0, "**"]

					# Remove the type signature (the default value) and the colon at the end of the keyword
					@annotations << [keyword.name_loc.end_offset - 1, value.closing_loc.end_offset - keyword.name_loc.end_offset + 1, ""]
					next "#{keyword.name}: #{type}"
				in { value: Prism::HashNode[elements: [Prism::AssocSplatNode[value: val_type_node]]] => value }
					type = val_type_node.slice

					# Make the parameter a splat
					@annotations << [keyword.name_loc.start_offset, 0, "**"]

					# Remove the type signature (the default value) and the colon at the end of the keyword
					@annotations << [keyword.name_loc.end_offset - 1, value.closing_loc.end_offset - keyword.name_loc.end_offset + 1, ""]
					next "#{keyword.name}: #{type}"
				# With default
				in {
					value: Prism::CallNode[
						block: Prism::BlockNode[
							body: Prism::StatementsNode => default_node
						]
					] => call
				}
					default = "(#{default_node.slice})"

					type = if call.closing_loc
						node.slice[(call.start_offset)...(call.closing_loc.end_offset)]
					else
						call.name
					end
				# No default
				else
					default = "nil"
					type = keyword.value.slice
				end

				value_location = keyword.value.location
				@annotations << [value_location.start_offset, value_location.end_offset - value_location.start_offset, default]
				"#{keyword.name}: #{type}"
			end.join(", ")
		end

		if node.rparen_loc
			@annotations << [
				start = node.rparen_loc.start_offset + 1,
				block.opening_loc.end_offset - start,
				";binding.assert(#{signature.join(", ")});__literally_returns__ = (;",
			]
		else
			@annotations << [
				start = node.equal_loc.start_offset - 1,
				block.opening_loc.end_offset - start,
				";__literally_returns__ = (;",
			]
		end

		return_type = if call.closing_loc
			node.slice[(call.start_offset)...(call.closing_loc.end_offset)]
		else
			call.name
		end
		@annotations << [
			block.closing_loc.start_offset,
			0,
			";);binding.assert(__literally_returns__: #{return_type});__literally_returns__;",
		]

		@annotations << [
			start = block.closing_loc.start_offset,
			block.closing_loc.end_offset - start,
			"end",
		]
	end
end
