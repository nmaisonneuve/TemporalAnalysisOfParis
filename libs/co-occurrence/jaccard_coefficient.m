% image co-occurrency:  present in the same images ?
% each candidate patch (word) appears in a image representing here a context (sentence in NLP).
% meaning association to leverage semantics in the same context
% the degree of co-occurrence of two terms by their mutual degree
%
% Jacard
% what is the ratio of context (an image is a context) they share 
%vs. the total number of context present for both
function co_occurence = jaccard_coefficient(patches_a, patches_b)

  img_occurence_a = patches_a(:,2);
  img_occurence_b = patches_b(:,2);
  
  %How many images on which they fired together
  nb_shared_images = numel(intersect(img_occurence_a, img_occurence_b));
  
  %How many images on which at least one fire
  nb_total_imgs = numel(union(img_occurence_a,img_occurence_b));
  
  co_occurence = nb_shared_images/ nb_total_imgs;
end