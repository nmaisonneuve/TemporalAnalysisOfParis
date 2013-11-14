path = '/Users/nico/Documents/MATLAB/data/images/period_6/13013_50005.jpg';
I = imread(path);
rect = [1180 1   60    80];
disp(rect);
disp(size(I));
I2 = imcrop(I,rect);
disp(size(I2));
    