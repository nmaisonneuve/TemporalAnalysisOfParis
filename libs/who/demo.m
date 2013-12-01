%add paths
addpath(genpath(fullfile(pwd, 'code')));

%compile features, if needed. Only needs to be done once.
%dirname=pwd;
%cd(fullfile(dirname, 'code', 'features'));
%compile;
%cd(dirname);

%% Training
% We will train a model from a single instance.
pos(1).im='train.jpg';
pos(1).x1=70;
pos(1).y1=202;
pos(1).x2=255;
pos(1).y2=500;

%show positive list
im=imread(pos(1).im);
figure(1);showboxes(im ,[pos(1).x1 pos(1).y1 pos(1).x2 pos(1).y2]);

%learn
model=learn_dataset(pos, [], '1');

%show HOG
figure(2); showHOG(model.w);

%% Testing
test(1).im='test.jpg';
boxes=test_dataset(test, model, '1');

%show detections
im=imread(test(1).im);
figure(3);showboxes(im, boxes{1});
