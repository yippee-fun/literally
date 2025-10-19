test "return type, keyword arg with default processes" do
	processed = Literally::Processor.call(<<~'RUBY')
		def say_hello(foo, name: String {"World"}) = String do
			"Hello #{name}!"
		end
	RUBY

	assert_equal_ruby(processed, <<~'RUBY')
		def say_hello(name: "World");binding.assert(name: String);__literally_returns__ = (;
			"Hello #{name}!"
		;);binding.assert(__literally_returns__: String);__literally_returns__;end
	RUBY
end
