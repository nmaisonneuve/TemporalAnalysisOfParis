
  
load('data/step2_exp_one_vs_all_period2_v2.mat');

tic;
params.positive_label = positive_label;
params.sbin = 8;
%detector_idx = find([candidates.id] == 3689);
detectors= learn_detectors(candidates(top_detectors_idx(1:100)),detections, imgs, params);
toc;

%% Testing
test = struct();
for (i = 1:numel(imgs))
  test(i).id = i;
  test(i).im = imgs(i).path;
end

tic;
who_detections = struct();
for (i = 1:numel(detectors))
  %%
  fprintf('\n finding detections for detector %d', i);
  id = candidates(top_detectors_idx(i)).id;
  who_detections(i).candidate_id = id;
  %% 
  tmp_detections = test_dataset_v2(test, detectors{i});
  no_empty = find(~cellfun(@isempty, tmp_detectionss));
  tmp_detections =  tmp_detections(no_empty);
  tmp_detections = cell2mat([tmp_detections(:)]);
  tmp_detections = [ones(size(tmp_detections,1),1) * id tmp_detections];  
  who_detections(i).detections = tmp_detections;
end
toc;

detections_who = [];
for (i = 1:(numel(who_detections)-1))
  no_empty = find(~cellfun(@isempty,who_detections(i).detections));
  detections_v2 = who_detections(i).detections(no_empty);
  detections_v2 = cell2mat([detections_v2(:)]);  
  detections_v2(:,2:5) = int16(detections_v2(:,2:5));
  
  neg_position = max(detections_v2(:,2:5)<0,[],2);
  detections_v2(neg_position,:) = [];
  
  %disp(detections_v2(1:10,:));
  %filename = sprintf('./test/patches_%d',i);
  %mkdir(filename);
  save_img_patches(detections_v2, imgs, filename);
  
  detections_who = [detections_who;  d];
end




