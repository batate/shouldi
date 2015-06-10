defmodule ShouldI.With do
  @moduledoc false

  def with(_env, context, [do: block]) do
    quote1 =
      quote do
        import ExUnit.Callbacks, except: [setup: 1, setup: 2]
        import ExUnit.Case, except: [test: 2, test: 3]
        import ShouldI, except: [setup: 1, setup: 2]
        import ShouldI.With

        matchers = @shouldi_matchers
        path     = @shouldi_with_path
        @shouldi_with_path [unquote(context)|path]
        @shouldi_matchers  []

        unquote(block)
      end

    quote2 =
      quote unquote: false do
        var!(define_matchers, ShouldI).()
        @shouldi_with_path path
        @shouldi_matchers Macro.escape(matchers)
      end

    quote do
      # Do not leak imports
      try do
        unquote(quote1)
        unquote(quote2)
      after
        :ok
      end
    end
  end

  defmacro test(name, var \\ quote(do: _), opts) do
    quote do
      @tag shouldi_with_path: Enum.reverse(@shouldi_with_path)
      ExUnit.Case.test(test_name(__MODULE__, unquote(name)), unquote(var), unquote(opts))
    end
  end

  defmacro setup(var \\ quote(do: _), [do: block]) do
    quote do
      var!(define_setup, ShouldI).(unquote(Macro.escape(var)), unquote(Macro.escape(block)))
    end
  end

  def test_name(module, name) do
    path = Module.get_attribute(module, :shouldi_with_path)
    "with '" <> path_to_name(path) <> "': " <> name
  end

  defp path_to_name(path) do
    Enum.reverse(path)
    |> Enum.join(" AND ")
  end

  def starts_with?([], _),
    do: true

  def starts_with?([elem|left], [elem|right]),
    do: starts_with?(left, right)

  def starts_with?(_, _),
    do: false

  def prepare_matchers(matchers) do
    Enum.map(matchers, fn {call, meta, code} ->
      code = Macro.prewalk(code, fn ast ->
        Macro.update_meta(ast, &Keyword.merge(&1, meta))
      end)

      quote do
        try do
          unquote(code)
          nil
        catch
          kind, error ->
            stacktrace = System.stacktrace
            {unquote(Macro.escape(call)), {kind, error, stacktrace}}
        end
      end
    end)
  end
end
