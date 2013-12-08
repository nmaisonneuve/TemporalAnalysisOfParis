function [ranked_candidates_idx, candidates] = KNN_ranking_v2(detections, threshold_purity, imgs, positive_label)
  dist_column_id = 3;
  candidate_column_id = 1;
  image_column_id = 2;
  period_labels = [1 2 3 5 6 7 8 9 10 11];
  positive_idx = find(period_labels == positive_label);
  
  % candidates ids
  candidates_ids = unique(detections(:,1));
  img_idx = unique(detections(:,2));
  
  nb_candidates = numel(candidates_ids);
  
  top_k_neighbors = numel(find([imgs(img_idx).label] == positive_label));
  min_k = 20;
  
  fprintf('\n from %d to %d', min_k , top_k_neighbors);
    
  % (debug) each row = 1 candidate, each column k the dist of kth nearest neighbor idx
  % top_nn_dist = zeros(nb_init_clusters, nb_neighbors);
  tic;
  candidates = struct('id','', 'pur_hist','', 'nn_detections_idx', '','labels','','purity','', 'frequency','');
  %fprintf('\nCandidate threshold',candidates(i).id, candidates(i).max_k);
     
  
  parfor (i = 1:nb_candidates)
      NN_patches_idx = find(detections(:, candidate_column_id) == candidates_ids(i));
      [~ , ord] = mink(detections(NN_patches_idx, dist_column_id), top_k_neighbors);
       candidates(i).id = candidates_ids(i);
%       
%       % purity histogram
      img_idx = detections(NN_patches_idx(ord),2);
       labels = [imgs(img_idx).label];
       pur_hist = cumsum(labels == positive_label)./(1:top_k_neighbors);
  %disp(size(pur_hist));
       candidates(i).pur_hist = pur_hist;

       max_k = min_k + find(pur_hist((min_k+1):top_k_neighbors) < threshold_purity, 1) -1;
       candidates(i).frequency = max_k; %;/top_k_neighbors;  
       candidates(i).nn_detections_idx = NN_patches_idx(ord(1:max_k));
       candidates(i).labels = labels(1:max_k); %[imgs(detections(candidates(i).nn_detections_idx,image_column_id)).label];        
       candidates(i).purity = pur_hist(max_k);
     fprintf('\nCandidate %d frequency: %f purity %f',candidates_ids(i),max_k,  pur_hist(max_k));
%         
  end
  toc;
   [~, ranked_candidates_idx] = sortrows([[candidates.frequency]' [candidates.purity]'],[1 2]);
   ranked_candidates_idx = flipdim(ranked_candidates_idx,[1 2]); % reverse
  
   %[~, ranked_candidates_idx] = sort([candidates.purity]',1, 'descend');
end