


%% REMOVE OVERLAPPING
fprintf('\nRemoving overlapping patches: (overlapping threshold: %f)',ds.params.patchOverlapThreshold);
tic;
%remove overlapping patches beyond a threshold
% and keep only the purest candidates of a overlapping pair
[~, priority_idx] = sort(ranked_candidates_idx);
to_keep_patches_idx = remove_overlapping_patches(patches, ds.params.patchOverlapThreshold, priority_idx);

toc;
fprintf('\n %d/%d candidates patches kept',numel(to_keep_patches_idx),size(patches,1));


% new ranking with overlapping element removed
fprintf('\nfiltering ranking with kept patches');
[~, inter_ranked_idx, ~ ] = intersect(ranked_candidates_idx, to_keep_patches_idx);
inter_ranked_idx = sort(inter_ranked_idx);
ranked_candidates_idx = ranked_candidates_idx(inter_ranked_idx);
candidates = candidates(ranked_candidates_idx);


