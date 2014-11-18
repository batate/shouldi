defmodule ShouldI.Matcher do
  defmacro defmatcher({name, _, _} = func, block) do
    quote do
      defmacro unquote(func) do
        ShouldI.Matcher.register(unquote(name), __CALLER__.module, unquote(block))
      end
    end
  end

  def register(name, module, quote) do
    matcher = {name, quote}
    matchers = Module.get_attribute(module, :shouldi_matchers)
    Module.put_attribute(module, :shouldi_matchers, [matcher|matchers])
  end
end
