
%%%% STEP 1 - computing seed candidate patches
data_step1_filename = sprintf('data/step1_%s.mat',ds.params.experiment_name);
data_step2_filename = sprintf('data/step2_%s.mat',ds.params.experiment_name);

% loading workspace if required
loaded_state_tmp2 = loaded_state;

switch loaded_state
  case 2
    disp('loading workspace at step 2');
    load(data_step2_filename);
  case 1
    disp('loading workspace at step 1');
    load(data_step1_filename);
end

loaded_state = loaded_state_tmp2;

% STEP 1 - generate pseudo-randomly some candidate
% discriminative patches/detectors
if (loaded_state < 1)
  step1_generate_candidates;
  
  % save workspace
  save(data_step1_filename);
  disp('saved workspace at step 1');
end


%%% STEP 2 - computing their K-nearest neighbors for all the images
if (loaded_state < 2)
  step2_nearest_neighboors;
  
  % save workspace
  save(data_step2_filename);
  disp('saved workspace at step 2');
end

% STEP 3 : to continue...

