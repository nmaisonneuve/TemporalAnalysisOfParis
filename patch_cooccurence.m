
%%
% Get only the top X nearest neighbors of each patch
nb_neighbors = 50;
nb_neighbors = min(nb_all_imgs, nb_neighbors);

% each row = 1 candidate, each column k the kth nearest neighbor idx
top_nn_idx = zeros(nb_init_clusters, nb_neighbors);

% (debug) each row = 1 candidate, each column k the dist of kth nearest neighbor idx
% top_nn_dist = zeros(nb_init_clusters, nb_neighbors);
tic;
parfor (i = 1:nb_init_clusters)
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
[~, sorted_idx] = sort(purity,1, 'descend');

%display the first 100 clusters (candidate + NN patches) 
nb_top_clusters = min(nb_init_clusters, 300);

best_clusters_idx = sorted_idx(1:nb_top_clusters);


% create co-occurrence matrix
clusters_co = nchoosek(best_clusters_idx,2);
  
%sort value: first column smaller than 2nd column
clusters_co(:,1:2) = [min(clusters_co(:,1:2),[],2) max(clusters_co(:,1:2),[],2)];

% add  image co-occurrence column
clusters_co = [clusters_co ones(size(clusters_co,1),1)];

for (i = 1:size(clusters_co,1))
  cluster_a_idx = clusters_co(i,1);
  cluster_b_idx = clusters_co(i,2);

  % get the first X nearest neigboors patches
  patches_a = closest_patches(top_nn_idx(cluster_a_idx,:),:);
  patches_b = closest_patches(top_nn_idx(cluster_b_idx,:),:);

  % image co-occurrency:  present in the same images ?
  nb_images = numel(intersect(patches_a(:,2), patches_b(:,2)));
  
  clusters_co(i,3) =  int8(nb_images * 100 / size(patches_a,1));
 % clusters_co(i,3) = size(patches_a,1) - nb_images;
  
  %fprintf('\n number of patches A = %d, B = %d , inter = %d :', size(patches_a,1),size(patches_b,1),nb_images);
  
  % overlapping inside the same images?
  % TODO
end

% we sorted by co-occurence
[~, sorted_idx ] = sort(clusters_co(:,3), 1, 'descend');
clusters_co = clusters_co(sorted_idx,:);

%particular example : finding co-occurance of the cluster couple {741,1001}
% clusters_co(find(ismember(clusters_co(:,1:2), [741 1001], 'rows')),:)
visulisation_coocurence;
