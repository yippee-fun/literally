# Literally

Literally is a tiny pre-processor for Ruby that lets you write methods with runtime type checking using [Literal](https://www.literal.fun).

Here, `a` and `b` are typed as `Numeric` and the return type is `Integer`.

```ruby
def add(a: Numeric, b: Numeric) = Integer do
  (a + b).floor
end
```
