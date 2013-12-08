img_idx = 1615;
im = im2double(imread(imgs(img_idx).path));
test_patches = patches(find(patches(:,1) == 1615),2:5);
im  = gen_heatmap(im, test_patches);
imshow(im);
