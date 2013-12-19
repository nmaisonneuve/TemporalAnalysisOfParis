%clear;

%config();

%add paths
%addpath(fullfile('./libs/who/'));



%compile features, if needed. Only needs to be done once.
%dirname=pwd;
%cd(fullfile(dirname, 'code', 'features'));
%compile;
%cd(dirname);

%load('data/step2_exp_one_vs_all_period2_v2.mat');



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

%% Testing
test = struct();
for (i = 1:numel(imgs))
  test(i).id = i;
  test(i).im = imgs(i).path;
end

%show positive list
i = 2;
im=imread(pos(i).im);
figure(1);
showboxes(im ,[pos(i).x1 pos(i).y1 pos(i).x2 pos(i).y2]);
pause;

%learn
%params.sbin =8;
%params.whitening = 1;
model=learn_dataset(pos(i), []);
disp(model);
%show HOG
figure(2); showHOG(model.w);

boxes=test_dataset_v2(test, model);

%show detections
im=imread(test(1).im);
figure(3);showboxes(im, boxes{1});
