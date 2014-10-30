defmodule ShouldI do

  defmacro __using__(_) do
    quote do
      use ExUnit.Case, except: [setup: 1, setup: 2]
      import ExUnit.Callbacks, except: [setup: 1, setup: 2]
      import ShouldI, except: [setup: 1, setup: 2]
      import ShouldI.OuterSetup
    end
  end

  defmacro should(name, options) do
    quote do
      test("should #{unquote name}", unquote(options))
    end
  end

  defmacro should(name, context, options) do
    quote do
      test("should #{unquote name}", unquote(context), unquote(options))
    end
  end

  defmacro setup(context_name, [do: block]) do
    quote do
      ExUnit.Callbacks.setup(context) do
        {:ok, unquote(context_name)} = @calling_module.__ex_unit__(:setup, context)

        { :ok, unquote(block) }
      end
    end
  end

  defmacro setup([do: _block]) do
    quote do
      raise "Calling setup without a context is unsupported"
    end
  end

  defmacro with(description, [do: block]) do

    module = "with #{description}"
          |> String.split(~r"\W")
          |> Enum.map(&String.capitalize/1)
          |> Enum.join
          |> List.wrap
          |> Module.concat

    calling_module = __CALLER__.module

    quote do
      defmodule unquote(module) do
        use ExUnit.Case
        import ExUnit.Callbacks, except: [setup: 1, setup: 2]
        import ShouldI
        import ShouldI.OuterSetup, except: [setup: 1, setup: 2]
        @calling_module unquote( calling_module )
        unquote(block)
      end
    end
  end
  
  defmodule OuterSetup do
    defmacro setup(context_name, [do: block]) do
      quote do
        ExUnit.Callbacks.setup(context) do
          unquote(context_name) = context
          {:ok, unquote(block)}
        end
      end
    end
  end
  
  def assign context, options do
    Dict.merge context, options
  end
end
