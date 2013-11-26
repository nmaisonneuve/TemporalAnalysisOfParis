function cluster_idx = clustering_hierarchical(sim_matrix)
  Z = linkage(sim_matrix,'single');
  cluster_idx = cluster(Z,'maxclust',10);
  dendrogram(Z);
end