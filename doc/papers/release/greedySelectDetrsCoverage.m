function [res,coverageinc]=greedySelectDetrsCoverage(indata,ispos,thresh,ntosel,conf)
%disp('WARNING: MODIFYING THRESHOLD')
%thresh=.8;
try
  if(~iscell(indata))
    indata={indata};
  end
  if(~exist('conf','var'))
    conf=struct();
  end
  for(m=1:numel(indata))
    [data,elid]=distributeby(indata{m},indata{m}(:,6));
    ispos=ispos(:)'>0;
    for(i=1:numel(data))
      dat=data{i};
      [~,ord]=sort(dat(:,5),'descend');
      dat=dat(ord,:);
      isposdat=ispos(dat(:,7));
      purity=cumsum(isposdat)./(1:numel(isposdat));
      tokeep=max(find(purity>=thresh));
      if(purity(end)>thresh)
        disp(['warning: min purity for ' num2str(elid(i)) ' was ' num2str(purity(end))]);
      end
      if(~dsbool(conf,'useoverlap'))
        data{i}=dat(1:tokeep,[1:4 6:7]);
        imind=6;
      else
        data{i}=dat(1:tokeep,:);
        imind=7;
      end
      data{i}=data{i}(ispos(data{i}(:,imind)),:);
      [~,ord]=sort(data{i}(:,imind));
      data{i}=data{i}(ord,:);
      if(mod(i,100)==0)
        disp(i);
      end
      if(dsbool(conf,'legaldetrs'))
        data{i}(~ismember(data{i}(:,imind-1),conf.legaldetrs),:)=[];
      end
      %if(i==2903),keyboard;end
    end
    data=cell2mat(data);
    indata{m}=data;
  end
  if(~dsbool(conf,'useoverlap'))
    indata=cell2mat(indata(:));
    [~,indata(:,imind)]=ismember(indata(:,imind),unique(indata(:,imind)));
    [res,coverageinc]=greedySelectDetrsCoveragemex(int64(indata),int64(ntosel));
  else
    indata=cell2mat(indata(:));
    maxdetr=max(indata(:,6));
    indata=distributeby(indata,indata(:,7));
    selected=[];
    for(i=1:numel(indata))
      indata{i}=indata{i}(myNmsClass(indata{i},.5),:);
      ovlp{i}=computeOverlap(indata{i}(:,1:4),indata{i}(:,1:4),'pedro')>.5;
    end
    for(j=1:ntosel)
      cts=zeros(maxdetr,1);
      for(i=1:numel(ovlp))
        %movl=indata{i}(~sum(ovlp{i}(ismember(indata{i}(:,6),selected),:),1),6);
        sovl=1./(1+sum(ovlp{i}(ismember(indata{i}(:,6),selected),:),1));
        %umovl=unique(movl);
        %cts(umovl)=cts(umovl)+histc(movl,unique(movl));
        for(t=1:numel(sovl))
          cts(indata{i}(t,6))=cts(indata{i}(t,6))+sovl(t);
        end
      end
      cts(selected)=-Inf;
      [coverageinc(j),selected(j)]=max(cts);
      disp(['selected ' num2str(selected(j)) ' count ' num2str(coverageinc(j))]);
    end
    res=selected(:);
  end
  %keyboard
catch ex,dsprinterr;end
end
