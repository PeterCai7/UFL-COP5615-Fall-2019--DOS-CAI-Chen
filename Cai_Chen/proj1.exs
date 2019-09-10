defmodule Vampire_Number do
  def factor_pairs(n) do
    first = trunc(n / :math.pow(10, div(char_len(n), 2)))
    last = :math.sqrt(n) |> round
    for i <- first..last, rem(n, i) == 0, do: {i, div(n, i)}
  end

  def vampire_factors(n) do
    if rem(char_len(n), 2) == 1 do
      []
    else
      half = div(length(to_charlist(n)), 2)
      sorted = Enum.sort(String.codepoints("#{n}"))

      Enum.filter(factor_pairs(n), fn {a, b} ->
        char_len(a) == half && char_len(b) == half &&
          Enum.count([a, b], fn x -> rem(x, 10) == 0 end) != 2 &&
          Enum.sort(String.codepoints("#{a}#{b}")) == sorted
      end)
    end
  end

  defp char_len(n), do: length(to_charlist(n))

  def check_vapirenumber(cheklist) do

  	anslist = 
    Enum.map(cheklist, fn n ->
      case vampire_factors(n) do
        [] -> []
        #vf -> IO.puts(String.replace("#{n}\t#{inspect(vf)}", ["{", "}", "[", "]", ","], ""))
        vf ->  [String.replace("#{n} #{inspect vf}", ["{", "[","]","}",","], "")]
      end
    end)
    anslist
  end
end

defmodule VpWorker do
  use GenServer

  def create_worker(default) when is_list(default) do
  	GenServer.start_link(__MODULE__, default)
  end

  @impl true
  def init(numstack) do
    {:ok, numstack}
  end

  @impl true
  def handle_cast({:push, numlist, boss}, state) do
  	#state = Vampire_Number.check_vapirenumber(numlist)
    GenServer.cast(boss, {:push, Vampire_Number.check_vapirenumber(numlist)})
    {:noreply, state}
  end
end

defmodule VpBoss do
  use GenServer

  @impl true
  def init(initial_data) do
    {:ok, initial_data}
  end


  def create_boss(l1, l2, l3, l4) do
  	numOfThread = 4;
    {:ok, parent} = GenServer.start_link(__MODULE__, [numOfThread | self()])
    assign_task(l1, l2, l3, l4, parent)
  end

  def assign_task(l1, l2, l3, l4, parent) do
  	{:ok, worker1} = VpWorker.create_worker([])
  	GenServer.cast(worker1, {:push, l1, parent})
  	{:ok, worker2} = VpWorker.create_worker([])
  	GenServer.cast(worker2, {:push, l2, parent})
  	{:ok, worker3} = VpWorker.create_worker([])
  	GenServer.cast(worker3, {:push, l3, parent})
  	{:ok, worker4} = VpWorker.create_worker([])
  	GenServer.cast(worker4, {:push, l4, parent})
  end

  @impl true
  def handle_cast({:push, numlist}, [head | tail]) do
  	head = head - 1;
  	Enum.each(numlist, fn x -> unless x == [] do
  		IO.puts x
  	 end
  	end)

  	if head == 0 do
  		send tail, {:done, "DONE"}
  	end 

    {:noreply, [head | tail]}
  end

end


args = System.argv()
startpoint = String.to_integer(Enum.at(args,0))
endpoint = String.to_integer(Enum.at(args,1))
workernum = round((endpoint - startpoint) / 4)
list1 = Enum.map(1 .. workernum, fn(x) -> (x - 1) * 4 + startpoint end)
#IO.inspect(list1)
list2 = Enum.map(1 .. workernum, fn(x) -> (x - 1) * 4 + 1 + startpoint end)
#IO.inspect(list2)
list3 = Enum.map(1 .. workernum, fn(x) -> (x - 1) * 4 + 2 + startpoint end)
#IO.inspect(list3)
list4 = Enum.map(1 .. workernum, fn(x) -> (x - 1) * 4 + 3 + startpoint end)
#IO.inspect(list4)
VpBoss.create_boss(list1, list2, list3, list4)

receive do
	{:done, _data} -> "DONE"
end
