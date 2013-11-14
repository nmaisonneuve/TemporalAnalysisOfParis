  %%
  % formatting output data 
  %generate the clusters struct
  clusters = struct();
  for (i = 1 : numel(best_clusters_idx))

    % the centroids
    centroid_pos = patches(best_clusters_idx(i),:);
   
    centroid.x1 = centroid_pos(2);
    centroid.x2 = centroid_pos(3);
    centroid.y1 = centroid_pos(4);
    centroid.y2 = centroid_pos(5);
    centroid.img_id = centroid_pos(1);
    centroid.patch_id = -1;
    centroid.cluster_id = i;
    clusters(i).centroid = centroid;
    % the related Nearest neighboors patches [img_id, patch_id]
    nn_patches = closest_patches(top_nn_idx(best_clusters_idx(i),:),[2 4:7]);
    nn = struct();
     for (j = 1: size(nn_patches,1))
       nn(j).cluster_id = i;
       nn(j).img_id = nn_patches(j,1);
       nn(j).patch_id = j;
       %nn(j).patch = nn_patches(j,2:end);
       nn(j).x1 = nn_patches(j,2);
       nn(j).x2 = nn_patches(j,3);
       nn(j).y1 = nn_patches(j,4);
       nn(j).y2 = nn_patches(j,5);
       nn(j).label = ismember(nn_patches(j,1),pos_idx);
     end
    clusters(i).nn = nn;

    % purity 
    clusters(i).purity = purity(best_clusters_idx(i));
  end

 experiment_dir = sprintf('results/%s',ds.params.experiment_name);
 if (exist(experiment_dir))
  rmdir(experiment_dir,'s')
 end

% create dir to save results from this experiment
mkdir(experiment_dir);
mkdir(sprintf('results/%s/images',ds.params.experiment_name)); 
 
%extract patchs from images
%a = [clusters.centroid];
%oldField = 'imidx';
%newField = 'img_id';
%[a.(newField)] = a.(oldField);
%a = rmfield(a,oldField);
extract_patches_from_position([clusters.centroid], imgs);
extract_patches_from_position([clusters.nn], imgs);

% save clusters.json
json_file = sprintf('results/%s/clusters_knn.json',ds.params.experiment_name);
savejson('',clusters,json_file);