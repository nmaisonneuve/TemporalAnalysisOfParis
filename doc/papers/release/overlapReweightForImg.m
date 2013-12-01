function reweights=overlapReweightForImg(dets,detridclassgroup)
global ds;
[~,idx]=ismember(dets(:,6),detridclassgroup(:,1));
imgs=dsload('ds.imgs{ds.conf.currimset}');
toovlweight1=detridclassgroup(idx,2)==imgs.label(dets(:,7));
if(~dsbool(ds.conf.params,'ovlweight'))
  reweights=ones(size(dets(:,1)));
else
toovlweightf=find(toovlweight1);
if(size(dets,2)>=8)
  toovlweightall{1}=toovlweightf(dets(toovlweightf,8)==0);
  toovlweightall{2}=toovlweightf(dets(toovlweightf,8)==1);
else
  toovlweightall={toovlweightf};
end
reweights=ones(size(idx));

for(i=1:numel(toovlweightall))
  toovlweight=toovlweightall{i};
  if(numel(toovlweight)>0)
    conf.groups=detridclassgroup(idx,3);
    conf.groups=conf.groups(toovlweight);
    reweights(toovlweight)=overlapReweight(dets(toovlweight,1:4),max(0,dets(toovlweight,5))+.000001,ds.conf.params.sBins,ds.conf.params.patchCanonicalSize,conf)./(max(0,dets(toovlweight,5))+.000001);
    if(any(reweights>1e10)),error('fail');end
  end
end
end
udetr=unique(idx);
idx(~toovlweight1)=0;
for(i=1:numel(udetr))
  reweights(idx==udetr(i))=reweights(idx==udetr(i))./sum(idx==udetr(i));
end
