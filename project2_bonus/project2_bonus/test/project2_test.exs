defmodule Test do
  def f(args) do
    Gossip.main(args)
  end
end

Test.f(["100","2D","gossip","50"])
