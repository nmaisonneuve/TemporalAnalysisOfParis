function [co_matrix, co_cluster_idx] = cooccurrence_analysis(candidates, formated_candidates, detections, co_params, root_dir)

  %% Compute co-occurrence matrix
  co_matrix = cooccurrence_matrix(candidates, detections, co_params);
  
  co_matrix(co_matrix ==1) = 0;
  
  % save co-occurence matrix for visualisation
  json_file = [root_dir '/cooccurrences_' co_params.context '.json'];
  save_cooccurrence_network(co_matrix, formated_candidates, json_file);

  % save to pajek format
  pajek_file = [root_dir '/cooccurrences_' co_params.context '.net'];
  write_matrix_to_pajek(co_matrix,pajek_file,'weighted',true,'directed',false);

  %% Clustering co-occurrence
  co_cluster_idx = clustering_louvain(co_matrix);

  % save clustering for visualisation
  json_file = [root_dir '/clustering_' co_params.context '.json'];
  save_cooccurrence_clustering(co_cluster_idx, formated_candidates,json_file);
end