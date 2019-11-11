defmodule Proj3.Node do
  use GenServer

  #Initialization 
  def start_link(nodeid, base, digit, nodeidspace, requests, parent) do
    GenServer.start_link(__MODULE__,[[[]],%{},nil,false, base, digit, nodeidspace, requests, 0, -1, parent], name: nodeid)
    
    node_insertion(nodeid, base, digit, nodeidspace)
    initialize_neighbormapping(nodeid, base, digit, nodeidspace)
  end

  def initialize_neighbormapping(nodeid, base, digit, nodeidspace) do
    GenServer.cast(nodeid, {:initialize_neighbormapping, base, digit, nodeidspace, nodeid})
  end

  def node_insertion(nodeid, base, digit, nodeidspace) do
    GenServer.cast(nodeid, {:node_insertion, base, digit, nodeidspace})
  end

  def publish_object(nodeid) do
    fileid = GenServer.call(nodeid, {:get_file_id})
    GenServer.cast(nodeid, {:route_to_target, fileid, nodeid, 0, 0, "publish"})
  end

  def unpublish_object(nodeid) do
    fileid = GenServer.call(nodeid, {:get_file_id})
    GenServer.cast(nodeid,{:route_to_target, fileid, nodeid, 0, 0, "unpublish"})
  end

  def route_to_obejct(nodeid, objectid) do
    GenServer.cast(nodeid, {:route_to_target, objectid, nodeid, 0, 0, "object"})
  end

  def route_to_node(nodeid, nodeid) do
    GenServer.cast(nodeid, {:route_to_target, nodeid, nodeid, 0, 0, "node"})
  end

  def make_requests(nodeid) do
    GenServer.cast(nodeid, {:make_all_requests, nodeid})
  end

  
  def init(state) do
    {:ok, state}
  end

  #Get File ID
  def handle_call({:get_file_id}, _, state) do
    fileid = Enum.at(state, 2)
    {:reply, fileid, state}
  end

  #Make Requests

  def handle_cast({:make_all_requests, nodeid}, state) do
    base = Enum.at(state, 4)
    digit = Enum.at(state, 5)
    nodeidspace = Enum.at(state, 6)
    requests = Enum.at(state, 7)
    make_request(nodeid, base, digit, nodeidspace, 0, requests)
    {:noreply, state}
  end

  def make_request(nodeid, base, digit, nodeidspace, requests, total_requests) do
    unless requests == total_requests do
      num = :rand.uniform(nodeidspace) - 1
      fileid = Integer.to_string(num, base) |> String.pad_leading(digit, "0") |> String.to_atom()
      # IO.puts("make_single_request called")
      GenServer.cast(nodeid, {:route_to_target, fileid, nodeid, 0, 0, "object"})
      make_request(nodeid, base, digit, nodeidspace, requests + 1, total_requests)
    end
  end

  #Receive Number of hops
  def handle_cast({:return_numofhops, hop}, state) do
    current_max = max(Enum.at(state, 9), hop);
    num_received = Enum.at(state, 8) + 1;
    updatedState = List.replace_at(state, 9, current_max)
    if num_received == Enum.at(state, 7) do
      # IO.inspect();
      send Enum.at(state, 10), {:ok, current_max}
    end
    {:noreply, List.replace_at(updatedState, 8, num_received)}
  end


    #Route to Target
  def handle_cast({:route_to_target, targetId, clientid, level, hop, flag}, state) do
    nodeidspace = Enum.at(state, 6);
    targetString = Atom.to_string(targetId)
    map = Enum.at(state, 1)
    cond do
      flag == "node" or flag == "object" ->   
        if map[targetId] == nil do
          if level == String.length(targetString) do
            GenServer.cast(clientid, {:return_numofhops, hop})
          else
            char = String.at(targetString, level)
            {charNum,""} = Integer.parse(char, Enum.at(state, 4))
            # IO.puts(Enum.at(Enum.at(state, 0), level))
            nextId = Enum.at(Enum.at(Enum.at(state, 0), level), charNum) 

            {nextNum,""} = Atom.to_string(nextId) |> Integer.parse(Enum.at(state, 4))

            if nextNum >= nodeidspace do
            
              GenServer.cast(clientid, {:return_numofhops, -1})
            else
              GenServer.cast(nextId, {:route_to_target, targetId, clientid, level + 1, hop + 1, flag})
            end
          end
        else
          value = Map.get(map, targetId)
          GenServer.cast(clientid, {:return_numofhops, hop})
        end

      flag == "publish" or flag == "unpublish" ->
        if map[targetId] == nil do
          map = Map.put(map, targetId, level)
        else
          map = Map.replace!(map, targetId, min(level, Map.get(map, targetId)))
        end
        updatedState = List.replace_at(state, 1, map)

        if level == String.length(targetString) do
          if flag == "publish" do
            {:noreply, List.replace_at(updatedState, 3, clientid)}
          else
            {:noreply, List.replace_at(updatedState, 3, nil)}
          end
        else

          char = String.at(targetString, level)

          {charNum,""} = Integer.parse(char, Enum.at(state, 4))

          nextId = Enum.at(Enum.at(Enum.at(state, 0), level), charNum) 
          {nextNum,""} = Atom.to_string(nextId) |> Integer.parse(Enum.at(state, 4))
          if nextNum < nodeidspace do
            GenServer.cast(nextId, {:route_to_target, targetId, clientid, level + 1, hop + 1, flag})
          end
          {:noreply, updatedState}
        end
    end 
      
    {:noreply, state}
  end

  

  #Initialize Neighbour Table
  def handle_cast({:initialize_neighbormapping, base, digit, nodeidspace, nodeid}, state) do
    {digitNam,""} = Atom.to_string(nodeid) |> Integer.parse(base)

    neighborList = initialNeighborListRow(base, 0, digit, Kernel.trunc(nodeidspace), digitNam)

    {:noreply, List.replace_at(state, 0, neighborList)}
  end

  def initialNeighborListRow(base, rowIndex, digit, nodeidspace, nodeid) do
    interval = Kernel.trunc(:math.pow(base, digit - 1 - rowIndex))
    startN = Kernel.trunc(Kernel.trunc(nodeid / (:math.pow(base, digit - rowIndex))) * (:math.pow(base, digit - rowIndex)))
    endN = 0
    if rowIndex == digit - 1 do
      [initialNeighborListCol(0, base, interval, startN, endN, digit, nodeidspace)]
      
    else
      [initialNeighborListCol(0, base, interval, startN, endN, digit, nodeidspace)] ++ initialNeighborListRow(base, rowIndex + 1, digit, nodeidspace, nodeid)
    end
  end

  def initialNeighborListCol(colIndex, base, interval, startN, endN, digit, nodeidspace) do
    endN = startN + interval
    if colIndex == base - 1 do
      [(:rand.uniform(endN - startN) - 1 + startN) |> Integer.to_string(base) |> String.pad_leading(digit, "0") |> String.to_atom()]
    else
      [(:rand.uniform(endN - startN) - 1 + startN) |> Integer.to_string(base) |> String.pad_leading(digit, "0") |> String.to_atom()] ++ initialNeighborListCol(colIndex + 1, base, interval, endN, endN, digit, nodeidspace)
    end
  end

  #node inserting and initialize objects
  def handle_cast({:node_insertion, base, digit, nodeidspace}, state) do
    fileid = (:rand.uniform(nodeidspace) - 1) |> Integer.to_string(base) |> String.pad_leading(digit, "0") |> String.to_atom()
    {:noreply, List.replace_at(state, 2, fileid)}
  end

end