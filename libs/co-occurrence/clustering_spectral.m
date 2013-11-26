function cluster_idx = clustering_spectral(sim_matrix)
[C,U]= SpectralClustering(sim_matrix, 10,2);
[a , b ,~ ] = find(C);
[~,sorted_idx]= sort(a);
cluster_idx = b(sorted_idx);
end