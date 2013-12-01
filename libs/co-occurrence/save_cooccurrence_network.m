function save_cooccurrence_network(A, candidates, json_file)

% each row = 1 candidate, each column k the kth nearest neighbor idx
% top_nn_idx = zeros(best_clusters_idx, best_clusters_idx-1);

% (debug) each row = 1 candidate, each column k the dist of kth nearest neighbor idx
% top_nn_dist = zeros(nb_init_clusters, nb_neighbors);
tic;
clusters = struct();
for (i = 1:numel(candidates))
  
  clusters(i).id = candidates(i).id;
  
  % the examplar patches/centroid
  clusters(i).centroid = candidates(i).centroid;
  
  % the cooccurent patches
  [freq, sorted_co_cluster_idx] = sort(A(:,i),1,'descend');
  %sorted_co_cluster_idx = best_clusters_idx(sorted_co_cluster_idx);
  
  nn = struct();
  co_candidates = candidates(sorted_co_cluster_idx);
  for (j = 1: numel(co_candidates )) 
    if (freq(j) > 0)
      nn(j).id = co_candidates(j).id;
      nn(j).score = freq(j);
      nn(j).img_path = co_candidates(j).centroid.img_path;
      nn(j).size = co_candidates(j).centroid.size;
      if (freq(j) == 12)
        fprintf('candidate %d ',clusters(i).id);
      end
      
    end
  end
  clusters(i).nn = nn;
end
toc;
savejson('',clusters,json_file);
