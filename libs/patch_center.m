%  compute center from patch coordinates
function [center_x, center_y] = patch_center(pp)
  center_x = pp(:,1) + (pp(:,2)- pp(:,1)) /2;
  center_y = pp(:,3) + (pp(:,4)- pp(:,3)) /2;
end
