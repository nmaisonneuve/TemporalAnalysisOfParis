
% EXPERIMENT 4
% discovering discriminative patches of a given time period vs the others


% clear workspace
clear;

% load basic configuration
config();

% set parameters for this experiment
global ds;
ds.params = struct(..., 
  'experiment_name', 'exp_one_vs_all_period7',...%<-- NAME OF THE EXPERIMENT: IMPORTANT to differenciate experimental saved results
  'pos_sample_size', 500, ... % sample size for positive images % usually 2000 positive images is enough; sometimes even 1000 works
  'neg_sample_size', 1500, ... % sample size for negative images % usually 2000 positive images is enough; sometimes even 1000 works   
  'seed_candidate_size', 250, ... %  ratio from the sample to get the number of images used to get seed patches candidates 
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
  'levelFactor', 2, ... % number of levels for pyramid HOG 
  'sampleBig', 0,...
  'knn_html_visualization',1); % do we generate KNN HTML visualisation?



%%%%% SETUP DATA FOR THIS EXPERIMENT

% load imgs data
load('data/all_paris_data.mat');
ds.imgs = imgs;

% define positive and negative labels
positive_label = 7; 
negative_labels = unique([ds.imgs.label]);
negative_labels(negative_labels == positive_label) = [];

% take a subset/sample of data with positive labels
pos_idx = find(ismember([ds.imgs.label], positive_label));
pos_idx = pos_idx(randsample(numel(pos_idx),ds.params.pos_sample_size));


% taks a subset of data with negative label
% here we respect th equality of all negative labels
% so we take the same sample size for each negative label
neg_idx = [];
neg_sample_label_size = round(ds.params.neg_sample_size/numel(negative_labels));
for (i = 1:numel(negative_labels))
  neg_label = negative_labels(i);
  label_idx = find(ismember([ds.imgs.label], neg_label));
  label_idx = label_idx(randsample(numel(label_idx),neg_sample_label_size));
  fprintf('\nnegative label %d - sample size: %d', neg_label, numel(label_idx));
  neg_idx = [neg_idx label_idx];
end

% we aggregate these 2 datasets into the dataset

ds.all_imgs_idx = [pos_idx, neg_idx];
fprintf('\nnegative labeled data %d - positive labeled data %d',numel(neg_idx),  numel(pos_idx));
disp('dataset for experiment done. ');


%%% MAIN ALGO

loaded_state = 1;
main;

visualisation_KNN;
%if (ds.params.knn_html_visualization)
%  
%end

%patch_cooccurence;

%%% POST PROCESSING