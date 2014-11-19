defmodule ShouldI.Matcher do
  defmacro defmatcher(func, block) do
    quote do
      defmacro unquote(func) do
        ShouldI.Matcher.register(unquote(Macro.escape(func)), unquote(block))
      end
    end
  end

  def register(call, quote) do
    quote do
      matcher = {unquote(Macro.escape(call)), unquote(Macro.escape(quote))}
      @shouldi_matchers [matcher|@shouldi_matchers]
    end
  end
end
