function [candidates] = scoring_detectors_v2(detections, imgs, params)
  
  dist_column_id = 3;
  candidate_column_id = 1;
  period_labels = [1 2 3 5 6 7 8 9 10 11];
  
  % candidates ids
  candidates_ids = unique(detections(:,1));
  img_idx = unique(detections(:,2));
  
  nb_candidates = numel(candidates_ids);
  
  number_positive_images = numel(find(ismember([imgs(img_idx).label], params.positive_label)));
  min_k_neighboors = round(params.representativity_threshold *  number_positive_images);
  
  fprintf('\nRepresentativity: from %d to %d neigboors',  min_k_neighboors , number_positive_images);
    
  % (debug) each row = 1 candidate, each column k the dist of kth nearest neighbor idx
  % top_nn_dist = zeros(nb_init_clusters, nb_neighbors);
  tic;
  candidates = struct('id','', 'pur_hist','', 'nn_detections_idx', '','labels','','purity','', 'frequency','');
  %fprintf('\nCandidate threshold',candidates(i).id, candidates(i).max_k);
  

  
parfor (i = 1:nb_candidates)
    NN_patches_idx = find(detections(:, candidate_column_id) == candidates_ids(i));
    %fprintf('\n number of detections: %d', numel(NN_patches_idx));

     [~ , ord] = mink(detections(NN_patches_idx, dist_column_id), number_positive_images);

     % purity histogram
     img_idx = detections(NN_patches_idx(ord),2);

     labels = [imgs(img_idx).label];
     pur_hist = cumsum(ismember(labels, params.positive_label))./(1:number_positive_images);

     % compute best purity for a given representivity thresold
     [best_purity, best_purity_idx] = max(pur_hist(min_k_neighboors:end));
     best_purity_idx = best_purity_idx + min_k_neighboors -1;

     %compute best frequency for a given discriminativity threshold
     pp = find(pur_hist((min_k_neighboors+1):number_positive_images) < params.discriminativity_threshold, 1);
     if (isempty(pp))
      frequency_k = number_positive_images;
     else
      frequency_k = min_k_neighboors -1 + pp; 
     end
      
     
     best_frequency = frequency_k / number_positive_images;
     if (isempty(best_frequency))
       fprintf('\n EROREOROER %f  %f', best_frequency, pur_hist(1)   );
       
     end
     
     candidates(i).id = candidates_ids(i);
     candidates(i).pur_hist = pur_hist;
     candidates(i).purity = best_purity; 
     candidates(i).purity_k = best_purity_idx;
     candidates(i).frequency = best_frequency;
     candidates(i).frequency_k = frequency_k;
     candidates(i).mean = 2 *(best_purity.*best_frequency) ./ (best_purity + best_frequency);
     
     % best sample of detections
     candidates(i).nn_detections_idx = NN_patches_idx(ord(1:best_purity_idx));
     candidates(i).labels = labels(1:best_purity_idx); %[imgs(detections(candidates(i).nn_detections_idx,image_column_id)).label];        

     %fprintf('\nCandidate %d frequency: %f purity %f',candidates_ids(i),best_frequency, best_purity);   
  end
  toc;

  % computing entropy
  function score = compute_entropy(labels)
    [p, ~ ] = hist(labels,period_labels);
    [~, mode_idx] = max(p); % if mode  == positive label
    if (mode_idx == positive_idx)
      p = p/sum(p) + 0.0001; % to prevent log(0)
      score = sum(p.*log2(p));  % reverse of entropy
    else
      score = -Inf;
    end
  end

end