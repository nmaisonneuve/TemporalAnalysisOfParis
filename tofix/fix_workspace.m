for (time_period = [1 2 3 5 6 7 8 9 10 11])
  disp(time_period);
  clearvars -except time_period;
  exp = sprintf('data/step2_exp_one_vs_all_period%d.mat',time_period);
  if exist(exp, 'file')
    load(exp);
    if (exist('closest_patches'))
       detections = closest_patches;
       clearvars 'closest_patches';
    end
    img_idx = unique(detections(:,2));
    imgs = ds.imgs(img_idx);
    clearvars 'img_idx';
    clearvars 'ans' 'loaded_state_tmp';
    clearvars 'best_clusters_idx' 'NN_patches_idx' 'pos_idx' 'nb_all_imgs';
    clearvars 'nb_top_clusters' 'nb_neighbors' 'image_column_id' 'i' 'purity';
    clearvars 'sorted_idx' 'ord' 'top_dist'  'top_nn_idx' 'top_nn_positive';
    clearvars 'dist_column_id' 'candidate_column_id';
    clearvars 'neg_label' 'seed_pos_idx' 'imga';
    clearvars 'loaded_state' 'loaded_state_tmp2' 'nb_init_clusters' 'label_idx' 'neg_idx' 'neg_sample_label_size';
    clearvars image_patches;
    save(exp);
  else
    disp('not existing');  
  end
end


 