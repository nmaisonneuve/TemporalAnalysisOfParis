function res=getannot(imid)
  global ds;
  bbs=dsload('.ds.bboxes{ds.conf.currimset}');
  inds=find(bbs.imidx==imid);
  res=effstridx(bbs,inds);
  res.boxid=inds;
end
