function model = learn_dataset(pos, neg, name)
% model = learn_dataset(pos, neg, name)
% pos is a struct array for the positive patches, with fields:
%	im: full path to the image
%	x1: xmin
%	y1: ymin
%	x2: xmax
%	(note: If you just have image patches, instead of bounding boxes, consider using learn.m directly)
% neg is a struct array for the negative patches with field:
%	im: full path to the image
% neg is used only when the background statistics cannot be found. If the background statistics are stored in the file location specified in
% bg_file_name, neg can be left empty ( [] ).
% name is just a "name" for the model.



% Load background statistics if they exist; else build them
file = bg_file_name;
try
  disp('loading background');
  load(file);
catch
  all = rmfield(pos,{'x1','y1','x2','y2'});
  all = [all neg];
  bg  = trainBG(all,20,5,8);
  save(file,'bg');
end
bg


end


