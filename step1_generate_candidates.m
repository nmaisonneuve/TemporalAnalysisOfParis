% takes a ramdom sample of positive images
% to get seed patch candidates
seed_pos_idx = randsample(pos_idx, ds.params.seed_candidate_size);
fprintf('\nComputing candidate patches from %d positive images', numel(seed_pos_idx));


% number of initial clusters
nb_init_clusters = numel(seed_pos_idx) * ds.params.seed_patches_per_image;

% take {ds.seed_candidate_size} random patches from each selected image

tic;

% we use struct  due to parallel computing
image_patches = struct(); 
parfor i = 1: numel(seed_pos_idx)  
  img_idx = seed_pos_idx(i);
disp(img_idx);
  [patches, feats, ~] = sampleRandomPatches(img_idx, ds, ds.params.seed_patches_per_image);
  fprintf('\n%d patches extracted from image %d (idx: %d)',size(patches,1), i, img_idx);
  img_id_col = ones(size(patches,1),1) * img_idx;
  patches_pos = [[patches.x1]' [patches.x2]' [patches.y1]' [patches.y2]'];

  %append
  image_patches(i).features = feats';
  image_patches(i).patches = [img_id_col patches_pos]';
end

toc;
  
initFeats = [image_patches.features]';
patches = [image_patches.patches]';
  
% normalizing candidate patches
initFeats = bsxfun(@rdivide,bsxfun(@minus,initFeats,mean(initFeats,2)),...
    sqrt(var(initFeats,1,2)).*size(initFeats,2));
  
% visualizing generated patches

  