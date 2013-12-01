function ctxmodel=gencontextmodel(alldata,allctxdets)
global ds;
%alldata(~ismember(alldata(:,6),tokeep),:)=[];
allctxdets=distributeby(allctxdets,allctxdets(:,6));
for(i=1:numel(allctxdets))
  allctxdets{i}(:,5)=allctxdets{i}(:,5)-min(allctxdets{i}(:,5));
end
allctxdets=cell2mat(allctxdets);
[allctxdets,ctximgid]=distributeby(allctxdets,allctxdets(:,[7 8 9]));
%allctxdets(allctxdets(:,5)<0,:)=[];
[tmp,imageid]=distributeby(alldata,alldata(:,[7 8 9]));
[~,imgstokeep] = maxk(cellfun(@(x) size(x,1),tmp),200);
imgstokeep=imageid(imgstokeep,:);
allimgs=imgstokeep;
alldata(~ismember(alldata(:,[7 8 9]),imgstokeep,'rows'),:)=[];
%allgtboxes=effstridx(allgtboxes,ismember([allgtboxes.imidx allgtboxes.flip allgtboxes.boxid],imgstokeep,'rows'));
allctxdets(~ismember(ctximgid,imageid,'rows'))=[];
if(~numel(allctxdets)==size(imageid,1))
  error('missing image');
end
%[alldata]=distributeby(alldata,alldata(:,6));
%posinkernel=cellfun(@(x) (1:size(x,1))',alldata);
%alldata=cell2mat(alldata);
%posinkernel=cell2mat(posinkernel);
[alldata detid,imglabs,alldatasort]=distributeby(alldata,(1:size(alldata,1))',alldata(:,[7 8 9]));
links=cell(size(allctxdets,1)*(size(allctxdets,1)-1)/2,1);
%keyboard
sb=ds.conf.params.sBins;
pcsz=ds.conf.params.patchCanonicalSize;
if(~isfield(ds,'tmpovlweights'))
  parfor(i=1:numel(alldata))
    tmp=overlapReweight(allctxdets{i}(:,1:4),max(0,allctxdets{i}(:,5)+1)+.000001,sb,pcsz,struct('detrgroups',(1:size(allctxdets{i}(:,1)))'));
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
  [~,ord]=sort(allctxdets{i}(:,6));
  ctxdetsord{i}=allctxdets{i}(ord,:);
  ovlweightsord{i}=ovlweights{i}(ord,:);
  detidord{i}=detid{i}(ord);
end
idx=1;
ctxmodel.detsbyim=alldataord;
ctxmodel.ctxdetsbyim=ctxdetsord;
ctxmodel.ovlweights=ovlweightsord;
ctxmodel.kernpos=detidord;
ctxmodel.ctxboxes=imglabs;
for(i=1:numel(alldata))
  for(j=i:numel(alldata))
    affinities=contextAffinities(alldataord{i},alldataord{j},ovlweightsord{i}*0+1,ovlweightsord{j}*0+1,ctxdetsord{i},ctxdetsord{j});
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
ctxmodel.detid=detid;
%ctxmodel.alldata=alldata;
%ctxmodel.alldatasort=alldatasort;
ctxmodel.kern=zeros(size(alldata,1),30);
for(i=1:numel(links))
  uids=unique(c(links{i}(:,1:2)));
  [~,pos]=ismember(links{i}(:,1:2),uids);
  tmp=links{i};
  tmp=[tmp(:,[1 2 3]);tmp(:,[2 1 4])];
  tmp=distributeby(tmp,tmp(:,1));
  affinity=full(sparse([pos(:,1);pos(:,2)],[pos(:,2);pos(:,1)],[links{i}(:,4);links{i}(:,3)]));
  affinity=exp(10*min(affinity,affinity'))/10;
  %kernel=zeros(size(affinity));
  %kernel(posinkernel{i}(uids),posinkernel{i}(uids))=affinity;
  [decomp,d]=eig(affinity);
  [~,ord]=sort(d,'descend');
  decomp=decomp(:,ord);
  ctxmodel.kern(uids,:)=decomp(:,1:size(ctxmodel.kern,2));
end
end
