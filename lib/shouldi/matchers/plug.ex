defmodule ShouldI.Matchers.Plug do
  @moduledoc """
  Convenience macros for generating short test cases of common structure.
  These matchers work with Plug connections.
  """

  import ExUnit.Assertions
  import ShouldI.Matcher

  @doc """
  The connection status (connection.status) should match the expected result.

  Rather than match a specific value, the matchers work against ranges:

  success:       (200...299)
  redirect:      (300...399)
  bad_request:   400
  unauthorized:  401
  missing:       404
  error:         (500..599)

  ## Examples

      setup context do
        some_plug_call_returning_a_context_having_a_connection_key
      end

      should_respond_with :success
  """
  defmatcher should_respond_with(expected_result) do
    quote do
      plug_should_respond_with(unquote(expected_result), context)
    end
  end

  def plug_should_respond_with( :success, context ) do
    assert context.connection.status in 200..299
  end

  def plug_should_respond_with( :redirect, context ) do
    assert context.connection.status in 300..399
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
    assert context.connection.status in 500..599
  end

  @doc """
  The connection body (`connection.resp_body`) should match the expected result.

      setup context do
        some_plug_call_returning_a_context_having_a_connection_key
      end

      should_match_body_to "this_string_must_be_present_in_body"

  """
  defmatcher should_match_body_to(expected) do
    quote do
      assert context.connection.resp_body =~ ~r"#{unquote(expected)}"
    end
  end
end
