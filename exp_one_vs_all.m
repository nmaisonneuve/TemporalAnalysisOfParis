
% EXPERIMENT 4
% discovering discriminative patches of a given time period vs the others


% clear workspace
clear;

% load basic configuration
config();

% set parameters for this experiment
global ds;
ds.params = struct(..., 
  'experiment_name', 'exp_one_vs_all_period',...%<-- NAME OF THE EXPERIMENT: IMPORTANT to differenciate experimental saved results
  'pos_sample_size', 500, ... % sample size for positive images % usually 2000 positive images is enough; sometimes even 1000 works
  'neg_sample_size', 1500, ... % sample size for negative images % usually 2000 positive images is enough; sometimes even 1000 works   
  'seed_candidate_size', 250, ... %  ratio from the sample to get the number of images used to get seed patches candidates 
  'seed_patches_per_image', 25,...  % -1 = no limit (cal's version: only use 25 patches per images?)
  'imageCanonicalSize', 400,...% images are resized so that their smallest dimension is this size.
  'patchCanonicalSize', {[80 80]}, ...% patches are extracted at this size.  Should be a multiple of sBins.
  'sBins', 8, ...% HOG sBins parameter--i.e. the width in height (in pixels) of each cell
  'useColor', 1, ...% include a tiny image (the a,b components of the Lab representation) in the patch descriptor
  'useColorHists',0,...
  'patchOnly', 0,...
  'sampleBig', 0,...
  'scaleIntervals', 8, ...% number of levels per octave in the HOG pyramid 
  'patchOverlapThreshold', 0.5, ...%detections (and random samples during initialization) with an overlap higher than this are discarded.
  'levelFactor', 2, ... % number of levels for pyramid HOG 
  'discriminativity_threshold',0.7, ...
  'representativity_threshold',0.05);% in the first step , the ratio of nearest neighboors used to compute purity as a ratio of the number of positive images.

%%%%% SETUP DATA FOR THIS EXPERIMENT

% load imgs data
% define positive and negative labels
positive_label = 8;
ds.params.experiment_name = [ds.params.experiment_name num2str(positive_label)];
[imgs, pos_idx] = prepare_data_one_vs_all(positive_label, ds.params);


%% MAIN ALGO
experiment_dir = sprintf('results/%s',ds.params.experiment_name);
mkdir(experiment_dir);

loaded_state = 0;

%%%% STEP 1 - computing seed candidate patches
data_step1_filename = sprintf('data/step1_%s.mat',ds.params.experiment_name);
data_step2_filename = sprintf('data/step2_%s.mat',ds.params.experiment_name);

switch loaded_state
  case 1
    disp('loading workspace at step 2');
    load(data_step2_filename);
  case 2
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



%%% STEP 3 - ranking detectors 
data_step3_filename = sprintf('data/step3_%s.mat',ds.params.experiment_name);
if (loaded_state  < 3)
   step3_ranking;
 
  % save workspace
  clearvars loaded_state;
  save(data_step3_filename);
  disp('saved workspace at step 3');
end

step_visualisation;

%% STEP 4 - bulding cooccurrence graph & co.
data_step4_filename = sprintf('data/step4_%s.mat',ds.params.experiment_name);
if (loaded_state  < 4)
   step4_cooccurence_analysis;
 
  % save workspace
  clearvars loaded_state;
  save(data_step4_filename);
  disp('saved workspace at step 4');
end