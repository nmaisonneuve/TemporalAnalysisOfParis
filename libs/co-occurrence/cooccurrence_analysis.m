function [co_matrix, co_cluster_idx] = cooccurrence_analysis(candidates, detections, co_params)

  %% Compute co-occurrence matrix
  co_matrix = cooccurrence_matrix(candidates, detections, co_params);
  
  % threshold to remove noise
  nb_filters = sum(co_matrix <= co_params.noise_threshold);
  fprintf('\nfiltering noise for threshold %f: %d link(s) removed',co_params.noise_threshold, nb_filters);
  co_matrix(co_matrix <= co_params.noise_threshold) = 0;

  %% Clustering co-occurrence
  co_cluster_idx = clustering_louvain(co_matrix);

  
end