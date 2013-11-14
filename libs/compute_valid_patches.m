 % compute patches of an image 
 % and return only valid ones (+ removing useless ones)
 
function [patches, features, pyramid] = compute_valid_patches(img_path, params, normalizing)
  
  % per default, we normalize features
  if nargin < 3
    normalizing = 1;
  end
  
  fprintf('\nGenerating patches + computing features for image %s', img_path);
  im = im2double(imread(img_path));
  
  % construct HOG pyramid 
  pyramid = constructFeaturePyramid(im, params);
  [features, levels, indexes,gradsums] = unentanglePyramid(pyramid, params);
  
  %patch_idx = 1:numel(features);
  patches = [levels indexes];
   
  raw_size = size(features,1);

  % remove invalid patches (because too low gradient)
  invalid =(gradsums<2);
  features(invalid,:) = [];
  patches(invalid,:) =  [];
  %patch_idx(invalid,:) = [];    
  
  fprintf('\nthrew out %d patches / %d', sum(invalid), raw_size);
  
  if (normalizing)
    % normalize remaining features
    features = bsxfun(@rdivide,bsxfun(@minus,features,mean(features,2)),sqrt(var(features,1,2)).*size(features,2));
  end
end
