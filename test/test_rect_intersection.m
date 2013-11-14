
% x1 x2 %y1 %y2
a = [1 2 1 2];
b = [2 3 1 2];


[width, height ] = patch_size(a);
A = [a(:, [1 3]) width height];

[width, height ] = patch_size(b);
B = [b(:, [1 3]) width height];

C = rectint(A,B);


t