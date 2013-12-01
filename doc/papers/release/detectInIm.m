function [dets,feats]=detectInIm(model,imid,conf)
  if(~exist('conf','var'))
    conf=struct();
  end
  if(~dsfield(conf,'thresh'))
    conf.thresh=-Inf;
  end
  conf2=conf;
  conf2.thresh=-model.rho+conf.thresh;
  boxid=[];
  if(exist('bestInImbb_context','file'))%'file' means 'function' apparently
    conf2.detrid=model.id;
    [pos,dist,clustid,feats,flip,boxid]=bestInImbb_context(model.w,imid,conf2);
  else
    [pos,dist,clustid,feats,flip,boxid]=bestInImbb(model.w,imid,conf2);
  end
  dist=dist+model.rho(clustid);
  if(isempty(dist))
    dets=zeros(0,9);
  else
    dets=[pos.x1,pos.y1,pos.x2,pos.y2,dist,model.id(clustid),repmat(imid,numel(dist),1),flip,boxid];
  end
end
