  %%
  % formatting output data 
  %generate the clusters struct
  
  % sorted by dist (lower = better)
  [~, sorted_idx ] = sort(clusters_co(:,3));
  clusters_co = clusters_co(sorted_idx,:);
  
  top_sim = min(size(clusters_co,1), 1000);
  similarity = struct();
  for (i = 1 :  top_sim)
  
    patch_a = struct();
    patch_b = struct();
    
    patch_a.id = clusters_co(i,1);
    patch_b.id = clusters_co(i,2);
           
    pos = patches(cluster_a_idx,:);
    patch_a.img_id =  pos(1);
    patch_a.patch_id =  patch_a.id;
    patch_a.cluster_id =  patch_a.id;
    patch_a.x1 = pos(2);
    patch_a.x2 = pos(3);
    patch_a.y1 = pos(4);
    patch_a.y2 = pos(5);
    
    pos = patches(cluster_b_idx,:);
    patch_b.img_id =  pos(1);
    patch_b.patch_id =  patch_b.id;
    patch_b.cluster_id =  patch_b.id;
    patch_b.x1 = pos(2);
    patch_b.x2 = pos(3);
    patch_b.y1 = pos(4);
    patch_b.y2 = pos(5);
   
    similarity(i).patch_a = patch_a;
    similarity(i).patch_b = patch_b;
    similarity(i).co_occurence = clusters_co(i,3); 
  end


% create dir to save results from this experiment
root_dir = sprintf('results/%s/co_occurence',ds.params.experiment_name)
mkdir(root_dir);

% generate images
img_dir = [root_dir '/images'];
mkdir(img_dir); 
extract_patches_from_position([similarity.patch_a], imgs, img_dir);
extract_patches_from_position([similarity.patch_b], imgs, img_dir);

% save co_occurrence.json
json_file = [root_dir '/co_occurrence.json'];
savejson('',similarity,json_file);