%if(0)
for(i=unique(ds.batchfordetr(:,2)'))
  disp(i)
  alldata{i}=dsload(['ds.round.prevdets{' num2str(i) '}'],'clear');
end
alldata=cell2mat(alldata(:));
%alldata(:,5)=min(1,alldata(:,5));
%allgtboxes={};
%for(i=ds.myiminds(:)')
%  allgtboxes{end+1,1}=getpascalannotmat(i,ds.conf.classord{1},ds.conf.params.vieword{1},struct('flipall','true'));
%end
%allgtboxes=cell2mat(allgtboxes);
imgs=dsload('ds.imgs{ds.conf.currimset}');
allgtboxes=genflips(ds.bboxes{ds.conf.currimset});
%[~,pos]=ismember(ds.conf.posclass{1},ds.conf.classord{1});
allgtboxes=effstridx(allgtboxes,imgs.label(allgtboxes.imidx)==ds.conf.posclass);
agb=allgtboxes;
agb.pos=allgtboxes;
agb=effstr2str(agb)
allimgs=extractpatches(agb,[],struct('noresize',1));
[posdets imgidx]=distributeby(alldata,alldata(:,[7 8 9]));
posdets(imgs.label(imgidx(:,1))~=ds.conf.posclass,:)=[];
clear imgidx;
posdets2=cell2mat(posdets);
tokeep=dsload('ds.finids{ds.conf.posclass}');
posdets2=posdets2(ismember(posdets2(:,6),tokeep(1:100)),:);

[tmp,imageid]=distributeby(posdets2,posdets2(:,[7 8 9]));
[~,imgstokeep] = maxk(cellfun(@(x) size(x,1),tmp),100);
imgstokeep=imageid(imgstokeep,:);
posdets2(~ismember(posdets2(:,[7 8 9]),imgstokeep,'rows'),:)=[];
%end

%end
%contextdict=gencontextdict(distributeby(posdets2,posdets2(:,[7 8 9])),0);
%end
[sp_images,sp_detrs]=spectralcontext(cell2mat(posdets),allimgs,allgtboxes,tokeep,struct());%'contextdict',{contextdict}));
return
