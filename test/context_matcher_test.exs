defmodule ContextMatcherTest do
  use ShouldI
  import ShouldI.Matchers.Context
  
  setup context do
    assign context, 
      one: 1, 
      tuple: {:ok, :works}
  end

  should_assign_key one: 1
  should_have_key :one
  should_not_have_key :two
  should_match_key tuple: {:ok, _}
  
  with "another level" do
    setup context do  
      assign context, 
        two: 2
    end
    
    should_assign_key two: 2
    should_assign_key one: 1
    should_have_key :one
  end
  
  with "an overwritten key" do
    setup context do  
      assign context, 
        one: "one"
    end
    
    should_assign_key one: "one"
  end
  

end
