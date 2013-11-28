%% For visualisation 

% histo of purity
%hist(double(purity),100);
%print -dpng 'test.png';
%cdfplot(purity); 

root_dir = sprintf('results/%s',ds.params.experiment_name);

% get the top 5% most discriminative patches 
nb_top_detectors = uint8(0.05 * size(patches,1));

% save to candidates + members as json file
fprintf('\nSaving patches metada to json...');
tic;
json_file = [root_dir '/candidates.json'];
%save_candidates_to_json(candidates, ... 
%  detections, pos_idx,json_file);
save_candidates_to_json(candidates(1:nb_top_detectors), patches, detections, json_file);
toc;

fprintf('\nCroping patches from images...');
tic;
img_dir = [root_dir '/images'];
save_candidates_imgs(candidates(1:nb_top_detectors), patches, detections, imgs, img_dir)
toc;
