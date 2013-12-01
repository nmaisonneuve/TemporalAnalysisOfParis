function dsrundist(command,mapvars,conf)
  global ds;
  if(~exist('conf','var'))
    conf=struct();
  end
  dsdistprocconf(conf);;
  dsdistprocmapvars(mapvars);

  ds.sys.distproc.command=command;
  dsresetdistproc;
  if(dsfield(conf,'forcerunset'))
     ds.sys.distproc.forcerunset=conf.forcerunset;
  end
  dsdistprocmgr(1);
end
