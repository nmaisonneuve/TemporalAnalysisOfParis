clear;
config();

load('data/paris_data.mat');

ds.imgs = imgs;
  
% select random images
nb_img_idx = 20; 
sample = randsample(numel(ds.imgs), nb_img_idx);

% or not...
% sample = [1 3 423 234]
% nb_img_idx = numel(sample);
mkdir('test/green_filter');
for i = 1:nb_img_idx
  
  img_path = ds.imgs(sample(i)).path;
  disp(img_path);
  org{i} = imread(img_path);
  
  im2=rgb2hsv(org{i});
  filter{i} = im2(:,:,1)>0.20&im2(:,:,1)<0.35&im2(:,:,2)>0.2&im2(:,:,3)>0.1;
  
  org_name = sprintf('test/green_filter/%d.jpg', sample(i) );
  filter_name = sprintf('test/green_filter/%d_filter.jpg', sample(i) );
  
  imwrite(org{i}, org_name);
  imwrite(filter{i}, filter_name);
end

 nb_rows = 2;
 nb_cols = nb_img_idx;

 ha = tight_subplot(nb_rows,nb_cols,[0 0],[0 0],[0 0]);

 for i = 1:nb_rows 
    for j = 1:nb_cols
      idx = j + (i-1) * nb_cols;
      axes(ha(idx));
      if (i == 1)
        imshow(org{j});
      else
        imshow(filter{j});
      end
    end
 end