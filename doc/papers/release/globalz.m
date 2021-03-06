function res=globalz(setnum)
    if(nargin<1||setnum==1)
      ctrelname='petr/GSwDownloader/data/cutouts/000/';
      res.datasetname='dataset.mat';
    elseif(setnum==2)
      ctrelname='petr/GSwDownloader/data2/cutouts/';
      res.datasetname='dataset2.mat';
    elseif(setnum==4)
      ctrelname='cvpr2010/';
      res.datasetname='dataset4.mat';
    elseif(setnum==5)
      ctrelname='petr/GSwDownloader/data/cutouts/000/';
      res.datasetname='dataset_negset.mat';
    elseif(setnum==6)
      ctrelname='petr/GSwDownloader/data/cutouts/000/';
      res.datasetname='dataset_multiscale.mat';
    elseif(setnum==7)
      ctrelname='petr/GSwDownloader/data2/cutouts/';
      res.datasetname='dataset_parnyc.mat';
    elseif(setnum==8)
      ctrelname='petr/GSwDownloader/data2/cutouts/';
      res.datasetname='dataset_parnycsub.mat';
    elseif(setnum==9)
      ctrelname='petr/GSwDownloader/data2/cutouts/';
      res.datasetname='dataset2_sub.mat';
    elseif(setnum==10)
      ctrelname='petr/GSwDownloader/data7/cutouts/';
      res.datasetname='dataset_xtrapraglon.mat';
    elseif(setnum==11)
      ctrelname='petr/GSwDownloader/data7/cutouts/';
      res.datasetname='dataset2_arrondized.mat';
    elseif(setnum==12)
      ctrelname='paintings/';
      res.datasetname='dataset_paintings.mat';
    elseif(setnum==13)
      ctrelname='petr/GSwDownloader/data8/cutouts/';
      res.datasetname='dataset_pitch.mat';
    elseif(setnum==14)
      ctrelname='petr/GSwDownloader/data9/cutouts/';
      res.datasetname='dataset_up.mat';
    elseif(setnum==15)
      ctrelname='petr/GSwDownloader/data10/';
      res.datasetname='dataset_france.mat';
    elseif(setnum==16)
      ctrelname='petr/GSwDownloader/data7/cutouts/';
      res.datasetname='dataset_manhattan.mat';
    elseif(setnum==17)
      ctrelname='indoor67/';
      res.datasetname='dataset_indoor67.mat';
    elseif(setnum==18)
      ctrelname='indoor67/';
      res.datasetname='dataset_indoor67_mini.mat';
    elseif(setnum==3)
      ctrelname='ecpfacades/ecpfacades/';
      res.datasetname='dataset3.mat'; 
    elseif(setnum==19)
      ctrelname='indoor67/';
      res.datasetname='dataset_indoor67_jpg.mat';
    elseif(setnum==20)
      ctrelname='indoor67/';
      res.datasetname='dataset_indoor67_test.mat';
    elseif(setnum==21)
      ctrelname='SUN397/';
      res.datasetname='dataset_suns_hierarchy.mat';
    elseif(setnum==22)
      ctrelname='VOC2011/JPEGImages/';
      res.datasetname='dataset_pascal.mat';
    elseif(setnum==23)
      ctrelname='indoor67/';
      res.datasetname='dataset_indoor67_withflip.mat';
    else
      disp('no such dataset');
      return;%throw exception
    end
    %ctrelname='GRAZ_02_trim/';
    [blah,compname]=unix('hostname');
    if(numel(strfind(compname,'warp.hpc1.cs.cmu.edu'))>0||numel(strfind(compname,'compute-'))>0)
      res.root='/nfs/baikal/cdoersch/im2gps2';
      res.tmpdir='/nfs/ladoga_no_backups/users/cdoersch/';
    elseif(numel(strfind(compname,'ladoga.graphics.cs.cmu.edu'))>0)
      res.root='/nfs/hn45/cdoersch/im2gps2';
      res.tmpdir='/ladoga_no_backups/users/cdoersch/';
    elseif(numel(strfind(compname,'gs10251.sp.cs.cmu.edu'))>0)
      res.root='/usr0/cdoersch/im2gps2';
    elseif(numel(strfind(compname,'onega.graphics.cs.cmu.edu'))>0)
      res.root='/nfs/hn45/cdoersch/im2gps2';
      res.tmpdir='/no_backups/users/cdoersch/';
    elseif(numel(strfind(compname,'balaton.graphics.cs.cmu.edu'))>0)
      res.root='/nfs/baikal/cdoersch/im2gps2';
      res.tmpdir='/nfs/ladoga_no_backups/users/cdoersch/';
    elseif(numel(strfind(compname,'cdoersch-laptop'))>0)
      res.root='/shared/docs/research/cdoersch/im2gps2';
    elseif(numel(strfind(compname,'teragrid'))>0)
      res.root='/usr/users/7/cdoersch/data';
    elseif(numel(strfind(compname,'master'))>0)
      res.root='/code/data';
    end
    %if(numel(strfind(compname,'ladoga.graphics.cs.cmu.edu'))>0)
    %  res.outdir='/hn45/cdoersch/';
    %else
    %  res.outdir='/nfs/hn45/cdoersch/';
    %end
    disp(compname)
    res.cutoutdir=[res.root filesep ctrelname];
    res.imgsurl=['http://baikal.graphics.cs.cmu.edu/cdoersch/im2gps2' filesep ctrelname];
end
