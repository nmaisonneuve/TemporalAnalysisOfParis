% clusters_assignment structure = 
% column [candidate_id , co_cluster_id]

function save_cooccurrence_clustering(clusters_idx, candidates, json_file)
  
nb_clusters = max(  clusters_idx);

% transform data to json 
  clusters = struct();
  for (i = 1:nb_clusters)    
    members_idx = find(clusters_idx == i);
    members = struct();
    for (j = 1:numel(members_idx))
      %fprintf('\nCluster %d, candidate idx= %d, rank = %d',i,idx,candidate_rank);
      members(j).id = candidates(members_idx(j)).id;
      members(j).img_path = candidates(members_idx(j)).centroid.img_path;
    end
    clusters(i).members = members;
  end
  
  savejson('',clusters,json_file);
end
