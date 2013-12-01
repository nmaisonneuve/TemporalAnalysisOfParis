
% k_nn = number of the nearest neighboors used for each candidate
% to compute purity according to their label and rank candidates
k_nn = 20;
fprintf('\nRanking candidates...');
tic;
%[ranked_candidates_idx, candidates] = KNN_ranking_purity(detections, k_nn ,pos_idx);
[ranked_candidates_idx, candidates] = KNN_ranking(detections, k_nn ,ds.imgs, positive_label);
toc;

%% REMOVE OVERLAPPING
fprintf('\nRemoving overlapping patches');
tic;
%remove overlapping patches beyond a threshold
% and keep only the purest candidates of a overlapping pair
purity = [candidates.purity];
to_keep_patches_idx = remove_overlapping_patches(patches, ds.params.patchOverlapThreshold, purity);
toc;
fprintf('\n %d/%d candidates patches kept',numel(to_keep_patches_idx),size(patches,1));


% new ranking with overlapping element removed
fprintf('\nfiltering ranking with kept patches');
[~, inter_ranked_idx, ~ ] = intersect(ranked_candidates_idx, to_keep_patches_idx);
inter_ranked_idx = sort(inter_ranked_idx);
ranked_candidates_idx = ranked_candidates_idx(inter_ranked_idx);
purity = purity(inter_ranked_idx);
candidates = candidates(ranked_candidates_idx);