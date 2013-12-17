
% generate 
function [img_idx, nb_detections, top_examples] = best_images_from_detectors(detections, cluster_candidates, positive_label, k )
  %k = 1;
  sub_detections_idx = (vertcat(cluster_candidates.nn_detections_idx));

  %only detections from positive images
  sub_labels = [cluster_candidates.labels]';
  sub_pos = ismember(sub_labels, positive_label);
  sub_detections_idx = sub_detections_idx(sub_pos);

  sub_detections = detections(sub_detections_idx,:);
  img_detections = sub_detections(:,2);
  [img_idx, nb_detections] = count_unique(img_detections);

  [nb_detections, sort_idx] = sort(nb_detections,'descend');
  img_idx = img_idx(sort_idx);
  
  top_examples = struct();
  for (i = 1:k)
   candidate_img_idx = img_idx(i);
   selected_detections = sub_detections(img_detections == candidate_img_idx,4:7);
   top_examples(i).img_idx = candidate_img_idx;
   top_examples(i).detections = selected_detections;
  end
end