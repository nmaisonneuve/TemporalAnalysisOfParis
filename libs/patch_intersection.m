% INPUT
% patches = [img_id x1, x2, y1, y2]

% OUTPUT 
% overlap = [indice_patchA, indice_patchB, ratio of surface of patchA overlapping
% patchB]
% (NOTE: return only the overlapping pairs)

function overlap = patch_intersection(patches)
  tic;
  imgs = unique(patches(:,1))';
  overlap = [];
  for (img_id = imgs)
 
    img_patches_idx = find(patches(:,1)== img_id);
    
    img_overlap = patch_intersection_per_img(patches(img_patches_idx,2:5));
    
    % transform to global index
    img_overlap(:,1) = img_patches_idx(img_overlap(:,1));
    img_overlap(:,2) = img_patches_idx(img_overlap(:,2));
    % append
    overlap = [overlap; img_overlap];
    
  end
  toc;
end