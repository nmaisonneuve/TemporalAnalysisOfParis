

addpath(genpath('./libs/co-occurrence/'));

co_dir = sprintf('results/%s/cooccurrence',ds.params.experiment_name);
mkdir(co_dir);

co_params.context = 'area';
co_params.only_positive = 1;
co_params.positive_label = positive_label;
co_params.overlap_threshold = 0.1;
co_params.noise_threshold = 1;

context_dir = sprintf('%s/%s',co_dir,co_params.context);
mkdir(context_dir);

tic;
[co_matrix, co_cluster_idx] = cooccurrence_analysis(candidates(top_detectors_idx), detections, co_params);
toc;

  
tic;
save_cooccurrences(co_matrix, co_cluster_idx, patches([candidates(top_detectors_idx).id],:), context_dir);
toc;

tic;
nb_samples = 10;
save_cooccurrence_sample_images(co_cluster_idx, candidates(top_detectors_idx), detections, imgs, positive_label, nb_samples, context_dir);
toc;
 
co_params.context = 'image';
co_params.noise_threshold = 0.05;
context_dir = sprintf('%s/%s',co_dir,co_params.context);
mkdir(context_dir);

[co_matrix, co_cluster_idx] = cooccurrence_analysis(candidates(top_detectors_idx),detections, co_params);

tic;
save_cooccurrences(co_matrix, co_cluster_idx, patches([candidates(top_detectors_idx).id],:), context_dir);
toc;

tic;
nb_samples = 10;
save_cooccurrence_sample_images(co_cluster_idx, candidates(top_detectors_idx), detections, imgs, positive_label, nb_samples, context_dir);
toc;  