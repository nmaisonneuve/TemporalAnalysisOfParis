function models = learn_detectors(detectors, detections, imgs, params)
  
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
  fprintf('\n learning %d detectors', numel(detectors));
  
  % for each detector
  for (i = 1:numel(detectors))
    detections_idx = detectors(i).nn_detections_idx;
     
    % only the positive
    pos_nn_idx = [ismember(detectors(i).labels, params.positive_label)]';
    detections_idx = detections_idx(pos_nn_idx);
    
    max_training_samples = min(numel(detections_idx), 5);
    fprintf('\n%d learning detector based on %d positive detections',i, max_training_samples);
   
    
    % for each positive detection
    % prepare the data
    pos = struct();
    for (j = 1:max_training_samples)
      pos(j).x1 = detections(detections_idx(j),6); 
      pos(j).y1 = detections(detections_idx(j),4); 
      pos(j).x2 = detections(detections_idx(j),7); 
      pos(j).y2 = detections(detections_idx(j),5); 
      pos(j).im = imgs(detections(detections_idx(j),2)).path;
    end
     models{i} = internal_learn_model(pos,bg);
 
  end
  
  function model = internal_learn_model(pos, bg)
    name = '1';
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
      
      % Learn by linear discriminant analysis
      model = learn(name,model,warped);
    else
      fprintf('\n---WARNING no learning ');
    end
    
    model.w=model.w./(norm(model.w(:))+eps);
    model.thresh = 0.7;
    model.bg=[];      
  end

end
