%%%% STEP 1 - computing seed candidate patches
data_step1_filename = sprintf('data/step1_%s.mat',ds.params.experiment_name);
if (step1_todo)
  step1_generate_patches;
  % save workspace
  save(data_step1_filename);
  disp('saved workspace at step 1');
else
  disp('loading workspace at step 1');
  load(data_step1_filename);
end


%%% STEP 2 - computing nearest neighbors
data_step2_filename = sprintf('data/step2_%s.mat',ds.params.experiment_name);
if (step2_todo)
  step2_nearest_neighboors;
  
  save(data_step2_filename);
  disp('saved workspace at step 2');
else
  disp('loading workspace at step 2');
  load(data_step2_filename);
end


if (ds.params.knn_html_visualization)
  KNN_visualisation
end

% STEP 3 : to continue...