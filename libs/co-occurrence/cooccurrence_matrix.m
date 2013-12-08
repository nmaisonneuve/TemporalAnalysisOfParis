
% members_idx [ row = cluster_id , cols = patch id of the members ] 
function co_occurrence_matrix = cooccurrence_matrix(candidates, detections, params)
  
  if nargin < 3
    method =   'image';
  end

  %config();
  % create co-occurrence matrix
  clusters_co = nchoosek(1:numel(candidates),2);

  %sort value: first column smaller than 2nd column
  %clusters_co(:,1:2) = [min(clusters_co(:,1:2),[],2) max(clusters_co(:,1:2),[],2)];

  % add  image co-occurrence column
  clusters_co = [clusters_co ones(size(clusters_co,1),1)];
  %pos_img = find([ds.imgs.label] == 11);
  
  tic;
  for (i = 1:size(clusters_co,1))
    
    detections_a_idx = select_detections(i,1, params.only_positive);
    detections_b_idx = select_detections(i,2, params.only_positive);
    
    patches_a = detections(detections_a_idx,:);
    patches_b = detections(detections_b_idx,:);

    % image co-occurrency:  present in the same images ?
    % nb_images = numel(intersect(patches_a(:,2), patches_b(:,2)));
    %clusters_co(i,3) =  nb_images;
    switch (params.context)
      case 'image'
        clusters_co(i,3) =  jaccard_coefficient(patches_a, patches_b);
        if (clusters_co(i,3) < 0.05)
          clusters_co(i,3) = 0;
        end
      case 'area'
        overlaps = overlap_cooccurrence(patches_a(:,[2 4:7]), patches_b(:,[2 4:7]), params.overlap_threshold);
        clusters_co(i,3) =  size(overlaps,1);
        %fprintf('\n%d overlapping candidates',clusters_co(i,3));
      otherwise
        fprintf('\nERROR method not recognized');
    end  
  end
  toc;

  % we sorted by co-occurence
  %[~, sorted_idx ] = sort(clusters_co(:,3), 1, 'descend');
  %clusters_co = clusters_co(sorted_idx,:);

  co_occurrence_matrix = to_matrix(clusters_co);
  
  function detections_idx = select_detections(idx, column_id, only_positive_detections)
    detections_idx = candidates(clusters_co(idx,column_id)).nn_detections_idx;
      % only the positive
      if (only_positive_detections)
        pos_nn_idx = [candidates(clusters_co(idx,column_id)).labels == params.positive_label];
        detections_idx = detections_idx(pos_nn_idx);
      end 
  end

  % transform to a full adjacency matrix
  function matrix = to_matrix(list)  
    rows = list(:,1);
    cols = list(:,2);
    w = list(:,3);
    matrix = sparse([rows; cols],[cols; rows],[w; w]);
    matrix = full(matrix);
  end

end

