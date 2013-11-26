% clusters_assignment structure = 
% column [candidate_id , co_cluster_id]

function save_cooccurrence_clustering(clusters_assignment, patches_info, json_file)
  
  nb_clusters = max(clusters_assignment(:,2));
  
% transform data to json 
  clusters = struct();
  for (i = 1:nb_clusters)
    
    members = struct();
    members_idx = clusters_assignment(clusters_assignment(:,2)==i,1);
    for (j = 1:numel(members_idx))
      idx = members_idx(j);
      candidate_rank = find(clusters_assignment(:,1)==idx);
      fprintf('\nCluster %d, candidate idx= %d, rank = %d',i,idx,candidate_rank);
      img_id = patches_info(idx,1);  
      members(j).img_id = img_id;
      members(j).img_path = [img_id candidate_rank -1];
    end
    clusters(i).members = members;
  end
  
  savejson('',clusters,json_file);
end
