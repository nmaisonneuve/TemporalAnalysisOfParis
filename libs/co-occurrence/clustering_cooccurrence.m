function cluster_idx = clustering_cooccurrence(sim_matrix)
  Z = linkage(sim_matrix,'average');
  cluster_idx = cluster(Z,'maxclust',4);
end