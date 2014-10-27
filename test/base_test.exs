# defmodule BaseTest do
#   use ExUnit.Case
#   setup context do 
#     IO.puts "Setting up outer"
#     {:ok, Map.put( context, :outer, :setup) }
#   end
#     
#   test "outer", context do
#     IO.inspect context
#     assert Stub.affirm
#   end
#   
#   defmodule Inner do
#     use ExUnit.Case
#     setup context do 
#       {:ok, context} = BaseTest.__ex_unit__(:setup, context)
#       IO.puts "Setting up inner"
#       user_setup context
#     end
# 
#     def user_setup context do
#       {:ok, Map.put( context, :inner, :setup) }
#     end
# 
#     test "inner", context do
#       IO.puts "Testing inner"
#       IO.inspect context
#       assert Stub.affirm
#     end
# 
#   end
#   
# end
# 
# 
# 
# 