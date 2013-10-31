%load metadata
disp('loading csv files');
fid = fopen('test1.csv');
imgs = textscan(fid, ['%s %f'], 'HeaderLines',1,'Delimiter',',','CollectOutput',1);
imgs = struct('path', imgs{1}, 'label' , num2cell(imgs{2}));
fclose(fid);


% collecting image size (may varying)
% (+ checking implicitly the availability of images)
disp('collecting the size of images...');
for i = 1: numel(imgs)
   if mod(i,100) == 0 
     fprintf('\ncollecting image size of %dth image',i); 
   end
   I = imread(imgs(i).path);
   imgs(i).imsize = size(I);
end

save('carldata','imgs');