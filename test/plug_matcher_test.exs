defmodule PlugMatcherTest do
  use ShouldI
  import ShouldI.Matchers.Plug

  setup context do
    Map.put(context, :connection, %{
      status: 200,
      resp_body: "<p>test</p>"
     })
  end

  having "context" do
    should_respond_with :success
    should_match_body_to "test"
    should_match_body_to ~r/test/
    should_match_body_to [~r/TEST/i, "test"]
  end
end
