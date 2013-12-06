% INPUT
% patches = [img_id x1, x2, y1, y2]

% OUTPUT 
% overlap = [indice_patchA, indice_patchB, ratio of surface of patchA overlapping
% patchB]
% (NOTE: return only the overlapping pairs)

  function overlap = filter_overlapping_patches(patches)

    imgs = unique(patches(:,1))';
    overlap = [];
    for (img_id = imgs)

      img_patches_idx = find(patches(:,1)== img_id);

      img_overlap = patch_intersection_per_img(patches(img_patches_idx,2:5));

      % transform to global index
      img_overlap(:,1) = img_patches_idx(img_overlap(:,1));
      img_overlap(:,2) = img_patches_idx(img_overlap(:,2));
      % append
      overlap = [overlap; img_overlap];

    end

  % Compute the intersection (the area) of a list of patches
  % INPUT
  % patches = [x1, x2, y1, y2]
  % OUTPUT 
  % overlap = [indice_patchA, indice_patchB, ratio of surface of patchA overlapping
  % patchB]
  % (NOTE: return only the overlapping pairs)
  function overlap = patch_intersection_per_img(patches)

    %transform data to [x1 y1 width height]
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

end