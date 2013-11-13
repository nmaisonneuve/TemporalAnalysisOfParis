%  compute basic  width , height colums from patch coordinates
function [nrows, ncols] = patch_size(pp)
  nrows = pp(:,2)- pp(:,1) +1;
  ncols = pp(:,4)- pp(:,3) +1;
end

