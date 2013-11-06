% clear workspace
clear;

% load configuration
config();

% preparing the dataset for the experiment
load_data();

%%%% STEP 1 - computing seed candidate patches

step1_todo = true;

if (step1_todo)
  
  % takes a ramdom sample of positive images
  % to get seed patch candidates
  seed_pos_idx = randsample(numel(pos_idx),ds.params.seed_candidate_size);
  fprintf('\nComputing candidate patches from %d positive images', numel(seed_pos_idx));
    
  % number of initial clusters
  nb_init_clusters = numel(seed_pos_idx) * ds.params.seed_patches_per_image;

  % take {ds.seed_candidate_size} random patches from each selected image
  initPatches = [];
  initFeats = [];
  parfor i = 1: numel(seed_pos_idx)  
    idx = seed_pos_idx(i);
    fprintf('\nComputing patches from image %d (idx: %d)', i, idx);
    [new_patches, new_feats, ~] = sampleRandomPatches(idx, ds, ds.params.seed_patches_per_image);
    
    %append
    initPatches = [initPatches new_patches];
    initFeats = [initFeats; new_feats];
  end
  
  initPatches = initPatches';
  
  % normalizing candidate clusters
  centers = bsxfun(@rdivide,bsxfun(@minus,initFeats,mean(initFeats,2)),...
    sqrt(var(initFeats,1,2)).*size(initFeats,2));
  
  % save workspace
  save('data/step1_workspace_state.mat');
else
  disp('loading workspace state at step 1');
  load('data/step1_workspace_state.mat');
end


%%% STEP 2 - computing nearest neighbors

nb_all_imgs = numel(ds.all_imgs_idx);

% INFO:
% structure of the closest_patches matrix
% [candidate_patch_id img_id img_patch_id dist]
% colname = {'candidate_id' ,'img_id' ,'img_patch_id', 'dist'};
closest_patches = [];
dist_column_id = 3;
candidate_column_id =1;
image_column_id =2;


%img_patches = zeros(nb_all_imgs * nb_init_clusters,5);
parfor i = 1: nb_all_imgs
  img_id = ds.all_imgs_idx(i);
  
  fprintf('\nComputing KNN for image %d (%d)', img_id, i);
  
  % generate img id column
  img_id_column = ones(nb_init_clusters,1) * img_id;
  
  % get the nearest patch in the image for each patch candidate  (+ its distance)
  % => in the NN process, 2 NN patches could not be from the same image =>
  % good
  % get image path
  img_path = ds.imgs(img_id).path;
  [~, dist, patches_coordinates] = nn_cluster(img_path, centers, ds.params);
  
  %img_patches(1+(i-1) * nb_init_clusters  : i * nb_init_clusters, :) = [img_id_column patches_coordinates];
  %img_patches = [img_patches; [img_id_column patches_coordinates]];
  
  % append
  closest_img_patches = [img_id_column dist patches_coordinates];
  
  closest_patches = [closest_patches; closest_img_patches];
end

% add a 'cluster_id' column
closest_patches = [repmat((1:nb_init_clusters), 1, nb_all_imgs)' closest_patches];

%(debug) add label 
%closest_patches = [closest_patches ismember(closest_patches(:,2), pos_idx)];


%%
% Get only the top 20 nearest neighbors of each patch
nb_neighbors = 20;
nb_neighbors = min(nb_all_imgs,nb_neighbors);

% each row = 1 candidate, each column k the kth nearest neighbor idx
top_nn_idx = [];

% (debug) each row = 1 candidate, each column k the dist of kth nearest neighbor idx
top_nn_dist = [];

parfor (i = 1:nb_init_clusters)
  NN_patches_idx = find(closest_patches(:, candidate_column_id) == i);
  [top_dist , ord] = mink(closest_patches(NN_patches_idx, dist_column_id), nb_neighbors);
  top_nn_idx = [top_nn_idx; NN_patches_idx(ord)'];
  %top_nn_dist = [top_nn_dist; top_dist'];
end

% (debug) top_img_idx = vec2mat(closest_patches(top_nn_idx(:),image_column_id),nb_seed_candidates)';

% each row = 1 cluster, each column k: 0 or 1 if the patch is labeled
% positive or not
top_nn_positive = vec2mat(ismember(closest_patches(top_nn_idx(:),image_column_id),pos_idx),nb_init_clusters)';

% compute purity of each cluster
purity = sum(top_nn_positive,2);

% change the format a bit to get pourcentage
purity = int8(purity * 100 / nb_neighbors);

%rank clusters by purity
[~, sorted_idx] = sort(purity, 'descend');

%display the first 100 clusters (candidate + NN patches) 
best_clusters_idx = sorted_idx(1:100);


%%
% formatting output data 
%generate the clusters struct
clusters = struct();
for (i = 1 : numel(best_clusters_idx))
  
  % the centroids
  centroid =  initPatches(best_clusters_idx(i)); 
  centroid.patch_id = -1;
  centroid.cluster_id = i;
  clusters(i).centroid = centroid;
  % the related Nearest neighboors patches [img_id, patch_id]
  nn_patches = closest_patches(top_nn_idx(best_clusters_idx(i),:),[2 4:7]);
  nn = struct();
   for (j = 1: size(nn_patches,1))
     nn(j).cluster_id = i;
     nn(j).img_id = nn_patches(j,1);
     nn(j).patch_id = j;
     %nn(j).patch = nn_patches(j,2:end);
     nn(j).x1 = nn_patches(j,2);
     nn(j).x2 = nn_patches(j,3);
     nn(j).y1 = nn_patches(j,4);
     nn(j).y2 = nn_patches(j,5);
     nn(j).label = ismember(nn_patches(j,1),pos_idx);
   end
  clusters(i).nn = nn;
  
  % purity 
  clusters(i).purity = purity(best_clusters_idx(i));
end


% generate a html page to see the results at this stage
% (too many params...)
generate_html_view(clusters, ds.imgs);


% STEP 3 : to continue...