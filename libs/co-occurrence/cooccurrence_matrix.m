
% members_idx [ row = cluster_id , cols = patch id of the members ] 
function co_occurrence_matrix = cooccurrence_matrix(clusters_idx, members_idx, detections)

  %config();
  % create co-occurrence matrix
  clusters_co = nchoosek(1:numel(clusters_idx),2);

  %sort value: first column smaller than 2nd column
  %clusters_co(:,1:2) = [min(clusters_co(:,1:2),[],2) max(clusters_co(:,1:2),[],2)];

  % add  image co-occurrence column
  clusters_co = [clusters_co ones(size(clusters_co,1),1)];
  tic;
  for (i = 1:size(clusters_co,1))

    cluster_a_idx = clusters_idx(clusters_co(i,1));
    cluster_b_idx = clusters_idx(clusters_co(i,2));

    % get the first X nearest neigboors patches
    patches_a = detections(members_idx(cluster_a_idx,:),:);
    patches_b = detections(members_idx(cluster_b_idx,:),:);

    % image co-occurrency:  present in the same images ?
    % nb_images = numel(intersect(patches_a(:,2), patches_b(:,2)));
    %clusters_co(i,3) =  nb_images;
    
    clusters_co(i,3) =  jaccard_coefficient(patches_a, patches_b);
  end
  toc;

  % we sorted by co-occurence
  %[~, sorted_idx ] = sort(clusters_co(:,3), 1, 'descend');
  %clusters_co = clusters_co(sorted_idx,:);

  co_occurrence_matrix = to_matrix(clusters_co);
end

% transform to a full adjacency matrix
function matrix = to_matrix(list)  
  rows = list(:,1);
  cols = list(:,2);
  w = list(:,3);
  matrix = sparse([rows; cols],[cols; rows],[w; w]);
  matrix = full(matrix);
end