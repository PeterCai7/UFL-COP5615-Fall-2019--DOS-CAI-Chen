# Project2

**TODO: Add description**

Team: Kailin Chen, Yinan Chen
###############################################

Command Line in terminal:

./gossip numNodes topology algorithm numFailures

################# ABOUT THIS PROJECT#################

This program builds up following kinds of topology:

line : Node only have neighbor before or after it except the first and last actor(node in our project)

ImpLine: Line arrangement but one other random neighbor is selected from the rest of nodes list

full : Every node is the neighbor of every other node

3D grid: Nodes form a 3D grid. Each node havs at least 3 neighbors and at most 6 neighbors. The nodes can only talk to the grid neighboors.

torus: Nodes are arranged in a torus. Each node has 4 neighbors(similar to 2D grid),but both directions are closed to form circles,just like torus, at first giving a 2D square grid and then let the boundary point connect to its'leftmost, rightmost,upmost and downmost side.

random2D grid: Nodes are randomly positioned at x,y coordinnates on a [0-1,0]X[0-1.0] square.Two nodes are connected if they are within 0.1 distance to each other.

And test how fast gossip and push sum (s is node number and w is 1 for all nodes) can converge on these four topologies. You can specify your network size in command line.

Input:

numNodes topology algorithm numFailures

numNodes is the number of nodes involved (for torus topology it is round up until getting a square; for 3D topology it is round up until getting a cube). 

topology should be one of {line, impline, full, 2D, 3D, torus} which matches {Line, Imperct Line, Full Network, Random 2D Grid, 3D Grid, torus} respectively.

algorithm should be one of gossip and pushsum, which represent Gossip and Push-Sum respectively.

numFailures is the number of failures

Output:

The amount of time it took to complete the algorithm.


################ LARGEST PROBLEM SCALE####################

We didn't compute the largest problem scale for failure model

################## IMPORTANT NOTICE####################
Notice:

In our project, we control the node not to send rumor anymore once it receives rumor 50 times rather than kill this node.
That means, whenever a node heard the rumor 50 times, other nodes' rumor play the role of a stop message.
But since handle_cast is an asynchronous request, so the 'erlang.exit(nil, :kill)' error may occur.

Please use numNodes which is greater than 1. Considering the round operation in 3D topology and torus topology.
Please use numNodes no less than 4 for torus and use numNodes no less than 8 for 3D Grid.

There might be some warning about unused variables, but they are won't affect the running.

For gossip, each node will start sending message once it has received one, and stops transmitting once it has head the rumor 50(we set it to be 50 in this proj) times. 

For pushsum, node only send message one time when received message one time, and convergence condition is sum estimation does not change more than 1.0e-10 in three consecutive rounds.

For Random 2D Grid topology, we randomly assigned a x,y coordinates to each node when it was created. 
It will lead to some situation that some nodes might be isolated and won't have neighbors to send message, unless you
use a really big numNodes. 
！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
Whenever this issue happens: 
We hold the receive process for 3s and after that, we deal like following:

In gossip algorithm, we choose to send a rumor to that isolated
node; 

In push-sum algorithm, we choose to states that the algorithm cannot be converged because of isolated node.
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `project2` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:project2, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/project2](https://hexdocs.pm/project2).

