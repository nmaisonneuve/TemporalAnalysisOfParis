% save image with patches annotation
% info: row of patches [img_id x1 x2 y1 y2]
function save_img_with_patches(patches, imgs, dirname, change)
 
red = uint8([255 0 0]);
shapeInserter = vision.ShapeInserter('Shape','Rectangles','BorderColor','Custom','CustomBorderColor',red);
  
  %color = 'r';
  if (nargin<4)
    change = 1;
  end
  
  % we sort by imidx (image idx) to not load the same image several times
  [~, sorted_patch_idx] = sort(patches(:,1));
  if (change == 1)
    % we change the struct to [x1, y1 width height]
    [height, width] = patch_size(patches(:,2:5));
    patches(:,2:5) = [patches(:,4) patches(:,2) height width];
  end
  
  last_idx = -1;

  for(idx = 1:numel(sorted_patch_idx))
    
    patch = patches(sorted_patch_idx(idx),:);
    
    img_id = patch(1);
       
    % load image if new image idx
    if (last_idx ~= img_id)
      
      % save previous image 
      if (last_idx ~= -1)
        % filename = sprintf('results/clusters/%d/patch_%d_%d.jpg', cluster_id, img_id, patch_id);
        filename = sprintf('%s/image_%d.jpg',dirname, last_idx);  
        imwrite(I, filename);
      end
      
      % load next image
      I = imread(imgs(img_id).path);    
      last_idx = img_id;
    end
     
    %box = [patches(i).x1 patches(i).y1, (patches(i).y2-patches(i).y1) (patches(i).x2-patches(i).x1)];    
    box = int16(patch(2:5));
    disp(box);
    I = step(shapeInserter, I, box);
    %rectangle('Position', box, 'EdgeColor', color , 'LineWidth', 1);
   % pause(0.1);
    
  end
  
    % save previous image 
      if (last_idx ~= -1)
        % filename = sprintf('results/clusters/%d/patch_%d_%d.jpg', cluster_id, img_id, patch_id);
        filename = sprintf('%s/image_%d.jpg',dirname, last_idx);  
        imwrite(I, filename);
      end
   
end