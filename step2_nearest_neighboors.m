
nb_all_imgs = numel(ds.all_imgs_idx);

% INFO:
% structure of the closest_patches matrix
% [candidate_patch_id img_id img_patch_id dist]
% colname = {'candidate_id' ,'img_id' ,'img_patch_id', 'dist'};
dist_column_id = 3;
candidate_column_id = 1;
image_column_id = 2;


% we first use a cell struct because of the parallel operator 'parfor'
closest_patches = cell(nb_all_imgs,1);
tic;
parfor i = 1: nb_all_imgs
  img_id = ds.all_imgs_idx(i);
  
  fprintf('\nComputing KNN for image %d (%d)', img_id, i);
 
  % get the nearest patch in the image for each patch candidate  (+ its distance)
  % => ! 2 NN patches could not be from the same image => good
  img_path = ds.imgs(img_id).path;
  [~, dist, patches_coordinates] = nn_cluster(img_path, initFeats, ds.params);  

  closest_patches{i} = [(1:nb_init_clusters)' ones(nb_init_clusters,1) * img_id dist  patches_coordinates];
%  closest_patches(i)= [ ... 
    %(1:nb_init_clusters)'...                        % generate cluster_id column
    %ones(nb_init_clusters,1) * img_id ....        % generate img id column
  %  dist patches_coordinates ...  
    %ones(nb_init_clusters,1) * ismember(img_id,pos_idx)... % generate label column
 % ];
end
toc;

closest_patches = cell2mat(closest_patches);

%%
% Get only the top X nearest neighbors of each patch
nb_neighbors = 20;
nb_neighbors = min(nb_all_imgs, nb_neighbors);

% each row = 1 candidate, each column k the kth nearest neighbor idx
top_nn_idx = zeros(nb_init_clusters, nb_neighbors);

% (debug) each row = 1 candidate, each column k the dist of kth nearest neighbor idx
% top_nn_dist = zeros(nb_init_clusters, nb_neighbors);
tic;
for (i = 1:nb_init_clusters)
  NN_patches_idx = find(closest_patches(:, candidate_column_id) == i);
  [top_dist , ord] = mink(closest_patches(NN_patches_idx, dist_column_id), nb_neighbors);
  top_nn_idx(i,:) = NN_patches_idx(ord)';
  %top_nn_dist(i,:) = top_dist';
end
toc;
% (debug) top_img_idx = vec2mat(closest_patches(top_nn_idx(:),image_column_id),nb_seed_candidates)';

% each row = 1 cluster, each column k: 0 or 1 if the patch is labeled
% positive or not
top_nn_positive = vec2mat(ismember(closest_patches(top_nn_idx(:),image_column_id),pos_idx),nb_init_clusters)';

%top_nn_similirarity = vec2mat(closest_patches(top_nn_idx(:),image_column_id),pos_idx),nb_init_clusters)';

% compute purity of each cluster
purity = sum(top_nn_positive,2);

% change the format a bit to get pourcentage
purity = int8(purity * 100 / nb_neighbors);

%rank clusters by purity
[~, sorted_idx] = sort(purity, 'descend');

%display the first 100 clusters (candidate + NN patches) 
nb_top_clusters = min(nb_init_clusters, 1000);

best_clusters_idx = sorted_idx(1:nb_top_clusters);




