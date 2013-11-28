function [ranked_candidates_idx, candidates] = KNN_ranking_candidates(detections, top_k_neighbors, positive_img_idx)
  dist_column_id = 3;
  candidate_column_id = 1;
  image_column_id = 2;
  
  % candidates ids
  candidates_ids = unique(detections(:,1));
  
  nb_candidates = numel(candidates_ids);
  
  % (debug) each row = 1 candidate, each column k the dist of kth nearest neighbor idx
  % top_nn_dist = zeros(nb_init_clusters, nb_neighbors);
  tic;
  candidates = struct();
 
  for i = 1:nb_candidates
      NN_patches_idx = find(detections(:, candidate_column_id) == candidates_ids(i));
      [~ , ord] = mink(detections(NN_patches_idx, dist_column_id), top_k_neighbors);
      missing_nn = top_k_neighbors - numel(ord);
      if (missing_nn> 0)
        fprintf('\nWARNING: not enough nearest neighbors');
      end

      candidates(i).id = candidates_ids(i);
      candidates(i).nn_detections_idx = NN_patches_idx(ord);
      candidates(i).labels = ismember(detections(candidates(i).nn_detections_idx,image_column_id),positive_img_idx);
      candidates(i).purity = sum(candidates(i).labels)/ numel(candidates(i).nn_detections_idx);

  end
  toc;
  
   %rank candidates clusters by purity
  [~, ranked_candidates_idx] = sort([candidates.purity]',1, 'descend');
  
end