clear;

%config();

%add paths
%addpath(fullfile('./libs/who/'));



%compile features, if needed. Only needs to be done once.
%dirname=pwd;
%cd(fullfile(dirname, 'code', 'features'));
%compile;
%cd(dirname);

clear;
load('data/step2_exp_one_vs_all_period1.mat');

%% Training
% We will train a model from a single instance.
pos = struct();
for (i = 1:size(patches,1))
pos(i).im=imgs(patches(i,:)).path;
pos(i).x1=patches(i,4);
pos(i).y1=patches(i,2);
pos(i).x2=patches(i,5);
pos(i).y2=patches(i,3);
end

%show positive list
im=imread(pos(1).im);
figure(1);showboxes(im ,[pos(1).x1 pos(1).y1 pos(1).x2 pos(1).y2]);

%learn
model=learn_dataset(pos, [], '1');

%show HOG
figure(2); showHOG(model.w);

%% Testing
test(1).im=imgs(patches(1,:)).path;
boxes=test_dataset_v2(test, model, '1');

%show detections
im=imread(test(1).im);
figure(3);showboxes(im, boxes{1});
