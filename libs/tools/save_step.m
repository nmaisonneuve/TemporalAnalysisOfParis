data_step_filename = sprintf('data/step%d_%s.mat',loaded_state, params.experiment_name);
save(data_step_filename );
disp(['saved workspace at step ' loaded_state]); 
