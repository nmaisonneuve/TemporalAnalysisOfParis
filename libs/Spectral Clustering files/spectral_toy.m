function spectral_toy(K,toy,epsilon,kn)
% spectral_toy - a toy experiment that compares spectral clustering and
% K-means with two adjency matrix functions - epsilon neighborhood and
% k-nearest neighbors.

% After initiating the code from the MATLAB command line a blank piece of
% plane segment will pop up.  You get to work placing as many points 
% in however many configurations you want.  When you've placed all the 
% points you care to place, press enter.

% Spectral clustering and K-means will then be run on the set of points you
% chose, and the output clusters (color-coded) will pop up in a figure, as
% well as a picture of the final graph and a plot of the adjacency matrix.

% One note: Because this is just a toy I've limited the maximum number of distinct
% clusters you can make to 8.  So if your configuration is found to have more than 8
% clusters you'll get an error.  You add to the number of possible clusters
% available by just adding custom colors to the "colors" vector.

% INPUTS:
% K - number of clusters for spectral clustering and K-means
% toy - choose between epsilon neighborhood weighting (toy = 0) and KNN
% weighting (toy = 1)
% epsilon - size of neighborhood in the epsilon adjacency matrix scheme 
% -A good value for playing purposes is epsilon = 1.5
% kn - the number of neighbors in KNN adjaceny matrix construction


% Written by Jeremy Watt
% Contact: jermwatt@gmail.com

%%% User generated points to cluster %%%
format long
stop = 0;
axis([0 10 0 10])    % Set viewing axes
x = [];
y = [];
while stop == 0
    hold on
    [a,b]=ginput(1);
    if sum(size(a)) > 0 & (a > 0 & a < 10 & b > 0 & b < 10)
        x = [x ; a];
        y = [y ; b];
        scatter(a,b,'fill','b')
    else
        stop = 1;
    end  
end
close(gcf)
pts = [x y];
n = size(pts,1);

%%% Produce adjacency matrix %%%
W = eye(n);
if toy == 0  % Epsilon nearest neighbor adjacency matrix
    for i = 1:size(pts,1)
        for j = i:size(pts,1)
            dist = norm(pts(i,:) - pts(j,:));
            if dist < epsilon
                W(i,j) = 1;
                W(j,i) = 1;
            end
        end
    end
else  % KNN adjacency matrix
    for i = 1:n
        s = repmat(pts(i,:),n,1);
        d = pts - s;
        e = diag(d*d');
        [val,ind] = sort(e);
        ind(1) = [];
        nbrs = ind(1:kn);
        W(i,nbrs) = 1;
        W(nbrs,i) = 1;
    end
end

% Print original and block-diagonalized adjacency matrix
figure(1)
subplot(1,2,1)
spy(W)
title('input adjacency matrix')
xlabel('')
subplot(1,2,2)
c = symrcm(W);
W = W(c,c);
spy(W)
title('block-diagonalized adjacency matrix')
xlabel('')

%%% Perform spectral clustering %%%
pts = pts(c,:);
x = zeros(n,1);

% Generate degree matrix
D = zeros(size(pts,1));
for i = 1:size(pts,1)
   D(i,i) = sum(W(:,i)); 
end

% Factorize the Laplacian
L = D - W;
[Y,lam] = eig(L);
lam = diag(lam);
[val,ind] = sort(lam);
keepers = ind(1:K);
Y = Y(:,keepers);    % Eigenvectors associated smallest K eigenvalues

colors = ['r','g','k','m','y','c','k','b']; % add custom colors to this vector to increase number of possible clusters
if K > 8
    fprintf('ERROR!! DOES NOT COMPUTE!!! OH THE HUMANITY!!! \nJust kidding - you have just put in too many clusters for this toy to\nvisualize very well. \nNo big deal. \nTry another round and remember to use 8 or fewer clusters!\n');
    return
end

% Cluster rows of eigenvector matrix of L corresponding to K smallest
% eigevnalues
[D,x] = kmeans(Y,K);

% Print spectral clustering results
figure(2)
subplot(1,2,1)
for j = 1:n
    hold on
    scatter(pts(j,1),pts(j,2),'fill',colors(x(j)))
end

axis([0 10 0 10])    % Set viewing axes
title('Spectral clustering result')

%%% Run K-means on input data %%%
[D,x] = kmeans(pts,K);
        
% Plot K-means results
subplot(1,2,2)
for k = 1:K
    hold on
    ind = find(x == k);
    scatter(pts(ind,1),pts(ind,2),'fill',colors(k))
end
hold on
scatter(D(:,1),D(:,2),100,'fill','b');
axis([0 10 0 10])    % Set viewing axes
title('K-means clustering result')

% Plot points with edge connections 
figure(3)
scatter(pts(:,1),pts(:,2),75,'fill','b')

for i = 1:n
    for j = i:n
        if W(i,j) == 1 & i ~= j
            hold on
            axis([0 10 0 10])    % Set viewing axes
            x = [pts(i,1) pts(j,1)];
            y = [pts(i,2) pts(j,2)];
            line(x,y,'Color','m','LineWidth',1.025)
        end
    end
end
title('Input points with edges from adjacency function')
axis([0 10 0 10])    % Set viewing axes


    % Performs K-means on input data matrix Y, returning centroids D and
    % assignment vector x
    function [D,x] = kmeans(Y,K) 
    cand = unique(round(10000*Y)/10000,'rows');
    c = datasample(cand,K,'Replace',false); % pick K random input pts as initial centroids
    D = c;
    x = zeros(size(Y,1),1);
    D_old = inf*ones(size(D));
    count = 1;
    while norm(D - D_old) > 0.00001 & count < 500 
        D_old = D;
        % Assign points to clusters
        for i = 1:n
            min = inf;
            for k = 1:K
                dist = norm(Y(i,:) - D(k,:));
                if dist < min
                    min = dist;
                    x(i) = k;
                end
            end
        end

        % Update centroid locations
        for k = 1:K
           ind = find(x == k);
           if length(ind) == 1
               D(k,:) = Y(ind,:);
           else
               D(k,:) = mean(Y(ind,:)); 
           end
        end

        count = count + 1;
    end 
        
    for i = 1:n
            min = inf;
            for k = 1:K
                dist = norm(Y(i,:) - D(k,:));
                if dist < min
                    min = dist;
                    x(i) = k;
                end
            end
        end    
    end

end
    
    








