function boxes=test_dataset(test, model, name)
% boxes=test_dataset(test, model, name)
% test is struct array with fields:
%	im:full path to image

parfor i = 1:length(test),
 % fprintf('%s: testing: %d/%d, threshold: %f\n', name, i, length(test),model.thresh);
  im = imread(test(i).im);
 % tic;
  b = detect(im, model, 0.85);
 % toc; tic;
 
  b = nms(b,0.3);
  if (~isempty(b))
    boxes{i} = [ones(size(b,1),1)*test(i).id b];
  end
  %toc;
  %if (isempty(boxes{i}))
  %   fprintf('\n no detections found');
  %else
   % figure(i);
    %showboxes(im,boxes{i});
    %  pause(1);
  %end
 

end

