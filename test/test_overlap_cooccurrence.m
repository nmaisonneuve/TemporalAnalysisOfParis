% x1 x2 y1 y2
a = [1 1 2 1 2;1 1 3 1 3; 2 1 3 1 3];
b = [1 1 2 1 2;1 4 5 4 5; 2 1 2 1 2];

%when 1 member of the clsuter A fired what is the probability that1 of the
%member B also fired and overlapped.
c1 = image_cooccurence(a,b);

c2 = overlap_cooccurence(a, b);
