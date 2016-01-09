defmodule ExUnit.Callbacks do
  @moduledoc ~S"""
  Define ExUnit Callbacks from Official ExUnit based on Elixir 1.2.0.
  To use `on_eixt` callback, should define `__merge__` as the following.

  ```
  def __merge__(_mod, context, {:ok, :ok}) do
    {:ok, context}
  end
  ```

  """

  @doc false
  defmacro __using__(_) do
    quote do
      @ex_unit_setup []
      @ex_unit_setup_all []

      @before_compile unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    [compile_callbacks(env, :setup),
     compile_callbacks(env, :setup_all)]
  end

  @doc """
  Defines a callback to be run before each test in a case.
  """
  defmacro setup(var \\ quote(do: _), block) do
    quote bind_quoted: [var: escape(var), block: escape(block)] do
      name = :"__ex_unit_setup_#{length(@ex_unit_setup)}"
      defp unquote(name)(unquote(var)), unquote(block)
      @ex_unit_setup [name|@ex_unit_setup]
    end
  end

  @doc """
  Defines a callback to be run before all tests in a case.
  """
  defmacro setup_all(var \\ quote(do: _), block) do
    quote bind_quoted: [var: escape(var), block: escape(block)] do
      name = :"__ex_unit_setup_all_#{length(@ex_unit_setup_all)}"
      defp unquote(name)(unquote(var)), unquote(block)
      @ex_unit_setup_all [name|@ex_unit_setup_all]
    end
  end

  @doc """
  Defines a callback that runs on the test (or test case) exit.
  An `on_exit` callback is a function that receives no arguments and
  runs in a separate process than the caller.
  `on_exit/2` is usually called from `setup` and `setup_all` callbacks,
  often to undo the action performed during `setup`. However, `on_exit`
  may also be called dynamically, where a reference can be used to
  guarantee the callback will be invoked only once.
  """
  @spec on_exit(term, (() -> term)) :: :ok
  def on_exit(ref \\ make_ref, callback) do
    case ExUnit.OnExitHandler.add(self, ref, callback) do
      :ok -> :ok
      :error ->
        raise ArgumentError, "on_exit/1 callback can only be invoked from the test process"
    end
  end

  ## Helpers

  @doc false
  def __merge__(_mod, context, :ok) do
    {:ok, context}
  end

  def __merge__(_mod, context, {:ok, :ok}) do
    {:ok, context}
  end

  def __merge__(mod, context, {:ok, data}) do
    {:ok, context_merge(mod, context, data)}
  end

  def __merge__(mod, _, data) do
    raise_merge_failed!(mod, data)
  end

  defp context_merge(mod, _context, %{__struct__: _} = data) do
    raise_merge_failed!(mod, data)
  end

  defp context_merge(_mod, context, %{} = data) do
    Map.merge(context, data)
  end

  defp context_merge(_mod, context, data) when is_list(data) do
    Enum.into(data, context)
  end

  defp context_merge(mod, _context, data) do
    raise_merge_failed!(mod, data)
  end

  defp raise_merge_failed!(mod, data) do
    raise "expected ExUnit callback in #{inspect mod} to return :ok " <>
          " or {:ok, keyword | map}, got #{inspect data} instead"
  end

  defp escape(contents) do
    Macro.escape(contents, unquote: true)
  end

  defp compile_callbacks(env, kind) do
    callbacks = Module.get_attribute(env.module, :"ex_unit_#{kind}") |> Enum.reverse

    acc =
      case callbacks do
        [] ->
          quote do: {:ok, context}
        [h|t] ->
          Enum.reduce t, compile_merge(h), fn(callback, acc) ->
            quote do
              {:ok, context} = unquote(acc)
              unquote(compile_merge(callback))
            end
          end
      end

    quote do
      def __ex_unit__(unquote(kind), context), do: unquote(acc)
    end
  end

  defp compile_merge(callback) do
    quote do
      unquote(__MODULE__).__merge__(__MODULE__, context, unquote(callback)(context))
    end
  end
end
