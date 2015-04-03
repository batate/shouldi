defmodule ShouldTest do
  use ShouldI

  setup context do
    Map.put(context, :setup, :outer)
    Dict.put(context, :outer, :setup)
  end

  should "outer" do
    assert 1 + 2 == 3
  end

  with "an inner context" do
    setup(context) do
      context
      |> Dict.put(:setup, :inner)
      |> Dict.put(:uid, uid("foo"))
    end

    test "should add inner and outer keywords", context do
      assert context[:setup] == :inner
    end

    test "should set uid for both setup and test", context do
      assert uid("foo") == context[:uid]
      assert uid("bar") == "Elixir.ShouldTest.test with 'an inner context': should set uid for both setup and test bar"
    end

    with "another inner context" do
      setup(context) do
        context
        |> Dict.put(:setup2, :even_more_inner)
      end

      test "should access inner and outer", context do
        assert context[:setup] == :inner
        assert context[:setup2] == :even_more_inner
      end
    end
  end
end
