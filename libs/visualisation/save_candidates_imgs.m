
function save_candidates_imgs(candidates, patches, detections, imgs, img_dir)
 

  % Collect metadata (img_id + position) of all the relevant patches 
  % (centroids + members of clusters) to crops
  patches_to_crops = patches([candidates.id],:);
  
  parfor i = 1:numel(candidates)
    
    % the related Nearest neighboors patches [img_id, patch_id]
    nn_patches = detections(candidates(i).nn_detections_idx,[2 4:7]);
    
    patches_to_crops = [
      patches_to_crops;...
      nn_patches 
    ];  
    
  end

  % create dir or clean it
  %if (exist(img_dir))
  %  rmdir(img_dir,'s');
  %end 
  %mkdir(img_dir);

  % crop and save
  save_img_patches(patches_to_crops, imgs, img_dir);
end
