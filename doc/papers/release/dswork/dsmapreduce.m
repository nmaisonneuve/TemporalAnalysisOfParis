function dsrundist(mapcommand,reducecommand,mapvars,mapreducevars,conf,conf1,conf2)
  global ds;
  dssave;
  if(~exist('conf','var'))
    conf=struct();
  end
  if(~exist('conf1','var'))
    conf1=struct();
  end
  if(~exist('conf2','var'))
    conf2=struct();
  end
  if(~iscell(mapreducevars))
    mapreducevars={mapreducevars};
  end
  for(i=1:numel(mapreducevars))
    mapreducevars{i}=dsabspath(mapreducevars{i});
    if(dsfield(['ds.sys.savestate' mapreducevars{i}(4:end)]))
      savest=eval(['ds.sys.savestate' mapreducevars{i}(4:end)]);
      if(~iscell(savest))
        error(['mapreduce variable ' mapreducevars{i} ' exists and is not a cell']);
      end
      if(numel(savest)>=2 && any(savest{2}(:)))
        error(['mapreduce variable ' mapreducevars{i} ' is non-empty']);
      end
    end
    %mapreducevars{i}=mapreducevars{i}(5:end);
  end
  %if(~dsbool(ds.sys.distproc,'readytorun'))
    dsdistprocconf(dsoverrideconf(conf,conf1));
    dsdistprocmapvars(mapvars);
    dsresetdistproc;
    if(dsfield(conf,'forcerunset'))
     ds.sys.distproc.forcerunsetlater=conf.forcerunset;
     ds.sys.distproc.reducemodulo=numel(conf.forcerunset);
    end
    ds.sys.distproc.donemap=0;
    ds.sys.distproc.mapvars=mapreducevars;
    ds.sys.distproc.reducelatervars=mapreducevars;
    ds.sys.distproc.command=mapcommand;
    ds.sys.distproc.reducelatercommand=reducecommand;
    ds.sys.distproc.reducelaterconf=dsoverrideconf(conf,conf2);
    ds.sys.distproc.mapreducing=1;
    ds.sys.distproc.reducestarted=0;
    ds.sys.distproc.readytorun=1;
    if(isfield(ds.sys.distproc,'forcerunset'))
      ds.sys.distproc=rmfield(ds.sys.distproc,'forcerunset');
    end
  uhosts=unique(ds.sys.distproc.hostname);
  for(i=1:numel(uhosts))
    unix(['ssh ' uhosts{i} ' "find ''' ds.sys.distproc.localdir ''' -name ds.* -print0 | xargs -0 rm"']);%' rm "' ds.sys.distproc.localdir '/ds.*"']);
    ['ssh ' uhosts{i} ' "find ''' ds.sys.distproc.localdir ''' -name ds.* -print0 | xargs -0 rm"']%' rm "' ds.sys.distproc.localdir '/ds.*"']);
  end
  %end
  dscompletemapreduce(1);
  %if(~dsbool(ds.sys.distproc,'donemap'))
  %dsdistprocmgr;
  %ds.sys.distproc.mapvars=ds.sys.distproc.reducelatervars;

  %ds.sys.distproc.readytorun=0;
end
