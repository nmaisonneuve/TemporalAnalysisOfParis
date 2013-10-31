
rand('seed',1234);
rng('default'); % For reproducibility

%[debug] format for output display (to mix integer + float)
format shortG;

addpath(fullfile('./libs/crossValClustering/'));
addpath(fullfile('./libs/MinMaxSelection/'));
addpath(fullfile('./libs/hog/'));
addpath(fullfile('./libs/'));
% (optional) add unit tests directory to run some tests/debug
addpath(fullfile('./test/'));

%parallel computing : opening 4 workers 
%matlabpool(4);

global ds;

%each patch as 10 x 10 = 100 HOG bins

ds.params = struct(...,
  'num_train_its', 5, ... %define the number of training iterations used.  The paper uses 3; sometime %using as many as 5 can result in minor improvements.
  'pos_sample_size', 20, ... % initial sample size % usually 2000 positive images is enough; sometimes even 1000 works
  'neg_sample_size', 40, ... % initial sample size % usually 2000 positive images is enough; sometimes even 1000 works   
  'seed_candidate_size', 1000, ... %  ratio from the sample to get the number of images used to get seed patches candidates 
  'patches_per_image', 25,...  % -1 = no limit (cal's version: only use 25 patches per images?)
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
  'sampleBig', 0 );





