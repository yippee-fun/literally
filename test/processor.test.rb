# frozen_string_literal: true

test "basic" do
	processed = Literally::Processor.call(<<~RUBY)
		def foo(a: Integer, b: String) = Numeric do
			a
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo(a: nil, b: nil);binding.assert(a: Integer, b: String);__literally_returns__ = (;
			a
		;);binding.assert(__literally_returns__: Numeric);__literally_returns__;end
	RUBY
end

test "no args" do
	processed = Literally::Processor.call(<<~RUBY)
		def foo = Numeric do
			a
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo;__literally_returns__ = (;
			a
		;);binding.assert(__literally_returns__: Numeric);__literally_returns__;end
	RUBY
end

test "no parens" do
	processed = Literally::Processor.call(<<~RUBY)
		def foo a: Integer, b: String = Numeric do
			a
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo(a: nil, b: nil);binding.assert(a: Integer, b: String);__literally_returns__ = (;
			a
		;);binding.assert(__literally_returns__: Numeric);__literally_returns__;end
	RUBY
end

test "with generic return type" do
	processed = Literally::Processor.call(<<~RUBY)
		def foo(a: Integer, b: String) = _String(length: 10) do
			a
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo(a: nil, b: nil);binding.assert(a: Integer, b: String);__literally_returns__ = (;
			a
		;);binding.assert(__literally_returns__: _String(length: 10));__literally_returns__;end
	RUBY
end

test "with generic input types" do
	processed = Literally::Processor.call(<<~RUBY)
		def foo(a: _Integer(1..), b: String(length: 10)) = String do
			a
		end
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo(a: nil, b: nil);binding.assert(a: _Integer(1..), b: String(length: 10));__literally_returns__ = (;
			a
		;);binding.assert(__literally_returns__: String);__literally_returns__;end
	RUBY
end

test "brace block" do
	processed = Literally::Processor.call(<<~RUBY)
		def foo(a: Integer, b: String) = Numeric {
			a
		}
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo(a: nil, b: nil);binding.assert(a: Integer, b: String);__literally_returns__ = (;
			a
		;);binding.assert(__literally_returns__: Numeric);__literally_returns__;end
	RUBY
end

test "positionals" do
	processed = Literally::Processor.call(<<~RUBY)
		def foo(a = Integer, b = String) = Numeric {
			a
		}
	RUBY

	assert_equal_ruby processed, <<~RUBY
		def foo(a = nil, b = nil);binding.assert(a: Integer, b: String);__literally_returns__ = (;
			a
		;);binding.assert(__literally_returns__: Numeric);__literally_returns__;end
	RUBY
end
