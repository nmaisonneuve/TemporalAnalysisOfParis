%init
%preparing data
%prepare_data();

%load imgs data
load('data/carldata.mat');
ds.imgs = imgs;

% split data into pos + neg dataset
positive_label = 2; % time period 2 (oldish buildings)
negative_label = 1; % time period 7 (newish buildings)
pos_idx = find([ds.imgs.label] == positive_label);
neg_idx = find([ds.imgs.label] == negative_label);

% we actually take a subset/sample
if (numel(pos_idx)> ds.params.neg_sample_size)
  pos_idx = pos_idx(randsample(numel(pos_idx),ds.params.pos_sample_size));
end
if (numel(neg_idx) > ds.params.neg_sample_size)
  neg_idx = neg_idx(randsample(numel(neg_idx),ds.params.neg_sample_size));
end

% we aggregate these 2 datasets into the dataset used for the experiment
ds.all_imgs_idx = [pos_idx, neg_idx];

disp('dataset for experiment done. ');