defmodule ShouldI do
  @moduledoc """
  ShouldI is a testing DSL around ExUnit.

  ShouldI supports having blocks for nested contexts,
  convenience apis for behavioral naming.

  ## Examples

      defmodule MyFatTest do

        having "necessary_key" do
          setup context do
            assign context,
              necessary_key: :necessary_value
          end

          should( "have necessary key", context ) do
            assert context.necessary_key == :necessary_value
          end

          having "sometimes_necessary_key" do
            setup context do
              assign context,
                :sometimes_necessary_key, :sometimes_necessary_value
            end

            # matchers to handle common testing idioms
            should_match_key sometimes_necessary_key: :sometimes_necessary_value
          end
        end
      end

  ShouldI provides support for common idioms through matchers.

  For example, these matchers are for plug:

      should_respond_having :success
      should_match_body_to "<div id="test">
  """

  defmacro __using__(args) do
    definition =
      quote do
        @shouldi_having_path []
        @shouldi_matchers []

        use ExUnit.Case, unquote(args)
        import ShouldI
        import ExUnit.Callbacks, except: [setup: 1, setup: 2]
      end

    helpers =
      quote unquote: false do
        # Store common code in a function definition to
        # avoid injecting many variables into a context.
        var!(define_matchers, ShouldI) = fn ->
          matchers = @shouldi_matchers
                  |> Enum.reverse
                  |> ShouldI.Having.prepare_matchers

          if matchers != [] do
            @tag shouldi_having_path: Enum.reverse(@shouldi_having_path)
            ExUnit.Case.test ShouldI.Having.test_name(__MODULE__, "should have passing matchers"), var!(context) do
              _ = var!(context)
              matcher_errors = unquote(matchers)
              matcher_errors = Enum.reject(matcher_errors, &is_nil/1)

              if matcher_errors != [] do
                raise ShouldI.MultiError, errors: matcher_errors
              end
            end
          end
        end
      end

    [definition, helpers]
  end

  defmacro setup(var \\ quote(do: _), [do: block]) do
    quote do
      ExUnit.Callbacks.setup unquote(var) do
        case unquote(block) do
          :ok -> :ok
          {:ok, list} -> {:ok, list}
          map -> {:ok, map}
        end
      end
    end
  end

  @doc """
  Sometimes, when running a test concurrently, it's helpful to generate a unique identifier
  so resources don't collide. This macro creates ids, optionally appended

  ## Examples

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

  @doc """
  Create a test case having an optional context. This macro thinly wraps ExUnit's
  test macro and names the test case having "should".

  ## Examples
      should "add two numbers", do: (assert 2 + 2 = 4)
      should "check context for :key", do: (assert context.key == :value)

  """
  defmacro should(name, var \\ quote(do: _), options) do
    quote do
      test("should #{unquote name}", unquote(var), unquote(options))
    end
  end

  @doc """
  A function for wrapping together common setup code.
  having is useful for nesting setup requirements:

  ## Examples

      having "a logged in user" do
        setup do
          ... setup a logged in user
        end

        having "a get to :index" do
          setup do
            assign context,
            response: get(:index)
          end

          should_respond_having :success
          should_match_body_to "some_string_to_match"
        end
      end
  """
  defmacro having(context, opts) do
    ShouldI.Having.having(__CALLER__, context, opts)
  end

  @doc """
  Shorthand function for assigning context key/value pairs.
  """
  def assign(context, options) do
    Dict.merge(context, options)
  end
end

defmodule ShouldI.MultiError do
  defexception [:errors]

  def message(_) do
    "multiple matcher errors"
  end
end
