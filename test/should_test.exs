defmodule ShouldTest do
  use ShouldI
  setup context do
    Map.put(context, :setup, :outer)
    Dict.put( context, :outer, :setup)
  end

  should "outer" do
    assert 1 + 2 == 3
  end

  with "an inner module" do
    setup(context) do
      Dict.put(context, :setup, :inner)
    end

    test "should add inner and outer keywords", context do
      assert context[:setup] == :inner
    end
  end
end



