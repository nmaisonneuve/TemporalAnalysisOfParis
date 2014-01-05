a = struct();
a(1).speed = mat2cell([1 2 3; 4 5 6]);
a(2).speed = mat2cell([8 9 10; 11 12 13]);


a = struct();
a(1).speed = [1 2 3; 4 5 6]';
a(2).speed = [8 9 10; 11 12 13]';
speed = [a.speed]';

b = cell(2,1);

b{1} = [1 2 3; 4 5 6];
b{2} = [8 9 10; 11 12 13];

cell2mat(b);