defmodule Proj3 do
  
  @moduledoc """
  Documentation for Proj3.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Proj3.hello()
      :world

  """
  def main(args) do

    nodeString = Enum.at(args,0)
    idspace  = String.to_integer(nodeString)
    base = 10
    digit = String.length(Integer.to_string(idspace - 1, base))
    requests = Enum.at(args,1) |> String.to_integer()

    main = self()
    IO.puts("Creating Node...")
    create_actor(0, base, digit, idspace, requests, main)
    IO.puts("Publishing Objects...")
    publish(0, base, digit, idspace);
    IO.puts("Making Requests...")
    requests(0, base, digit, idspace);
    IO.puts("Waiting For Response...")
    IO.puts("Max number: "); 
    IO.puts(wait_reply(0, idspace))
  end

  def wait_reply(n, idspace) do
    if n == idspace - 1 do
      receive do
        {:ok, num} -> num
      end
    else
      receive do
        {:ok, num} -> max_hop = max(num, wait_reply(n + 1, idspace))
                      max_hop
      end
    end
  end


  def create_actor(n, base, digit, idspace, requests, main) do
    name = Integer.to_string(n, base) |> String.pad_leading(digit, "0") |> String.to_atom()
    Proj3.Node.start_link(name, base, digit, idspace, requests, main)
    unless n == idspace - 1 do
      create_actor(n + 1, base, digit, idspace, requests, main) 
    end
  end

  def publish(n, base, digit, idspace) do
    name = Integer.to_string(n, base) |> String.pad_leading(digit, "0") |> String.to_atom()
    Proj3.Node.publish_object(name)
    unless n == idspace - 1 do
      publish(n + 1, base, digit, idspace)
    end
  end

  def requests(n, base, digit, idspace) do
    name = Integer.to_string(n, base) |> String.pad_leading(digit, "0") |> String.to_atom()
    Proj3.Node.make_requests(name)
    unless n == idspace - 1 do
      requests(n + 1, base, digit, idspace)
    end
  end
end
