function models = learn_patches(patches, imgs)
  
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


  for (i = 1:size(patches,1))
    pos = struct();
    name = '1';
    pos.x1 = patches(i,4);
    pos.y1 = patches(i,2);
    pos.x2 = patches(i,5);
    pos.y2 = patches(i,3);
    pos.im = imgs(patches(i,1)).path;
 
    im=imread(pos.im);
  
    showboxes(im ,[pos.x1 pos.y1 pos.x2 pos.y2]);


    % Define model structure
    model = initmodel(name,pos,bg);
    %skip models if the HOG window is too skewed
    if(max(model.maxsize)<4*min(model.maxsize))

    %get image patches
    warped=warppos(model, pos);

    %flip if necessary
    if(isfield(pos, 'flipped'))
      fprintf('Warning: contains flipped images. Flipping\n');
      for k=1:numel(warped)
        if(pos(k).flipped)
          warped{k}=warped{k}(:,end:-1:1,:);
        end
      end
    end


    % Learn by linear discriminant analysis
    model = learn(name,model,warped);
    model.w=model.w./(norm(model.w(:))+eps);
    model.thresh = 0.5;
    model.bg=[];
    models{i} = model;
  end  
end
