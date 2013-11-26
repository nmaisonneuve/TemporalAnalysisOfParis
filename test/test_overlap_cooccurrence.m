% x1 x2 y1 y2
a = [1 1 2 1 2;1 1 3 1 3; 2 1 3 1 3];
b = [1 1 2 1 2;1 4 5 4 5; 2 1 2 1 2];

%when 1 member of the clsuter A fired what is the probability that1 of the
%member B also fired and overlapped.
c1 = dice_coefficient(a,b);


 co_occurence = 2 * numel(intersect(img_occurence_a, img_occurence_b))/...
    (numel(img_occurence_a) + numel(img_occurence_b));
  
img_occurence_a = [1 1 1 1 1 1 3];
img_occurence_b = [1 1 1 1 1 1 2];



c2 = overlap_cooccurence(a, b);
