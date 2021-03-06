%init
%preparing data
%prepare_data();

% load imgs data
load('data/paris_data.mat');
ds.imgs = imgs;

% split data into pos + neg dataset
positive_period = 1; % time period 2 (oldish buildings)
negative_period = 7; % time period 7 (newish buildings)
pos_idx = find([ds.imgs.label] == positive_period);
neg_idx = find([ds.imgs.label] ~= positive_period);

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

% FAKE TO TEST 
%ds.all_imgs_idx = [neg_idx(1:6) pos_idx(1:3)];
%ds.params.seed_candidate_size = 20;

