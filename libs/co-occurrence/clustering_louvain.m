function cluster_idx = clustering_louvain(sim_matrix)
  a = cluster_jl_cpp(sim_matrix);
  disp(a);
  % 1rst level
  cluster_idx = a.COM{1}';
  
  %cluster_idx = a.COM{end}';
end