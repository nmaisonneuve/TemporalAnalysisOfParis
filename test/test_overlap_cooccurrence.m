%img_id x1 x2 y1 y2
a = [1 1 2 1 2;
  1 1 3 1 3; 
  2 1 3 1 3];

b = [
  2 1 2 1 2;
  1 4 5 4 5; 
  1 1 2 1 2];

%when 1 member of the clsuter A fired what is the probability that1 of the
%member B also fired and overlapped.
c1 = dice_coefficient(a,b);



presence in the top 
img_occurence_a = [1 1 1 1 1 1 3];
img_occurence_b = [1 1 1 1 1 1 2];

 co_occurence = 2 * numel(intersect(img_occurence_a, img_occurence_b))/...
    (numel(img_occurence_a) + numel(img_occurence_b));
  




c2 = overlap_cooccurrence(a, b);
