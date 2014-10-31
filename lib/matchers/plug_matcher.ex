defmodule ShouldI.Matchers.Plug do
  import ExUnit.Assertions
  @moduledoc """
  Convenience macros for generating short test cases of common strucutre. 
  These matchers work with Plug connections.
  """
  

  @doc """
  The connection status (connection.status) should match the expected result. 
  
  Rather than match a specific value, the matchers work against ranges:
  
  success:       (200...299)
  redirect:      (300...399)
  bad_request:   400
  unauthorized:  401
  missing:       404
  error:         (500..599)

  ## exmaples: 
  
  setup context do
    some_plug_call_returning_a_context_having_a_connection_key
  end
    
  should_respond_with :success
    
  """
  defmacro should_respond_with expected_result do
    quote do
      should "respond_with #{unquote(expected_result)}", context do
        plug_should_respond_with unquote(expected_result), context
      end
    end
  end
  
  def plug_should_respond_with( :success, context ) do
    assert Enum.member?( Enum.to_list(200..299), context.connection.status )
  end
  
  def plug_should_respond_with( :redirect, context ) do
    assert Enum.member?( Enum.to_list(300..399), context.connection.status )
  end
  
  def plug_should_respond_with( :bad_request, context ) do
    assert context.connection.status == 400
  end
  
  def plug_should_respond_with( :unauthorized, context ) do
    assert context.connection.status == 401
  end
  
  def plug_should_respond_with( :missing, context ) do
    assert context.connection.status == 404
  end
  
  def plug_should_respond_with( :error, context ) do
    assert Enum.member?( Enum.to_list(500..599), context.connection.status )
  end
  
  @doc """
  The connection body (connection.resp_body) should match the expected result. 
  
  setup context do
    some_plug_call_returning_a_context_having_a_connection_key
  end
    
  should_match_body_to "this_string_must_be_present_in_body"  
    
  """
  defmacro should_match_body_to expected do
    quote do
      should "match body to #{unquote(expected)}", context do
        assert context.connection.resp_body =~ ~r"#{unquote(expected)}"
      end
    end
  end
end
