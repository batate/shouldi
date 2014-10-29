defmodule PlugTest do
  use ShouldI
  import ShouldI.Matchers.Plug
  
  setup context do
    Map.put( context, :connection, %{ status: 200 })
  end

  should_respond_with :success

end



