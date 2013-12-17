% clusters_assignment structure = 
% column [candidate_id , co_cluster_id]

function save_cooccurrence_clustering(clusters_idx, patches, json_file)
  
  nb_clusters = max(clusters_idx);

 % [patches(:,6), patches(:,7)] = patch_size(patches(:,2:5));
 % transform data to json 
  clusters = struct();
  for (i = 1:nb_clusters)    
  
    members_idx = find(clusters_idx == i);
    members = struct();
    for (j = 1:numel(members_idx))
      %fprintf('\nCluster %d, candidate idx= %d, rank = %d',i,idx,candidate_rank);
      members(j).id = members_idx(j);
      members(j).img_path = patches(members_idx(j),1:5);
    end
    
    clusters(i).members = members;
  end
  
  savejson('',clusters,json_file);
end
