defmodule ShouldTest do
  use ShouldI

  setup_all do
    IO.puts "this is setup_all"
    on_exit fn ->
      IO.puts "this is on_exit on setup_all"
    end
  end

  setup context do
    IO.puts "this is setup"

    Map.put(context, :setup, :outer)
    Dict.put(context, :outer, :setup)

    on_exit fn ->
      IO.puts "this is on_exit on setup"
    end
  end

  should "outer" do
    assert 1 + 2 == 3
  end

  having "an inner context" do
    setup(context) do
      IO.puts "this is setup in having"

      on_exit fn ->
        IO.puts "this is on_exit on setup in having"
      end

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
        IO.puts "this is setup in nested another having"

        on_exit fn ->
          IO.puts "this is on_exit on setup in nested another having"
        end

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
