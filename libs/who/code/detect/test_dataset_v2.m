function boxes=test_dataset_v2(test, model)
% boxes=test_dataset(test, model, name)
% test is struct array with fields:
%	im:full path to image

  boxes = cell(0);
  for i = 1:numel(test)
    % fprintf('%s: testing: %d/%d, threshold: %f\n', name, i, length(test),model.thresh);
    im = im2double(imread(test(i).im));
    % tic;
    [b, feats]= detect(im, model, 0.8,1);
    % toc; tic;
   
    b = nms(b,0.3);
   
    fprintf('\n detection found for image %d:  %d', test(i).id, size(b,1));
   
    if (~isempty(b))
      % fprintf('\n detections found');
       %imshow(im);
      % showboxes(im,b);
      % pause(1);
       
       boxes{i} = [ones(size(b,1),1)*test(i).id b];
      % figure(i);
      %showboxes(im,boxes{i});
      
    else
      %imshow(im);
      %pause(1);
      %   fprintf('\n no detections found');
    end
  end
end
