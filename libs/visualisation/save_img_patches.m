% TODO be much more efficient if patches are identical
function save_img_patches(patches, imgs, dirname)
  
  % we sort by imidx (image idx) to not load the same image several times
  [~, sorted_patch_idx] = sort(patches(:,1));
  
  % we modify the struct
  [width, height] = patch_size(patches(:,2:5));
  patches(:,6)= width;
  patches(:,7) = height; 
  
  %patches(:,2:5) = [patches(:,4) patches(:,2) width height];
 
  last_idx = -1;

  for(idx = 1:numel(sorted_patch_idx))
    
    patch = patches(sorted_patch_idx(idx),:);
    
    img_id = patch(1);
       
    % load image if new image idx
    if (last_idx ~= img_id)
      I = imread(imgs(img_id).path);    
      img_dir = sprintf('%s/%d',dirname, img_id);
      mkdir(img_dir);
      last_idx = img_id;
    end
     
    rect = [patch(:,4) patch(:, 2) patch(:,6) patch(:,7)];
    
    I2 = imcrop(I,rect);
    if (isequal(size(I2),[0 0]))
      fprintf('\nerror extracting patch for img %d (idx: %d)',img_id,idx);
    else
      % filename = sprintf('results/clusters/%d/patch_%d_%d.jpg', cluster_id, img_id, patch_id);
      filename = sprintf('%s/crop_%d_%d_%d_%d.jpg',img_dir, patch(2), patch(3), patch(4), patch(5));       
      imwrite(I2, filename);
    end
    
   end
end