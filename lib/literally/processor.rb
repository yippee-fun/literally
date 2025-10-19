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
				default = "nil"
				type = optional.value.slice
				# binding.irb

				if optional in {
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
				end

				loc = optional.value.location
				@annotations << [loc.start_offset, loc.end_offset - loc.start_offset, default]
				"#{optional.name}: #{type}"
			end.join(", ")
		end

		if (keywords = node.parameters&.keywords)&.any?
			signature << keywords.map do |keyword|
				default = "nil"
				type = keyword.value.slice

				if keyword in {
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
				end

				loc = keyword.value.location
				@annotations << [loc.start_offset, loc.end_offset - loc.start_offset, default]
				"#{keyword.name}: #{type}"
			end.join(", ")
		end

		# TODO 5: handle sigs with splats

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
