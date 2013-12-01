[~,nm]=unix('hostname');
distprocconf=struct();
if(numel(strfind(nm,'teragrid'))>0)
   targmachine='local';
   targdir='teragrid';
   tg=1;
   njobs=127;
   unix('echo $PBS_JOBID');
elseif(numel(strfind(nm,'balaton'))>0)
   targmachine='local';
   targdir='hn25';
   tg=0;
   njobs=35;
elseif(numel(strfind(nm,'master'))>0)
   targmachine='master';
   targdir='ebs1';
   tg=0;
   njobs=80;
   %distprocconf=struct('qsubopts','-pe orte 2');
   distprocconf=struct('qsubopts','');%'-l h_vmem=6G');
else
   targmachine='warp.hpc1.cs.cmu.edu';
   targdir='lustre';
   tg=0;
   njobs=150;
   chunksize=1;
   distprocconf=struct('qsubopts','-l nodes=1:ppn=1');
end
