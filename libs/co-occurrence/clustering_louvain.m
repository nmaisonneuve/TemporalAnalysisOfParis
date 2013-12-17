function cluster_idx = clustering_louvain(sim_matrix)
  a = cluster_jl_cpp(sim_matrix);
  % 1rst level
  cluster_idx = a.COM{1}';
  
  %cluster_idx = a.COM{end}';
end