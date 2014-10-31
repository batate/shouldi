defmodule ShouldI.Matchers.Context do
  import ExUnit.Assertions
  
  defmacro should_assign_key [{key, value}|_] do
    quote do
      should "should set #{unquote key} to #{unquote value}", context do
        assert context[unquote(key)] == unquote(value)
      end
    end
  end

  defmacro should_match_key [{key, expected}|_] do
    quote do
      should "should match context[#{unquote key}]  to #{Macro.to_string(unquote(Macro.escape(expected)))}", context do
        
        assert unquote(expected) = context[unquote(key)] 
      end
    end
  end

  defmacro should_have_key key do
    quote do
      should "should have key #{unquote key}", context do
        assert Enum.member?( (Dict.keys context), unquote(key))
      end
    end
  end
  
  defmacro should_not_have_key key do
    quote do
      should "should not have key #{unquote key}", context do
        assert !Enum.member?( (Dict.keys context), unquote(key))
      end
    end
  end
  
end
