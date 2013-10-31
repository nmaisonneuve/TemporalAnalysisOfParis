
clear;
% load configuration
config();

%preprocess data and save the result into a .mat file.
%prepare_data();

%load imgs data
load('data/carldata.mat');

ds.imgs = imgs;

i = find_image_by_name(ds.imgs,'48.866799_2.359082_270_-004');
img_path = ds.imgs(i).path;

I = im2double(imread(img_path));
tic;
pyramid = constructFeaturePyramidForImg(I, ds.params);
toc;
disp(pyramid);

tic;
%for each patch of every level + every index (= 15556 patches for each 537 z 936 image) 1of a given level get related features (2112 Features) + gradientsum
[features, levels, indexes,gradsums] = unentanglePyramid(pyramid, ds.params);
toc;

invalid=(gradsums<9);



disp(sum(invalid));  
fprintf('\nthrew out %d patches',sum(invalid));
  