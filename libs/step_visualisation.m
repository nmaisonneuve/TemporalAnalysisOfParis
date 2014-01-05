%% For visualisation 


a = [candidates.purity];
b = [candidates.frequency];
z = [candidates.mean];
scatter([candidates.purity], [candidates.frequency], 20, z,'fill');
axis([0,1.0,0.0,1.0]);

root_dir = sprintf('results/%s',ds.params.experiment_name);
mkdir(root_dir);
% get the top 5% most discriminative patches 

% save to candidates + members as json file
fprintf('\nSaving patches metada to json...');
tic;
json_file = [root_dir '/candidates.json'];
%save_candidates_to_json(candidates, ... 
%  detections, pos_idx,json_file);
save_candidates_to_json(candidates(top_detectors_idx), patches, detections, json_file);
toc;

fprintf('\nCroping patches from images...');
tic;
img_dir = [root_dir '/images'];
save_candidates_imgs(candidates(top_detectors_idx), patches, detections, imgs, img_dir);
toc;
