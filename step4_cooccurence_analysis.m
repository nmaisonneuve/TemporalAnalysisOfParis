
addpath(fullfile('./libs/jsonlab/'));
addpath(genpath('./libs/co-occurrence/'));

root_dir = sprintf('results/%s/cooccurrence',ds.params.experiment_name);
mkdir(root_dir);

context = 'image';
cooccurrence_analysis(candidates, formated_candidates, detections, context);

context = 'area';
cooccurrence_analysis(candidates, formated_candidates, detections, context);