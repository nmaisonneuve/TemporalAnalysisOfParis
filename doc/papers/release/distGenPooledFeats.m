function feats=distGenPoolFeats(detrs,imidx);
  global ds;
  i=imidx;%ds.myiminds(imidx);
  im=im2double(getimg(ds,i));%imread([ds.conf.gbz.cutoutdir ds.imgs{i}.fullname]);
  %dsload('ds.flip');
  %'decisionthresh'
  %ds.conf.detectionParams.fixedDecisionThresh;
  %ds.conf.detectionParams
  %global dets;
  %if(isempty(dets))
  %  loaddetectors;
  %end
  %disp('detecting')
  %dsload(['ds.pooledFeats{1:' num2str(numel(dsload('ds.banksize'))) '}{' num2str(dsidx) '}']);
  %if(~dsfield(ds,'pooledFeats')||size(ds.pooledFeats,2)<dsidx||all(cellfun(@isempty,ds.pooledFeats(:,dsidx))))
    feats=genPoolFeats2(detrs,im);
    im=im(:,end:-1:1,:);
    feats=(feats+genPoolFeats2(detrs,im))/2;
    
    %if(dsfield(ds,'pooledFeats'))
    %  ds=rmfield(ds,'pooledFeats');
    %end
    %ds.pooledFeats(:,dsidx)=mat2cell(feats(:),dsload('ds.banksize')*5,1);
    feats=feats(:)';
    %for(i=1:numel(ds.banksize))
    %  ds.pooledFeats(i,dsidx)={feats((i-1)*ds.banksize(i)*5+1:(i-1)*ds.banksize(i)*5+ds.banksize(i)*5)};
    %end
  %end
%  disp('simplifying')
  %ds.detsimple{dsidx}=simplifydets(results,i);
%  if(~dsbool(ds,'conf','detectionParams','removeFeatures'))
%  if(numel(ds.detsimple{dsidx})>0)
%    disp([num2str(numel(ds.detsimple{dsidx})) ' detections'])
%  end
%return;
%  ds.detectvisfig{i}=figure();
%  imagesc(im);
%  for(j=1:numel(detsimplecurr))
%    pos=detsimplecurr(j).pos;
%    maxsz=max(pos.y2-pos.y1,pos.x2-pos.x1);
%    reszx=64*(pos.x2-pos.x1)/maxsz;
%    reszy=64*(pos.y2-pos.y1)/maxsz;
%    ds.bestbin.alldiscpatchimg{currpatch}=imresize(im(pos.y1:pos.y2,pos.x1:pos.x2,:),[reszy reszx]);
    %rectangle(pos.x1,pos.x2,pos.x2-pos.x1,pos.y2-pos.y1)
%    currpatch=currpatch+1;
%  end
%  detsimple=[detsimple;detsimplecurr];
%dsload('ds.svm');
%if(dsfield(ds,'svm'))
  %dsload('ds.transmat')
  %if(dsfield(ds,'transmat'))
  %  feat=(ds.pooledFeats{dsidx}(:)')*ds.transmat;
  %else
  %  feat=ds.pooledFeats{dsidx};
  %end
  %dsclear('ds.transmat');
  %feat=feat(:)';
  %dsload(['ds.ifvFeats{' num2str(dsidx) '}']);
  %for(i=1:numel(ds.svm))
    %for(j=1:size(ds.svm,2))
      %[~,~,probs]=svmpredict(1,normrows(ds.pooledFeats{i,dsidx}(:)',1),ds.svm(i));
      %feat=cell2mat(ds.pooledFeats(:,dsidx))';
      %dsload('ds.transfun');
      %if(dsfield(ds,'transfun'));
      %  disp('transfun')
      %  feat=ds.transfun(feat);
      %end
      %if(dsfield(ds,'ifvFeats'))
      %  feat=[feat ds.ifvFeats{dsidx}'*16];
      %end
      %[probs]=feat*ds.svm(i).w(:)-ds.svm(i).rho;
      %[probs]=cell2mat(cellfun(@(x) x(1:630),ds.pooledFeats(:,dsidx),'UniformOutput',false))'*ds.svm(i).w(:)-ds.svm(i).rho;
      %[probs]=ds.pooledFeats{i,dsidx}(1:ds.banksize(i)*5)'*ds.svm(i).w(:)-ds.svm(i).rho;
      %ds.scores{dsidx}(i)=probs(1);
    %end
  %end
%end
%dssave;
%ds.pooledFeats={};
