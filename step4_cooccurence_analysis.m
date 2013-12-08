

addpath(genpath('./libs/co-occurrence/'));

co_dir = sprintf('results/%s/cooccurrence',ds.params.experiment_name);
mkdir(co_dir);

nb_top_detectors = sum([candidates.purity]>=0.7);

co_params.context = 'area';
co_params.only_positive = 1;
co_params.positive_label = positive_label;
co_params.overlap_threshold = 0.5;
cooccurrence_analysis(candidates(1:nb_top_detectors), formated_top_candidates, detections, co_params, co_dir);



co_params.context = 'image';
cooccurrence_analysis(candidates(1:nb_top_detectors), formated_top_candidates, detections, co_params, co_dir);