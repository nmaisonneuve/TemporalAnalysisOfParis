function detections = step2_knn_detections(candidates_feats, imgs, params)
  nb_all_imgs = numel(imgs);
  nb_init_clusters = size(candidates_feats,1);
  tic;
  detections = cell(nb_all_imgs,1); % cell for parallel computing
  parfor img_id = 1: nb_all_imgs

    img_path = imgs(img_id).path;

    fprintf('\nComputing KNN for image %d', img_id);

    % get the nearest patch in the image for each patch candidate  (+ its distance)
    % => ! 2 NN patches could not be from the same image => good
    [best_detections, dist] = KNN_cluster(img_path, candidates_feats, params);  
    if (~isempty(best_detections))
      detections{img_id} = [...
        (1:nb_init_clusters)' ...
        ones(nb_init_clusters,1) * img_id dist  ...
        best_detections ...
       ];
    end
  end
  detections = cell2mat(detections);
  toc;
end