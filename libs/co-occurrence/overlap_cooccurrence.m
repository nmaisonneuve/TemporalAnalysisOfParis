function overlaps = overlap_cooccurrence(patches_a, patches_b, min_overlap_threshold)
  
  if (nargin<3)
    min_overlap_threshold = 0;
  end

  overlaps = [];
  
% P(overlap,image shared) = P(image shared) * P(overlap/ image shared)
  % compute the shared image
  shared_images = intersect(patches_a(:,1), patches_b(:,1));
  shared_images = unique(shared_images);

  %fprintf('\n%d shared images ',numel(shared_images));
  
  % for each shared image, compute how many are overlapping
  for (i = 1:numel(shared_images))
    pa_idx = find(patches_a(:,1)== shared_images(i));
    pb_idx = find(patches_b(:,1)== shared_images(i));
    
    % for all the possible pairwise
    pairs = allcomb(pa_idx, pb_idx);
    
    img_patches_a = patches_a(pairs(:,1),2:5);
    img_patches_b = patches_b(pairs(:,2),2:5);
    
      % compute their size
    [width, height ] = patch_size(img_patches_a);
    area_a = width.*height;

    [width, height ] = patch_size(img_patches_a);
     area_b = width.*height;
 
   % swap pair to get patch with the smallest area always in first column
    [min_area, ~] = min([ area_a ,area_b], [], 2);
  
    % number of pairs
    inter_area = patch_intersection_basic(img_patches_a, img_patches_b);
    inter_relative = inter_area ./min_area ;
    img_overlaps = find(inter_relative > min_overlap_threshold);
    if (~isempty(img_overlaps))
      overlaps = [overlaps; [pairs(img_overlaps,1) pairs(img_overlaps,2) inter_relative(img_overlaps)]];
    end
  end
 
end