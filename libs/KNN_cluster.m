% function used to be a distributed work
function [patches_position, dist] = KNN_cluster(img_path, centroids, params)
  
  [patches , features_patches, pyramid] = compute_valid_patches(img_path, params);
  
  if(isempty(patches))
    disp('ALERT NO patch FOUND ');
    patches_position = [];
    dist = [];
  else
    % for each candidate what is the closest patche
    % (and not for each patch what is the closest candidate)
    % [closest_patches_idx, dist]=assigntoclosest(single(centroids),single(features_patches));
  
    [closest_patches_idx, dist]=assigntoclosest(centroids,features_patches);

    % return patch info only from the closest patches
    patches = patches(closest_patches_idx,:);
    features_patches(closest_patches_idx,:);

    patches_position = patch_level_to_position(patches, pyramid, params);
  end
end
