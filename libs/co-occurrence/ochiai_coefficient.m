% image co-occurrency:  present in the same images ?
%
% Ochiai coefficient - http://en.wikipedia.org/wiki/Cosine_similarity#Ochiai_coefficient
function co_occurence = ochiai_coefficient(patches_a, patches_b)

  img_occurence_a = patches_a(:,2);
  img_occurence_b = patches_b(:,2);
  
  co_occurence = 2 * numel(intersect(img_occurence_a, img_occurence_b))/...
    sqrt(numel(img_occurence_a) * numel(img_occurence_b));

end