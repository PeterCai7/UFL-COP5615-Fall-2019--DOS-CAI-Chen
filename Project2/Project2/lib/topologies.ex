defmodule Gossip.Topologies do

  def create_nodes(n) when n == 1 do
    Gossip.Node.start_link(:node1,1)
  end
  def create_nodes(n) when n > 1 do
    "node"<>Integer.to_string(n) |> String.to_atom() |> Gossip.Node.start_link(n)
    create_nodes(n - 1)
  end

  def build_neighborhood(numnodes, topology) do
    IO.puts("Setting topology as #{topology}")
    create_nodes(numnodes)
    case topology do
      :line -> neighbors_for_line_nodes(numnodes,numnodes)
      :honeycomb-> neighbors_for_honeycomb(1, numnodes)
      :full -> neighbors_for_full_nodes(numnodes, numnodes)
      :rand_twoD -> neighbors_for_2D_nodes(1, numnodes)
      :threeD -> neighbors_for_3D_nodes(1, numnodes)
      :randomhoney -> neighbors_for_random_honeycomb(1, numnodes)
    end

  end


  ######################## line topology ###################################
  def neighbors_for_line_nodes(cur_node_seq, total_nodes_num) when total_nodes_num == 1, do: nil
  def neighbors_for_line_nodes(cur_node_seq, total_nodes_num) when cur_node_seq == 1 do
    Gossip.Node.update_neighbors(:node1, {:node2})
  end
  def neighbors_for_line_nodes(cur_node_seq, total_nodes_num) when cur_node_seq == total_nodes_num do
    curnode = "node"<>Integer.to_string(cur_node_seq) |> String.to_atom()
    prenode = "node"<>Integer.to_string(cur_node_seq - 1) |> String.to_atom()
    Gossip.Node.update_neighbors(curnode, {prenode})
    neighbors_for_line_nodes(cur_node_seq - 1, total_nodes_num)
  end
  def neighbors_for_line_nodes(cur_node_seq, total_nodes_num) when cur_node_seq > 1 and cur_node_seq < total_nodes_num do
    curnode = "node"<>Integer.to_string(cur_node_seq) |> String.to_atom()
    prenode = "node"<>Integer.to_string(cur_node_seq - 1) |> String.to_atom()
    nextnode = "node"<>Integer.to_string(cur_node_seq + 1) |> String.to_atom()
    Gossip.Node.update_neighbors(curnode, {prenode, nextnode})
    neighbors_for_line_nodes(cur_node_seq - 1, total_nodes_num)
  end


  ######################## honeycomb topology ###################################
  def neighbors_for_honeycomb(cur_node_seq, numnodes) when cur_node_seq > numnodes or numnodes==1, do: nil
  def neighbors_for_honeycomb(cur_node_seq, numnodes) when cur_node_seq <= numnodes and numnodes !=1  do
    neighbors = {}
    cur_node = "node"<>Integer.to_string(cur_node_seq) |> String.to_atom()
    rows = round(:math.pow(numnodes,1/2))
    if rem(rows,2) == 1 do
        neighbors=Tuple.append(neighbors,is_even(cur_node_seq)&&not_left_bound2(cur_node_seq,rows)&& "node"<>Integer.to_string(cur_node_seq - 1) |> String.to_atom())
        neighbors=Tuple.append(neighbors,is_odd(cur_node_seq)&&not_right_bound2(cur_node_seq,rows,numnodes)&& "node"<>Integer.to_string(cur_node_seq + 1) |> String.to_atom())
        neighbors=Tuple.append(neighbors,not_up_bound2(cur_node_seq,numnodes,rows)&& "node"<>Integer.to_string(cur_node_seq + rows) |> String.to_atom())
        neighbors=Tuple.append(neighbors,not_down_bound2(cur_node_seq,rows)&& "node"<>Integer.to_string(cur_node_seq - rows) |> String.to_atom())
        neighbors=tuple_delete_nil2(neighbors)
        Gossip.Node.update_neighbors(cur_node, neighbors)
        neighbors_for_honeycomb(cur_node_seq + 1,numnodes)

    else
      if rem(div(cur_node_seq-1,rows),2)==0 do
        neighbors=Tuple.append(neighbors,is_even(cur_node_seq)&&not_left_bound2(cur_node_seq,rows)&& "node"<>Integer.to_string(cur_node_seq - 1) |> String.to_atom())
        neighbors=Tuple.append(neighbors,is_odd(cur_node_seq)&&not_right_bound2(cur_node_seq,rows,numnodes)&& "node"<>Integer.to_string(cur_node_seq + 1) |> String.to_atom())
        neighbors=Tuple.append(neighbors,not_up_bound2(cur_node_seq,numnodes,rows)&& "node"<>Integer.to_string(cur_node_seq + rows) |> String.to_atom())
        neighbors=Tuple.append(neighbors,not_down_bound2(cur_node_seq,rows)&& "node"<>Integer.to_string(cur_node_seq - rows) |> String.to_atom())
        neighbors=tuple_delete_nil2(neighbors)
        Gossip.Node.update_neighbors(cur_node, neighbors)
        neighbors_for_honeycomb(cur_node_seq + 1,numnodes)
        else
        neighbors=Tuple.append(neighbors,is_odd(cur_node_seq)&&not_left_bound2(cur_node_seq,rows)&& "node"<>Integer.to_string(cur_node_seq - 1) |> String.to_atom())
        neighbors=Tuple.append(neighbors,is_even(cur_node_seq)&&not_right_bound2(cur_node_seq,rows,numnodes)&& "node"<>Integer.to_string(cur_node_seq + 1) |> String.to_atom())
        neighbors=Tuple.append(neighbors,not_up_bound2(cur_node_seq,numnodes,rows)&& "node"<>Integer.to_string(cur_node_seq + rows) |> String.to_atom())
        neighbors=Tuple.append(neighbors,not_down_bound2(cur_node_seq,rows)&& "node"<>Integer.to_string(cur_node_seq - rows) |> String.to_atom())
        neighbors=tuple_delete_nil2(neighbors)
        Gossip.Node.update_neighbors(cur_node, neighbors)
        neighbors_for_honeycomb(cur_node_seq + 1,numnodes)


      end


    end
    end

  def is_odd(cur_node_seq) do
    if rem(cur_node_seq,2)==1 do
      true
    else
      false
    end
  end
  def is_even(cur_node_seq) do
    if rem(cur_node_seq,2)==0 do
      true
    else
      false
    end
  end
  def not_left_bound2(cur_node_seq, rows) do
    if cur_node_seq > 1 and (div(cur_node_seq - 1, rows) == div(cur_node_seq - 2, rows)) do
      true
    else
      nil
    end
  end
  def not_right_bound2(cur_node_seq, rows,numnodes) do
    if (div(cur_node_seq, rows) == div(cur_node_seq - 1, rows)&&cur_node_seq<numnodes) do
      true
    else
      nil
    end
  end
  def not_up_bound2(cur_node_seq, numnodes,rows) do
    if (cur_node_seq+rows <= numnodes) do
      true
    else
      nil
    end
  end
  def not_down_bound2(cur_node_seq, rows) do
    if (cur_node_seq>rows) do
      true
    else
      nil
    end
  end
  def tuple_delete_nil2(tuple) do
    list = Tuple.to_list(tuple)
    list = [nil|list] |> Enum.uniq() |> Enum.sort() |> List.delete_at(0)
    List.to_tuple(list)
  end


  ######################## Random HoneyComb topology ###################################
  def neighbors_for_random_honeycomb(cur_node_seq, total_nodes_num) do
    neighbors_for_honeycomb(cur_node_seq, total_nodes_num)
    build_random_connection(cur_node_seq, total_nodes_num)
  end

  def build_random_connection(cur_node_seq, total_node_num) when cur_node_seq > total_node_num or total_node_num == 1, do: nil
  def build_random_connection(cur_node_seq, total_node_num) when cur_node_seq <= total_node_num and total_node_num !=1 do
    cur_node = "node"<>Integer.to_string(cur_node_seq) |> String.to_atom()
    cur_node_neighbors = Gossip.Node.get_neighbors(cur_node)
    if tuple_size(cur_node_neighbors) <4 do
      all_seq_list = Enum.to_list(1..total_node_num)
      seq_list_except = all_seq_list -- [cur_node_seq] -- Tuple.to_list(cur_node_neighbors)
      random_one = "node"<>Integer.to_string(Enum.random(seq_list_except)) |> String.to_atom()
      add_neighbor(cur_node, random_one)
      add_neighbor(random_one, cur_node)
    end
    build_random_connection(cur_node_seq + 1, total_node_num)
  end

  def add_neighbor(cur_node, new_neighbor) do
    neighbors = Gossip.Node.get_neighbors(cur_node)
    new_neighbors_list = Tuple.to_list(neighbors) ++ [new_neighbor]
    new_neighbors = List.to_tuple(new_neighbors_list)
    Gossip.Node.update_neighbors(cur_node, new_neighbors)
  end



  ######################## full topology ###################################
  def neighbors_for_full_nodes(cur_node_seq, total_nodes_num) when total_nodes_num == 1, do: nil
  def neighbors_for_full_nodes(cur_node_seq, total_nodes_num) when cur_node_seq == 0, do: nil
  def neighbors_for_full_nodes(cur_node_seq, total_nodes_num) when total_nodes_num < cur_node_seq, do: nil
  def neighbors_for_full_nodes(cur_node_seq, total_nodes_num) when cur_node_seq >= 1 and cur_node_seq <= total_nodes_num do
    all_nodes_tuple = create_all_nodes_tuple({}, 1, total_nodes_num)
    curnode = "node"<>Integer.to_string(cur_node_seq) |> String.to_atom()
    curnode_neighbors = Tuple.delete_at(all_nodes_tuple, cur_node_seq - 1)
    Gossip.Node.update_neighbors(curnode, curnode_neighbors)
    neighbors_for_full_nodes(cur_node_seq - 1, total_nodes_num)
  end

  def create_all_nodes_tuple(tuple, n, numnodes) when n == numnodes do
    new_tuple = Tuple.append(tuple, "node"<>Integer.to_string(n) |> String.to_atom())
  end
  def create_all_nodes_tuple(tuple, n, numnode) when n < numnode do
    new_tuple = Tuple.append(tuple, "node"<>Integer.to_string(n) |> String.to_atom())
    create_all_nodes_tuple(new_tuple, n + 1, numnode)
  end



  ######################## 2D topology ###################################
  def neighbors_for_2D_nodes(cur_node_seq, total_nodes_num) when total_nodes_num == 1, do: nil
  def neighbors_for_2D_nodes(cur_node_seq, total_nodes_num) when cur_node_seq > total_nodes_num, do: nil
  def neighbors_for_2D_nodes(cur_node_seq, total_nodes_num) when cur_node_seq >= 1 and cur_node_seq <= total_nodes_num do
    cur_node = "node"<>Integer.to_string(cur_node_seq) |> String.to_atom()
    cur_node_data = Gossip.Node.get_data(cur_node)
    cur_node_coordinates = Enum.at(cur_node_data, 6)
    cur_node_x = Enum.at(cur_node_coordinates, 0)
    cur_node_y = Enum.at(cur_node_coordinates, 1)
    cur_node_neighbors = add_neighbors({}, cur_node_x, cur_node_y, cur_node_seq, 1, total_nodes_num)
    Gossip.Node.update_neighbors(cur_node, cur_node_neighbors)
    neighbors_for_2D_nodes(cur_node_seq + 1, total_nodes_num)
  end

  def add_neighbors(tuple, x, y, cur_node_seq, other_node_seq, total_nodes_num) when other_node_seq > total_nodes_num, do: updated_neighbor_tuple = tuple
  def add_neighbors(tuple, x, y, cur_node_seq, other_node_seq, total_nodes_num) when other_node_seq == cur_node_seq do
    add_neighbors(tuple, x, y, cur_node_seq, other_node_seq + 1, total_nodes_num)
  end
  def add_neighbors(tuple, x, y, cur_node_seq, other_node_seq, total_nodes_num) when other_node_seq != cur_node_seq and other_node_seq <= total_nodes_num do
    other_node = "node"<>Integer.to_string(other_node_seq) |> String.to_atom()
    other_node_data = Gossip.Node.get_data(other_node)
    other_node_coordinates = Enum.at(other_node_data, 6)
    Gossip.Node.get_data(other_node)
    other_node_x = Enum.at(other_node_coordinates, 0)
    other_node_y = Enum.at(other_node_coordinates, 1)
    updated_neighbor_tuple = insert_a_neighbor(x, y, other_node_x, other_node_y, tuple, other_node)
    add_neighbors(updated_neighbor_tuple, x, y, cur_node_seq, other_node_seq + 1, total_nodes_num)
  end

  def insert_a_neighbor(x1, y1, x2, y2, neighbor_tuple, other_node) do
    updated_neighbor_tuple =
      if (:math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2)) <= :math.pow(10, -2) do
      Tuple.append(neighbor_tuple, other_node)
    else
      neighbor_tuple
    end
  end



  ######################## 3D topology #######################################
  def neighbors_for_3D_nodes(cur_node_seq, numnodes) when cur_node_seq > numnodes or numnodes == 1, do: nil
  def neighbors_for_3D_nodes(cur_node_seq, numnodes) when cur_node_seq <= numnodes and numnodes != 1 do
    neighbors = {}
    rows = round(:math.pow(numnodes, 1/3))
    numnodes_in_a_layer = round(:math.pow(rows, 2))
    cur_node = "node"<>Integer.to_string(cur_node_seq) |> String.to_atom()
    floor =
      if div(cur_node_seq, rows * rows) == cur_node_seq / (rows * rows) do
        div(cur_node_seq, rows * rows)
      else
        div(cur_node_seq, rows * rows) + 1
      end
    neighbors = Tuple.append(neighbors, not_left_bound(cur_node_seq, rows) && "node"<>Integer.to_string(cur_node_seq - 1) |> String.to_atom())
    neighbors = Tuple.append(neighbors, not_right_bound(cur_node_seq, rows) && "node"<>Integer.to_string(cur_node_seq + 1) |> String.to_atom())
    neighbors = Tuple.append(neighbors, not_front_bound(cur_node_seq, rows, floor) && "node"<>Integer.to_string(cur_node_seq - rows) |> String.to_atom())
    neighbors = Tuple.append(neighbors, not_back_bound(cur_node_seq, rows, floor) && "node"<>Integer.to_string(cur_node_seq + rows) |> String.to_atom())
    neighbors = Tuple.append(neighbors, not_up_bound(cur_node_seq, rows) && "node"<>Integer.to_string(cur_node_seq + numnodes_in_a_layer) |> String.to_atom())
    neighbors = Tuple.append(neighbors, not_down_bound(cur_node_seq, rows) && "node"<>Integer.to_string(cur_node_seq - numnodes_in_a_layer) |> String.to_atom())
    neighbors = tuple_delete_nil(neighbors)
    Gossip.Node.update_neighbors(cur_node, neighbors)
    neighbors_for_3D_nodes(cur_node_seq + 1, numnodes)
  end

  def not_left_bound(cur_node_seq, rows) do
    if cur_node_seq > 1 and (div(cur_node_seq - 1, rows) == div(cur_node_seq - 2, rows)) do
      true
    else
      nil
    end
  end

  def not_right_bound(cur_node_seq, rows) do
    if div(cur_node_seq, rows) == div(cur_node_seq - 1, rows) do
      true
    else
      nil
    end
  end

  def not_front_bound(cur_node_seq, rows, floor) do
    if cur_node_seq - (floor - 1) * rows * rows > rows do
      true
    else
      nil
    end
  end
  def not_back_bound(cur_node_seq, rows, floor) do
    if cur_node_seq <= :math.pow(rows, 2) * floor - rows do
      true
    else
      nil
    end
  end

  def not_down_bound(cur_node_seq, rows) do
    if cur_node_seq > :math.pow(rows, 2) do
      true
    else
      nil
    end
  end

  def not_up_bound(cur_node_seq, rows) do
    if cur_node_seq <= :math.pow(rows, 3) - :math.pow(rows, 2) do
      true
    else
      nil
    end
  end

  def tuple_delete_nil(tuple) do
    list = Tuple.to_list(tuple)
    list = [nil|list] |> Enum.uniq() |> Enum.sort() |> List.delete_at(0)
    List.to_tuple(list)
  end






end
