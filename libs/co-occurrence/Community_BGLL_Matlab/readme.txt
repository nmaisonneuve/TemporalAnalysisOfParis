Matlab / C++ implementation of community detection algorithm.
After "Fast unfolding of community hierarchies in large networks"
Vincent D. Blondel, Jean-Loup Guillaume, Renaud Lambiotte and
Etienne Lefebvre
Journal of Statistical Mechanics: Theory and Experiment, 1742-5468, P10008 (12 pp.), 2008.

Implementation : Antoine Scherrer
antoine.scherrer@ens-lyon.fr

*** USAGE - Full matlab

Event E1 =  patch A et B s'overlape
Event E2 = Patch B est detecte
Event E3 = Patch A est detecte

Event E4 = patch A et B sont détecte

P(E4) = P(E2 inter Ee) = P(E2).P(E3)
P(E1/E4) = P(E1 inter E4) / P(E4)
  
P(E1/E4) = P(E4/E1) * P(E1)/ P(E4)

Si P(E1 et B) sont indépendant P(E1/E2) = P(E1)


probabilité que (A et B s'overlapp / sachant que A et B ont été fire)


See help of m files for details.

cluster_jl.m : Weighted (or not), non oriented version of algorithm 
 matrix is symetrized using sum of incoming and outgoing weights)

cluster_jl_orient.m : Weighted (or not), oriented version of algorithm 
 using extended definition of modularity for oriented graphs 

cluster_jl_orientT.m : Weighted (or not), oriented version of algorithm 
 using symetric matrix A = M*M^t 

*** USAGE - Matlab/C++

You need to compile jl_clust.cpp, jl_mnew.cpp and jl_clust_orient.cpp
with mex compiler. Then you can use the following routines to perform
the community detection faster.

cluster_jl_cpp.m : Weighted (or not), non oriented version of algorithm 
 matrix is symetrized using sum of incoming and outgoing weights)

cluster_jl_orient_cpp.m : Weighted (or not), oriented version of algorithm 
 using extended definition of modularity for oriented graphs 

cluster_jl_orientT_cpp.m : Weighted (or not), oriented version of algorithm 
 using symetric matrix A = M*M^t 


