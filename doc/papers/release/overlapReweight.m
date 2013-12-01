function resw=overlapReweight(pos,origw,gridsize,minsize,conf)
  %save(['/ebs1/tmp' num2str(floor(rand*1000)) '.mat']);
  try
  if(size(pos,1)==0)
    resw=[];
    return;
  end
  pos=(pos-.5)/gridsize+1;
  minsize=prod(minsize/gridsize);
  imsize=ceil([max(pos(:,4)),max(pos(:,3))]);
  if(isfield(conf,'groups'))
    [pos,origw,ord]=distributeby(pos,origw,(1:numel(origw))',conf.groups);
    ord=cell2mat(ord);
  else
    [pos,origw]=distributeby(pos,origw,(1:numel(origw))');
    ord=(1:numel(origw))';
  end
  %normfact=max(.00001,min(origw));
  %origw=origw/normfact;
  imsize
  dim=[imsize ceil(log2(min(imsize))*5)];
  field=zeros(dim);
  field2=field;
  linidx=1;
  addvec={};
  for(j=1:numel(pos))
    %fieldtmp=sparse(prod(dim),1);
    allinds={};
    for(i=1:size(pos{j},1))
      p=pos{j}(i,:);
      patsize=(p(4)-p(2)+1)*(p(3)-p(1)+1);
      lvl=log2(sqrt(patsize/minsize))+1;
      p=[p([2 1]) lvl p([4 3]) lvl+5];
      f=floor(p);
      b=p-[f(1) f(2) f(3) f(1) f(2) f(3)];
      toadd=getaddvec(b).*origw{j}(i);
      if(size(pos{j},1)>1)
        %[col,row,slice]=meshgrid(f(2):f(2)+size(toadd,2)-1,f(1):f(1)+size(toadd,1)-1,f(3):f(3)+size(toadd,3)-1);
        %inds=sub2ind(dim,row(:),col(:),slice(:));
        field2(f(1):f(1)+size(toadd,1)-1,f(2):f(2)+size(toadd,2)-1,f(3):f(3)+size(toadd,3)-1)=max(field2(f(1):f(1)+size(toadd,1)-1,f(2):f(2)+size(toadd,2)-1,f(3):f(3)+size(toadd,3)-1),toadd);
        %fieldtmp(inds)=max(fieldtmp(inds),toadd(:));
        allinds{i}=[f(1),f(1)+size(toadd,1)-1,f(2),f(2)+size(toadd,2)-1,f(3), f(3)+size(toadd,3)-1];%inds;
      else
        try
        field(f(1):f(1)+size(toadd,1)-1,f(2):f(2)+size(toadd,2)-1,f(3):f(3)+size(toadd,3)-1)=field(f(1):f(1)+size(toadd,1)-1,f(2):f(2)+size(toadd,2)-1,f(3):f(3)+size(toadd,3)-1)+toadd;
        catch ex,dsprinterr;end
        linidx=linidx+1;
      end
    end
    if(size(pos{j},1)>1)
      field=field+field2;
      for(i=1:size(pos{j},1))
        f=allinds{i};
        addvec{linidx}=c(field2(f(1):f(2),f(3):f(4),f(5):f(6)))./max(origw{j}(i),eps);%(fieldtmp(allinds{i})./max(origw{j}(i),eps));
        linidx=linidx+1;
      end
      field2(:)=0;
    end
  end
  field=1./max(field,eps);%bsxfun(@max,field,reshape(1/(prod(minsize)*2.^(0:size(field,3)-1),1,1,[])));

  pos=cell2mat(pos);
  origw=cell2mat(origw);
  resw=zeros(size(origw));
  for(i=1:size(pos,1))
    p=pos(i,:);
    patsize=(p(4)-p(2)+1)*(p(3)-p(1)+1);
    lvl=log2(sqrt(patsize/minsize))+1;
    p=[p([2 1]) lvl p([4 3]) lvl+5];
    f=floor(p);
    b=p-[f(1) f(2) f(3) f(1) f(2) f(3)];
    %p=pos(i,:);
    %patsize=(p(4)-p(2)+1)*(p(3)-p(1)+1);
    %lvl=max(log2(sqrt(patsize/minsize))+1,1);
    %for(j=[0,1])
      %lvld=floor(lvl+j);
      %interpw=origw(i)*abs(lvld-lvl);
      %f=floor(p);
      %b=p-[f(1) f(2) f(1) f(2)];
      toadd=getaddvec(b);
      sta=sum(toadd(:));
      if(numel(addvec)>=i && ~isempty(addvec{i}))
        toadd=reshape(addvec{i},size(toadd));
      end
      if(sta>0)
        toadd=toadd./sta;
      end
      try
      resw(i)=resw(i)+(reshape(field(f(1):f(1)+size(toadd,1)-1,f(2):f(2)+size(toadd,2)-1,f(3):f(3)+size(toadd,3)-1),1,[])*toadd(:))*origw(i);
      catch ex,dsprinterr;end
    %end
  end
  if(any(resw>1.000001)),try,error('weightincrease');catch ex, dsprinterr;end,end
  if(any(isnan(resw))),try,error('nan');catch ex, dsprinterr;end,end
  resw=(min(resw,1).*origw);%*normfact;
  resw(ord)=resw;
  if(any(resw<0)),try,error('less than zero');catch ex, dsprinterr;end,end
  catch ex,dsprinterr;end
end
function toadd=getaddvec(b)
      toadd=zeros(ceil(b(3:4)));
      dim=ceil(b(4:6));
      permvec=[];
      for(i=1:3)
        interpv=ones(dim(i),1);
        %interpv(1)=1-b(i);
        %interpv(end)=b(i+3)-numel(interpv)+1;
        permvec=[i permvec];
        if(i>1)
          interpv=permute(interpv,permvec);
        end
        mult{i}=interpv;
      end
      toadd=bsxfun(@times,bsxfun(@times,mult{1},mult{3}),mult{2});
      %toadd(2:end-1,2:end-1)=1;
      %toadd(1,2:end-1)=1-b(1);
      %toadd(end,2:end-1)=b(3)-size(toadd,2)+1;
      %toadd(2:end-1,1)=1-b(2);
      %toadd(2:end-1,end)=b(4)-size(toadd,2)+1;
      %toadd(1,1)=toadd(1,2)*toadd(2,1);
      %toadd(1,end)=toadd(2,end)*toadd(1,end-1);
      %toadd(end,1)=toadd(end,2)*toadd(end-1,1);
      %toadd(end,end)=toadd(end-1,end)*toadd(end,end-1);
end
