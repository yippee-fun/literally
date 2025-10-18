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
			foo = keywords.map do |keyword|
				loc = keyword.value.location
				@annotations << [loc.start_offset, loc.end_offset - loc.start_offset, "nil"]
				"#{keyword.name}: #{keyword.value.slice}"
			end.join(", ")
		end

		@annotations << [
			start = node.rparen_loc.start_offset + 1,
			block.opening_loc.end_offset - start,
			";binding.assert(#{foo});__literally_returns__ = (;"
		]

		@annotations << [
			block.closing_loc.start_offset,
			0,
			";);binding.assert(__literally_returns__: #{call.name});__literally_returns__;"
		]
	end
end
