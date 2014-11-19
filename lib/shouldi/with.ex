defmodule ShouldI.With do
  @moduledoc false

  def with(_env, context, [do: block]) do
    quote1 =
      quote do
        import ExUnit.Callbacks, except: [setup: 1, setup: 2]
        import ExUnit.Case, except: [test: 2, test: 3]
        import ShouldI, except: [setup: 1, setup: 2]
        import ShouldI.With

        @shouldi_matchers []
        path = @shouldi_with_path
        @shouldi_with_path [unquote(context)|path]

        unquote(block)
      end

    quote2 =
      quote unquote: false do
        matchers = @shouldi_matchers
                |> Enum.reverse
                |> prepare_matchers

        if matchers != [] do
          @tag shouldi_with_path: @shouldi_with_path
          ExUnit.Case.test test_name(__MODULE__, "matchers"), var!(context) do
            _ = var!(context)
            matcher_errors = unquote(matchers)
            matcher_errors = Enum.reject(matcher_errors, &is_nil/1)

            if matcher_errors != [] do
              raise ShouldI.MultiError, errors: matcher_errors
            end
          end
        end

        @shouldi_with_path path
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
      @tag shouldi_with_path: @shouldi_with_path
      ExUnit.Case.test(test_name(__MODULE__, unquote(name)), unquote(var), unquote(opts))
    end
  end

  defmacro setup(var \\ quote(do: _), [do: block]) do
    if_quote =
      quote unquote: false do
        starts_with?(unquote(shouldi_with_path), shouldi_path)
      end

    quote do
      shouldi_with_path = Enum.reverse(@shouldi_with_path)
      ExUnit.Callbacks.setup unquote(var) do
        shouldi_path = Enum.reverse(unquote(var)[:shouldi_with_path] || [])

        if unquote(if_quote) do
          {:ok, unquote(block)}
        else
          :ok
        end
      end
    end
  end

  def test_name(module, name) do
    path = Module.get_attribute(module, :shouldi_with_path)
    "with: " <> path_to_name(path) <> ": " <> name
  end

  defp path_to_name(path) do
    Enum.join(path, ", ")
  end

  def starts_with?([], _),
    do: true

  def starts_with?([elem|left], [elem|right]),
    do: starts_with?(left, right)

  def starts_with?(_, _),
    do: false

  def prepare_matchers(matchers) do
    Enum.map(matchers, fn {call, code} ->
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
