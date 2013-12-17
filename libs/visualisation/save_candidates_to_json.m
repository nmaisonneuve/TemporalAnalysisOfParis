function clusters = save_candidates_to_json(candidates, patches, detections, json_file)
%%
  % formatting output data 
  %generate the clusters struct

  %for c_idx = 1:size(patches,1);
  clusters = struct();
  tic;
  for i = 1:numel(candidates);
    
    c_idx = candidates(i).id;
    
    clusters(i).id = c_idx;
    clusters(i).purity = candidates(i).purity;
    clusters(i).frequency = candidates(i).frequency;
    clusters(i).purity_k = candidates(i).purity_k;
    clusters(i).frequency_k = candidates(i).frequency_k;
    clusters(i).mean = candidates(i).mean;

    % the centroids
    centroid = struct();
    centroid.img_path = patches(c_idx,:);
    centroid.size = patch_size(patches(c_idx,2:5));
   
    clusters(i).centroid = centroid;
    
    % the related Nearest neighboors patches [img_id, patch_id]
    nn_patches = detections(candidates(i).nn_detections_idx, [2 4:7]);
    nn = struct();
    for (j = 1: size(nn_patches,1))
     nn(j).img_path = [nn_patches(j,:)]; 
     %if (c_idx ~= detections(top_members_idx(i,j),1))
     % fprintf('\ncandidates %d : member candidates %d', c_idx,  detections(top_members_idx(i,j),1));
     %end
     nn(j).label = candidates(i).labels(j);
    end
    clusters(i).nn = nn;
  end
  toc;
  savejson('',clusters,json_file);
end
