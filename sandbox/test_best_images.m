nb_co_images  = max(detections(:,2));
co_images = zeros(nb_co_images, 1);
dd = candidates(top_detectors_idx);
group_candidates = dd(co_cluster_idx == 1);

[imgs_idx, nb_detections, examples] = best_images_from_detectors( detections,group_candidates, positive_label,10);

recall = numel(imgs_idx) / numel(pos_idx);
ratio_detectors = nb_detections/numel(group_candidates);

for (i = 1:10)
  selected_image = imgs(examples(i).img_idx); 
  selected_detections = examples(i).detections;
  im = im2double(imread(selected_image.path));
  imshow( im );
  im = gen_heatmap(im, selected_detections);
  imshow(im);
  pause(2);
end