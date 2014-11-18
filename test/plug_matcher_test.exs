defmodule PlugMatcherTest do
  use ExUnit.Case
  use ShouldI
  import ShouldI.Matchers.Plug

  setup context do
    Map.put(context, :connection, %{
      status: 200,
      resp_body: "<p>test</p>"
     })
  end

  should_respond_with :success
  should_match_body_to "test"
end
