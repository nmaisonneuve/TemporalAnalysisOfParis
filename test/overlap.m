function overlap =  overlap(ax,ay,bx,by)
% Put coordinates into a matrix, each column is a rectangle
X = [ax(:) bx(:)];
Y = [ay(:) by(:)];

% Segments overlap if maxmin < minmax
% Segments are adjacent if maxmin == minmax
% Segments don't overlap if maxmin > minmax
% where
% maxmin = the right-most left edge
% minmax = the left-most right edge
%
% Overlap example:
%      ax(1)--------ax(2)
%            bx(1)----------bx(2)
%
% X = [ax(1) bx(1); ax(2) bx(2)]
% min(X) == [ax(1) bx(1)]
% max(X) == [ax(2) bx(2)]
% max(min) == bx(1)
% min(max) == ax(2)
% bx(1) < ax(2) ==> segments overlap
overlapFunc = @(c) max(min(c)) < min(max(c));

% For a rectangle, both X and Y must overlap
overlap = overlapFunc(X) & overlapFunc(Y);
end