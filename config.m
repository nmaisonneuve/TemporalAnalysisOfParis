
rand('seed',1234);
rng('default'); % For reproductability

%[debug] format for output display (to mix integer + float)
format shortG;

addpath(fullfile('./libs/crossValClustering/'));
addpath(fullfile('./libs/MinMaxSelection/'));
%addpath(fullfile('./libs/hog/'));
addpath(fullfile('./libs/jsonlab/'));
%addpath(fullfile('./libs/pf-segmentation/'));
addpath(fullfile('./libs/'));
addpath(fullfile('./libs/tools/'));
addpath(fullfile('./libs/visualisation/'));
addpath(fullfile('./libs/co-occurrence/'));
addpath(genpath('./libs/who/'));
% (optional) add unit tests directory to run some tests/debug
addpath(fullfile('./test/'));

%parallel computing : opening 4 workers 
if (matlabpool('size') == 0)
  matlabpool(3);
end