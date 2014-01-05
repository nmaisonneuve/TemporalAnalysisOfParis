
clear;
% load configuration
config();

addpath(fullfile('./libs/voc'));



%load imgs data
load('data/paris_data.mat');

ds.imgs = imgs;

I = im2double(imread(imgs(1).path));