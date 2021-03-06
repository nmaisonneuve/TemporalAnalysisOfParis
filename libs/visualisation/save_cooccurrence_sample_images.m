function save_cooccurrence_sample_images(clusters_idx, top_detectors, detections, imgs, positive_label, nb_samples, co_dir)

  nb_co_images  = max(detections(:,2));

  sample_dir = [co_dir '/sample_images'];
  mkdir(sample_dir);

  for (cluster_idx = clusters_idx')

    clusters_detectors = top_detectors(clusters_idx == cluster_idx);
    [imgs_idx, nb_detections, examples] = best_images_from_detectors( detections,clusters_detectors, positive_label,nb_samples);

    for (i = 1:numel(examples))
      
      selected_image = imgs(examples(i).img_idx); 
      
      selected_detections = examples(i).detections;
      fprintf('\n nb detections %d', size(selected_detections,1));
      im = im2double(imread(selected_image.path));
      
      filename = sprintf('%s/cluster_%d_%d.jpg',sample_dir,cluster_idx ,  examples(i).img_idx);
      imwrite(im, filename);

      im = gen_heatmap(im, selected_detections);
      filename = sprintf('%s/cluster_%d_%d_heatmap.jpg',sample_dir,cluster_idx , examples(i).img_idx);    
      
      heatmap.img_idx = examples(i).img_idx;
      heatmap.cluster_idx = cluster_idx;
      heatmap.filename = filename;   
      
      imwrite(im, filename);
    end  
  end
  
  %saving image descriptor
  json_file(heatmaps,[co_dir 'sample_images.json']);
  
end

