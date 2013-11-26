function co_occurence = overlap_cooccurence(patches_a, patches_b)
  % image co-occurrency:  present in the same images ?
  shared_images = intersect(patches_a(:,1), patches_b(:,1));
  shared_images = unique(shared_images);

  
  co_occurence = 0;
  for (i = 1:numel(shared_images))
    pa_idx = patches_a(:,1)==shared_images(i);
    pb_idx = patches_b(:,1)==shared_images(i);

    img_patches_a = patches_a(pa_idx,2:5);
    img_patches_b = patches_b(pb_idx,2:5);
    
    % number of pairs
    inter_area = patch_intersection(img_patches_b,img_patches_a);
    nb_overlapping_patches = numel(nonzeros(inter_area));
    disp(inter_area);
    co_occurence = co_occurence + nb_overlapping_patches;
  end
 
end