
% load configuration
config();

%preprocess data and save the result into a .mat file.
%prepare_data();

%load imgs data
load('data/carldata.mat');

ds.imgs = imgs;

i = find_image_by_name(ds.imgs,'48.866799_2.359082_270_-004');


%for i = 1: 3
   %I = im2double(imread(ds.imgs(i).path));
   %ds.imgs(i).imsize = size(I);
   % only use 25 patches per images?
[ds.patches(i).metadata, ds.patches(i).features, ~] = sampleRandomPatches(i);
%end

res=extract_patches(ds.imgs(i).patches, imgs);

display_patches(ds.imgs(i).patches, imgs);
