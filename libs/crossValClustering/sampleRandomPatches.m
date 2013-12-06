%Edit: Carl Doersch (cdoersch at cs dot cmu dot edu) to use dswork.
function [patches, patFeats, probabilities] = sampleRandomPatches(pos,imgs, params)

% Samples random patches. 
% Sampling is biased to reduce selection of blank patches.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

samplelimit = params.seed_patches_per_image;
  
%global ds;

levelFactor = params.levelFactor;
img_path = imgs(pos).path;

%data = pos;
%pos = pos.annotation;
%rand('seed',1000*pos);

I = im2double(imread(img_path));%imread([ds.conf.gbz{ds.conf.currimset}.cutoutdir ds.imgs(pos).fullpath]));

pyramid = constructFeaturePyramidForImg(I, params);

[features, levels, indexes] = unentanglePyramid(pyramid, params);

% converting into a size regular size?
if(params.imageCanonicalSize ==-1)
  IS=I;
  scale=1;
else
[IS, scale] = convertToCanonicalSize(I, params.imageCanonicalSize);
end
 
[rows, cols, ~] = size(IS);

%fprintf('\n size image %d x %d', size(I,1), size(I,2));
%fprintf('\n size of the canonical image %d x %d', rows, cols);
 
%imshow(IS);
IG = getGradientImage(IS);
%imshow(IG);


% select only a subset of levels / scales
selLevels = 1 : params.scaleIntervals/2 : length(pyramid.scales);
levelScales = pyramid.scales(selLevels);
numLevels = length(selLevels);


  
[prSize, pcSize, ~] = getCanonicalPatchHOGSize(params);

patches = [];
patFeats = [];
probabilities = [];

basenperlev=pyramid.features{selLevels(end)};
basenperlev=(basenperlev(1)-prSize+1)*(basenperlev(2)-pcSize+1);

for i = 1 : numLevels
  % size of the patch at this level
  levPatSize = floor(params.patchCanonicalSize .* levelScales(i));
  
  if(params.sampleBig)
    numLevPat=floor(basenperlev/levelFactor);
  else
    numLevPat = floor((rows / (levPatSize(1) / levelFactor)) * ...
      (cols / (levPatSize(2) / levelFactor))*2);
  end
  
  %fprintf('\n %d patches of %dx%d generated for scale %s', numLevPat,levPatSize(1),levPatSize(2), num2str(levelScales(i)));
  
  levelPatInds = find(levels == selLevels(i));
  if numLevPat <= 0
    continue;
  end
  
  IGS = IG;
  pDist = getProbDistribution(IGS, levPatSize);
  pDist1d = pDist(:);
  randNums = getRandForPdf(pDist1d, numLevPat);
  probs = pDist1d(randNums);
  [IY, IX] = ind2sub(size(IGS), randNums);
  IY = ceil(IY ./ (levelScales(i) * params.sBins));
  IX = ceil(IX ./ (levelScales(i) * params.sBins));
  
  [nrows, ncols, ~] = size(pyramid.features{selLevels(i)});
  IY = IY - floor(prSize / 2);
  IX = IX - floor(pcSize / 2);
  xyToSel = IY>0 & IY<=nrows-prSize+1 & IX>0 & IX<=ncols-pcSize+1;
  IY = IY(xyToSel);
  IX = IX(xyToSel);
  probs = probs(xyToSel);
  inds = sub2ind([nrows-prSize+1 ncols-pcSize+1], IY, IX);
  [inds, m, ~] = unique(inds);
  probs = probs(m);
  
  selectedPatInds = levelPatInds(inds);
  
  % create metadata of all the patches
  metadata = getMetadataForPositives(selectedPatInds, levels,...
    indexes, prSize, pcSize, pyramid, pos, imgs(pos));

  
  feats = features(selectedPatInds, :);
  if ~isempty(metadata)
    

    
    % remove overlapping patches (a patch overlapping a previous one is removed)
    patInds = cleanUpOverlappingPatches(metadata, ...
      params.patchOverlapThreshold, probs);
   % fprintf('\nafter clean overlapping %d on %d initial patches',numel(patInds), numel(metadata));
    
    % Tree oclusion: remove patch with too much green inside
    % TODO
    
    % patInds = 1:numel(metadata);
    patches = [patches; metadata(patInds)'];
    patFeats = [patFeats; feats(patInds, :)];
    probabilities = [probabilities; probs(patInds)];
  end
  
 % disp(size(patches,2));
end
  if(samplelimit~=-1)
    inds=randperm(numel(patches));
    inds=inds(1:min(numel(inds),samplelimit));
    patches=patches(inds);
    patFeats=patFeats(inds,:);
    probabilities=probabilities(inds);
  end
end

function patInds = cleanUpOverlappingPatches(patches, thresh, probs)

    % sort patch per gradient probability (most interesting first)
    [~, probInds] = sort(probs,1, 'descend');
    
patInds = zeros(1, length(patches));
indCount = 0;

mask = zeros(patches(1).size.nrows, patches(1).size.ncols);
%[rows, columns] = size(mask);
%fprintf('\nClean overlapping patches: row: %d x col: %d',rows, columns);

nr = patches(1).x2 - patches(1).x1 + 1;
nc = patches(1).y2 - patches(1).y1 + 1;

%fprintf('\n row: %d x col: %d', nr, nc);

patchArea = nr * nc;
for i = 1 : numel(probInds)
  p = patches(probInds(i));
  %fprintf('\n %d, %d,%d, %d',p.x1,p.x2, p.y1,p.y2); 
  subMaskArea = sum(sum(mask(p.x1:p.x2, p.y1:p.y2)));
  if subMaskArea / patchArea > thresh
    continue;
  end
  mask(p.x1:p.x2, p.y1:p.y2) = 1;
  indCount = indCount + 1;
  patInds(indCount) = probInds(i);
end
patInds = patInds(1:indCount);
patInds = sort(patInds);
end


function ext = getVerticalExtent(obj)
  [x,y] = getLMpolygon(obj.polygon);
  ext = max(y) - min(y) + 1;
end

function [cx cy] = getCenter(obj, data)
  bb = getBoundingBox(obj, data.annotation);
  cx = (bb(1) + bb(3)) / 2;
  cy = (bb(2) + bb(4)) / 2;
end

function I1 = getGradientImage(I)
  [GX, GY] = gradient(I);
  I1 = sum(abs(GX), 3) + sum(abs(GY), 3);
  I1 = I1.^2;
end

function dist = getProbDistribution(I, pSize)
  h = fspecial('gaussian', pSize, min(pSize)/3);
  I = imfilter(I, h);
  dist = I ./ sum(sum(I));
end
