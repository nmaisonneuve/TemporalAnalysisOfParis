function conf=detectionconfforimg(imid)
  global ds;
  annot=getannot(imid);
  conf=struct();
  if(any(ismember(annot.label,ds.conf.posclass))||any(ismember(annot.label,ds.conf.ignoreclass)))
    conf.detsforclass=ds.conf.posclass;
  end
end
