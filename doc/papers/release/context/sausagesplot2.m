%alldata: |||minx,miny,maxx,maxy,score,detid,imid,gtboxid,viewid,flip|||
%allgtboxes: |||minx,miny,maxx,maxy,??,imid,gtboxid,viewid,flip|||
function [dispimgs,dispdetrs]=sausagesplot(alldata,allimgs,allgtboxes,tokeep,conf)
try
global ds;
[tmp,imageid]=distributeby(alldata,alldata(:,[7 8 9]));
[~,imgstokeep] = maxk(cellfun(@(x) size(x,1),tmp),200);
imgstokeep=imageid(imgstokeep,:);
alldata(~ismember(alldata(:,[7 8 9]),imgstokeep,'rows'),:)=[];
allimgs(~ismember([allgtboxes.imidx allgtboxes.flip allgtboxes.boxid],imgstokeep,'rows'))=[];
allgtboxes=effstridx(allgtboxes,ismember([allgtboxes.imidx allgtboxes.flip allgtboxes.boxid],imgstokeep,'rows'));
alldatahist=alldata;
alldatahist(~ismember(alldatahist(:,6),tokeep(1:20)),:)=[];
[~,imgind]=ismember(alldatahist(:,[7 8 9]),[allgtboxes.imidx allgtboxes.flip allgtboxes.boxid],'rows');
histvals2=zeros(size(allgtboxes.imidx,1),max(alldata(:,6)));
for(i=1:size(alldatahist,1))
  histvals2(imgind(i),alldatahist(i,6))=histvals2(imgind(i),alldatahist(i,6))+1;
end
histvals2(:,sum(histvals2,1)<=5)=[];
histvals=normrows(histvals2,1,.0000001);
rand('seed',1);
rp=randperm(max(imgind));
if(0)
  for(i=1:numel(rp))
    [dist,ord]=sort(histvals*histvals(rp(i),:)','descend');%sort(allpairsdist(histvals(rp(i),:),histvals));

    sval=sum(histvals2(rp(i),:))
    if(sval==0)
      continue;
    end
    for(j=1:25)
      subplot(5,5,j);
      imagesc(allimgs{ord(j)});
      xlabel([num2str(j) ':' num2str(dist(j))]);
    end
    drawnow;
    waitforbuttonpress;
  end
end
allimgs2=allimgs;
allimgs2(sum(histvals2,2)==0)=[];
histvals(sum(histvals2,2)==0,:)=[];
[coeff,fixmatlabbug]=princomp(histvals);

pts=histvals*coeff(:,1);
eucdist=allpairsdist(pts,pts);
    eucdist(1:size(eucdist,1)+1:end)=0;
    eucdist(eucdist<0)=0;
    eucdist=sqrt(eucdist);

%pts=mdscale(eucdist,1,'Criterion','sstress');

[~,imgsord]=sort(pts);

imgstokeep=1:2:numel(imgsord);
allgtboxes=effstridx(allgtboxes,imgsord(imgstokeep));
allimgs=allimgs(imgsord(imgstokeep));
ds.myimg=allimgs;
if(isfield(conf,'dispdets'))
  alldata=conf.dispdets;
end
todisp=alldata(ismember(alldata(:,6),tokeep(1:min(numel(tokeep),100))) & ismember(alldata(:,[7 8 9]),[allgtboxes.imidx allgtboxes.flip allgtboxes.boxid],'rows'),:);
[scorecomp,detid]=distributeby(todisp,todisp(:,6));
maxdetscore=cellfun(@(x) max(x(:,5)),scorecomp);
mindetscore=cellfun(@(x) min(x(:,5)),scorecomp);
ds.patchimg=extractpatches(mat2det2(todisp));
for(i=1:numel(ds.patchimg))
  pos=find(detid==todisp(i,6));
  weight=(todisp(i,5)-mindetscore(pos))/(maxdetscore(pos)-mindetscore(pos))*.7+.3;
  ds.patchimg{i}=im2double(ds.patchimg{i})*weight+(1-weight);
end
dispimgs = unique(allgtboxes.imidx);
dispdetrs = tokeep(1:min(numel(tokeep),100));
[todisp,ds.patchimg]=distributeby(todisp,ds.patchimg(:),todisp(:,[6:9]));
for(i=1:numel(todisp))
  [~,idx]=max(todisp{i}(:,5));
  todisp{i}=todisp{i}(idx,:);
  ds.patchimg{i}=ds.patchimg{i}{idx};
end
todisp=cell2mat(todisp);
ds.patchimg=ds.patchimg';
conf2=struct();
if(isfield(conf,'contextdict'))
  [alldata,imgidx]=distributeby(alldata,alldata(:,[7 8 9]));
  for(i=1:size(todisp,1))
    [~,idx]=ismember(todisp(i,[7 8 9]),imgidx,'rows');
    [~,idxinimg]=ismember(todisp(i,:),alldata{idx},'rows');
    [scores(i) num(i) ctxdisplay(i)]=contextfromdict(alldata{idx},idxinimg,conf.contextdict);
    if(mod(i,10)==0)
      disp([num2str(i) '/' num2str(size(todisp,1))]);
    end
  end
  [scorebydetr,detrid]=distributeby([scores(:) num(:)],todisp(:,6));
  meanscore=cellfun(@(x) sum(x(:,1))/sum(x(:,2)),scorebydetr);
  %meanscore=cellfun(@(x) x(:,1)'*x(:,2)/sum(x(:,2)),scorebydetr);
  %scorebydetr=cell2mat(cellfun(@(x,y) x./y,scorebydetr,meanscore,'UniformOutput',false);
  [~,meanscoreidx]=ismember(todisp(:,6),detrid);
  scores=scores(:)-meanscore(meanscoreidx).*c(num);
  conf2.detscore=sign(scores).*sqrt(abs(scores));
  conf2.detscore=conf2.detscore./max(abs(conf2.detscore));
  %keyboard;
  for(i=1:numel(ctxdisplay))
    ctxdisplay(i).score=ctxdisplay(i).score-meanscore(meanscoreidx(i)).*ctxdisplay(i).num;
    ctxdisplay(i).score=ctxdisplay(i).score/max(abs(ctxdisplay(i).score));
    mhprender('singleimgcontext.mhp',['ds.imgctxhtml{' num2str(i) '}'],overrideConf(ctxdisplay(i),struct('imidx',todisp(i,7))));
    if(mod(i,100)==0)
      disp([num2str(i) '/' num2str(size(todisp,1))]);
      pause(.5);
    end
  end
  %conf2.detscore=scores;
  
end
mhprender('sausagesplotmhp2.mhp','ds.sausagesplothtml',overrideConf(conf2,struct('alldata',todisp,'allgtboxes',allgtboxes,'tokeep',tokeep(1:min(numel(tokeep),100)))));
mhprender('contextreweight2.mhp','ds.reweightplothtml',overrideConf(conf2,struct('alldata',todisp,'allgtboxes',allgtboxes,'tokeep',tokeep(1:min(numel(tokeep),100)))));
dssave;
catch ex, dsprinterr;end
end
