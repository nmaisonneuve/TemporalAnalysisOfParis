function save_cooccurrence_sample_images(clusters_idx, top_detectors, detections, imgs, positive_label, nb_samples, co_dir)

  nb_co_images  = max(detections(:,2));

  sample_dir = [co_dir '/samples_images'];
  mkdir(sample_dir);

  for (cluster_idx = clusters_idx')

    clusters_detectors = top_detectors(clusters_idx == cluster_idx);
    [imgs_idx, nb_detections, examples] = best_images_from_detectors( detections,clusters_detectors, positive_label,nb_samples);

    for (i = 1:numel(examples));
      selected_image = imgs(examples(i).img_idx); 
      selected_detections = examples(i).detections;
      im = im2double(imread(selected_image.path));
      
      filename = sprintf('%s/cluster_%d_%d.jpg',sample_dir,cluster_idx ,  examples(i).img_idx);
      imwrite(im, filename);

      im = gen_heatmap(im, selected_detections);
      filename = sprintf('%s/cluster_%d_%d_heatmap.jpg',sample_dir,cluster_idx , examples(i).img_idx);    
      imwrite(im, filename);
    end  
  end
end

