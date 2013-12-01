%TODO: epsilon to beta
if(0)
global ds;
setdistprocvars;
njobs=128;

myaddpath;
ds.prevnm=mfilename;

mydssetout(ds.prevnm,targdir);
dssetlocaldir('/mnt/sgeadmin/');
gbz=globalz(19)
if(~exist(gbz.datasetname,'file'))
  preprocessindoor67;
end

loadimset(19);
if(isfield(ds.conf.gbz{ds.conf.currimset},'imgsurl'))
  ds.imgsurl=ds.conf.gbz{ds.conf.currimset}.imgsurl;
end
rand('seed',1234)
ds.conf.params= struct( ...
  'ovlweight', 0, ... % use the inter-element communication scheme to set the weights.
  'negsperpos', 8, ... % during element training, the number of images we hard-mine 
                   ... % negatives from during for each positive training image.
  'maxpixels',300000,... % large images will be downsampled to this many pixels.
  'minpixels',300000,... % small images will be upsampled to this many pixels.
  'patchCanonicalSize', {[64 64]}, ... % resolution for each detected patch.
  'scaleIntervals', 8, ... % number of pyramid levels per scale.
  'sBins', 8, ... % pixel width/height for HOG cells
  'useColor', 1, ... % include Lab tiny images in the descriptor for a patch.
  'whitening', 1, ... % whiten the patch features
  'normbeforewhit', 1, ... % mean-subtract and normalize features before applying whitening
  'normalizefeats', 1, ... % mean-subtract and normalize features after applying whitening
  'graddescfun', @doGradDescentproj, ... % function ptr for the optimization function
  'stepsize', .005, ... % step size used by the optimizer
  'lambdainit', .02, ... % lambda value for the optimization used during the first 
                      ... % training round (gets increased proportional to the number 
                      ... % of samples at later training rounds)
  'epsilon', 1, ... % beta value for the optimization
  'optimizationComputeLimit',1500,... % maximum number of vector-matrix multiplies that the
                                  ... % optimizer may perform on each training iteration
  'samplingOverlapThreshold', 0.6, ... % patches sampled initially can't have overlap larger
                                   ... % than this value.
  'samplingNumPerIm',20,... % sample this many patches per image.
  'includeflips', 1, ... % flip training images horizontally to get more data
  'multperim', 1, ... % allow multiple detections per image
  'nmsOverlapThreshold', 0.4 ... % overlap threshold for NMS during detection.
  )

%pick which images to use out of the dataset
imgs=ds.imgs{ds.conf.currimset};
ds.myiminds=1:numel(imgs.label);

% ds.roundinds stores the indices of the images to use at each iteration of training 
[~,cls]=ismember(ds.imgs{ds.conf.currimset}.label(ds.myiminds),unique(ds.imgs{ds.conf.currimset}.label));
imgsbyclass=distributeby(ds.myiminds(:),cls);
rp=randperm(numel(ds.myiminds));
% the first 3 rounds of training are just used to set the initial bandwidth, so we
% use a very small subset of them.
% actually it's pretty stupid that this takes 3 rounds; it could be done in 1 except
% that doing so would generate tons of useless feature vectors in the current pipeline.
ds.roundinds{1}=ds.myiminds(rp(1:20));
ds.roundinds{2}=ds.myiminds(rp(21:60));
ds.roundinds{3}=ds.myiminds(rp(61:120));
% evenly divide the rest of the images. Note that the classes aren't quite balanced,
% so the last round deals with extra/missing images.
for(i=4:8)
  ds.roundinds{i}=[];
  for(j=1:numel(imgsbyclass))
    if(i==8)
      ul=numel(imgsbyclass{j});
    else
      ul=16;
    end
    ds.roundinds{i}=[ds.roundinds{i};imgsbyclass{j}(1:ul)];
    imgsbyclass{j}(1:ul)=[];
  end
  ds.roundinds{i}=ds.roundinds{i}(randperm(numel(ds.roundinds{i})));
end
if(~dsmapredisopen())
  dsmapredopen(njobs,targmachine,distprocconf);
  disp('waiting 10 sec for mapreducers to start...')
  pause(10)
end

% Generate the whitening matrix based on 1500 randomly sampled images.
ds.aggcov.myiminds=ds.myiminds(rp(1:min(numel(rp),1500)));;
dssave;
dscd('ds.aggcov');
dsrundistributed('aggregate_covariance',{'ds.myiminds'},struct('allatonce',1,'noloadresults',1,'maxperhost',8));
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
ds.sample=struct();
ds.sample.initInds=ds.myiminds;
dsrundistributed('[ds.sample.patches{dsidx}, ds.sample.feats{dsidx}]=sampleRandomPatchesbb(ds.sample.initInds(dsidx),20);',{'ds.sample.initInds'},struct('maxperhost',8));

% divide the sampled patches into batches (two images' worth of sampled
% patches per batch).  The batches are purely for efficiency, specifically
% to limit the number of files that get written.  Note that each
% batch needs to have a single class label.
batchsz=cellfun(@(x) size(x,1),ds.sample.patches)';
ds.classperbatch=ds.imgs{ds.conf.currimset}.label(ds.sample.initInds);
[batchsz,cpb]=distributeby(batchsz,ds.classperbatch);
for(i=1:numel(batchsz))
  if(mod(numel(batchsz{i}),2)==0)
    batchsz{i}=batchsz{i}(1:2:end)+batchsz{i}(2:2:end);
  else
    batchsz{i}=[batchsz{i}(1:2:end-1)+batchsz{i}(2:2:end-1); batchsz{i}(end)];
  end
  cpb2{i,1}=repmat(cpb(i),numel(batchsz{i}),1);
end
batchsz=cell2mat(batchsz)';
% store the class label for each batch.
ds.classperbatch=cell2mat(cpb2);
ds.classperbatch(batchsz==0)=[];
batchsz(batchsz==0)=[];
initPatches=[structcell2mat(ds.sample.patches(:))];
initPatches=[initPatsExtra(:); initPatches];
disp(['sampled ' num2str(size(initPatches,1)) ' patches']);
ds.initFeats=cell2mat(ds.sample.feats');
ds.initFeats=[initFeatsExtra; ds.initFeats];

% convert the patch features for each batch into a detector structure.
ds.detectors=cellfun(@(x,y,z) struct('w',x,'rho',y,'id',z),...
                   mat2cell([ds.initFeats],batchsz,size(ds.initFeats,2)),...
                   mat2cell(repmat(-1,size(ds.initFeats,1),1),batchsz,1),...
                   mat2cell((1:size(ds.initFeats,1))',batchsz,1),'UniformOutput',false)';
initPatches(1:sum(batchsz),6)=1:size(ds.initFeats,1);
ds.initPatches=initPatches;
% batchfordetr is an n-by-2 detector for the n detectors: column 1 is
% a detector id, column 2 is the index of the batch containing it.
marks=zeros(size(ds.initFeats,1),1);
marks(cumsum(batchsz)+1)=1;
marks(end)=[];
marks(1)=1;
ds.batchfordetr=[(1:size(ds.initFeats,1))' cumsum(marks)];
dssave();
dsdelete('ds.sample')

if(exist([ds.prevnm '_wait'],'file'))
  keyboard;
end

% initialize the set of detectors: this will only update the rho value.
ds.initFeats=[];
runset=ds.sys.distproc.availslaves;
dsrundistributed('autoclust_opt_init',{'ds.detectors'},struct('noloadresults',1,'maxperhost',4,'forcerunset',runset));

roundid=1;
uniquelabels=1:numel(ds.conf.gbz{ds.conf.currimset}.labelnames);
ds.uniquelabels=uniquelabels(:)';
while(roundid<=(numel(ds.roundinds)))
  %if(roundid>4)
  ds.round.myiminds=ds.roundinds{roundid}; % images to run training on
  ds.round.ndetrounds=max(roundid-3,1); % the number of real detection rounds we've completed
  ds.round.roundid=roundid;
  if(~isfield(ds.round,'detrgroup'))
    % make a fake clustering for the first few rounds
    ds.round.detrgroup=[ds.batchfordetr(:,1), (1:size(ds.batchfordetr,1))'];
  end
  if(roundid<=2)
    mph=1;
  elseif(roundid<=3)
    mph=3;
  elseif(roundid<=4)
    mph=8;
  else
    mph=10;
  end
  if(mod(roundid,1)==0)
    % matlab's memory footprint grows even if it's not using the memory; restarting frees it.
    dsmapredrestart;
  end
  if(roundid>=4)
    % increase lambda (the bandwidth) proportional to the number of images we've run detection on.
    ds.round.lambda=(roundid-3)*ds.conf.params.lambdainit;
  else
    % if we're initializing, epsilon determines how large rho is.  Since we initialize on a small
    % set, we want to make epsilon artificially small so that the detector will fire less
    % when it starts doing detection for real.  This reduces the number of useless patch features
    % get generated.
    ds.round.epsilon=ds.conf.params.epsilon/3;
  end
  %end

  % the main mapreduce that runs detectors on images and sends the detected feature vectors
  % to reducers, each of which optimizes one batch of detectors. We use forcerunset to
  % make sure each detector is always optimized on the same machine, since these machines
  % cache features locally.
  dsmapreduce(['detectors=dsload(''ds.round.detectors'')'';'...
               'imgs=dsload(''ds.imgs{ds.conf.currimset}'');'...
               'dsload(''ds.classperbatch'');'...
               'posbats=find(imgs.label(ds.round.myiminds(dsidx))==ds.classperbatch);'... % run all detectors whose class matches the class of this image
               'negbats=find(imgs.label(ds.round.myiminds(dsidx))~=ds.classperbatch);'...
               'rp=randperm(numel(negbats));'...
               'negbats=negbats(rp(1:min(numel(negbats),numel(posbats)*ds.conf.params.negsperpos)));'... % run a random subset of the detectors for other classes
               '[dets,feats]=detectInIm(effstrcell2mat(detectors([posbats(:); negbats(:)])),ds.round.myiminds(dsidx),struct(''thresh'',-.02/dsload(''ds.round.ndetrounds''),''multperim'',dsload(''ds.round.roundid'')>2,''flipall'',true));' ...
               'ctridx=dsload(''ds.batchfordetr'');'...
               'dsload(''ds.round.detrgroup'');'...
               '[~,detrgroupord]=ismember(ds.round.detrgroup(:,1),ctridx(:,1));'...
               'ovlweight=overlapReweightForImg(dets,[ctridx(:,1) ds.classperbatch(ctridx(:,2)) ds.round.detrgroup(detrgroupord,2)]);'...% ovlweights are the \alpha_i,j from the paper
               'ds.round.newfeat(1:numel(unique(ctridx(:,2))),dsidx)={struct(''assignedidx'',[],''feat'',[])};'...
               'if(~isempty(dets)),'...
                 '[~,ctrpos]=ismember(dets(:,6),ctridx(:,1));'...
                 '[dets,feats,ovlweight,outpos]=distributeby(dets,single(feats),ovlweight,ctridx(ctrpos,2));'...
                 'ds.round.newfeat(outpos,dsidx)=cellfun(@(x,y,z) struct(''assignedidx'',x,''feat'',y,''ovlweights'',z),dets,feats,ovlweight,''UniformOutput'',false);'...
               'end']...
              ,'autoclust_optimize',{'ds.round.myiminds'},'ds.round.newfeat',struct('noloadresults',1,'forcerunset',runset),struct('maxperhost',mph),struct('maxperhost',8));
  %end

  if(roundid>=4)
    dsrundistributed(['dsload(''ds.classperbatch'');dsload(''ds.batchfordetr'');'...
                      '[~,~,ds.round.component{dsidx}]='...
                      'findOverlapping3(''ds.nextround.prevdets'',find(ds.classperbatch==ds.uniquelabels(dsidx)),'...
                      '[ds.batchfordetr(:,1),ds.classperbatch(ds.batchfordetr(:,2))],'...
                      'struct(''ndetsforoverlap'',.5,''maxoverlaps'',3,''clusterer'',''agglomerative''))'],'ds.uniquelabels',struct('maxperhost',5));
    component=[];
    toadd=0;
    for(i=1:numel(ds.round.component))
      tmpcomponent=ds.round.component{i};
      tmpcomponent(:,2)=tmpcomponent(:,2)+toadd;
      component=[component;tmpcomponent];
      toadd=max(component(:,2));  
    end
    [~,cord]=ismember(ds.batchfordetr(:,1),component(:,1));
    component=component(cord,:);
    ds.nextround.detrgroup=component(:,1:2);

    detsbyim=cell2mat(dsload('ds.nextround.prevdets','clear')');
    [detsbyim,~,ord]=distributeby(detsbyim,detsbyim(:,7));
    ds.nextround.detsbyim=detsbyim';
    clear detsbyim;
    %end
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

    batchestodisp=1:40:numel(unique(ds.batchfordetr(:,2)));
    batchestodisp=batchestodisp(1:min(10,numel(batchestodisp)));
    dets=cell2mat(dsload(['ds.nextround.prevdets{' num2str(batchestodisp) '}'])');
    %if(dsbool(ds.conf.params,'ovlweight'))
      ovlweights=cell2mat(dsload(['ds.nextround.prevweights{' num2str(batchestodisp) '}'])');
    %else
    %  ovlweights=ones(size(dets(:,1)));
    %end
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
    %if(dsbool(ds.conf.params,'ovlweight'))
      conf.ovlweights=ovlweights;
    %end
    mhprender('patchdisplay.mhp',['ds.progressdisplay' num2str(roundid) '.displayhtml'],conf);
    fail=1;while(fail),try
    dssave;
    fail=0;catch ex,if(fail>5),rethrow(ex);end,fail=fail+1;end,end
    dsclear(['ds.progressdisplay' num2str(roundid)]);
  end
  ds.round=struct();
  dsmv('ds.round',['ds.round' num2str(roundid)]);
  if(roundid>4)
    dsdelete(['ds.round' num2str(roundid)]);
  end
  dsmv('ds.nextround','ds.round');
  roundid=roundid+1;
end

uniquelabels=1:numel(ds.conf.gbz{ds.conf.currimset}.labelnames);
ds.uniquelabels=uniquelabels(:)';
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
%return
%ds.detrs=model.w;
%dsload('ds.detn.finctrs');
%ds.detrs=cell2mat(dsload('ds.detn.finctrs','clear')');
dssave;

%ds.banksize=ones(numel(ds.uniquelabels),1)*200;
%dsrundistributed('distGenPooledFeats',{'ds.myiminds'},struct('noloadresults',true));
%dsrundistributed('ds.poolfeats{dsidx}=distGenPooledFeats(ds.finmodel,im2double(getimg(ds.myiminds(dsidx))))',{'ds.myiminds'},struct('noloadresults',true));
dsrundistributed('dsload(''ds.finmodel'');ds.poolfeats{dsidx}=distGenPooledFeats(ds.finmodel,ds.myiminds(dsidx))',{'ds.myiminds'},struct('noloadresults',true));
trainlab=ds.imgs{ds.conf.currimset}.label;
loadimset(20);
ds.mytestinds=1:numel(ds.imgs{ds.conf.currimset}.fullname);
dsrundistributed('dsload(''ds.finmodel'');ds.testpoolfeats{dsidx}=distGenPooledFeats(ds.finmodel,ds.mytestinds(dsidx))',{'ds.mytestinds'},struct('noloadresults',true));
%dsrundistributed('ds.testpoolfeats{dsidx}=distGenPooledFeats(ds.finmodel,ds.mytestinds(dsidx))',{'ds.myiminds'},struct('noloadresults',true));
%ds.pooledFeatsCat=cell2mat(ds.pooledFeats)';
%dsclear('ds.pooledFeats');
%ds.transmat=qr(dsload('ds.pooledFeatsCat','clear')');
%ds.trainfeats=(dsload('ds.pooledFeatsCat','clear')*ds.transmat);
%end
%ds.transfun=@(x) 100*(sqrt(max(x,-1)+2)-1);%./(1+exp(-((x)*3-2)));
if(1)
  % Note we're assuming here that the ifv IMDB order is the same as
  % our order (since the ifv output doesn't actually include the imdb :-/)
  % This will be true if the order of directory listings is deterministic,
  % since the IMDB gets their file listing in the same way we do.  However,
  % the madlab docs say that the order returned by dir actually depends on
  % the OS.
  ifvpermutation=1:10000;
  fils=cleandir('/ebs1/ifv/data/codes/FKtest_comb_train_chunk*');
  for(i=1:numel(fils))
    load(['/ebs1/ifv/data/codes/' fils(i).name]);
    [~,idx]=ismember(index,ifvpermutation);
    for(j=1:numel(idx))
      trainifvfeats(idx(j),:)=chunk(:,j)';
    end
    disp(i)
  end
  ifvkern=trainifvfeats*trainifvfeats';

  fils=cleandir('/ebs1/ifv/data/codes/FKtest_comb_test_chunk*');
  for(i=1:numel(fils))
    load(['/ebs1/ifv/data/codes/' fils(i).name]);
    [~,idx]=ismember(index,ifvpermutation);
    for(j=1:numel(idx))
      testifvFeats(idx(j),:)=chunk(:,j)';
    end
    disp(i)
  end
  ifvtestkern=trainifvfeats*testifvFeats';
  pfwt=.01;
  thresh=.6;
  ifvwt=18;
else
  ifvkern=0;
  ifvtestkern=0;
  if(dsbool(ds.conf.params,'ovlweight'))
    pfwt=.012;
    thresh=.7;
    ifvwt=0;
  else
    pfwt=.2;
    thresh=.3;
    ifvwt=0;
  end
end



trainpf2=cell2mat(dsload('ds.poolfeats','clear')');
testpf2=cell2mat(dsload('ds.testpoolfeats','clear')');
end
%end
%end
kernfun=@(x,y) ((max(x+thresh,0))*(max(y+thresh,0))');
transfun=@(x) max(x+.3,0)/sqrt(200);

pfkern=kernfun(trainpf2,trainpf2);
kernmat=ifvkern*ifvwt+pfkern*pfwt;
classes=unique(trainlab)
parfor(i=1:numel(classes))%:numel(ds.classes))
  inds=find(trainlab==classes(i));
  label=-ones(size(kernmat,1),1);
  label(inds)=1;
  trainedsvm{i}=svmtrain(label,double([(1:numel(label))' kernmat]),'-s 0 -t 4 -c .1 -h 0');
  disp(i)
end

pftestkern=kernfun(trainpf2,testpf2);
traintestkern=ifvtestkern*ifvwt+pftestkern*pfwt;
testscr=[];
for(i=1:numel(trainedsvm))
  testscr(i,:)=(trainedsvm{i}.sv_coef'*traintestkern(trainedsvm{i}.SVs,:)-trainedsvm{i}.rho)*trainedsvm{i}.Label(1);
end

[~,label]=max(testscr,[],1);
truth=ds.imgs{ds.conf.currimset}.label';
perf=sum(truth==label)./numel(label)
return

for(i=1:numel(classes))
  ds.svm{i}=getMinimalModel2(trainedsvm{i},transfun(trainpf2));
end
allscores=testscr';

prevdets=cell2mat(dsload('ds.round.prevdets','clear')');
prevdets=distributeby(prevdets,prevdets(:,6));
ds.dispdets=cell2mat(maxkall(prevdets(:),5,5));
clear prevdets;
ds.dispdets=ds.dispdets(ismember(ds.dispdets(:,6),ds.finmodel.id),:);
dssave;
%end
for(disperror=[0 1])
  if(disperror)
    dscd('.ds.errorimages');
    errorval=allscores(sub2ind(size(allscores),(1:size(allscores,1))',label(:)))-allscores(sub2ind(size(allscores),(1:size(allscores,1))',truth(:)));
    ds.cls=[truth(:) label(:)]
  else
    dscd('.ds.easyimages');
    for(i=1:size(allscores,1))
      [scr,ds.cls(i,:)]=maxk(allscores(i,:),2);
      errorval(i)=scr(1)-scr(2);
    end
  end

  [confidence,ds.todisp]=maxk(errorval,100);
  ds.transfun=transfun;
  loadimset(20);

  dsrundistributed(['detrs=dsload(''.ds.finmodel'');svm=dsload(''.ds.svm'');transfun=dsload(''ds.transfun'');'...
                    'cls=dsload(''ds.cls'');dispdets=dsload(''.ds.dispdets'');dsload(''.ds.imgs'');'...
                    'im=im2double(getimg(ds.todisp(dsidx)));'...
                    'ds.origimg{dsidx}=im;'...
                    '[ds.leftposimg{dsidx},ds.leftnegimg{dsidx}]=dispClassifier('...
                      'detrs,im,svm{cls(ds.todisp(dsidx),1)},transfun,dispdets,[''ds.display_left_'' num2str(dsidx)],19);'...
                    '[ds.rightposimg{dsidx},ds.rightnegimg{dsidx}]=dispClassifier('...
                      'detrs,im,svm{cls(ds.todisp(dsidx),2)},transfun,dispdets,[''ds.display_right_'' num2str(dsidx)],19);'],'ds.todisp',struct('noloadresults',1));

  mhprender('errdisp.mhp','ds.errhtml',struct('trueclasses',{ds.conf.gbz{ds.conf.currimset}.labelnames(ds.cls(ds.todisp,1))},'guessclasses',{ds.conf.gbz{ds.conf.currimset}.labelnames(ds.cls(ds.todisp,2))},'confidence',confidence,'iserror',disperror));
  dssave;
end

dscd('.ds');
perf=sum(truth==label)./numel(label)
return







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
dssave;
dscd('.ds.test');
dsrundistributed('ds.poolfeats{dsidx}=distGenPooledFeats(ds.finmodel,ds.myiminds(dsidx))',{'ds.myiminds'},struct('noloadresults',true));
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
