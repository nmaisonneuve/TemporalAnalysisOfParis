function  selected = mask_filtering(mask, patches, thresh)

  selected = zeros(1, length(patches));
  
  [nrows, ncols]= patch_size(patches);
  
  patch_area = nrows * ncols;

  for (i = 1:numel(patches))
    mask_area = sum(sum(mask(patches(i,1):patches(i,2), patches(i,3):patches(i,4))));
    if mask_area / patch_area(i) < thresh
       selected(i) = 1;
    end
  end
end