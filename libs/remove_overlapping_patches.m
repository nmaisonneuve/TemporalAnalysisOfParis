% remove overlapping patches beyond a threshold
% and keep only the candidates with the highest purity/priority score
function to_keep_patches_idx = remove_overlapping_patches(patches, threshold, priority)
  
  %debug
  %nb_init = size(patches,1);

  % computer overlapping
  intersection = filter_overlapping_patches(patches);

  % we keep only patches overlapping less than a threshold
  over = find((intersection(:,3) < threshold));

  %debug
  %nb_overlapping = numel(unique([intersection(over,1); intersection(over,2)]));

  % for each pair, choosing which one to select according to a given priority(e.g. purity)
  to_keep_first_patch = find(priority(intersection(over,1)) > priority(intersection(over,2)));
  to_keep_second_patch = setdiff(over, over(to_keep_first_patch));
  
  
  to_keep_patches_idx = unique([intersection(to_keep_first_patch,1); intersection(to_keep_second_patch,2)]);
  
  %to_remove = setdiff(1:size(patches,1), selected);
end
