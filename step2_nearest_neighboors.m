
nb_all_imgs = numel(ds.all_imgs_idx);

% Structure of the closest_patches matrix:
% [candidate_patch_id img_id patch_id dist]
% colname = {'candidate_id' ,'img_id' ,'patch_id', 'dist'};
dist_column_id = 3;
candidate_column_id = 1;
image_column_id = 2;

% we first use a cell struct because of the parallel operator 'parfor'
tic;
closest_detections = cell(nb_all_imgs,1);

parfor i = 1: nb_all_imgs
  
  img_id = ds.all_imgs_idx(i);
  img_path = ds.imgs(img_id).path;
  
  fprintf('\nComputing KNN for image %d (%d)', img_id, i);
  
  % get the nearest patch in the image for each patch candidate  (+ its distance)
  % => ! 2 NN patches could not be from the same image => good
  [~, dist, patches_coordinates] = KNN_cluster(img_path, initFeats, ds.params);  

  closest_detections{i} = [...
    (1:nb_init_clusters)' ...
    ones(nb_init_clusters,1) * img_id dist  ...
    patches_coordinates ...
   ];
end
closest_detections = cell2mat(closest_detections);
toc;

% k_nn = number of the nearest neighboors used for each candidate
% to compute purity according to their label and rank candidates
k_nn = 20;
[ranked_candidates_idx, purity, members_idx] = KNN_ranking_candidates(closest_detections, k_nn ,pos_idx);

% remove overlapping patches beyond a threshold
% and keep only the purest candidates
to_keep_patches_idx = remove_overlapping_patches(patches, ds.params.patchOverlapThreshold, purity);

% intersection {ranked patches, kept patches}
% producing a new ranking
[~, inter_ranked_idx, ~ ] = intersect(ranked_candidates_idx, to_keep_patches_idx);
inter_ranked_idx = sort(inter_ranked_idx);

% clean ranking 
ranked_candidates_idx = ranked_candidates_idx(inter_ranked_idx);
purity = purity(inter_ranked_idx);
members_idx = members_idx(inter_ranked_idx,:);

% get the top 5% most discriminative patches 
nb_top_detectors = uint8(0.05 * size(patches,1));
best_candidates_idx = ranked_candidates_idx(1:nb_top_detectors);

hist(double(purity),100);
print -dpng 'test.png';

KNN_visualisation(patches(best_candidates_idx,:), purity(best_candidates_idx), member_idx(best_candidates_idx), closest_patches);

 