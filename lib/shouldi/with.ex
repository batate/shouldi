defmodule ShouldI.With do
  @moduledoc false

  def with(_env, context, [do: block]) do
    quote do
      @shouldi_with_setup nil
      path = @shouldi_with_path
      @shouldi_with_path [unquote(context)|path]

      unquote(block)

      # TODO: Collect should macros and generate test

      unless @shouldi_with_setup do
        setup do
        end
      end

      @shouldi_with_path path
    end
  end

  def setup(_env, _var, _block) do
    # TODO: call parent setup
    quote do
      @shouldi_with_setup true
      # TODO: ...
    end
  end

  def test(_env, _name, _var, _block) do
    # TODO: call current setup
    # TODO: ...
  end

  def parent_setup_name(env) do
    path = Module.get_attribute(env.module, :shouldi_with_path)

    if path == [] do
      nil
    else
      "setup " <> path_to_name(tl(path))
    end
  end

  def current_setup_name(env) do
    path = Module.get_attribute(env.module, :shouldi_with_path)
    "setup " <> path_to_name(path)
  end

  def test_name(env, name) do
    path = Module.get_attribute(env.module, :shouldi_with_path)
    path_to_name(path) <> " " <> name
  end

  defp path_to_name(path) do
    Enum.join(path, ", ")
  end
end
