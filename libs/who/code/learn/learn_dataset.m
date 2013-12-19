function model = learn_dataset(pos, neg)
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


% Define model structure
model = initmodel(pos,bg);
%skip models if the HOG window is too skewed
if(max(model.maxsize)<4*min(model.maxsize))

  %get image patches
  warped=warppos( model, pos);

  %flip if necessary
  if(isfield(pos, 'flipped'))
    fprintf('Warning: contains flipped images. Flipping\n');
    for k=1:numel(warped)
      if(pos(k).flipped)
        warped{k}=warped{k}(:,end:-1:1,:);
      end
    end
  end
  model = learn(model,warped);
end


% Learn by linear discriminant analysis

model.w=model.w./(norm(model.w(:))+eps);
model.thresh = 0.5;
model.bg=[];
end


