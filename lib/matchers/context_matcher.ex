defmodule ShouldI.Matchers.Context do
  import ExUnit.Assertions
  @moduledoc """
  Convenience macros for generating short test cases of common strucutre. These matchers work with the context.
  """

  @doc """
  Exactly match a key in the context to a value.

  ## exmaples:
  setup context do
    assign context, key_from_context_returned_by_setup: "exact expected value"
  end

  should_assign_key key_from_context_returned_by_setup: "exact expected value"

  """
  defmacro should_assign_key [{key, value}] do
    quote do
      should "set #{unquote key} to #{unquote value}", context do
        assert context[unquote(key)] == unquote(value)
      end
    end
  end

  @doc """
  Pattern match against context[key]

  ## exmaples:
  ...

  should_match_key context_key: {:ok, _}

  """
  defmacro should_match_key [{key, expected}] do
    quote do
      should "match context[#{unquote key}]  to #{Macro.to_string(unquote(Macro.escape(expected)))}", context do

        assert unquote(expected) = context[unquote(key)]
      end
    end
  end

  @doc """
  Check for existance of a key in the context returned by setup.

  ## exmaples:
  ...

  should_have_key :must_be_present

  """
  defmacro should_have_key key do
    quote do
      should "have key #{unquote key}", context do
        assert Enum.member?( (Dict.keys context), unquote(key))
      end
    end
  end

  @doc """
  Negative check for existance of a key in the context returned by setup.

  ## exmaples:
  ...

  should_not_have_key :must_not_be_present

  """
  defmacro should_not_have_key key do
    quote do
      should "not have key #{unquote key}", context do
        assert !Enum.member?( (Dict.keys context), unquote(key))
      end
    end
  end
end
