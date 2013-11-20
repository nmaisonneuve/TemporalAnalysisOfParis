% EXPERIMENT 1
% Discovering visual elements from old buildings


% clear workspace
clear;

%%%%% SETUP PARAMETERS FOR THIS EXPERIMENT
config();

global ds;
ds.params = struct(..., 
  'experiment_name', 'exp1',...%<-- NAME OF THE EXPERIMENT: IMPORTANT to differenciate experimental saved results
  'num_train_its', 5, ... %define the number of training iterations used.  The paper uses 3; sometime %using as many as 5 can result in minor improvements.
  'pos_sample_size', 100, ... % initial sample size % usually 2000 positive images is enough; sometimes even 1000 works
  'neg_sample_size', 400, ... % initial sample size % usually 2000 positive images is enough; sometimes even 1000 works   
  'seed_candidate_size', 100, ... %  ratio from the sample to get the number of images used to get seed patches candidates 
  'seed_patches_per_image', 25,...  % -1 = no limit (cal's version: only use 25 patches per images?)
  'imageCanonicalSize', 400,...% images are resized so that their smallest dimension is this size.
  'patchCanonicalSize', {[80 80]}, ...% patches are extracted at this size.  Should be a multiple of sBins.
  'scaleIntervals', 8, ...% number of levels per octave in the HOG pyramid 
  'sBins', 8, ...% HOG sBins parameter--i.e. the width in height (in pixels) of each cell
  'useColor', 1, ...% include a tiny image (the a,b components of the Lab representation) in the patch descriptor
  'useColorHists',0,...
  'patchOnly', 0,...
  'patchOverlapThreshold', 0.5, ...%detections (and random samples during initialization) with an overlap higher than this are discarded.
  'overlap', 0.4, ...% detections with overlap higher than this are discarded.  
  'svmflags', '-s 0 -t 0 -c 0.1',...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'fixedDecisionThresh', -1.002,...
  'levelFactor', 2, ... % number of levels for pyramid HOG 
  'sampleBig', 0,...
  'knn_html_visualization',1); % do we generate KNN HTML visualisation?


%%%%% SETUP DATA FOR THIS EXPERIMENT

%load imgs data
load('data/paris_data.mat');
ds.imgs = imgs;

% split data into pos + neg dataset
positive_period = [1]; % old time period
pos_idx = find(ismember([ds.imgs.label], positive_period));
neg_idx = setdiff(1:numel(ds.imgs), pos_idx);


% we actually take a subset/sample for the experiment
if (numel(pos_idx)> ds.params.pos_sample_size)
  pos_idx = pos_idx(randsample(numel(pos_idx),ds.params.pos_sample_size));
end
if (numel(neg_idx) > ds.params.neg_sample_size)
  neg_idx = neg_idx(randsample(numel(neg_idx),ds.params.neg_sample_size));
end

% we aggregate these 2 datasets into the dataset used for the experiment
ds.all_imgs_idx = [pos_idx, neg_idx];

disp('dataset for experiment done. ');


%% EXECUTE ALGO 
loaded_state = 2;
main;