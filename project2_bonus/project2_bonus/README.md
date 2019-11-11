# Project2

**TODO: Add description**

Team:Ju Cai UFID:9669-1796, Tianyang Chen UFID:4925-2917
###############################################

Command Line in terminal:

./my_program numNodes topology algorithm numFailures

(On windows)  escript my_program numNodes topology algorithm  numFailures

################# ABOUT THIS PROJECT#################

This program builds up following kinds of topology:

line : Node only have neighbor before or after it except the first and last actor(node in our project)

full : Every node is the neighbor of every other node

3D grid: Nodes form a 3D grid. Each node havs at least 3 neighbors and at most 6 neighbors. The nodes can only talk to the grid neighboors.

random2D grid: Nodes are randomly positioned at x,y coordinnates on a [0-1,0]X[0-1.0] square.Two nodes are connected if they are within 0.1 distance to each other.

honeycomb:Actors are arranged in form of hexagons. Two actors are connected if they are connected to each other. Each actor has maximum degree 3.

honeycomb with a random neighbor: Actors are arranged in form of hexagons (Similar to Honeycomb). The only difference is that every node has one extra connection to a random node in the entire network.

And test how fast gossip and push sum (s is node number and w is 1 for all nodes) can converge on these six topologies. You can specify your network size in command line.

Input:

numNodes topology algorithm numFailures

numNodes is the number of nodes involved (for torus topology it is round up until getting a square; for 3D topology it is round up until getting a cube). 

topology should be one of {line, honeycomb, full, 2D, 3D, randomhoney} which matches {Line, honeycomb, Full Network, Random 2D Grid, 3D Grid, honeycomb with a random neighbor} respectively.

algorithm should be one of gossip and pushsum, which represent Gossip and Push-Sum respectively.

numFailures is the number of failures

Output:

The amount of time it took to complete the algorithm.


################ LARGEST PROBLEM SCALE####################

We didn't compute the largest problem scale for failure model

################## IMPORTANT NOTICE####################
Notice:

In our project, we control the node not to send rumor anymore once it receives rumor 100 times rather than kill this node.
That means, whenever a node heard the rumor 100 times, other nodes' rumor play the role of a stop message.
But since handle_cast is an asynchronous request, so the 'erlang.exit(nil, :kill)' error may occur.

Please use numNodes which is no less than 1. Considering the round operation in 3D topology.

There might be some warning about unused variables, but they are won't affect the running.

For gossip, each node will start sending message once it has received one, and stops transmitting once it has head the rumor 100(we set it to be 100 in this proj) times. 

For pushsum, node only send message one time when received message one time, and convergence condition is sum estimation does not change more than 1.0e-10 in three consecutive rounds.

For Random 2D Grid topology, we randomly assigned a x,y coordinates to each node when it was created. 
It will lead to some situation that some nodes might be isolated and won't have neighbors to send message, unless you
use a really big numNodes. 

Whenever this issue happens: 
We hold the receive process for 3s and after that, we deal like following:

In gossip algorithm, we choose to send a rumor to that isolated node; 

In push-sum algorithm, we choose to states that the algorithm cannot be converged because of isolated node.



