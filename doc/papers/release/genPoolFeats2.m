function [feature] = genPoolFeats(detr, im)

      %detectionParams = struct( ...
      %  'selectTopN', false, ...
      %    'useDecisionThresh', true, ...
      %      'overlap', .5,...%collatedDetector.params.overlapThreshold, ...
      %        'fixedDecisionThresh', -.7);
global ds;
%randInds = randperm(length(dtm));
%for ids = 1 : length(randInds)
%  i = randInds(ids);
%  fileId = sprintf('%d.mat', i);
%  fileNames{i} = [outputDir fileId];
%  if isStillUnprocessed(fileId, outputDir)
%    sample = dtm(i);
    pyramid = constructFeaturePyramid(im, ds.conf.params);
    [features, levels, indexes,gradsums] = unentanglePyramid(pyramid, ...
      ds.conf.params.patchCanonicalSize/ds.conf.params.sBins-2);
  invalid=(gradsums<9);
  size(features)
  features(invalid,:)=[];
  levels(invalid)=[];
  indexes(invalid,:)=[];
  gradsums(invalid)=[];
  disp(['threw out ' num2str(sum(invalid)) ' patches']);
  %if(size(features,2)==size(detr,2)-1)%do detrs have a bias?
  %  features=[features ones(size(features,1),1)];
  %end
   patsz=ds.conf.params.patchCanonicalSize;%allsz(resinds(k),:);
   fsz=(patsz-2*ds.conf.params.sBins)/ds.conf.params.sBins;
   pos=pyridx2pos(indexes,reshape(levels,[],1),fsz,pyramid);
   %fsz=(patsz-2*ds.conf.params.sBins)/ds.conf.params.sBins;
   %pos=pyridx2pos(indexes,pyramid.canonicalScale,pyramid.scales(levels),...
   %                fsz(1),fsz(2),ds.conf.params.sBins,size(im(:,:,1)));
    posy=(pos.y1 + pos.y2)/2+.000001;
    posx=(pos.x1 + pos.x2)/2+.000001;
    idx=1;
    feature=zeros(5,size(detr.w,1));
    for(i=[-1 1])
      for(j=[-1 1]);
        [~,dist]=assigntoclosest(detr.w,features(i*(posy-size(im,1)/2) > 0 & j*(posx-size(im,2)/2) > 0,:),1);
        dist=dist(:)+detr.rho;
        feature(idx,:)=dist(:)';
        idx=idx+1;
      end
    end
    feature(end,:)=max(feature(1:end-1,:),[],1);
    feature=feature(:)';
    %[~,dist2]=assigntoclosest(detr,features(posy<=size(im,1)/2,:));
    
    %feature=feature-detectionParams.fixedDecisionThresh;
    %feature(feature<0)=0;
    %feature(1:3:end)=dist(:);
    %feature(2:3:end)=dist2(:);
    %feature(3:3:end)=max(dist(:),dist2(:));
    %keyboard;
    %feature=sum(feature.*weights,1);
%    save(fileNames{i}, 'feature', 'weights', 'labels');
%    doneProcessing(fileId, outputDir);
%    fprintf('Done processing image %d\n', i);
%    clear feature weights labels;
%  end
end
