function save_candidates_to_json(patches, purity, top_members_idx, detections, json_file)
%%
  % formatting output data 
  %generate the clusters struct
  clusters = struct();
  for c_idx = 1:numel(patches);
  
    clusters(c_idx).id = c_idx;
    clusters(c_idx).purity = purity(c_idx);
    
    % the centroids
    centroid_pos = patches(c_idx,:)
    centroid.position = centroid_pos(:);
    centroid.img_path = [centroid_pos(1)  c_idx -1];
    centroid.level = patch_size(centroid.position(2:5)') /ds.params.patchCanonicalSize(1);
    clusters(c_idx).centroid = centroid;
    
    % the related Nearest neighboors patches [img_id, patch_id]
    nn_patches = detections(top_members_idx(c_idx,:), [2 4:7]);
    nn = struct();
     for (j = 1: size(nn_patches,1))
       nn(j).img_path = [nn_patches(j,1), c_idx, j]; 
       %sprintf('%d/cluster_%d_patch_%d.jpg',  nn_patches(j,1), i, j);
       nn(j).label = ismember(nn_patches(j,1),pos_idx);
     
     end
    clusters(c_idx).nn = nn;
 
    % purity 
  
  end
  
  savejson('',clusters,json_file);
  
end
