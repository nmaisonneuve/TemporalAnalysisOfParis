function pyra = myfeatpyramid(im, type, grid_spacing, feat_size, interval, maxLevel) % patch_size = [y x]
% Compute feature pyramid.
%
% pyra.feat{i} is the i-th level of the feature pyramid.
% pyra.scales{i} is the scaling factor used for the i-th level.
% pyra.feat{i+interval} is computed at exactly half the resolution of feat{i}.
% first octave halucinates higher resolution data.

if ~exist('type', 'var')
    type = 1;
end
if ~exist('grid_spacing', 'var')
    grid_spacing = 8;
end
if ~exist('feat_size', 'var')
    feat_size = 2 * grid_spacing;
end
if ~exist('interval', 'var')
    interval = 5;
end
if ~exist('maxLevel', 'var')
    maxLevel = Inf;
end

sc = 2 ^(1/interval);
imsize = [size(im, 1) size(im, 2)];
max_scale = 1 + floor(log(min(imsize)/(5*grid_spacing))/log(sc));
pyra.feat = cell(min(maxLevel, max_scale),1);
pyra.scale = zeros(min(maxLevel, max_scale),1);

if size(im, 3) == 1
  im = repmat(im,[1 1 3]);
end
im = double(im); % our resize function wants floating point values

for i = 1:interval
  if i > maxLevel
      break;
  end
  scaled = resize(im, 1/sc^(i-1));
  [pyra.feat{i} pyra.gridx{i} pyra.gridy{i}] = myfeatures(type, scaled, grid_spacing, feat_size);
  pyra.scale(i) = 1/sc^(i-1);
  % remaining interals
  for j = i+interval:interval:max_scale
    if j > maxLevel
        break;
    end 
    scaled = reduce(scaled);
    [pyra.feat{j} pyra.gridx{j} pyra.gridy{j}] = myfeatures(type, scaled, grid_spacing, feat_size);
    pyra.scale(j) = 0.5 * pyra.scale(j-interval);
  end
end

keep = true(length(pyra.feat), 1);
for i = 1:length(pyra.feat)
    if isempty(pyra.feat{i})
        keep(i : end) = 0;
    end
end
pyra.feat = pyra.feat(keep);
pyra.scale = pyra.scale(keep);
pyra.gridx = pyra.gridx(keep);
pyra.gridy = pyra.gridy(keep);

for i = 1:length(pyra.feat)
  pyra.gridx{i} = pyra.gridx{i} / pyra.scale(i);
  pyra.gridy{i} = pyra.gridy{i} / pyra.scale(i);
end

pyra.interval = interval;
pyra.imy = imsize(1);
pyra.imx = imsize(2);
