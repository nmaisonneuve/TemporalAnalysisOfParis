
% transform data to json 
clusters = struct();
for (i = 1:nb_co_clusters) 
  members = struct();
  members_idx = co_clusters(co_clusters(:,2)==i,1);
  for (j = 1:numel(members_idx))
    idx = members_idx(j);
    members(j).img_id = patches(best_clusters_idx(idx),1);    
    members(j).img_path = [img_id idx -1];
  end
  clusters(i).members=members;
end

%save
root_dir = sprintf('results/%s/cooccurrence',ds.params.experiment_name);
json_file = [root_dir '/clustering.json'];
savejson('',clusters,json_file);
