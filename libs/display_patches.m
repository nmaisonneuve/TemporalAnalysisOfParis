function display_patches(patches, imgs)

  color = 'r';
  
  % we sort by imidx (image idx) to not load the same image several times
  [~, sorted_patch_idx] = sort([patches.imidx]);
  
  last_idx = -1;
  for(i = sorted_patch_idx(:)')
  %for (i = [31])
    img_idx = patches(i).imidx;
    scale_level = patches(i).pyramid(1);
    
    % load image if new image idx
    if (last_idx ~= img_idx)
      I = imread(imgs(img_idx).path);
      imshow(I);
      
      last_idx = img_idx;
    end
    hold on;
    color = [0 scale_level / 17.0 0];
    box = [patches(i).x1 patches(i).y1, (patches(i).y2-patches(i).y1) (patches(i).x2-patches(i).x1)];    
    rectangle('Position', box, 'EdgeColor', color , 'LineWidth', 1);
    pause(0.1);
    hold off;
  end
end