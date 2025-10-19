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

		if (keywords = node.parameters&.keywords)
			signature = keywords.map do |keyword|
				loc = keyword.value.location
				@annotations << [loc.start_offset, loc.end_offset - loc.start_offset, "nil"]
				"#{keyword.name}: #{keyword.value.slice}"
			end.join(", ")
		end

		if node.rparen_loc
			@annotations << [
				start = node.rparen_loc.start_offset + 1,
				block.opening_loc.end_offset - start,
				";binding.assert(#{signature});__literally_returns__ = (;",
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
	end
end
