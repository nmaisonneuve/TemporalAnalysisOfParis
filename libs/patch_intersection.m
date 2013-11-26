% compute the intersection (the area) of 2 sets of patches
% x1 y1 x2 y2
function area = patch_intersection(a,b)
  [width, height ] = patch_size(a);
  A = [a(:, [1 3]) width height];

  [width, height ] = patch_size(b);
  B = [b(:, [1 3]) width height];
  disp(A);
  disp(B);
  area = rectint(A,B);
end



