
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
  clusters_co(i,3) = size(patches_a,1) - nb_images;
  %fprintf('\n number of patches A = %d, B = %d , inter = %d :', size(patches_a,1),size(patches_b,1),nb_images);
  
  % overlapping inside the same images?
  % TODO
end
[~, sorted_idx ] = sort(clusters_co(:,3));

clusters_co = clusters_co(sorted_idx,:);


clusters_co(find(ismember(clusters_co(:,1:2), [741 1001], 'rows')),:)
