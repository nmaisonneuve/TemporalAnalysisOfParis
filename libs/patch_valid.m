% check position validity of patches compared to image size
function patch_valid(patches, imgs)

  % sorted by image_id
  [~, sorted_img_idx] = sort(patches(:,1));
  patches = patches(sorted_img_idx,:);
  
  last_idx = -1;
  nrows = 0;
  ncols =0;
  
  for (i = 1:size(patches,1))
    img_id = patches(i,1);
    
    % load image if new image idx
    if (last_idx ~= img_id) 
      [nrows , ncols,~] = size(imread(imgs(img_id).path));
      last_idx = img_id;      
     % fprintf('\nimage %d - size : %d x %d', img_id, nrows, ncols);
    end
    
    xmin =patches(i,2);
    xmax =patches(i,3);
    ymin =patches(i,4);
    ymax =patches(i,5);
    
    valid = (xmin > 0) && (xmax <= nrows) && (ymin > 0) && (ymax<= ncols);
    if (valid == 0)
      fprintf('\nERROR PATCH CLIPPED: %d x %d <= %d, %d x %d <= %d, ',xmin, xmax, nrows, ymin, ymax, ncols);
    else
     % disp('ok');
    end
    
   end
  
end