load('/ebs2/tmp.mat');
i=1;
j=2;
myaddpath
addpath('context');
ffinities=contextAffinities(alldataord{i},alldataord{j},ovlweightsord{i},ovlweightsord{j});
