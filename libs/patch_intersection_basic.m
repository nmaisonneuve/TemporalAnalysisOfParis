% compute the intersection (the area) of 2 sets of patches
% x1 y1 x2 y2
% return overlapping area in pixel
function area = patch_intersection_basic(a,b)
  [width, height ] = patch_size(a);
  %area_a = width .*height;

  A = [a(:, [1 3]) width height];

  [width, height ] = patch_size(b);
 % area_b = width .*height;
  B = [b(:, [1 3]) width height];
  
  
  area = rectint(A,B);
end



