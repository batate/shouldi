ShouldI
=======

ExUnit is fine for small, simple applications, but when you want to do more complex test cases, it has limitations. ShouldI provides nested contexts to eliminate duplication in tests, and has better support for naming tests based on behavior. This API is based on the shoulda framework for Ruby on Rails.

Quick start
------------
Just add the hex dependency to your mix file:

~~~elixir
defp deps do
  [{:shouldi, only: :test}]
end
~~~

and add

~~~elixir
...
use ShouldI
...
~~~

to your test script in place of

~~~elixir
...
use ExUnit.Case
...
~~~

Name tests with `should`
------------
When you're testing behavior, you can get better names with a more descriptive macro. The test code...

~~~elixir
test "should return ok on parse" do
  assert :ok == Parser.parse
end
~~~

...can become more descriptive and shorter with...


~~~elixir
should "return :ok on parse" do
   assert :ok == Parser.parse
end
~~~

Nest your context using `having`
---------------

Say you have a test case that needs some setup. ExUnit has support for a context that can be set once, and passed to all clients. You can use the `setup` method to pass a map to each of your test cases, like this:

~~~elixir
defmodule MyFlatTest do
  setup context do
    {:ok, Dict.put context, :necessary_key, :necessary_value}
  end

  test( "this test needs :necessary_key", context ) do
    assert context.necessary_key == :necessary_value
  end
end
~~~

This approach breaks down when several, but not all, tests need the same set of values. ShouldI solves this problem with nested contexts, which you can provide with the `having` keyword, like this:

~~~elixir
defmodule MyFatTest do

  having "necessary_key" do
    setup context do
      Dict.put context, :necessary_key, :necessary_value
    end

    should( "have necessary key", context ) do
      assert context.necessary_key == :necessary_value
    end
  end

  having "sometimes_necessary_key" do
    setup context do
      Dict.put context, :sometimes_necessary_key, :sometimes_necessary_value
    end

    should( "have necessary key", context ) do
      assert context.sometimes_necessary_key == :sometimes_necessary_value
    end
  end
end
~~~

This approach is much nicer than the alternatives when you're testing something like a controller with dramatically different requirements across tests:

~~~elixir
having "a logged in user" do
  setup context do
    login context, user
  end

  ...
end

having "a logged out user" do
   ...
end

having "a logged in admin" do
  setup context do
    login context, admin
  end

  ...
end
~~~

Use `assign` to set the context
------------
`assign` is a macro that is syntactic sugar for updating the `context`.

~~~elixir
setup context do
  Dict.put context, :necessary_key, :necessary_value
end
~~~

becomes

~~~elixir
setup context do
  assign context, necessary_key: :necessary_value
end
~~~

Use matchers simplify tests
---------------------------

You can package macros that write your own tests. Matchers encode common assertion patterns. For example, our plug matchers

~~~elixir
having "a logged in admin" do
  setup context do
    login context, admin
  end

  having "a get to :index" do
    setup context do
      # process get
    end
    should_respond_with :success
    should_match_body_to "<html>"
  end
end
~~~

The two matchers, `should_respond_with` and `should_match_body_to`, will run in a single test, against the context created in the `setup` function (or setup functions, if you've used multiple contexts). Even if both of these tests fail, you'll see two failures in your output.

Create your own matchers with `defmatcher`
------------------------

We come prepackaged with a set of matchers, but you can code your own as well. The following is the matcher to check for existence of a dictionary key in the context:

~~~elixir
defmatcher should_assign_key([{key, value}]) do
  quote do
    assert var!(context)[unquote(key)] == unquote(value)
  end
end
~~~

This macro allows you to build a matcher macro.

We'll have more information about creating matchers later. In the mean time, you can read through the matchers we've created in the project. Matchers should be stateless, as all matchers within a `having` clause will run to completion, unless there is an `error`, even if a test fails.

Existing Matchers
-----------------

- Context
    - `should_assign_key key, value`: assert that the value for `key` in the context is `value`
    - `should_match_key key, expected`: assert that the value for `key` in the context satisfies the pattern match `expected`
    - `should_have_key key`: assert that `key` exists in the context
    - `should_not_have_key key`: assert that `key` does not exist in the context
- Plug
    - `should_respond_with expected`: Assert that the value for `context.connection.status` in the context matches a reasonable value for `:success`, `:redirect`, `:bad_request`, `:unauthorized`, `:missing` or `:error`
    - `should_match_body_to expected`: Assert that the value for `context.resp_body` contains the text `expected`.

Unique IDs
----------

When running tests asynchronously it can be useful to have a way to generate IDs or names that will not conflict with other tests that run concurrently. `uid()` will generate an ID unique for the current test and setup. If it is called again during the same test it will return the same ID. An additional string can be given `uid("some string")` so multiple IDs can be generated during the same test.

One Experiment, Multiple Measurements
-------------------------------------

The philosophy is that experiments go in `setup` and measurements go into matchers. `shouldi` will make sure that the context is passed between them cleanly so that things compose correctly.

When you run a `shouldi` test, for each context:

- one `should` test is created, collecting all of the matchers in a `having` clause.
- one exunit `test` is created for each `should` block
- for each test
- - all of the ancestor `setup` functions will fire, from outermost to innermost.
- - the test will fire
- - if a test is a matcher test, all of the matchers will run to completion, even if there is a failure, stopping only on errors.
- - if a test is a `should` block, the first failure will halt the test, as in `ExUnit`.  

Happy testing. Open an issue if there are any matchers you'd like to see. Feedback and pull requests are welcome. Send a pull request if you'd like to contribute.

Special thanks to ThoughtBot's shoulda, which formed the foundation for this approach.
