% For reproductability
format shortG;

clear;

%[debug] format for output display (to mix integer + float)

load('./data/step1_exp_one_vs_all_period1.mat');


% switch to who
rmpath(fullfile('./libs/hog/'));
addpath(genpath('./libs/who/'));

tic;
models = learn_patches(patches(1:2,:),ds.imgs);
toc;

same_size_idx =find(patches(:,7) ==80);

%% Testing
for (i = 1:numel(ds.all_imgs_idx))
  test(i).id = ds.all_imgs_idx(i);
  test(i).im = ds.imgs(test(i).id).path;
end

ds.all_imgs_idx;

disp(test);
tic;
boxes=test_dataset(test(1:100), models(1).model, '1');
toc;