function [posheatmap, negheatmap] = genPoolFeats(detr, im, svm, feattransf,dets,displayname,dispimset)
try

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
    posy=(pos.y1 + pos.y2)/2+.000001;
    posx=(pos.x1 + pos.x2)/2+.000001;
    posheatmap=zeros(size(im(:,:,1)));%max(pos.y2),max(pos.x2));
    negheatmap=zeros(size(posheatmap));
    idx=1;
    feature=zeros(5,size(detr.w,1));
    wmat=reshape(svm.w,5,[]);
    for(i=[-1 1])
      for(j=[-1 1]);
        posidx=find(i*(posy-size(im,1)/2) > 0 & j*(posx-size(im,2)/2) > 0);
        [assignedidx,dist]=assigntoclosest(detr.w,features(i*(posy-size(im,1)/2) > 0 & j*(posx-size(im,2)/2) > 0,:),1);
        dist=dist(:)+detr.rho;
        posidx2=posidx(assignedidx);
        posmat=[pos.x1 pos.y1 pos.x2 pos.y2];
        posmat2=posmat(i*(posy-size(im,1)/2) > 0 & j*(posx-size(im,2)/2) > 0,:);
        if(exist('feattransf','var'))
          dist=feattransf(dist')';
        end
        feature(idx,:)=dist(:)';
        assignedidxall{idx}=assignedidx;
        posall{idx}=posmat2(assignedidx,:);
        wt=dist(:)'.*wmat(idx,:);
        posheatmap=posheatmap+genheatmap(wt(wt>0)',posmat2(assignedidx(wt>0),:),size(posheatmap));
        negheatmap=negheatmap+genheatmap(-wt(wt<0)',posmat2(assignedidx(wt<0),:),size(posheatmap));
        idx=idx+1;
      end
    end
    [feature(end,:),maxpos]=max(feature(1:end-1,:),[],1);
    wt=feature(end,:).*wmat(end,:);
    for(i=1:4)
       posheatmap=posheatmap+genheatmap(wt(wt>0&maxpos==i)',posall{i}(wt>0&maxpos==i,:),size(posheatmap));
       negheatmap=negheatmap+genheatmap(-wt(wt<0&maxpos==i)',posall{i}(wt<0&maxpos==i,:),size(posheatmap));
    end
    hm=posheatmap-negheatmap-svm.rho/numel(posheatmap);
    posheatmap=hm.*(hm>0);
    negheatmap=-hm.*(hm<0);
    if(nargin>4)
      currimset=ds.conf.currimset;
      if(exist('dispimset','var'))
        ds.conf.currimset=dispimset;%assume imgs is loaded; don't want to run dsup.
      end
      contrib=sum(feature.*wmat,1);
      [wt,todisp]=maxk(contrib,25);
      todisp(wt<0)=[];
      wt(wt<0)=[];
      todisp=detr.id(todisp);
      dsup([displayname '_pos.patchimg'],extractpatches(dets(ismember(dets(:,6),todisp),:)));
      conf=struct('dets',dets(ismember(dets(:,6),todisp),:),'detrord',todisp,...
                  'message',{cellfun(@(x) ['contribution:' num2str(x)],num2cell(wt),'UniformOutput',false)});
      mhprender('patchdisplay.mhp',[displayname '_pos.displayhtml'],conf);
      [wt,todisp]=mink(contrib,50);
      todisp(wt>0)=[];
      wt(wt>0)=[];
      todisp=detr.id(todisp);
      dsup([displayname '_neg.patchimg'],extractpatches(dets(ismember(dets(:,6),todisp),:)));
      conf=struct('dets',dets(ismember(dets(:,6),todisp),:),'detrord',todisp,...
                  'message',{cellfun(@(x) ['contribution:' num2str(x)],num2cell(wt),'UniformOutput',false)});
      mhprender('patchdisplay.mhp',[displayname '_neg.displayhtml'],conf);
      if(exist('dispimset','var'))
        ds.conf.currimset=currimset;
      end
    end
    
    feature=feature(:);
    im=repmat(rgb2gray(im),[1,1,3]);
    posheatmap=heatmap2jet(posheatmap*40000)*.5+im*.5;
    negheatmap=heatmap2jet(negheatmap*40000)*.5+im*.5;
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
catch ex,dsprinterr;end
end

function res=heatmap2jet(heatmap)
  cmp=colormap('jet');
  res=zeros([size(heatmap) 3]);
  heatmap=round(heatmap*size(cmp,1));
  heatmap(heatmap<1)=1;
  heatmap(heatmap>size(cmp,1))=size(cmp,1);
  for(chan=1:3)
    res(:,:,chan)=reshape(cmp(heatmap,chan),size(heatmap));
  end
end
