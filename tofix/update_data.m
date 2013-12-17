
function update_data(i)
  clearvars -except i;
  data_file = sprintf('data/step2_exp_one_vs_all_period%d.mat',i);
  data_file_v2 = sprintf('data/step2_exp_one_vs_all_period%d_v2.mat',i);
  load(data_file);

  % 
   imgs_detection = unique(detections(:,2))';
   dd = arrayfun(@(x) x.path,imgs,'uni',false);

   tic;
   for img_detection = imgs_detection
     new_img_idx = find(strcmp(dd, ds.imgs(img_detection).path));
     detections(detections(:,2) == img_detection,2) = new_img_idx; 
   end
   clearvars 'new_img_idx'  'imgs_detection'  'img_detection';
   toc;

   tic;
   patches_detection = unique(patches(:,1))';
   for img_detection =  patches_detection
     new_img_idx = find(strcmp(dd, ds.imgs(img_detection).path));
     patches(patches(:,1) == img_detection,1) = new_img_idx; 
   end
   clearvars 'dd' 'new_img_idx'  'patches_detection'  'img_detection';
   toc;

   clearvars 'all_imgs_idx' 'k_nn' 't' 'tt' 'to_keep_patches_idx';
   clearvars  'ranked_candidates_idx' 'patches_a' 'inter_ranked_idx';

   step3_ranking;
  
   step_visualisation;
   
   save(data_file_v2);
  end