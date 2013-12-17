
  


tic;
params.positive_label = positive_label;
%detector_idx = find([candidates.id] == 3689);
models= learn_detectors(candidates(top_detectors_idx(1:3)),detections, imgs, params);


%% Testing
test = struct();
for (i = 1:40)
  test(i).id = i;
  test(i).im = imgs(i).path;
end



disp(test);
tic;
for (i = 1:numel(models))
  boxes=test_dataset_v2(test, models{i}, '1');
end
toc;