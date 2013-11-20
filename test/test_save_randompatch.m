clear;

% load configuration
config();

%preprocess data and save the result into a .mat file.
global ds;
ds.params = struct(..., 
  'experiment_name', 'exp1',...%<-- NAME OF THE EXPERIMENT: IMPORTANT to differenciate experimental saved results
  'num_train_its', 5, ... %define the number of training iterations used.  The paper uses 3; sometime %using as many as 5 can result in minor improvements.
  'pos_sample_size', 100, ... % initial sample size % usually 2000 positive images is enough; sometimes even 1000 works
  'neg_sample_size', 400, ... % initial sample size % usually 2000 positive images is enough; sometimes even 1000 works   
  'seed_candidate_size', 100, ... %  ratio from the sample to get the number of images used to get seed patches candidates 
  'seed_patches_per_image', 25,...  % -1 = no limit (cal's version: only use 25 patches per images?)
  'imageCanonicalSize', 400,...% images are resized so that their smallest dimension is this size.
  'patchCanonicalSize', {[120 80]}, ...% patches are extracted at this size.  Should be a multiple of sBins.
  'scaleIntervals', 8, ...% number of levels per octave in the HOG pyramid 
  'sBins', 8, ...% HOG sBins parameter--i.e. the width in height (in pixels) of each cell
  'useColor', 1, ...% include a tiny image (the a,b components of the Lab representation) in the patch descriptor
  'useColorHists',0,...
  'patchOnly', 0,...
  'patchOverlapThreshold', 0, ...%detections (and random samples during initialization) with an overlap higher than this are discarded.
  'overlap', 0.4, ...% detections with overlap higher than this are discarded.  
  'svmflags', '-s 0 -t 0 -c 0.1',...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'fixedDecisionThresh', -1.002,...
  'levelFactor', 2, ... % number of levels for pyramid HOG 
  'sampleBig', 0,...
  'knn_html_visualization',1); % do we generate KNN HTML visualisation?

%load imgs data
load('data/paris_data.mat');

ds.imgs = imgs;

%i = find_image_by_name(ds.imgs,'48.866799_2.359082_270_-004');


root_dir = sprintf('random_patches');
 if (exist(root_dir))
  rmdir(root_dir,'s')
 end 
mkdir(root_dir);

for i = 1: 10

[patches, features, ~] = sampleRandomPatches(i, ds, ds.params.seed_patches_per_image);
%end

patches_pos = [[patches.x1]' [patches.x2]' [patches.y1]' [patches.y2]'];
patches = [ ones(size(patches,1),1)*i, patches_pos];
%res=extract_patches(ds.imgs(i).patches, imgs);


save_img_with_patches(patches, imgs, root_dir);
end