  %%
  % formatting output data 
  %generate the clusters struct
  
  % sorted by dist (lower = better)

  top_sim = min(size(clusters_co,1), 1000);
  similarity = struct();
  patches_to_crops = [];
  j = 1;
  for (i = 1:top_sim)
    
    cluster_a_idx = clusters_co(i,1);
    cluster_b_idx = clusters_co(i,2);
 
    
    patch_A = patches(cluster_a_idx,:);
    patch_B = patches(cluster_b_idx,:);
    % cluster same image , potential bug
    if (patch_A(1) == patch_B(1))
      %disp('error warning same image: cluster idx');
      
    else 
    patches_to_crops = [patches_to_crops; [patch_A cluster_a_idx -1]];
    patches_to_crops = [patches_to_crops; [patch_B cluster_b_idx -1]];
   
    similarity(j).patch_a = [patch_A(1) cluster_a_idx -1];
    similarity(j).patch_b = [patch_B(1) cluster_b_idx -1];
    similarity(j).co_occurence = clusters_co(i,3); 
    j = j +1;
    end
    
  end


% create dir to save results from this experiment
root_dir = sprintf('results/%s/cooccurence',ds.params.experiment_name);
 if (exist(root_dir))
  rmdir(root_dir,'s')
 end 
mkdir(root_dir);

% generate images
img_dir = [root_dir '/images'];
mkdir(img_dir); 
save_img_patches(patches_to_crops, imgs, img_dir);

% save co_occurrence.json
json_file = [root_dir '/cooccurrence.json'];
savejson('',similarity,json_file);