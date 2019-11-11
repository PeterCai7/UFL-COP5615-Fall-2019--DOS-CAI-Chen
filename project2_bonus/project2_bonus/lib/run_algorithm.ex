defmodule Gossip.RunAlgorithm do
  @moduledoc false


  #record the time for running gossip
  def task(numnodes, failures, :gossip) do
    IO.puts("Running gossip...")
    {runningtime,_} = :timer.tc(fn  -> run_gossip_with_failure(numnodes, failures) end)
    IO.puts("Gossip completed after #{div(runningtime,1000)}ms.")
  end

  #record the time for running pushsum
  def task(numnodes, failures, :pushsum) do
    IO.puts("Running pushsum...")
    {runningtime,_} = :timer.tc(fn  -> run_pushsum_with_failure(numnodes) end)
    IO.puts("Pushsum algorithm completed after #{div(runningtime,1000)}ms.")
  end

  #randomly choose a start node
  def choose_start_node(numnodes) do
    start_node_seq = :rand.uniform(numnodes)
    start_node = "node" <> Integer.to_string(start_node_seq) |> String.to_atom()
    if Gossip.Node.get_status(start_node) == false do
      choose_start_node(numnodes)
    else
      start_node
    end
  end

  #start runnning gossip with failures
  def run_gossip_with_failure(numnodes, failures) do
    start_node = choose_start_node(numnodes)
    rumor = "Winter is coming!"
    Gossip.Node.send_rumor(start_node, rumor, self())
    listen_nodes_running(1, numnodes - failures, rumor)
  end

  #In gossip, mainpid should tracking nodes situations and do corresponding treatment
  def listen_nodes_running(n, total_nodes, rumor) do
    if n > total_nodes do
      nil
    end
    if n > 0 and n <= total_nodes do
      receive do
        {:Getit} -> listen_nodes_running(n + 1, total_nodes, rumor)
      after
        5_000 ->
          IO.puts("Only #{n-1} nodes heard rumor yet. Algorithm is forced to terminate")
      end
    end
  end

  #start runnning pushsum with failures
  def run_pushsum_with_failure(numnodes) do
    start_node = choose_start_node(numnodes)
    Gossip.Node.pushsum(start_node, 0, 0, self())
    still_converging(0, 1)
  end

  #In pushsum, mainpid need to judge whether the algorithm converged
  def still_converging(one_before_last, last) do
    receive do
      {:estimated_sum, current_estimation} ->
        if converged(one_before_last, last, current_estimation) do
          IO.puts("Pushsum algorithm converged. Estimated sum is #{current_estimation}.")
        else
          still_converging(last, current_estimation)
        end
    after
      5_000 ->
        IO.puts("Cannot converge because some nodes isolated. Algorithm stopped.")
    end
  end

  def converged(one, two, three) do
    flag = abs(one - two) <= :math.pow(10, -10) and abs(two - three) <= :math.pow(10, -10)
  end


end
