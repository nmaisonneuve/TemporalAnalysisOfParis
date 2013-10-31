function res=extract_patches_from_level(patches, imgs)

  % we sort by imidx (image idx) to not load the same image several times
  [~, sorted_patch_idx] = sort([patches.imidx]);

  last_idx = -1;
  for(i = sorted_patch_idx(:)')
    img_idx = patches(i).imidx;
    scale_level = patches(i).pyramid(1);
    
    % load image if new image idx
    if (last_idx ~= img_idx)
      I = imread(imgs(img_idx).path);
      last_idx = img_idx;
    end
    
    % cut the image according to patch dimension
    res{i} = I(patches(i).y1:patches(i).y2,patches(i).x1:patches(i).x2,:);
    filename = sprintf('results/patch_%d_%d_%d.jpg',img_idx, scale_level, i);
    imwrite(res{i},filename);
    
  end
end