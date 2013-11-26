% Compute the intersection (the area) of a list of patches

% INPUT
% patches = [x1, x2, y1, y2]

% OUTPUT 
% overlap = [indice_patchA, indice_patchB, ratio of surface of patchA overlapping
% patchB]
% (NOTE: return only the overlapping pairs)
function overlap = patch_intersection_list(patches)
  
  %prepare data 
  [width, height ] = patch_size(patches);
  A = [patches(:, [1 3]) width height];
  area = width.*height;
  
  % compute intersection
  int_area = rectint(A,A);
 
  % remove pairs (i,i)
  int_area(eye(size(int_area))==1) = 0;
  
  % construct list
  int_area = sparse(int_area);
  [i,j, s] = find(int_area);
  pairs = [i j];
 
  % swap pair to get patch with the smallest area always in first column
  [min_area, smallest_patches_idx] = min([area(i),area(j)], [], 2);
  row_to_swap = find(smallest_patches_idx==2);
  pairs(row_to_swap,:) = [pairs(row_to_swap,2) pairs(row_to_swap,1)];
  
  % divide intersection surface by its smallest area surface
  inter_relative = s ./min_area ;
  overlap = [pairs(:,1) pairs(:,2) inter_relative];
end
