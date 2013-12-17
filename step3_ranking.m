
%% SCORING
% scoring patches according to their discriminativity and representativity
tic;
params.discriminativity_threshold = 0.7;
params.representativity_threshold = 0.05;
params.positive_label = positive_label;
candidates = scoring_detectors_v2(detections,imgs, params);
toc;

%filter candidates below threshold
%filter = ([candidates.purity] > params.discriminativity_threshold) & ([candidates.frequency] > params.representativity_threshold);
%candidates = candidates(filter);

% sort by a criteria harmonic mean , purity or frequency
[~, ranked_candidates_idx] = sort([candidates.purity],'descend');

top_detectors_idx = ranked_candidates_idx(1:300);