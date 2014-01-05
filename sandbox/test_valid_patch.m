clear;
% load configuration
config();

%preprocess data and save the result into a .mat file.
%prepare_data();

%load imgs data
load('data/carldata.mat');

ds.imgs = imgs;
params = ds.params;
i = find_image_by_name(ds.imgs,'48.866799_2.359082_270_-004');

img_path = ds.imgs(i).path;

fprintf('\n Generating patches + computing features for image %s\n', img_path);
  im = im2double(imread(img_path));
  
  % construct HOG pyramid 
  tic;
  pyramid = constructFeaturePyramid(im, params);
  toc;
  
  tic;
  [features, levels, indexes,gradsums] = unentanglePyramid(pyramid, params);
  toc;
  
  %patch_idx = 1:numel(features);
  patch = [levels indexes];
  
  
  raw_size = size(features,1);

  % remove invalid patches (because too low gradient)
  invalid =(gradsums<9);
  features(invalid,:) = [];
  patch(invalid,:) =  [];
  %patch_idx(invalid,:) = [];
    
  fprintf('\nthrew out %d patches / %d', sum(invalid), raw_size);  