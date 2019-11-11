defmodule Test do
  def f(args) do
    Gossip.main(args)
  end
end

Test.f(["1000","3D","pushsum"])

