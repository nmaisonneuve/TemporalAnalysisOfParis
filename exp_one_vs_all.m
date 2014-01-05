% EXPERIMENT
% discovering discriminative patches of a given time period vs the others

% clear workspace
clear;

% load basic configuration
config();

% time periods indices
PERIODS = [ 1 2 3 5 6 7 8 9 10 11];

% Parameters for this experiment
params = struct(..., 
  'positive_labels', [8],... % set of time periods defined as positive labels
  'experiment_name', 'exp_one_vs_all_period' ,...%<-- NAME OF THE EXPERIMENT: IMPORTANT to differenciate experimental saved results
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

% update name of the experiment 
params.experiment_name = [params.experiment_name num2str(params.positive_labels)];

% deduce negative labels
negative_labels = setdiff(PERIODS, positive_labels);
      
% create dir where results will be put
experiment_dir = sprintf('results/%s',params.experiment_name);
mkdir(experiment_dir);

exp_step = 0; % CURRENT STEP OF THE EXPERIMENT
running_all = true; % want to run only a specific step or from a specific spec?
saving_step = true; % saving step?




% START

% loading a given step of the experiment ?
if (exp_step > 0)
  disp(['loading experiment at step ' exp_step]);
  load(data_step_filename);
end

while (running_all && (exp_step ~= END_STEP))
  
  % According to the current step of the experiment
  switch exp_step

    % STEP  Generate pseudo-randomly some candidate
    case 0
      
      % prepare data
      [imgs, pos_idx] = prepare_data(positive_labels, negative_labels, params);   
      
      step1_generate_candidates;
      exp_step = exp_step + 1;

    % STEP  Computing their K-nearest neighbors for all the images
    case 1    
      detections = step2_knn_detections(initFeats,imgs,params);
      exp_step = exp_step + 1;

    % STEP  Ranking detectors 
    case 2 
      step3_ranking;
      step_visualisation;
      exp_step = exp_step + 1;

    % STEP - Bulding cooccurrence graph & co.  
    case 3
      step4_cooccurence_analysis;
      exp_step = END_STEP;      
  end

  % save step/workspace into .mat file
  if saving_step
    save_step;
  end
end

