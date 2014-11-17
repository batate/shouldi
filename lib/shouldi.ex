defmodule ShouldI do
  @moduledoc """
  ShouldI is a testing DSL around ExUnit.

  ShouldI supports with blocks for nested contexts,
  convenience apis for behavioral naming.

  ## Examples

  ~~~
  defmodule MyFatTest do

    with "necessary_key" do
      setup context do
        assign context,
          necessary_key: :neccessary_value
      end

      should( "have necessary key", context ) do
        assert context.necessary_key == :necessary_value
      end

      with "sometimes_necessary_key" do
        setup context do
          assign context,
            :sometimes_necessary_key, :sometimes_neccessary_value
        end

        # matchers to handle common testing idioms
        should_match_key sometimes_necessary_key: :sometimes_necessary_value
    end
  end
  ~~~

  ShouldI provides support for common idioms through matchers.

  For example, these matchers are for plug:

  ~~~
    should_respond_with :success
    should_match_body_to "<div id="test">
  ~~~

  """

  defmacro __using__(_) do
    quote do
      @shouldi_with_path []

      import ExUnit.Callbacks, except: [setup: 1, setup: 2]
      import ExUnit.Case, except: [test: 2, test: 3]
      import ShouldI
    end
  end

  @doc """
  Sometimes, when running a test concurrently, it's helpful to generate a unique identifier
  so resources don't collide. This macro creates ids, optionally appended


  ## examples
    assert {:ok, _} = join_chatroom(uid("discussion"), Mock.user)

  """
  defmacro uid(id \\ nil) do
    {function, _} = __CALLER__.function
    if String.starts_with?(Atom.to_string(function), "test ") do
      "#{__CALLER__.module}.#{function} #{id}"
    else
      quote do
        "#{var!(context).case}.#{var!(context).test} #{unquote(id)}"
      end
    end
  end

  defmacro test(name, var \\ quote(do: _), opts) do
    ShouldI.With.test(__CALLER__, name, var, opts)
  end

  defmacro setup(var \\ quote(do: _), opts) do
    ShouldI.With.setup(__CALLER__, var, opts)
  end

  @doc """
  Create a test case with an optional context. This macro thinly wraps ExUnit's
  test macro and names the test case with "should".


  ## examples
  should "add two numbers", do: (assert 2 + 2 = 4)
  should "check conext for :key", do: (assert context.key == :value)

  """
  defmacro should(name, var \\ quote(do: _), options) do
    quote do
      test("should #{unquote name}", unquote(var), unquote(options))
    end
  end

  @doc """
  A function for wrapping together common setup code.
  with is useful for nesting setup requirements:

  ## example

  with "a logged in user" do
    setup do
      ... setup a logged in user
    end

    with "a get to :index" do
      setup do
        assign context,
        response: get(:index)
      end

      should_respond_with :success
      should_match_body_to "some_string_to_match"
    end
  end


  """
  defmacro with(context, opts) do
    ShouldI.With.with(__CALLER__, context, opts)
  end

  @doc """
  Shorthand function for assigning context key/value pairs.
  """
  def assign(context, options) do
    Dict.merge(context, options)
  end
end
