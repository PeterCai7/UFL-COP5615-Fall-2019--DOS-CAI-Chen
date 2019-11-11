defmodule Gossip.Node do
  use GenServer

  #State in GenServer is a list here, it contains nodedata.
  # index_0 : rumor kept in this node
  # index_1 : number of times this node heard the rumor
  # index_2 : intitial value of s for this node
  # index_3 : intinial value of w for this node
  # index_4 : neighbors tuple of this node
  # index_5 : sequence number of this node
  # index_6 : 2D-coordinates for this node
  # index_7 : status of this node. False means this node is a failure
  ##################### Server side #####################
  def start_link(nodename, node_seq) do
    GenServer.start_link(__MODULE__,["",0,node_seq,1,{},node_seq,[:rand.uniform(), :rand.uniform()], true], name: nodename)
  end

  def get_data(nodename) do
    GenServer.call(nodename, :get_data)
  end

  def get_neighbors(nodename) do
    GenServer.call(nodename, :get_neighbors)
  end

  def get_coordinates(nodename) do
    GenServer.call(nodename, :get_coordinates)
  end

  def get_status(nodename) do
    GenServer.call(nodename, :get_status)
  end

  def terminate_node(nodename) do
    GenServer.cast(nodename, :terminate)
  end

  def remove_neighbor(nodename, remove_node) do
    GenServer.cast(nodename, {:remove_neighbor,remove_node})
  end

  def send_rumor(nodename, rumor, bosspid) do
    GenServer.cast(nodename, {:send_rumor, rumor, bosspid})
  end

  def update_neighbors(nodename, neighbors) do
    GenServer.cast(nodename,{:update_neighbors, neighbors})
  end

  def pushsum(nodename, s, w, bosspid) do
    GenServer.cast(nodename, {:pushsum, s, w, bosspid})
  end


  ##################### Client side #####################

  def init(nodedata) do
    {:ok, nodedata}
  end

  def handle_call(:get_data, _from, nodedata) do
    {:reply, nodedata, nodedata}
  end

  def handle_call(:get_neighbors, _from, nodedata) do
    neighbors = Enum.at(nodedata, 4)
    {:reply, neighbors, nodedata}
  end

  def handle_call(:get_coordinates, _from, nodedata) do
    coordinates = Enum.at(nodedata, 6)
    {:reply, coordinates, nodedata}
  end

  def handle_call(:get_status, _from, nodedata) do
    status = Enum.at(nodedata, 7)
    {:reply, status, nodedata}
  end

  def handle_cast({:update_neighbors, neighbors}, nodedata) do
    {:noreply, List.replace_at(nodedata, 4, neighbors)}
  end

  def handle_cast({:send_rumor, rumor, bosspid}, nodedata) do
    max_heard_times = 100
    list_neighbors =
    if Enum.at(nodedata, 4) != {} do
      Enum.at(nodedata,4) |> Tuple.to_list()
    else
      []
    end
    subProcess_name = "node"<>Integer.to_string(Enum.at(nodedata, 5))<>"_subProcess" |> String.to_atom()
    if Process.whereis(subProcess_name) == nil && Enum.at(nodedata, 1) < max_heard_times do
      send bosspid,{:Getit}
      subProcess = spawn(Gossip.Node, :keep_sending_rumor, [rumor, list_neighbors, bosspid])
      Process.register(subProcess, subProcess_name)
    end
    updated_nodedata = List.replace_at(nodedata, 0, rumor)
    updated_nodedata = List.replace_at(updated_nodedata, 1, Enum.at(updated_nodedata, 1) + 1)

    if Process.whereis(subProcess_name) != nil && Enum.at(updated_nodedata, 1) >= max_heard_times do
      Process.sleep(5)
      if Process.whereis(subProcess_name) != nil && Enum.at(updated_nodedata, 1) >= max_heard_times  do
        Process.sleep(5)
        if Process.whereis(subProcess_name) != nil && Enum.at(updated_nodedata, 1) >= max_heard_times do
          subProcess_name |> Process.whereis() |> Process.exit(:kill)
          remove_from_neighbors("node"<>Integer.to_string(Enum.at(updated_nodedata,5)) |> String.to_atom(),Enum.at(updated_nodedata, 4) |> Tuple.to_list())
          updated_nodedata = List.replace_at(updated_nodedata, 7, false)
          updated_nodedata = List.replace_at(updated_nodedata, 4, {})
        end
      end
    end

    {:noreply, updated_nodedata}
  end

  def handle_cast({:pushsum, s, w, bosspid}, nodedata) do
    #IO.puts("node#{Enum.at(nodedata,5)} receive message，status is #{Enum.at(nodedata, 7)}}")
    list_neighbors = Enum.at(nodedata, 4) |> Tuple.to_list()

      updated_s = (Enum.at(nodedata, 2) + s) / 2
      updated_w = (Enum.at(nodedata, 3) + w) / 2
      updated_nodedata = List.replace_at(nodedata, 2, updated_s)
      updated_nodedata = List.replace_at(updated_nodedata, 3, updated_w)
      estimation = updated_s / updated_w
      send bosspid, {:estimated_sum, estimation}
    if length(list_neighbors) > 0 do
      next_node=Enum.random(list_neighbors)
      check(next_node,list_neighbors)|>pushsum(updated_s, updated_w, bosspid)
      else
      send bosspid, {:end}
    end
    {:noreply, updated_nodedata}
  end

  def handle_cast(:terminate, nodedata) do
    cur_node = "node"<>Integer.to_string(Enum.at(nodedata,5)) |> String.to_atom()
    neighbors_list = Enum.at(nodedata, 4) |> Tuple.to_list()
    remove_from_neighbors(cur_node, neighbors_list)
    updated_nodedata = List.replace_at(nodedata, 7, false)
    updated_nodedata = List.replace_at(updated_nodedata, 4, {})
    {:noreply, updated_nodedata}
  end

  def handle_cast({:remove_neighbor, remove_node}, nodedata) do
    neighbors_list = Enum.at(nodedata, 4) |> Tuple.to_list()
    updated_neighbors_list = neighbors_list -- [remove_node]
    #IO.puts("#{remove_node} is removed from node#{Enum.at(nodedata, 5)}'s neighbor list")
    #Enum.each(updated_neighbors_list, fn ele -> IO.puts(ele) end)
    updated_neighbors = List.to_tuple(updated_neighbors_list)
    updated_nodedata = List.replace_at(nodedata, 4, updated_neighbors)
    {:noreply, updated_nodedata}
  end


  def random_neighbor(list_neighbors) do
    index = length(list_neighbors) |> :rand.uniform()
    rand_receiver = Enum.at(list_neighbors, index - 1)
  end

  def keep_sending_rumor(rumor, list_neighbors, bosspid) do
    if list_neighbors != [] do
      receiver = Enum.random(list_neighbors)
      send_rumor(receiver, rumor, bosspid)
      keep_sending_rumor(rumor, list_neighbors, bosspid)
    else
      nil
    end
  end

  def remove_from_neighbors(cur_node, neighbors_list) when length(neighbors_list) == 0, do: nil
  def remove_from_neighbors(cur_node, neighbors_list) when length(neighbors_list) != 0 do
    [head|rest_neighbors_list] = neighbors_list
    remove_neighbor(head, cur_node)
    remove_from_neighbors(cur_node, rest_neighbors_list)
  end
  def check(next_node,list_neighbors) when next_node == nil do
      next_node=Enum.random(list_neighbors)
      check(next_node,list_neighbors)
   end

  def check(next_node,list_neighbors) when next_node != nil do
       next_node=next_node
  end


end
