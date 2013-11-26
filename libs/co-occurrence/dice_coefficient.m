% Dice coefficient - http://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient
% image co-occurrency:  present in the same images ?
%Analysis of co-occurrence should define a proper size of the 
% window where words or terms co-occur.

function co_occurence = dice_coefficient(patches_a, patches_b)

  img_occurence_a = patches_a(:,2);
  img_occurence_b = patches_b(:,2);
  
  co_occurence = 2 * numel(intersect(img_occurence_a, img_occurence_b))/...
    (numel(img_occurence_a) + numel(img_occurence_b));

end
