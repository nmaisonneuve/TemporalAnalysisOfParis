for (time_period = [1 2 3 5 6 7 8 9 10 11])
  disp(time_period);
  exp = sprintf('data/step1_exp_one_vs_all_period%d.mat',time_period);
  if exist(exp, 'file')
    load(exp);
    clearvars 'neg_label' 'seed_pos_idx';
    clearvars 'neg_label' 'seed_pos_idx' 'imga'
    clearvars 'loaded_state' 'loaded_state_tmp2' 'nb_init_clusters' 'label_idx' 'neg_idx' 'neg_sample_label_size';
    clearvars image_patches;
    save(exp);
  else
    disp('not existing');  
  end
end


 