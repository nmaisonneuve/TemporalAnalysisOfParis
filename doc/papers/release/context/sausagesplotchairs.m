%if(0)
for(i=unique(ds.ctridx4pat(:,2)'))
  disp(i)
  alldata{i}=dsload(['ds.round.prevdets{' num2str(i) '}'],'clear');
end
alldata=cell2mat(alldata(:));
allgtboxes={};
for(i=ds.myiminds(:)')
  allgtboxes{end+1,1}=getpascalannotmat(i,ds.conf.classord{1},ds.conf.params.vieword{1},struct('flipall','true'));
end
allgtboxes=cell2mat(allgtboxes);
[~,pos]=ismember(ds.conf.posclass{1},ds.conf.classord{1});
allgtboxes(allgtboxes(:,6)~=pos,:)=[];
allimgs=extractpatches(mat2det(allgtboxes),[],struct('noresize',1));
[posdets imgidx]=distributeby(alldata,alldata(:,[7 8 10]));
posdets(~ds.ispos(imgidx(:,1)))=[];
clear imgidx;
posdets2=cell2mat(posdets);
posdets2=posdets2(ismember(posdets2(:,6),ds.tokeep(1:100)),:);

[tmp,imageid]=distributeby(posdets2,posdets2(:,[7 8 10]));
[~,imgstokeep] = maxk(cellfun(@(x) size(x,1),tmp),100);
imgstokeep=imageid(imgstokeep,:);
posdets2(~ismember(posdets2(:,[7 8 10]),imgstokeep,'rows'),:)=[];

%contextdict=gencontextdict(distributeby(posdets2,posdets2(:,[7 8 10])),0);
%end
%end
[sp_images,sp_detrs]=sausagesplot(cell2mat(posdets),allimgs,allgtboxes,ds.tokeep,struct())%,struct('contextdict',{contextdict}));
return
