iter = 50000;
A = zeros(1,iter);
sz = 55;

tic;
for i=1:iter
  A(i)= max(svd(rand(sz)));
end
toc;


A = zeros(1,iter);

matlabpool open 2
tic;
parfor i=1:iter
  A(i)= max(svd(rand(sz)));
end
toc;
matlabpool close;

