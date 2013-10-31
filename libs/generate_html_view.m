
function generate_html_view(initPatches, closest_patches, best_clusters_idx, top_nn_idx, imgs)

clusters = struct();
for (i = 1 : numel(best_clusters_idx))
  % the centroids
  centroid = initPatches(best_clusters_idx(i)); 
  clusters(i).centroid =  struct('imidx',centroid.im, 'patch',[centroid.x1 centroid.x2 centroid.y1 centroid.y2]);
  % the related Nearest neighboors patches [img_id, patch_id]
  nn_patches = closest_patches(top_nn_idx(best_clusters_idx(i),:),[2 4:7]);
  nn = struct();
   for (j = 1: size(nn_patches,1))
     nn(j).imidx = nn_patches(j,1);
     %nn(j).patch = nn_patches(j,2:end);
     nn(j).x1 = nn_patches(j,2);
     nn(j).x2 = nn_patches(j,3);
     nn(j).y1 = nn_patches(j,4);
     nn(j).y2 = nn_patches(j,5);
     nn(j).label = ismember(nn_patches(j,1),pos_idx);
   end
  clusters(i).nn = nn;
  clusters(i).purity = purity(best_clusters_idx(i));
end

%generate image patches
extract_patches_from_position([clusters.nn], imgs);

% save clusters.json
savejson('results/clusters.json',clusters);
end
