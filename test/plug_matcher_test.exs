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

  with "context" do
    should_respond_with :success
    should_match_body_to "test"
  end

  with "JSON response" do
    setup context do
      Map.put(context, :connection, %{
        status: 200,
        resp_body: ~s({"test":1})
      })
    end

    should_return_json_of %{ "test" => 1 }
  end
end
