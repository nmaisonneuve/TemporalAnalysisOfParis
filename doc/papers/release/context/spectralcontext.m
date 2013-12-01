%alldata: |||minx,miny,maxx,maxy,score,detid,imid,gtboxid,viewid,flip|||
%allgtboxes: |||minx,miny,maxx,maxy,??,imid,gtboxid,viewid,flip|||
function [dispimgs,dispdetrs]=sausagesplot(alldata,allimgs,allgtboxes,tokeep,conf)
try
global ds;
alldata(~ismember(alldata(:,6),tokeep),:)=[];
alldata(alldata(:,5)<0,:)=[];
[tmp,imageid]=distributeby(alldata,alldata(:,[7 8 9]));
[~,imgstokeep] = maxk(cellfun(@(x) size(x,1),tmp),200);
imgstokeep=imageid(imgstokeep,:);
alldata(~ismember(alldata(:,[7 8 9]),imgstokeep,'rows'),:)=[];
allimgs(~ismember([allgtboxes.imidx allgtboxes.flip allgtboxes.boxid],imgstokeep,'rows'))=[];
allgtboxes=effstridx(allgtboxes,ismember([allgtboxes.imidx allgtboxes.flip allgtboxes.boxid],imgstokeep,'rows'));
[alldata detid,imglabs,alldatasort]=distributeby(alldata,(1:size(alldata,1))',alldata(:,[7 8 9]));
links=cell(size(alldata,1)*(size(alldata,1)-1)/2,1);
%keyboard
sb=ds.conf.params.sBins;
pcsz=ds.conf.params.patchCanonicalSize;
if(~isfield(ds,'tmpovlweights'))
parfor(i=1:numel(alldata))
  tmp=overlapReweight(alldata{i}(:,1:4),max(0,alldata{i}(:,5)+1)+.000001,sb,pcsz,struct('detrgroups',(1:size(alldata{i}(:,1)))'));
  ovlweights{i}=tmp(:);
  %sumwt{i,1}=[imglabs(i,:), size(ovlweights{i},1)];
  clear conftmp;
end
ds.tmpovlweights=ovlweights;
else
  ovlweights=ds.tmpovlweights;
end
for(i=1:numel(alldata))
  [~,ord]=sort(alldata{i}(:,6));
  alldataord{i}=alldata{i}(ord,:);
  ovlweightsord{i}=ovlweights{i}(ord,:);
  detidord{i}=detid{i}(ord);
end
idx=1;
for(i=1:numel(alldata))
  for(j=i+1:numel(alldata))
    keyboard;
    affinities=contextAffinities(alldataord{i},alldataord{j},ovlweightsord{i}*0+1,ovlweightsord{j}*0+1,alldataord{i},alldataord{j});
    links{idx}=[detidord{i}(affinities(:,1)) detidord{j}(affinities(:,2)) affinities(:,3)./numel(ovlweightsord{j}) affinities(:,3)./numel(ovlweightsord{i})];
    if(any(isinf(links{idx}(:,3))))
      keyboard;
    end
    idx=idx+1;
  end
  disp([num2str(i) '/' num2str(numel(alldata))]);
end
alldata=invertdistributeby(alldata,alldatasort);
links=cell2mat(links);
[links,detid]=distributeby(links,alldata(links(:,1),6));
for(i=123)%1:numel(links))
  uids=unique(c(links{i}(:,1:2)));
  [~,pos]=ismember(links{i}(:,1:2),uids);
  tmp=links{i};
  tmp=[tmp(:,[1 2 3]);tmp(:,[2 1 4])];
  tmp=distributeby(tmp,tmp(:,1));
  affinity=full(sparse([pos(:,1);pos(:,2)],[pos(:,2);pos(:,1)],[links{i}(:,4);links{i}(:,3)]));
  %affinity=bsxfun(@rdivide,affinity,sum(affinity,1)');
  if(1)
  for(j=1:numel(tmp))
    if(rand<1)
      affinity2=affinity;
      affinity2=min(affinity2,affinity2');
      affinity2=bsxfun(@rdivide,affinity2,sum(affinity2,1));
      selaffinity=affinity2(:,j);
      selaffinity=selaffinity/norm(selaffinity);
      [denom,d]=eigs(affinity2,1);
      if(any(denom<0))
        denom=-denom;
      end
      %affinity2=bsxfun(@rdivide,affinity2,denom(:)+mean(denom)/2)
      affinity2=bsxfun(@rdivide,affinity2,sum(affinity2,1));
      affinity2(j,:)=affinity2(j,:)+1;
      affinity2=bsxfun(@rdivide,affinity2,sum(affinity2,1));
      [myeig,d]=eigs(affinity2,1);
      if(any(myeig<0))
        myeig=-myeig;
      end
      selaffinity=[selaffinity myeig];
      
      for(m=1:2)
        [~,ord]=sort(selaffinity(:,m),'descend');%tmp{j}(:,3),'descend');
        pats=extractpatches(alldata(uids(ord),:));%tmp{j}(ord,2),:));
        disp(['numpats:' num2str(numel(pats))]);
        figure(m)
        clf
        targ=extractpatches(alldata(tmp{j}(1,1),:));
        subplot(4,20,1);
        imagesc(targ{1});
        for(k=1:numel(ord))
          subplot(4,20,k+1);
          imagesc(pats{k});
          title(num2str(selaffinity(ord(k),m)))%tmp{j}(ord(k),3)));
          if(k==79)
            break;
          end
        end
      end
      waitforbuttonpress;
    end
  end
  end
      affinity2=affinity;
      affinity2=min(affinity2,affinity2');
      affinity2=bsxfun(@rdivide,affinity2,sum(affinity2,1));
      selaffinity=affinity2(:,j);
      selaffinity=selaffinity/norm(selaffinity);
      [denom,d]=eigs(affinity2,1);
      if(any(denom<0))
        denom=-denom;
      end
      affinity=bsxfun(@rdivide,bsxfun(@rdivide,affinity2,sqrt(denom(:)+mean(denom)/2)),sqrt(denom(:)+mean(denom)/2)');
      affinity=min(affinity,affinity');
  %affinity=exp(bsxfun(@minus,affinity,max(affinity,[],1)));
  %for(k=1:size(affinity,2))
  %  [~,ord]=maxk(affinity(:,k),10);
  %  affinity(:,k)=0;
  %  affinity(ord,k)=1;
  %end
  %affinity=max(affinity,affinity')+.0001;%*20;
  %affinity=exp(affinity)-1;%-max(affinity(:)));
  %affinity(1:size(affinity,1)+1:end)=0;
  %affinity=normrows(affinity')';
  %[v,d]=eigs(affinity,2);
  [~,v]=ncutW(affinity,3);
  v=v(:,2:3);
  %v=sum(affinity,2);
  %v=[v v]
  v=bsxfun(@minus,v,min(v,[],1));
  v=bsxfun(@rdivide,v,max(abs(v),[],1));
  alleigs{i}=[v uids];
  
end

alleigs=cell2mat(alleigs(:));
[~,ord]=sort(alleigs(:,3));
alleigs=alleigs(ord,1:2);

imgstokeep=1:2:numel(allimgs);%imgstokeep(1:2:size(imgstokeep,1),:);
allgtboxes=effstridx(allgtboxes,imgstokeep);
allimgs=allimgs(imgstokeep);
ds.myimg=allimgs;
dispeigs=alleigs(ismember(alldata(:,6),tokeep(1:min(numel(tokeep),100))) & ismember(alldata(:,[7 8 9]),[allgtboxes.imidx allgtboxes.flip allgtboxes.boxid],'rows'),:);
todisp=alldata(ismember(alldata(:,6),tokeep(1:min(numel(tokeep),100))) & ismember(alldata(:,[7 8 9]),[allgtboxes.imidx allgtboxes.flip allgtboxes.boxid],'rows'),:);
[scorecomp,detid]=distributeby(todisp,todisp(:,6));
maxdetscore=cellfun(@(x) max(x(:,5)),scorecomp);
mindetscore=cellfun(@(x) min(x(:,5)),scorecomp);
ds.patchimg=extractpatches(mat2det(todisp));
for(i=1:numel(ds.patchimg))
  pos=find(detid==todisp(i,6));
  weight=(todisp(i,5)-mindetscore(pos))/(maxdetscore(pos)-mindetscore(pos))*.7+.3;
  ds.patchimg{i}=im2double(ds.patchimg{i})*weight+(1-weight);
end
dispimgs = unique(allgtboxes.imidx);
dispdetrs = tokeep(1:min(numel(tokeep),100));
[todisp,alleigs,ds.patchimg]=distributeby(todisp,alleigs,ds.patchimg(:),todisp(:,[6:9]));
for(i=1:numel(todisp))
  [~,idx]=max(todisp{i}(:,5));
  todisp{i}=todisp{i}(idx,:);
  ds.patchimg{i}=ds.patchimg{i}{idx};
  alleigs{i}=alleigs{i}(idx,:);
end
todisp=cell2mat(todisp);
alleigs=cell2mat(alleigs);
ds.patchimg=ds.patchimg';
conf2=struct();
conf2.detscore=alleigs(:,1);

[clustdets,clusteigs,clustinds,clustdetrid]=distributeby(todisp,alleigs,(1:size(alleigs,1))',todisp(:,6));
for(i=1:numel(clusteigs))
  mhprender('disppatchspace.mhp',['ds.clusthtml{' num2str(i) '}'],struct('pos',clusteigs{i},'patchidx',clustinds{i}));
  detrurl{find(tokeep==clustdetrid(i))}=['clusthtml[]/' num2str(i) '.html'];
end
mhprender('contextreweight2.mhp','ds.reweightplothtml',overrideConf(conf2,struct('alldata',todisp,'allgtboxes',allgtboxes,'tokeep',tokeep(1:min(numel(tokeep),100)),'detrurl',{detrurl})));
dssave;
catch ex, dsprinterr;end
end
