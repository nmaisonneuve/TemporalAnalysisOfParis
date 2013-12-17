
% SAVING 
function save_cooccurrences(co_matrix, co_cluster_idx, patches, co_dir)
  % save co-occurence matrix for visualisation
  json_file = [co_dir '/cooccurrences.json'];
  save_cooccurrence_network(co_matrix, patches, json_file);
  
 % save to pajek format
  pajek_file = [co_dir '/cooccurrences.net'];
  write_matrix_to_pajek(co_matrix,pajek_file,'weighted',true,'directed',false);
  
  % save clustering for visualisation
  json_file = [co_dir '/clusters.json'];
  save_cooccurrence_clustering(co_cluster_idx, patches,json_file);
end
