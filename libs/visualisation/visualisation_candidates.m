  %%
  % formatting output data 
  %generate the clusters struct
  clusters = struct();
  
  patches_to_crops = patches;
  patches_to_crops = [patches_to_crops (1:size(patches,1))' ones(size(patches,1),1)*-1];
  disp(size(  patches_to_crops));  candidates_imgs = struct();
  previous_patches = 1;
  for (i = 1:numel(seed_pos_idx))
      img_idx = seed_pos_idx(i);
      sub_patches_idx = find(patches(:,1)==img_idx);
      nb_patches = numel(sub_patches_idx)+  previous_patches -1;
      candidates_imgs(i).id = img_idx;
      candidates_imgs(i).patches =  previous_patches:nb_patches;
      previous_patches = nb_patches +1;
  end
  
  experiment_dir = sprintf('results/%s',ds.params.experiment_name);


% create dir to save results from this experiment
root_dir = sprintf('results/%s/candidates',ds.params.experiment_name);
 if (exist(root_dir))
  rmdir(root_dir,'s')
 end 
mkdir(root_dir);

% extract images
img_dir = [root_dir '/images'];
mkdir(img_dir);

save_img_patches(  patches_to_crops, imgs, img_dir);
%save_img_patches([clusters.nn], imgs, img_dir);

% save clusters.json
json_file = [root_dir '/candidates.json'];
savejson('',  candidates_imgs,json_file);