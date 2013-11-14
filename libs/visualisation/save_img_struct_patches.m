% TODO be much more efficient if patches are identical
function save_img_struct_patches(patches, imgs, dirname)
  
  % we sort by imidx (image idx) to not load the same image several times
  [~, sorted_patch_idx] = sort([patches.img_id]);

  last_idx = -1;

  for(i = 1:numel(sorted_patch_idx))
    idx = sorted_patch_idx(i);
    img_id = patches(idx).img_id;
    cluster_id = patches(idx).cluster_id;
    % patch_id = patches(idx).patch_id;
    
    % load image if new image idx
    if (last_idx ~= img_id)
      I = imread(imgs(img_id).path);
      last_idx = img_id;
      dir = sprintf('%s/%d',dirname, img_id);
     % disp(imgs(img_id).path);
      mkdir(dir);
    else
    % disp('good');
    end
   
    % fprintf('image %d',img_id);    
    % cut the image according to patch dimension
    %res{i} = I(patches(i).y1:patches(i).y2,patches(i).x1:patches(i).x2,:);
    
    rect = [patches(i).y1 patches(i).x1 (patches(i).y2-patches(i).y1) (patches(i).x2-patches(i).x1)];

   % rect = [patches(i).x1 patches(i).y1 (patches(i).x2-patches(i).x1)+1 (patches(i).y2-patches(i).y1)+1];
   % disp(rect);
   % disp(size(I));
    
    I2 = imcrop(I,rect);
    if (isequal(size(I2),[0 0]))
     fprintf('\nerror extracting patch for img %d',img_id);

    else
      % filename = sprintf('results/clusters/%d/patch_%d_%d.jpg', cluster_id, img_id, patch_id);
    filename = sprintf('%s/cluster_%d.jpg',dir, cluster_id);       
    imwrite(I2, filename);
    end
    %imshow(I2),figure
    
   
   % catch
      
    % 
    %  
    %end
   end
end