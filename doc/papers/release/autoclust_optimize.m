dsload('ds.batchfordetr');
dsload('ds.classperbatch');
imgs=dsload('ds.imgs{ds.conf.currimset}');
prevdets=dsload(['ds.round.prevdets{' num2str(dsidx) '}'],'clear');
dsload(['ds.round.prevweights{' num2str(dsidx) '}']);
if(isfield(ds.round,'prevweights'))
  prevweights=ds.round.prevweights{dsidx};
  ds.round=rmfield(ds.round,'prevweights');
else
  prevweights=ones(size(prevdets,1),1);
end
dsload('ds.round.roundid');
if(dsfield(ds,'sys','distproc','localdir'))
  if(ds.round.roundid>5)
    delete([ds.sys.distproc.localdir 'prevfeats' num2str(dsidx) '_' num2str(ds.round.roundid-2) '.mat']);
  end
  load([ds.sys.distproc.localdir 'prevfeats' num2str(dsidx) '_' num2str(ds.round.roundid-1) '.mat']);
else
  prevfeats=dsload(['ds.round.prevfeats{' num2str(dsidx) '}'],'clear');
end

dsload('ds.round.myiminds');
mydetrs=ds.batchfordetr(ds.batchfordetr(:,2)==dsidx,1);

dsload('ds.round.discardprevpatches');
dsload('ds.round.exceptfirst');
tokeep=~ismember(prevdets(:,7),ds.round.myiminds);
% the first listed detection for each detector is the one that was 
% randomly sampled (the 'candidate' patch); we (usually) don't discard it.
[~,candidatepatches]=ismember(mydetrs,prevdets(:,6),'R2012a');
%candidatepatches(candidatepatches==0)=[];
if(~all(imgs.label(prevdets(candidatepatches,7))==ds.classperbatch(dsidx)))
  error('classperbatch wrong');
end
tokeep(candidatepatches)=true;
if(dsbool(ds.round,'discardprevpatches'))
  tokeep(:)=false;
  if(dsbool(ds.round,'exceptfirst'))
    tokeep(candidatepatches)=true;
  end
end
discardifnew=prevdets(candidatepatches(tokeep(candidatepatches)),[6:7]);
dets={prevdets(tokeep,:)};
feats={prevfeats(tokeep,:)};
allovlweight={prevweights(tokeep,:)};
clear prevdets;
clear prevfeats;
clear prevweights;

for(i=1:numel(ds.round.myiminds))
  if(~isempty(ds.round.newfeat{dsidx,i}.assignedidx))
    tokeep=~ismember(ds.round.newfeat{dsidx,i}.assignedidx(:,6:7),discardifnew,'rows');
    dets{end+1}=ds.round.newfeat{dsidx,i}.assignedidx(tokeep,:);
    feats{end+1}=double(ds.round.newfeat{dsidx,i}.feat(tokeep,:));
    if(isfield(ds.round.newfeat{dsidx,i},'ovlweights'))
      allovlweight{end+1}=ds.round.newfeat{dsidx,i}.ovlweights(tokeep,:);
    else
      allovlweight{end+1}=ones(size(feats{end},1),1);
    end
  end
  if(mod(i,100)==0)
    disp(['img ' num2str(i) ' of ' num2str(numel(ds.round.myiminds))])
  end
end
ds.newdets{dsload('ds.round.roundid'),dsidx}=structcell2mat(dets(2:end)');

dets=structcell2mat(dets(:));
allovlweight=structcell2mat(allovlweight(:));
feats=structcell2mat(feats(:));
if(size(feats,1)>500000)
  error('featsall too big')
end
[dets feats allovlweight idforcell]=distributeby(dets, feats, allovlweight, dets(:,6));
idforcell
mydetrs
if(~all(idforcell==mydetrs(:)))
  error('something got out of order!');
end

ctrs=dsload(['ds.round.detectors{' num2str(dsidx) '}'],'clear');
%miscstates=dsload(['ds.round.miscstates{' num2str(dsidx) '}'],'clear');
newctrs=zeros(size(ctrs));
resfeat={};
resdets={};

ds.round.newfeat={};
nsv=[];
for(i=1:numel(mydetrs))
  a=tic;
  mymemory;
  weights=allovlweight{i};

  disp(['optimizing:' num2str(mydetrs(i))]);
  
  disp(['total features:' num2str(size(feats{i},1))]);
  ctr=effstridx(ctrs,i);
  %miscstates{i}.roundid=dsload('ds.round.roundid');
  %if(mydetrs(i)==6420)
  %keyboard
  %end
  [newctrtmp,scores]=ds.conf.params.graddescfun(feats{i}',imgs.label(dets{i}(:,7))==ds.classperbatch(dsidx),[ctr.w ctr.rho]',weights,dsload('ds.round.roundid'));
  newctr{i,1}=ctr;
  newctrtmp=newctrtmp(:)';
  newctr{i}.w=newctrtmp(1:end-1);
  newctr{i}.rho=newctrtmp(end);

  dets{i}(:,5)=scores(:);

  thr=sort(scores,'descend');
  thr=min(-.02/dsload('ds.round.ndetrounds'),thr(min(ceil(size(ctr.w,2)/5),numel(thr))));
  scores(1)=Inf;%make sure we keep the first one, since the rest of the code assumes it's there.
  feats{i}=feats{i}((scores>=thr)',:);
  dets{i}=dets{i}(scores>=thr,:);
  allovlweight{i}=allovlweight{i}(scores>=thr);
  %ds.nextround.nsv{mydetrs(i)}=sum(scores>=thr);
  nsv(i,1)=sum(scores>=thr);
  toc(a)
end
%for(i=1:numel(dets))
%  disp(size(dets{i}));
%end
dets=cell2mat(dets(:));
feats=cell2mat(feats(:));
ds.nextround.prevdets{dsidx}=dets;
ds.nextround.nsv{dsidx}=nsv;
if(dsfield(ds,'sys','distproc','localdir'))
  prevfeats=feats;
  save([ds.sys.distproc.localdir 'prevfeats' num2str(dsidx) '_' num2str(ds.round.roundid) '.mat'],'prevfeats');
else
  ds.nextround.prevfeats{dsidx}=resfeat;
end
ds.nextround.detectors{dsidx}=effstrcell2mat(newctr);
%ds.nextround.miscstates{dsidx}=miscstates;

dssave();
ds.nextround=struct();
ds.round=struct();
ds.newdets={};
