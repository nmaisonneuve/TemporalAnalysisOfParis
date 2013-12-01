function mydssetout(name,base)
  if(nargin<2)
    base='nas';
  end
  global ds;
  ds.conf.prevnm=name;
  if(strcmp(base,'ladoga_no_backups'))
    [blah,compname]=unix('hostname');
    %if(numel(strfind(compname,'ladoga.graphics.cs.cmu.edu'))>0)
    %  nfsstr='';
    %else
      nfsstr='/nfs';
    %end
    dssetout([nfsstr '/ladoga_no_backups/users/cdoersch/france_run/' name '_out']);
  elseif(strcmp(base,'hn45'))
    [blah,compname]=unix('hostname');
    %if(numel(strfind(compname,'ladoga.graphics.cs.cmu.edu'))>0)
    %  nfsstr='';
    %else
      nfsstr='/nfs';
    %end
    dssetout([nfsstr '/hn45/cdoersch/france_run/' name '_out']);
  elseif(strcmp(base,'onega'))
    [blah,compname]=unix('hostname');
      nfsstr='/nfs';
    dssetout([nfsstr '/onega_no_backups/users/cdoersch/france_run/' name '_out']);
  elseif(strcmp(base,'shm'))
    [blah,compname]=unix('hostname');
    mkdir('/dev/shm/cdoersch/');
    dssetout(['/dev/shm/cdoersch/' name '_out']);
  elseif(strcmp(base,'hn25'))
    [blah,compname]=unix('hostname');
    if(numel(strfind(compname,'balaton.graphics.cs.cmu.edu'))>0)
      nfsstr='';
    else
      nfsstr='/nfs';
    end
    dssetout([nfsstr '/hn25/cdoersch/france_run/' name '_out']);
  elseif(strcmp(base,'lustre'))
    [blah,compname]=unix('hostname');
    disp(compname)
    dssetout(['/lustre/cdoersch/france_run/' name '_out']);
  elseif(strcmp(base,'nas'))
    dssetout(['/nfs/nas-3-39/cdoersch/france_run/' name '_out']);
  elseif(strcmp(base,'ebs1'))
    dssetout(['/ebs1/' name '_out']);
    ds.conf.dispoutpath=['/ebs1/display/' name '_out/'];
    mymkdir(ds.conf.dispoutpath);
  elseif(strcmp(base,'teragrid'))
    %if(numel(strfind(compname,'teragrid'))>0)
      [~,scr]=unix('echo $SCRATCH_RAMDISK');
      scr=strtrim(scr);
      disp([scr '/' name '_out']);
      dssetout([scr '/' name '_out']);
    [~,scr]=unix('echo $SCRATCH');
    scr=strtrim(scr);
    ds.dispoutpath=[scr '/' ds.conf.prevnm '_out/'];
    mymkdir(ds.dispoutpath);
    %else
    %end
  else
    disp('mydssetout: base not found!!');
  end
    %ds.dispoutpath=['/nfs/hn45/cdoersch/france_run/' ds.conf.prevnm '_out/'];
    %mkdir(ds.dispoutpath);
  if(numel(strfind(ds.sys.outdir,'lustre'))>0 || numel(strfind(ds.sys.outdir,'nas-3-39'))>0)
    ds.dispoutpath=['/nfs/hn45/cdoersch/france_run/' ds.conf.prevnm '_out/'];
    mymkdir(ds.dispoutpath);
  end
end
