function cooccurrence(candidates, formated_candidates, detections, method)

  %% Compute co-occurrence matrix
  co_matrix = cooccurrence_matrix(candidates(1:nb_top_detectors), detections, method);

  % save co-occurence matrix for visualisation
  json_file = [root_dir '/cooccurrences_' method '.json'];
  save_cooccurrence_network(co_matrix, formated_candidates, json_file);

  % save to pajek format
  pajek_file = [root_dir '/cooccurrences_' method '.net'];
  write_matrix_to_pajek(co_matrix,pajek_file,'weighted',true,'directed',false);

  %% Clustering co-occurrence
  co_cluster_idx = clustering_louvain(co_matrix);

  % save clustering for visualisation
  json_file = [root_dir '/clustering_' method '.json'];
  save_cooccurrence_clustering(co_cluster_idx, formated_candidates,json_file);
end