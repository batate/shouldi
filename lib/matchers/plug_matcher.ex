defmodule ShouldI.Matchers.Plug do
  import ExUnit.Assertions
  
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
  
  defmacro should_match_body_to expected do
    quote do
      should "match body to #{unquote(expected)}", context do
        assert context.connection.resp_body =~ ~r"#{unquote(expected)}"
      end
    end
  end
end
