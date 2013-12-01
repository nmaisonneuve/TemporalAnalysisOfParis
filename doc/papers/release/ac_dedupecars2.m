%if(0)
setdistprocvars;
njobs=8*18;
%distprocconf=struct('qsubopts','-l nodes=1:ppn=1');

global ds;
myaddpath;
addpath('context');
ds.prevnm=mfilename;

mydssetout(ds.prevnm,targdir);
dssetlocaldir('/mnt/sgeadmin/');

loadimset(22);
if(isfield(ds.conf.gbz{ds.conf.currimset},'imgsurl'))
  ds.imgsurl=ds.conf.gbz{ds.conf.currimset}.imgsurl;
end
rand('seed',1234)
negatives_per_positive=20;
ds.conf.params= struct( ...
  'ovlweight', 1, ...
  'patchCanonicalSize', {[80 80]}, ...
  'maxLevels', 4, ...
  'patchScaleIntervals', 2, ...
  'scaleIntervals', 8, ...
  'sBins', 8, ...
  'useColor', 1, ...
  'levelFactor', 2, ...
  'whitening', 1, ...
  'normbeforewhit', 1, ...
  'normalizefeats', 1, ...
  'graddescfun', @doGradDescentproj, ...
  'stepsize', .04, ...
  'lambdainit', .002, ...
  'epsilon', 1, ...
  'maxIter',1000,...
  'samplingOverlapThreshold', 0.6, ...
  'samplingNumPerIm',20,...
  'includeflips', 1, ...
  'multperim', 1, ...
  'nmsOverlapThreshold', 0.4)

%pick which images to use out of the dataset
imgs=ds.imgs{ds.conf.currimset};

[~,ds.conf.posclass]=ismember({'car'},ds.conf.gbz{ds.conf.currimset}.labelnames);
[~,ds.conf.ignoreclass]=ismember({'car','bus','motorbike'},ds.conf.gbz{ds.conf.currimset}.labelnames);
[boxbyim,imid]=distributeby(ds.bboxes{ds.conf.currimset},ds.bboxes{ds.conf.currimset}.imidx);
haspos=cellfun(@(x) any(ismember(x.label,ds.conf.posclass)),boxbyim);
imgs.label=zeros(size(imgs.fullname),1);
imgs.label(imid(haspos))=ds.conf.posclass;
dsdelete('ds.imgs{ds.conf.currimset}');
ds.imgs{ds.conf.currimset}=imgs;

negs=find(~imgs.label);
pos=find(imgs.label);
%sample random positive "candidate" patches
rp=randperm(numel(negs));
negs=negs(rp(1:min(numel(pos)*negatives_per_positive,numel(rp))));
ds.myiminds=[pos(:)' negs(:)'];
for(i=1:5)
  ds.roundinds{i}=ds.myiminds(i:5:end);
end
rp=randperm(numel(negs));
oi=negs(rp(1:380));
initri={oi(1:20),oi(21:80),oi(81:380)};
ds.roundinds=[initri ds.roundinds];

if(~dsmapredisopen())
  dsmapredopen(njobs,targmachine,distprocconf);
  disp('waiting 10 sec for mapreducers to start...')
  pause(10)
end
ds.aggcov.myiminds=ds.myiminds(rp(1:min(numel(rp),1500)));;
dssave;
dscd('ds.aggcov');
dsrundistributed('aggregate_covariance',{'ds.myiminds'},struct('allatonce',1,'noloadresults',1,'maxperhost',8));
%end
total=0;
clear featsum dotsum;
dsload('ds.n');
for(i=1:numel(ds.n))
  if(isempty(ds.n{i})),continue;end
  total=total+dsload(['ds.n{' num2str(i) '}'],'clear');
  if(~exist('dotsum','var'))
    dotsum=dsload(['ds.dotsum{' num2str(i) '}'],'clear');
  else
    dotsum=dotsum+dsload(['ds.dotsum{' num2str(i) '}'],'clear');
  end
  if(~exist('featsum','var'))
    featsum=dsload(['ds.featsum{' num2str(i) '}'],'clear');
  else
    featsum=featsum+dsload(['ds.featsum{' num2str(i) '}'],'clear');
  end
  if(any(isnan(dotsum(:)))||any(isnan(featsum(:))))
    keyboard;
  end
  disp(i);
end
covmat=(dotsum./total-(featsum'./total)*(featsum./total));
covmat=covmat+.01*eye(size(covmat,1));
dscd('.ds');
ds.datamean=featsum./total;
disp('performing matrix square root...');
ds.invcovmat=inv(covmat);
ds.whitenmat=sqrtm(ds.invcovmat);
clear featsum dotsum total;
clear covmat;
dsdelete('ds.aggcov');
dssave;

disp('sampling positive patches');
extrparams=ds.conf.params;
initFeatsExtra=[];
initPatsExtra=[];

if(0)
  load('misseddets.mat');
  pats=extractpatches(misseddets);
  for(i=1:numel(misseddets))
    disp(i)
    im=im2double(pats{i});%imresize(im2double(imread([patchdir pats(i).name])),[80,80]);
    extrparams.imageCanonicalSize=min(size(im(:,:,1)));
    extrparams.basePatchSize=size(im(:,:,1));
    tmp=constructFeaturePyramidForImg(im,extrparams,1);
    [prSize, pcSize,pzSize]=size(tmp.features{1});
    [features, levels, indexes] = unentanglePyramid(tmp, ...
    [prSize, pcSize, pzSize,0]);
    initFeatsExtra=[initFeatsExtra;features];
    initPatsExtra(i)=misseddets(i);%struct('decision',0,'pos',pos,'imidx',0,'detector',i);
  end
end

rp=randperm(numel(negs));
posimgs=find(imgs.label==ds.conf.posclass);
ds.sample=struct();
ds.sample.initInds=[posimgs;negs(rp(1:100))];
dsrundistributed('[ds.sample.patches{dsidx}, ds.sample.feats{dsidx}]=sampleRandomPatchesbb(ds.sample.initInds(dsidx),20,detectionconfforimg(ds.sample.initInds(dsidx)));',{'ds.sample.initInds'},struct('maxperhost',8));
batchsz=cellfun(@(x) size(x,1),ds.sample.patches(1:numel(posimgs)))';
batchsz(batchsz==0)=[];
batchsz=cellfun(@sum,distributeby(batchsz,ceil((1:numel(batchsz))/2)'));
ds.classperbatch=repmat(ds.conf.posclass,size(batchsz));

ds.initPatches=[structcell2mat(ds.sample.patches(:))];
ds.initPatches=[initPatsExtra; ds.initPatches];
disp(['sampled ' num2str(size(ds.initPatches,1)) ' patches']);
ds.initFeats=cell2mat(ds.sample.feats');
ds.initFeats=[initFeatsExtra; ds.initFeats];
dsdelete('ds.sample')

ds.detectors=cellfun(@(x,y,z) struct('w',x,'rho',y,'id',z),...
                   mat2cell([ds.initFeats(1:sum(batchsz),:)],batchsz,size(ds.initFeats,2)),...
                   mat2cell(repmat(-1,sum(batchsz),1),batchsz,1),...
                   mat2cell((1:sum(batchsz))',batchsz,1),'UniformOutput',false)';
ds.selectedClust=1:sum(batchsz);
ds.initPatches(1:sum(batchsz),6)=ds.selectedClust(:);
dssave();
marks=zeros(size(ds.selectedClust(:)));
marks(cumsum(batchsz)+1)=1;
marks(end)=[];
marks(1)=1;
ds.batchfordetr=[ds.selectedClust(:) cumsum(marks)];%create an index of where in the detectors array each patch ended up
dssave();

if(exist([ds.prevnm '_wait'],'file'))
  keyboard;
end

ds.initFeats=[];

runset=ds.sys.distproc.availslaves;
dsrundistributed('autoclust_opt_init',{'ds.detectors'},struct('noloadresults',1,'maxperhost',4,'forcerunset',runset));

dsmapreduce(['detectors=effstrcell2mat(dsload(''ds.round.detectors'')'');'...
               'dsload(''ds.classperbatch'');'...
               'conf=detectionconfforimg(ds.myiminds(dsidx));'...
               '[dets]=detectInIm(effstrcell2mat(detectors),ds.myiminds(dsidx),overrideConf(conf,struct(''thresh'',-.02/dsload(''ds.round.ndetrounds''),''multperim'',false,''flipall'',true)));'
               'ctridx=dsload(''ds.batchfordetr'');'...
               'if(~isempty(dets)),'...
                 '[~,ctrpos]=ismember(dets(:,6),ctridx(:,1));'...
                 '[dets,outpos]=distributeby(dets,ctridx(ctrpos,2));'...
                 'ds.untraineddets(outpos,dsidx)=dets;'...
               'end'],...
             ['dets=cell2mat(ds.untraineddets(dsidx,:));'...
              'dets=distributeby(dets,dets(:,6));'...
              '[~,ord]=sort(dets{i}(:,5),''descend'');'...
              'imgs=getimgs();'...
              'ispos=ismember(imgs.label(dets{i}(:,7)),ds.conf.posclass);'...
              'purity=(cumsum(ispos(:)''))./(1:numel(ispos));'...
              'dets{i}=dets{i}(ord(1:max(find(purity>.5))));'
              'ds.origdets=cell2mat(dets);']...
              ,{'ds.myiminds'},'ds.untraineddets',struct('noloadresults',1,'forcerunset',runset),struct('maxperhost',mph),struct('maxperhost',8));

uniquelabels=1:numel(ds.conf.gbz{ds.conf.currimset}.labelnames);
ds.uniquelabels=uniquelabels(:)';
dets=cell2mat(ds.origdets(:));
ds.origdets=[];

tokeep=greedySelectDetrsCoverage(dets,ds.imgs{ds.conf.currimset}.label==ds.uniquelabels(dsidx),.7,200,struct('useoverlap',1));
ctxdets=dets;
ctxdets(~ismember(dets(:,6),tokeep),:)=[];
ds.ctxmodel=genctxmodel(dets,ctxdets);

[dets]=distributeby(dets,dets(:,6));
for(i=1:numel(dets))
  [~,ord]=sort(dets{i}(:,5),'descend');
  dets{i}=dets{i}(ord(1:min(20,size(dets{i},1))),:);
end
dets=cell2mat(dets);
ovlweights=cell2mat(ovlweights);
dsup(['ds.initdisplay' num2str(roundid) '.patchimg'],extractpatches(dets));
conf=struct('dets',dets,'detrord',ds.batchfordetr(ismember(ds.batchfordetr(:,2),batchestodisp),1));
if(dsbool(ds.conf.params,'ovlweight'))
  conf.ovlweights=ovlweights;
end
mhprender('patchdisplay.mhp',['ds.progressdisplay' num2str(roundid) '.displayhtml'],conf);
clear dets;
for(i=1:numel(unique(ds.batchfordetr(:,2))))
  detr=dsload('ds.round.detectors{i}');
  detr.w=[detr.w zeros(size(detr.w,1),30)];
  dsup(['ds.round.detectors{' num2sr(i) '}'],detr);
  dssave(['ds.round.detectors{' num2sr(i) '}']);
  ds.round.detectors={};
end
 
roundid=1;
while(roundid<=(numel(ds.roundinds)))
  %if(roundid>4)
  ds.round.myiminds=ds.roundinds{roundid};
  ds.round.ndetrounds=max(roundid-3,1);
  ds.round.roundid=roundid;
  if(~isfield(ds.round,'detrgroup'))
    ds.round.detrgroup=[ds.batchfordetr(:,1), (1:size(ds.batchfordetr,1))'];
  end
  if(roundid<=2)
    mph=2;
  elseif(roundid<=3)
    mph=4;
  elseif(roundid<=4)
    mph=8;
  else
    mph=12;
  end
  if(mod(roundid,1)==0)
    dsmapredrestart;%get rid of leaked memory
  end
  if(roundid==4)
    ds.round.exceptfirst=1;
  end
  if(roundid>=4)
    ds.round.lambda=(roundid-3)*ds.conf.params.lambdainit;
  end
  dsmapreduce(['detectors=effstrcell2mat(dsload(''ds.round.detectors'')'');'...
               'dsload(''ds.classperbatch'');'...
               'dsload(''ds.ctxmodel'');'...
               'conf=detectionconfforimg(ds.round.myiminds(dsidx));'...
               '[dets,feats]=detectInIm(effstrcell2mat(detectors),ds.round.myiminds(dsidx),struct(''thresh'',-.02/dsload(''ds.round.ndetrounds''),''multperim'',dsload(''ds.round.roundid'')>2,''flipall'',true,''ctxmodel'',ds.ctxmodel));' ...
               'ctridx=dsload(''ds.batchfordetr'');'...
               'dsload(''ds.round.detrgroup'');'...
               '[~,detrgroupord]=ismember(ds.round.detrgroup(:,1),ctridx(:,1));'...
               'ovlweight=overlapReweightForImg(dets,[ctridx(:,1) ds.classperbatch(ctridx(:,2)) ds.round.detrgroup(detrgroupord,2)]);'...
               'ds.round.newfeat(1:numel(unique(ctridx(:,2))),dsidx)={struct(''assignedidx'',[],''feat'',[])};'...
               'if(~isempty(dets)),'...
                 '[~,ctrpos]=ismember(dets(:,6),ctridx(:,1));'...
                 '[dets,feats,ovlweight,outpos]=distributeby(dets,single(feats),ovlweight,ctridx(ctrpos,2));'...
                 'ds.round.newfeat(outpos,dsidx)=cellfun(@(x,y,z) struct(''assignedidx'',x,''feat'',y,''ovlweights'',z),dets,feats,ovlweight,''UniformOutput'',false);'...
               'end']...
              ,'autoclust_optimize',{'ds.round.myiminds'},'ds.round.newfeat',struct('noloadresults',1,'forcerunset',runset),struct('maxperhost',mph),struct('maxperhost',8));

  if(roundid>=4 && dsbool(ds.conf.params,'ovlweight'))
    [~,~,component]=findOverlapping3('ds.nextround.prevdets',unique(ds.batchfordetr(:,2)),[ds.batchfordetr(:,1),ds.classperbatch(ds.batchfordetr(:,2))],struct('ndetsforoverlap',.5,'maxoverlaps',3,'clusterer','agglomerative'));
    [~,cord]=ismember(ds.batchfordetr(:,1),component(:,1));
    component=component(cord,:);
    ds.nextround.detrgroup=component(:,1:2);

    detsbyim=cell2mat(dsload('ds.nextround.prevdets','clear')');
    [detsbyim,~,ord]=distributeby(detsbyim,detsbyim(:,7));
    ds.nextround.detsbyim=detsbyim';
    clear detsbyim;
    dsrundistributed(['ctridx=dsload(''ds.batchfordetr'');'...
                     'dsload(''ds.classperbatch'');'...
                     'dsload(''ds.nextround.detrgroup'');'...
                     '[~,detrgroupord]=ismember(ds.nextround.detrgroup(:,1),ctridx(:,1));'...
                     'ds.nextround.reweights{dsidx}=overlapReweightForImg(ds.nextround.detsbyim{dsidx},[ctridx(:,1) ds.classperbatch(ctridx(:,2)) ds.nextround.detrgroup(detrgroupord,2)]);'],'ds.nextround.detsbyim');
    ds.nextround.detsbyim={};
    dsload('ds.nextround.prevdets');
    reweights=mat2cell(invertdistributeby(ds.nextround.reweights(:),ord),cellfun(@(x) size(x,1),ds.nextround.prevdets),1);
    classfordetr(ds.batchfordetr(:,1))=ds.classperbatch(ds.batchfordetr(:,2));
    
    for(i=1:numel(reweights))
      [currdets,currweights,detid,ord]=distributeby(ds.nextround.prevdets{i},reweights{i},ds.nextround.prevdets{i}(:,6));
      for(j=1:numel(currdets))
        ispos=find(ds.imgs{ds.conf.currimset}.label(currdets{j}(:,7))==c(classfordetr(currdets{j}(:,6))));
        if(ispos(1)~=1)
          'ispos(1)'
          keyboard
        end
        if(numel(ispos)>1)
          currweights{j}(1)=.5^(roundid-4)+(1-.5^(roundid-4))*mean(currweights{j}(ispos(2:end)));
        end
      end
      reweights{i}=invertdistributeby(currweights,ord);
    end
    ds.nextround.prevweights=reweights(:)';
  end

  if(roundid>=4)
    batchestodisp=1:40:numel(unique(ds.batchfordetr(:,2)));
    batchestodisp=batchestodisp(1:min(10,numel(batchestodisp)));
    dets=cell2mat(dsload(['ds.nextround.prevdets{' num2str(batchestodisp) '}'])');
    if(dsbool(ds.conf.params,'ovlweight'))
      ovlweights=cell2mat(dsload(['ds.nextround.prevweights{' num2str(batchestodisp) '}'])');
    else
      ovlweights=ones(size(dets(:,1)));
    end
    [dets,ovlweights]=distributeby(dets,ovlweights,dets(:,6));
    for(i=1:numel(dets))
      [~,ord]=sort(dets{i}(:,5),'descend');
      ovlweights{i}=ovlweights{i}(ord(1:min(20,size(dets{i},1))));
      dets{i}=dets{i}(ord(1:min(20,size(dets{i},1))),:);
    end
    dets=cell2mat(dets);
    ovlweights=cell2mat(ovlweights);
    dsup(['ds.progressdisplay' num2str(roundid) '.patchimg'],extractpatches(dets));
    conf=struct('dets',dets,'detrord',ds.batchfordetr(ismember(ds.batchfordetr(:,2),batchestodisp),1));
    if(dsbool(ds.conf.params,'ovlweight'))
      conf.ovlweights=ovlweights;
    end
    mhprender('patchdisplay.mhp',['ds.progressdisplay' num2str(roundid) '.displayhtml'],conf);
    fail=1;while(fail),try
    dssave;
    fail=0;catch ex,if(fail>5),rethrow(ex);end,fail=fail+1;end,end
    dsclear(['ds.progressdisplay' num2str(roundid)]);
  end
  ds.round=struct();
  dsmv('ds.round',['ds.round' num2str(roundid)]);
  %dsdelete(['ds.round' num2str(roundid)]);
  dsmv('ds.nextround','ds.round');
  roundid=roundid+1;
end

%ds.heldoutdets=heldoutdets;
%heldoutdets=cell2mat(heldoutdets(:));
dsrundistributed(['dsload(''ds.batchfordetr'');dsload(''ds.classperbatch'');dsload(''ds.imgs'');dsload(''ds.roundinds'');'...
  'if(sum(ds.classperbatch==ds.uniquelabels(dsidx))==0),return;end,'...
  'dsload([''ds.newdets{'' num2str(numel(ds.roundinds)-2:numel(ds.roundinds)) ''}{'' num2str(find(ds.classperbatch(:)''==ds.uniquelabels(dsidx))) ''}'']);'...
  'detsbyround={};'...
  'for(i=numel(ds.roundinds)-1:numel(ds.roundinds)),'...
    'detsbyround{end+1,1}=structcell2mat(ds.newdets(i,:)'');'...
  'end,'...
  '[ds.finids{dsidx},ds.scores{dsidx}]=greedySelectDetrsCoverage(detsbyround,ds.imgs{ds.conf.currimset}.label==ds.uniquelabels(dsidx),.7,200,struct(''useoverlap'',1));'...
  'ds.newdets={}'...
  ],'ds.uniquelabels',struct('maxperhost',2));

heldoutdets={};
for(i=numel(ds.roundinds)-2:numel(ds.roundinds))
  newdets=cell2mat(dsload(['ds.newdets{' num2str(i) '}{1:' num2str(dssavestatesize('ds.newdets',2)) '}'])');
  ds.newdets={};
  newdets(~ismember(newdets(:,6),cell2mat(ds.finids(:))),:)=[];
  heldoutdets{end+1,1}=newdets;
end
heldoutdets=cell2mat(heldoutdets(:));

[heldoutdets,detid]=distributeby(heldoutdets,heldoutdets(:,6));
for(i=1:numel(ds.finids))
  heldoutdetsbyclass=heldoutdets(ismember(detid,ds.finids{i}));
  ds.topk{i}=cell2mat(maxkall(heldoutdetsbyclass,5,20));
end
ds.classes=ds.conf.gbz{ds.conf.currimset}.labelnames(:)';
dsrundistributed(['if(isempty(ds.finids{dsidx})),return;end,'...
                  'dsup([''ds.display_'' ds.classes{dsidx} ''.patchimg''],extractpatches(ds.topk{dsidx}));'...
                  'conf=struct(''dets'',ds.topk{dsidx},'...
                              '''detrord'',ds.finids{dsidx},'...
                              '''message'',{cellfun(@(x) [''score:'' num2str(x)],num2cell(ds.scores{dsidx}),''UniformOutput'',false)});'...
                  'mhprender(''patchdisplay.mhp'',[''ds.display_'' ds.classes{dsidx} ''.displayhtml''],conf);']...
                  ,{'ds.finids','ds.scores','ds.topk','ds.classes'},struct('noloadresults',true));

model=effstrcell2mat(dsload('ds.round.detectors','clear')');
model=selectdetrs2(model,cell2mat(ds.finids(:)));
ds.finmodel=model;
return
ds.detrs=model.w;
%dsload('ds.detn.finctrs');
%ds.detrs=cell2mat(dsload('ds.detn.finctrs','clear')');
dssave;

ds.detrs=[];
ds.banksize=ones(numel(ds.uniquelabels),1)*200;
dsrundistributed('distGenPooledFeats',{'ds.myiminds'},struct('noloadresults',true));
%ds.pooledFeatsCat=cell2mat(ds.pooledFeats)';
%dsclear('ds.pooledFeats');
%ds.transmat=qr(dsload('ds.pooledFeatsCat','clear')');
%ds.trainfeats=(dsload('ds.pooledFeatsCat','clear')*ds.transmat);
%end
%ds.transfun=@(x) 100*(sqrt(max(x,-1)+2)-1);%./(1+exp(-((x)*3-2)));
if(0)
fils=cleandir('/ebs1/ifv/data/codes/FKtest_comb_train_chunk*');
for(i=1:numel(fils))
  load(['/ebs1/ifv/data/codes/' fils(i).name]);
  [~,idx]=ismember(index,ds.myiminds);
  for(j=1:numel(idx))
    ds.ifvFeats{idx(j)}=chunk(:,j);
  end
  disp(i)
end

fils=cleandir('/ebs1/ifv/data/codes/FKtest_comb_test_chunk*');
for(i=1:numel(fils))
  load(['/ebs1/ifv/data/codes/' fils(i).name]);
  [~,idx]=ismember(index,ds.myiminds);
  for(j=1:numel(idx))
    ds.test.ifvFeats{idx(j)}=chunk(:,j);
  end
  disp(i)
end
end
%end
ds.transfun=@(x) 2*bsxfun(@minus,x,mean(x,2));%./(1+exp(-((x+1)/2-4)));
%ds.transfun=@withinclass;
clear kernmat
loadimset(19);
%end
for(dsidx=1:numel(ds.classes))
  pooledfeatsvm;
  dsidx
end
%dsrundistributed('pooledfeatsvm',{'ds.classes'},struct('maxperhost',1));
loadimset(20);
ds.test.myiminds=1:numel(ds.imgs{ds.conf.currimset}.fullname);
ds.test.svm=cell2mat(ds.trainedsvm');
ds.test.transfun=ds.transfun;
%for(i=1:numel(ds.test.svm))
%  ds.banksize(i)=numel(ds.test.svm(i).w)/5;
%end
ds.test.banksize=ds.banksize;
%ds.test.transmat=ds.transmat;
dssave;
dscd('.ds.test');

dsrundistributed('distGenPooledFeats',{'ds.myiminds'},struct('noloadresults',true));
%dsmapredclose;
dsload('ds.scores');
%end
[~,guess]=max(cell2mat(ds.scores'),[],2);
imgs=getimgs();
[~,truth]=imgs.label;

dssave;
sum(guess==truth)/numel(truth)
allscores=cell2mat(ds.scores');
errorval=allscores(sub2ind(size(allscores),(1:size(allscores,1))',guess))-allscores(sub2ind(size(allscores),(1:size(allscores,1))',truth));
[~,ds.todisp]=maxk(errorval,144);
ds.guess=guess;
ds.groundtruth=truth;
dsrundistributed(['dsload(''ds.myiminds'');i=ds.myiminds(ds.todisp(dsidx));im=im2double(getimg(i));svm=dsload(''ds.svm'');dsload(''ds.guess'');dsload(''ds.groundtruth'');'...
                 '[ds.errdisp.trueposimg{dsidx},ds.errdisp.truenegimg{dsidx}]=dispClassifier(dsload(''.ds.detrs''),im,svm(ds.groundtruth(ds.todisp(dsidx)),:));'...
                 '[ds.errdisp.guessposimg{dsidx},ds.errdisp.guessnegimg{dsidx}]=dispClassifier(dsload(''.ds.detrs''),im,svm(ds.guess(ds.todisp(dsidx)),:));'...
                 ],'ds.todisp',struct('noloadresults',1));

ds.errdisp.guess=guess;
ds.errdisp.groundtruth=truth;
ds.errdisp.todisp=ds.todisp;
dscd('.ds.test.errdisp');
uniquelabels=dsload('.ds.uniquelabels');
mhprender('errdisp.mhp','ds.errhtml',struct('trueclasses',{ds.conf.gbz{ds.conf.currimset}.labelnames(truth(ds.todisp))},'guessclasses',{ds.conf.gbz{ds.conf.currimset}.labelnames(guess(ds.todisp))}));

dscd('.ds');
return
