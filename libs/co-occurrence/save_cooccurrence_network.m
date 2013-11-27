function save_cooccurrence_network(A, best_clusters_idx, patches, json_file)

% each row = 1 candidate, each column k the kth nearest neighbor idx
% top_nn_idx = zeros(best_clusters_idx, best_clusters_idx-1);

% (debug) each row = 1 candidate, each column k the dist of kth nearest neighbor idx
% top_nn_dist = zeros(nb_init_clusters, nb_neighbors);
tic;
clusters = struct();
for (i = 1:numel(best_clusters_idx))
  
  clusters(i).id = best_clusters_idx(i);
  
  % the examplar patches/centroid
  img_id = patches(best_clusters_idx(i),1);    
  centroid.img_path = [img_id i -1];
  clusters(i).centroid = centroid;
  
  % the cooccurent patches
  [freq, sorted_co_cluster_idx] = sort(A(:,i),1,'descend');
  %sorted_co_cluster_idx = best_clusters_idx(sorted_co_cluster_idx);
  
  nn = struct();
  for (j = 1: numel(sorted_co_cluster_idx)) 
    if (freq(j) > 0)
      nn(j).id = best_clusters_idx(sorted_co_cluster_idx(j));
      nn(j).score = freq(j);
      img_id = patches(nn(j).id,1);  
      nn(j).img_path = [img_id  sorted_co_cluster_idx(j) -1];
    end
  end
  clusters(i).nn = nn;
  %top_nn_dist(i,:) = top_dist';
end
toc;
disp(clusters);
disp(json_file);
savejson('',clusters,json_file);