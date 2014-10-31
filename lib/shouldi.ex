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
      use ExUnit.Case, except: [setup: 1, setup: 2]
      import ExUnit.Callbacks, except: [setup: 1, setup: 2]
      import ShouldI, except: [setup: 1, setup: 2]
      import ShouldI.OuterSetup
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

  @doc """
  Create a test case. This macro thinly wraps ExUnit's test macro
  and names the test case with "should". 
  
  
  ## examples 
  should "add two numbers", do: (assert 2 + 2 = 4)
    
  """
  defmacro should(name, options) do
    quote do
      test("should #{unquote name}", unquote(options))
    end
  end

  
  @doc """
  Create a test case with context. This macro thinly wraps ExUnit's test macro
  and names the test case with "should". 
  
  
  ## examples 
  should "check conext for :key", do: (assert context.key == :value)
    
  """
  defmacro should(name, context, options) do
    quote do
      test("should #{unquote name}", unquote(context), unquote(options))
    end
  end

  @doc """
  Wrap ExUnit's setup macro, but allow nesting. Setups will be chained
  with the outer most modules running first. 
  
    
  """
  defmacro setup(context_name, [do: block]) do
    quote do
      ExUnit.Callbacks.setup(context) do
        {:ok, unquote(context_name)} = @calling_module.__ex_unit__(:setup, context)

        { :ok, unquote(block) }
      end
    end
  end

  @doc """
  Wrap ExUnit's setup macro, without context.
  
    
  """
  defmacro setup([do: _block]) do
    quote do
      raise "Calling setup without a context is unsupported"
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
  defmacro with(description, [do: block]) do

    this_module = "with #{description}"
               |> String.split(~r"\W")
               |> Enum.map(&String.capitalize/1)
               |> Enum.join

    calling_module = __CALLER__.module
    module = Module.concat(calling_module, this_module)

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
  
  @doc """
  Shorthand function for assigning context key/value pairs. 
  """
  def assign context, options do
    Dict.merge context, options
  end
end
