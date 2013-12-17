function save_cooccurrence_network(A, patches, json_file)

% each row = 1 candidate, each column k the kth nearest neighbor idx
% top_nn_idx = zeros(best_clusters_idx, best_clusters_idx-1);

% (debug) each row = 1 candidate, each column k the dist of kth nearest neighbor idx
% top_nn_dist = zeros(nb_init_clusters, nb_neighbors);
  tic;

  [patches(:,6), patches(:,7)] = patch_size(patches(:,2:5));

  patches_json = struct();
  for (i = 1:size(patches,1))

    patches_json(i).id = i;

    % the examplar patches/centroid
    patches_json(i).centroid = centroid(patches(i,:)); 

    % the cooccurent patches
    nn = struct();
    [score, sorted_co_cluster_idx] = sort(A(:,i),1,'descend');  
    
    for (j = 1:numel(sorted_co_cluster_idx)) 
      if (score(j) > 0)
        nn(j).id = sorted_co_cluster_idx(j);
        nn(j).score = score(j);
        nn(j).centroid= centroid(patches( nn(j).id,:));   
      end
    end
    patches_json(i).nn = nn;

  end
  toc;
  
  savejson('',patches_json,json_file);

  function c = centroid(patch)
    c = struct();
     % the centroids
    c.img_path = patch(1:5);
    c.size = patch(6:7);
  end
end
