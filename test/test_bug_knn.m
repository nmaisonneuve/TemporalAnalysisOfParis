
% load configuration
config();

global ds;
ds.params = struct(..., 
  'experiment_name', 'exp1',...%<-- NAME OF THE EXPERIMENT: IMPORTANT to differenciate experimental saved results
  'num_train_its', 5, ... %define the number of training iterations used.  The paper uses 3; sometime %using as many as 5 can result in minor improvements.
  'pos_sample_size', 100, ... % initial sample size % usually 2000 positive images is enough; sometimes even 1000 works
  'neg_sample_size', 300, ... % initial sample size % usually 2000 positive images is enough; sometimes even 1000 works   
  'seed_candidate_size', 100, ... %  ratio from the sample to get the number of images used to get seed patches candidates 
  'seed_patches_per_image', 25,...  % -1 = no limit (cal's version: only use 25 patches per images?)
  'imageCanonicalSize', 400,...% images are resized so that their smallest dimension is this size.
  'patchCanonicalSize', {[80 80]}, ...% patches are extracted at this size.  Should be a multiple of sBins.
  'scaleIntervals', 8, ...% number of levels per octave in the HOG pyramid 
  'sBins', 8, ...% HOG sBins parameter--i.e. the width in height (in pixels) of each cell
  'useColor', 1, ...% include a tiny image (the a,b components of the Lab representation) in the patch descriptor
  'useColorHists',0,...
  'patchOnly', 0,...
  'patchOverlapThreshold', 0.5, ...%detections (and random samples during initialization) with an overlap higher than this are discarded.
  'overlap', 0.4, ...% detections with overlap higher than this are discarded.  
  'svmflags', '-s 0 -t 0 -c 0.1',...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'fixedDecisionThresh', -1.002,...
  'levelFactor', 2, ... % number of levels for pyramid HOG 
  'sampleBig', 0,...
  'knn_html_visualization',1);

%preprocess data and save the result into a .mat file.
%prepare_data();

%load imgs data
load('data/paris_data.mat');
ds.imgs = imgs;

i = 1;
img_path = ds.imgs(i).path;


[x,y,z]=size(imread(img_path));


[patches, features, ~] = sampleRandomPatches(i, ds, ds.params.seed_patches_per_image);
%end

candidates = [patches.x1; patches.x2; patches.y1; patches.y2]';

[nrows, ncols] = patch_size(candidates);

candidates = [candidates nrows, ncols];

% normalize
features = bsxfun(@rdivide,bsxfun(@minus,features,mean(features,2)),...
    sqrt(var(features,1,2)).*size(features,2));
  

%res=extract_patches(metadatas, imgs);

%display_patches(metadata, imgs);

% get the nearest patch in the image for each patch candidate  (+ its distance)
% => ! 2 NN patches could not be from the same image => good

[test_patches , test_features, pyramid] = compute_valid_patches(img_path, ds.params);
  
  
  if(isempty(patches))
    disp('ALERT NO patch FOUND ');
    return;
  end

  % for each candidate what is the closest patche
  % (and not for each patch what is the closest candidate)
  % [closest_patches_idx, dist]=assigntoclosest(single(centroids),single(features_patches));
  
  [closest_patches_idx, dist]=assigntoclosest(features,test_features);
  
  % return patch info only from the closest patches
  test_patches = test_patches(closest_patches_idx,:);
 % features_patches(closest_patches_idx,:);
  
   pp = patch_level_to_position( test_patches, pyramid, ds.params);
  
  [nrows, ncols] = patch_size(pp);

   pp = [pp nrows, ncols];
   
   equality = isequal(pp, candidates);
   
   fprintf('TEST NEAREST NEIGHBORS: equal patches = %d', equality);
   
  