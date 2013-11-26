
nb_all_imgs = numel(ds.all_imgs_idx);

% Structure of the closest_patches matrix:
% [candidate_patch_id img_id img_patch_id dist]
% colname = {'candidate_id' ,'img_id' ,'img_patch_id', 'dist'};
dist_column_id = 3;
candidate_column_id = 1;
image_column_id = 2;

% we first use a cell struct because of the parallel operator 'parfor'
tic;
closest_detections = cell(nb_all_imgs,1);
parfor i = 1: nb_all_imgs
  img_id = ds.all_imgs_idx(i);
  fprintf('\nComputing KNN for image %d (%d)', img_id, i);
  % get the nearest patch in the image for each patch candidate  (+ its distance)
  % => ! 2 NN patches could not be from the same image => good
  img_path = ds.imgs(img_id).path;
  [~, dist, patches_coordinates] = KNN_cluster(img_path, initFeats, ds.params);  

  closest_detections{i} = [(1:nb_init_clusters)' ...
    ones(nb_init_clusters,1) * img_id dist  ...
    patches_coordinates];
end
closest_detections = cell2mat(closest_detections);
toc;


% k_nn = number of the nearest neighboors used for each candidate
% to compute purity according to their label and rank candidates
k_nn = 20;
[ranked_candidates_idx, purity,members_idx] = KNN_ranking_candidates(closest_detections, k_nn ,pos_idx);

% select only the top N candidates
nb_top_detectors = 300;
best_candidates_idx = ranked_candidates_idx(1:nb_top_detectors);

