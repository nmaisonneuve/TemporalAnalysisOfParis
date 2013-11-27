

%%
  % formatting output data 
  %generate the clusters struct
  clusters = struct();
  patches_to_crops = [];

  for (i = 1 : numel(best_clusters_idx))
  
    clusters(i).id = best_clusters_idx(i);
    
    % the centroids
    centroid_pos = patches(best_clusters_idx(i),:);
    
    centroid.position = centroid_pos(:);
    centroid.img_path = [centroid_pos(1)  i -1];
    % patch level
    
    centroid.level = patch_size(centroid.position(2:5)') /ds.params.patchCanonicalSize(1);
    clusters(i).centroid = centroid;
    
    tmp = [centroid_pos i -1];
    patches_to_crops = [patches_to_crops; tmp];
    
    % the related Nearest neighboors patches [img_id, patch_id]
    nn_patches = closest_patches(top_nn_idx(best_clusters_idx(i),:),[2 4:7]);
    tmp = [nn_patches ones(size(nn_patches,1),1)*i (1:size(nn_patches,1))'];
    patches_to_crops = [patches_to_crops; tmp];
    nn = struct();
     for (j = 1: size(nn_patches,1))
       nn(j).img_path = [nn_patches(j,1), i, j]; %sprintf('%d/cluster_%d_patch_%d.jpg',  nn_patches(j,1), i, j);
       nn(j).label = ismember(nn_patches(j,1),pos_idx);
     
     end
    clusters(i).nn = nn;
 
    % purity 
    clusters(i).purity = purity(best_clusters_idx(i));
  end


create = true;
 root_dir = sprintf('results/%s/nn',ds.params.experiment_name);
 
if (create)
  % clean dir 
   if (exist(root_dir))
    rmdir(root_dir,'s');
   end 
   mkdir(root_dir);
end


% save clusters.json

json_file = [root_dir '/clusters_knn.json'];
savejson('',clusters,json_file);

if (create)
  % extract images
  img_dir = [root_dir '/images'];
  mkdir(img_dir);
  save_img_patches(patches_to_crops, imgs, img_dir);
  
  %save_img_patches([clusters.nn], imgs, img_dir);
end
end



