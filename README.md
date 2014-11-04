ShouldI
=======

ExUnit is fine for small, simple applications, but when you want to do more complex test cases, it has limitations. ShouldI provides nested contexts to eliminate duplication in tests, and has better support for naming tests based on behavior. This API is based on the shoulda framework for Ruby on Rails.

Installation
------------
Just add the hex dependency to your mix file:

~~~
defp deps do
  [...
   {:shouldi, env: :test}
   ...]
end
~~~



and add

~~~
...
use ShouldI
...
~~~

to your test script in place of

~~~
...
use ExUnit.Case
...
~~~

Better Names
------------
When you're testing behavior, you can get better names with a more descriptive macro. The test code...

~~~
test "should return ok on parse" do
  assert :ok == Parser.parse
end
~~~

...can become more descriptive and shorter with...


~~~
should "return :ok on parse" do
   assert :ok == Parser.parse
end
~~~

That's not all. Often test cases in functional languges can have too much repetition. We can eliminte much of that.

Nested Contexts
---------------

Say you have a test case that needs some setup. ExUnit has support for a context that can be set once, and passed to all clients. You can use the `setup` method to pass a map to each of your test cases, like this:

~~~
defmodule MyFlatTest do
  setup context do
    {:ok, Dict.put context, :necessary_key, :neccessary_value}
  end

  test( "this test needs :necessary_key", context ) do
    assert context.necessary_key == :necessary_value
  end
end
~~~

This approach breaks down when several, but not all, tests need the same set of values. ShouldI solves this problem with nested contexts, which you can provide with the `with` keyword, like this:

~~~
defmodule MyFatTest do

  with "necessary_key" do
    setup context do
    {:ok, Dict.put context, :necessary_key, :neccessary_value}
    end

    should( "have necessary key", context ) do
      assert context.necessary_key == :necessary_value
    end

  with "sometimes_necessary_key" do
    setup context do
    {:ok, Dict.put context, :sometimes_necessary_key, :sometimes_neccessary_value}
    end

    should( "have necessary key", context ) do
      assert context.sometimes_necessary_key == :sometimes_necessary_value
    end
  end
end
~~~

This approach is much nicer than the alternatives when you're testing something like a controller with dramatically different requirements across tests:

~~~
with "a logged in user" do
  setup context do
    login context, user
  end
  ...
end

with "a logged out user" do

   ...

end

with "a logged in admin" do
  setup context do
    login context, admin
  end
  ...
end
~~~

Finally, you can package macros that write your own tests. Matchers encode common assertion patterns. For example, our plug matchers

~~~
with "a logged in admin" do
  setup context do
    login context, admin
  end
  with "a get to :index" do
    setup context do
      # process get
    end
    should respond_with :success
  end
end
~~~

Unique IDs
----------

When running tests asynchronously it can be useful to have a way to generate IDs or names that will not conflict with other tests that run concurrently. `uid()` will generate an ID unique for the current test and setup. If it is called again during the same test it will return the same ID. An additional string can be given `uid("some string")` so multiple IDs can be generated during the same test.

Special thanks to ThoughtBot's shoulda, which formed the foundation for this approach.
