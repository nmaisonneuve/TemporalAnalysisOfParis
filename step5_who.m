

tic;
models = learn_patches(patches(candidates(1).id,:),imgs);
toc;


%% Testing
for (i = 1:numel(imgs))
  test(i).id = i;
  test(i).im = imgs(i).path;
end

ds.all_imgs_idx;

disp(test);
tic;
boxes=test_dataset(test(1:100), models{1}, '1');
toc;