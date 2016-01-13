defmodule ShouldTest do
  use ShouldI

  setup context do
    Map.put(context, :setup, :outer)
    Dict.put(context, :outer, :setup)
  end

  should "outer" do
    assert 1 + 2 == 3
  end

  having "an inner context" do
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
      assert uid("bar") == "Elixir.ShouldTest.test having 'an inner context': should set uid for both setup and test bar"
    end

    having "another inner context" do
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

defmodule ShouldSetupTest do
  use ShouldI

  setup do
    :ok
  end

  setup do
    {:ok, [context: :setup]}
  end

  setup context do
    assert context[:context] == :setup
    context |> Dict.put(:context, :setup_context)
  end

  should "setup context", context do
    assert context[:context] == :setup_context
  end

  having "having context" do

    setup do
      :ok
    end

    setup do
      {:ok, [context: :setup_in_having]}
    end

    setup context do
      assert context[:context] == :setup_in_having
      context |> Dict.put(:context, :setup_in_having_context)
    end

    test "setup context", context do
      assert context[:context] == :setup_in_having_context
    end
  end
end
