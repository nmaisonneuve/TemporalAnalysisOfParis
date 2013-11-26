function [ranked_candidates_idx, purity, top_k_members_idx] = KNN_rank_candidates(closest_patches, top_k_neighbors, positive_img_idx)
  dist_column_id = 3;
  candidate_column_id = 1;
  image_column_id = 2;
  
  % number of candidates
  nb_init_clusters = max(closest_patches(:,1));

  % each row = 1 candidate (row idx = candidate idx), 
  % each column k =the idx of the kth nearest neighbor detected patche 
  top_k_members_idx = zeros(nb_init_clusters, top_k_neighbors);

  % (debug) each row = 1 candidate, each column k the dist of kth nearest neighbor idx
  % top_nn_dist = zeros(nb_init_clusters, nb_neighbors);
  tic;
  parfor (i = 1:nb_init_clusters)
    NN_patches_idx = find(closest_patches(:, candidate_column_id) == i);
    [top_dist , ord] = mink(closest_patches(NN_patches_idx, dist_column_id), top_k_neighbors);
    top_k_members_idx(i,:) = NN_patches_idx(ord)';
    %top_nn_dist(i,:) = top_dist';
  end
  toc;
  % (debug) top_img_idx = vec2mat(closest_patches(top_nn_idx(:),image_column_id),nb_seed_candidates)';

  % each row = 1 cluster, each column k: 0 or 1 if the patch is labeled
  % positive or not
  top_nn_positive = vec2mat(ismember(closest_patches(top_k_members_idx(:),image_column_id), positive_img_idx),nb_init_clusters)';

  %top_nn_similirarity = vec2mat(closest_patches(top_nn_idx(:),image_column_id),pos_idx),nb_init_clusters)';

  % compute purity of each cluster
  purity = sum(top_nn_positive,2);

  % change the format a bit to get pourcentage
  purity = purity / top_k_neighbors;

  %rank clusters by purity
  [purity, sorted_idx] = sort(purity,1, 'descend');
  
  ranked_candidates_idx = sorted_idx(1:nb_init_clusters);

end