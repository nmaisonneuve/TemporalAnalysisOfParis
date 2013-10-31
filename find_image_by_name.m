% find image idx according to image name
function idx = find_image_by_name(imgs, image_name)
  d = arrayfun(@(x) not(isempty(strfind(x.path,image_name))), imgs);
  idx = find(d)
end