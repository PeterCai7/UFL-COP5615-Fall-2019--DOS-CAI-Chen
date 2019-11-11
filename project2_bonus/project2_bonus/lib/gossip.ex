defmodule Gossip do
  @moduledoc """
  Documentation for Project2.
  """

  def main(args) do
    {numnodes, topology, algorithm, fail_numenodes} = parse_args(args)
    Gossip.Topologies.build_neighborhood_with_failures(numnodes, topology, fail_numenodes)
    Gossip.RunAlgorithm.task(numnodes, fail_numenodes, algorithm)
  end

  def parse_args(args) do
    numNodes  =  Enum.at(args,0) |> String.to_integer()
    topology  =  Enum.at(args,1) |> parse_topo()
    algorithm =  Enum.at(args,2) |> parse_algo()
    fail_numbers = Enum.at(args, 3) |> String.to_integer()
    if topology == :threeD do
      IO.puts("The given number of nodes #{numNodes} is rounded to #{handle_round(topology, numNodes)}")
      {handle_round(topology, numNodes),topology,algorithm, fail_numbers}
    else
      {numNodes,topology,algorithm, fail_numbers}
    end
  end

  def parse_topo(topo) do
    case topo do
      "line" -> :line
      "honeycomb" -> :honeycomb
      "full" -> :full
      "2D" -> :rand_twoD
      "3D" -> :threeD
      "randomhoney" -> :randomhoney
    end
  end

  def parse_algo(algo) do
    case algo do
      "pushsum" -> :pushsum
      "gossip" -> :gossip
    end
  end

  def handle_round(topology, numNodes) do
    numNodes =
    case topology do
      :threeD -> round_to_cube(numNodes)
      :torus -> round_to_square(numNodes)
    end
  end

  def round_to_square(n) do
    n |> :math.sqrt() |> :math.floor() |>  :math.pow(2) |> round()
  end

  def round_to_cube(n) do
    n |> :math.pow(1/3) |> :math.ceil() |>  :math.pow(3) |> round()
  end



end
