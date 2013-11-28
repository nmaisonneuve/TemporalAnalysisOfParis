config();
addpath(fullfile('./libs/jsonlab/'));
addpath(genpath('./libs/co-occurrence/'));


root_dir = sprintf('results/%s/cooccurrence',ds.params.experiment_name);
mkdir(root_dir);
%% Compute co-occurrence matrix
co_matrix = cooccurrence_matrix(candidates(1:nb_top_detectors), detections);
% remove weak ties
%co_matrix(co_matrix(:) < 0.05)=0;

% display histogram
hist(co_matrix);

% save co-occurence matrix for visualisation
json_file = [root_dir '/cooccurrences.json'];
save_cooccurrence_network(co_matrix, formated_candidates, json_file);
pajek_file = [root_dir '/cooccurrences.net'];
write_matrix_to_pajek(co_matrix,pajek_file,'weighted',true,'directed',false);


%% Clustering co-occurrence
co_matrix(co_matrix(:) < 0.02) = 0;
co_cluster_idx = clustering_louvain(co_matrix );

% save clustering for visualisation
json_file = [root_dir '/clustering.json'];
save_cooccurrence_clustering(co_cluster_idx, formated_candidates,json_file);


%now you can visuaize the result at
%/visualisation/co_occurrence_clusters.html?exp={experiment_name}