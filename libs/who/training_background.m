
sample_idx = [];

period_labels = [1 2 3 5 6 7 8 9 10 11];
sample_label_size = round(2000/numel(period_labels));
 

 for (i = 1:numel(period_labels))
    neg_label = period_labels(i);
    label_idx = find(ismember([ds.imgs.label], neg_label));
    disp(size(label_idx));
    label_idx = label_idx(randsample(numel(label_idx), sample_label_size))';
    fprintf('\n label %d - sample size: %d', neg_label, numel(label_idx));
    sample_idx = [sample_idx; label_idx];
 end
 
 %% Testing
test = struct();
for (i = 1:numel(sample_idx))
  test(i).id = i;
  test(i).im = ds.imgs(sample_idx(i)).path;
end
bg = trainBG(test, 20, 10, 8);