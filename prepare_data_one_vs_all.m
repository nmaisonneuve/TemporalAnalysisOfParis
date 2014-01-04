function [selected_imgs, pos_idx] = prepare_data_one_vs_all(positive_labels, params)
  
  load('data/all_paris_data.mat');
  
  negative_labels = unique([imgs.label]);
  negative_labels(ismember(negative_labels,positive_labels)) = [];

  % take a subset/sample of data with positive labels
  pos_idx = find(ismember([imgs.label], positive_labels));
  pos_idx = pos_idx(randsample(numel(pos_idx), params.pos_sample_size));

  % taks a subset of data with negative label
  % here we respect th equality of all negative labels
  % so we take the same sample size for each negative label
  neg_idx = [];
  neg_sample_label_size = round(params.neg_sample_size/numel(negative_labels));
  for (i = 1:numel(negative_labels))
    neg_label = negative_labels(i);
    label_idx = find(ismember([imgs.label], neg_label));
    label_idx = label_idx(randsample(numel(label_idx),neg_sample_label_size));
    fprintf('\nnegative label %d - sample size: %d', neg_label, numel(label_idx));
    neg_idx = [neg_idx label_idx];
  end
  
  % we aggregate these 2 datasets into the dataset
  all_imgs_idx = [pos_idx, neg_idx];
  fprintf('\nnegative labeled data %d - positive labeled data %d',numel(neg_idx),  numel(pos_idx));
  disp('dataset for experiment done. ');

  selected_imgs = imgs(all_imgs_idx);
  pos_idx = 1:numel(pos_idx);
end