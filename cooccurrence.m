config();
addpath(fullfile('./libs/jsonlab/'));
addpath(genpath('./libs/co-occurrence/'));



root_dir = sprintf('results/%s/cooccurrence',ds.params.experiment_name);

%% Compute co-occurrence matrix
co_matrix = cooccurrence_matrix(best_clusters_idx, top_nn_idx, closest_patches);
% remove weak ties
%co_matrix(co_matrix(:) < 0.05)=0;

% display histogram
hist(co_matrix);

% save co-occurence matrix for visualisation
json_file = [root_dir '/cooccurrences.json'];
save_cooccurrence_network(co_matrix, best_clusters_idx, patches, json_file);


%% Clustering co-occurrence
co_cluster_idx = clustering_louvain(co_matrix);

% save clustering for visualisation
json_file = [root_dir '/clustering.json'];
save_cooccurrence_clustering([best_clusters_idx co_cluster_idx], patches, json_file);


%now you can visuaize the result at
%/visualisation/co_occurrence_clusters.html?exp={experiment_name}