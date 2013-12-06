
%%%% STEP 1 - computing seed candidate patches
data_step1_filename = sprintf('data/step1_%s.mat',ds.params.experiment_name);
data_step2_filename = sprintf('data/step2_%s.mat',ds.params.experiment_name);

switch loaded_state
  case 2
    disp('loading workspace at step 2');
    load(data_step2_filename);
  case 1
    disp('loading workspace at step 1');
    load(data_step1_filename);
end

% STEP 1 - generate pseudo-randomly some candidate
% discriminative patches/detectors
if (loaded_state < 1)
  step1_generate_candidates;
  
  % save workspace
  clearvars image_patches;
  save(data_step1_filename);
  disp('saved workspace at step 1');
end


%%% STEP 2 - computing their K-nearest neighbors for all the images
if (loaded_state < 2)
   detections = step2_knn_detections(initFeats,imgs,ds.params);
 
  % save workspace
  tmp = loaded_state;
  clearvars loaded_state;
  save(data_step2_filename);
  loaded_state = tmp;
  disp('saved workspace at step 2');
end

visualisation;

% STEP 3 : to continue...
%%% STEP 2 - computing their K-nearest neighbors for all the images
data_step3_filename = sprintf('data/step3_%s.mat',ds.params.experiment_name);
if (loaded_state  < 3)
   step3_ranking;
 
  % save workspace
  clearvars loaded_state;
  save(data_step3_filename);
  disp('saved workspace at step 3');
end



%cooccurrence;

