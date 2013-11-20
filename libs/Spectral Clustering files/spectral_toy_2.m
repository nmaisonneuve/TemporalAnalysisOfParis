function spectral_toy_2
% spectral_toy_2 - a toy experiment that generates a simple graph with two
% densely connected subgraphs with sparse interconnections, and then plots
% the values of the eigenvector 

% Written by Jeremy Watt
% Contact: jermwatt@gmail.com

%%% Random block-diagonal matrix generation testing %%%

dimW = 500;
num_blocks = 2;  % You'll actually get num_blocks + 1 blocks

% Generate block diagonal matrix
W = zeros(dimW);
block_corners = datasample(1:size(W,1)-1,num_blocks,'Replace',false);
inds = sort(block_corners);
gaps = [inds(1)];
for i = 2:length(inds)
   gaps = [gaps  inds(i) - inds(i-1)];
end
gaps = [gaps (dimW - inds(end))];
blocks = cell(length(gaps));

for i = 1:length(gaps)
   blocks{i} = ones(gaps(i)); 
end
W = blkdiag(blocks{:});
disp(size(W));
% Print adjacency matrix 
figure(1)
spy(W)
title('input adjacency matrix')
xlabel('')

% Perform spectral clustering
Y = spectral(W,3);

% Print out the first eigenvector
figure(2)
plot(Y(:,1),'r');
hold on
plot(Y(:,2),'g');
hold on
plot(Y(:,3),'b');
legend('eig-vec 1','eig-vec 2','eig-vec 3')
title('eigenvectors for clean adjacency matrix')

%%% Add sparse interconnecting and missing links %%%
error_links = 200; % Number of sparse interconnections to add
missing_links = 20000; % Number of links to remove from the blocks
H = triu(W,1);
G = tril(10*ones(dimW));
H = H + G;
ind = find(H == 0);
a = datasample(1:length(ind), error_links,'Replace',false);
H(ind(a)) = -1;
ind = find(H == 1);
a = datasample(1:length(ind), missing_links,'Replace',false);
H(ind(a)) = -2;
for i = 1:dimW
    for j = i:dimW
       if H(i,j) == -1
          W(i,j) = 1;
          W(j,i) = 1;
       end
       if H(i,j) == -2
          W(i,j) = 0;
          W(j,i) = 0;
       end
    end
end

figure(3)
spy(W)
title('noisy adjacency matrix')
xlabel('')

% Perform spectral clustering
Y = spectral(W,3)

% Print out the first eigenvector
figure(4)
plot(Y(:,1),'r');
hold on
plot(Y(:,2),'g');
hold on
plot(Y(:,3),'b');
legend('eig-vec 1','eig-vec 2','eig-vec 3')
title('eigenvectors for noisy adjacency matrix')


    function Y = spectral(W,K) % spectral clustering function
       
    % Generate degree matrix
    D = zeros(dimW);
    for i = 1:dimW
       D(i,i) = sum(W(:,i)); 
    end

    % Factorize the Laplacian
    L = D - W;
    [Y,lam] = eig(L);
    lam = diag(lam);
    ind = find(lam < 0);
    lam(ind) = 0;
    [val,ind] = sort(lam);
    keepers = ind(1:K);
    Y = Y(:,keepers);    % Eigenvectors associated smallest K eigenvalues 
        
    end
end
    
    








