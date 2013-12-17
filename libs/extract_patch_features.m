function warped = extract_patch_features(patches, params)



heights = double([patches(:).y2]' - [patches(:).y1]' + 1);
widths = double([patches(:).x2]' - [patches(:).x1]' + 1);
siz = [round(heights/params.sbin) round(widths/params.sbin)];
siz = max(siz,1);

cropsize = (siz+2) * params.sbin;
%cropsize = (siz) * params.sbin; %no padding
%cropsize = (ones(size(siz,1),2)*10) * params.sbin; %no padding

pixels = double(siz * params.sbin);
warped  = [];
lastreadimg='';
numpos = numel(patches);

if (params.whitening)
  disp('loading background for whitening HOG');
  bg_ws = load(bg_file_name);
  nys = unique(siz(:,1));
  nxs = nys;
  
  % for each patch size, we load the whiten params
  for (i = 1:numel(nys))
    tic;
    fprintf('\n loading background for patch hog size %d %d',nxs(i), nys(i));
    [R,neg] = whiten(bg_ws.bg,nxs(i),nys(i));
    bg(i).scale = nys(i);
    bg(i).R = R;
    bg(i).neg = neg; 
    toc;
  end
  
end



for i = 1:numpos
  
  if(~strcmp(patches(i).im, lastreadimg))	    
  	im = imread(patches(i).im);
    lastreadimg=patches(i).im;
  end

  %padx = params.sbin * widths(i) / pixels(2);
  %pady = params.sbin * heights(i) / pixels(1);
  padx = 0;
  pady = 0;
  x1 = round(double(patches(i).x1)-padx);
  x2 = round(double(patches(i).x2)+padx);
  y1 = round(double(patches(i).y1)-pady);
  y2 = round(double(patches(i).y2)+pady);

  window = subarray(im, y1, y2, x1, x2, 1);
  disp(size(window));
  disp(cropsize(i,:));
  wind = imresize(window, cropsize(i,:), 'bilinear');
  disp(size(wind));
  imshow(wind);
  figure();
  
  % extract feature
  
  feat = features(double(wind),params.sbin);
  disp(size(feat));
   
  if (params.whitening)
    
  
    
    ny = siz(i,1);
    nx = siz(i,2);
    nf = size(feat,3) - 1;
   
    bg_idx = find([bg.scale] == nx);
     fprintf('\n %d %d %d %d', [nx ny nf], bg_idx);
     disp(bg);
    R = bg(bg_idx).R;
    neg = bg(bg_idx).neg;
    
    % fprintf('\nnormal features');
    % showHOG(feat);
    % pause;

    %remove padding trunc feats
    f1=feat(:,:,1:end-1);
    disp(size(f1));
    %convert into column vector
    f1=f1(:);

    %center and multiply by R^{-T}
    fwh=R'\(f1-neg);

    %reshape
     fwh=reshape(fwh, [ny nx nf]);

    fprintf('\nwihtened features');
    figure();
    showHOG(f1, fwh);

  end
  
end


% if(dsbool(params,'useColor'))
%   im2=RGB2Lab(im).*.0025;
%   if(dsbool(params,'extraColor'))
%     im2=im2.*25;
%   end
% end

  function B = subarray(A, i1, i2, j1, j2, pad)

    % B = subarray(A, i1, i2, j1, j2, pad)
    % Extract subarray from array
    % pad with boundary values if pad = 1
    % pad with zeros if pad = 0

    dim = size(A);
    %i1
    %i2
    is = i1:i2;
    js = j1:j2;

    if pad,
      is = max(is,1);
      js = max(js,1);
      is = min(is,dim(1));
      js = min(js,dim(2));
      B  = A(is,js,:);
    else
      % todo
    end

  end
end