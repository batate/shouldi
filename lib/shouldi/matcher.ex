defmodule ShouldI.Matcher do
  defmacro defmatcher(func, block) do
    quote do
      defmacro unquote(func) do
        meta = [line: __CALLER__.line]
        ShouldI.Matcher.register(unquote(Macro.escape(func)), meta, unquote(block))
      end
    end
  end

  def register(call, meta, quote) do
    quote do
      matcher = {unquote(Macro.escape(call)), unquote(meta), unquote(Macro.escape(quote))}
      @shouldi_matchers [matcher|@shouldi_matchers]
    end
  end
end
