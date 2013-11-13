  function extract_patches_from_position(patches, imgs)
  
  global ds;
  % we sort by imidx (image idx) to not load the same image several times
  [~, sorted_patch_idx] = sort([patches.img_id]);

  last_idx = -1;


  
  for(i = sorted_patch_idx(:)')
    
    img_id = patches(i).img_id;
    cluster_id = patches(i).cluster_id;
    patch_id = patches(i).patch_id;
    
    % load image if new image idx
    if (last_idx ~= img_id)
      I = imread(imgs(img_id).path);
      last_idx = img_id;
      dir = sprintf('results/%s/images/%d',ds.params.experiment_name, img_id);
      mkdir(dir);
    end
   
   % fprintf('image %d',img_id);
    
    % cut the image according to patch dimension
    %res{i} = I(patches(i).y1:patches(i).y2,patches(i).x1:patches(i).x2,:);
    
    rect = [patches(i).y1 patches(i).x1 (patches(i).y2-patches(i).y1) (patches(i).x2-patches(i).x1)];

    I2 = imcrop(I,rect);
    if (isequal(size(I2),[0 0]))
     fprintf('error extracting patch for img %s',img_id);

    else
      % filename = sprintf('results/clusters/%d/patch_%d_%d.jpg', cluster_id, img_id, patch_id);
    filename = sprintf('results/%s/images/%d/patch_%d.jpg',ds.params.experiment_name,img_id, patch_id);       
    imwrite(I2, filename);
    end
    %imshow(I2),figure
    
   
   % catch
      
    % 
    %  
    %end
   end
end