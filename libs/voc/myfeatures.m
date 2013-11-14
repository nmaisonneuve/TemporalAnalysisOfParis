function [feat gridx gridy] = myfeatures(type, im, grid_spacing, feat_size)
    if ~exist('feat_size', 'var')
        feat_size = 2 * grid_spacing;
    end
    if mod(feat_size, grid_spacing) ~= 0
        error('feat_size must be a multiple of grid_spacing.');
    end
    
    % yeah it's crappy, its because I want that every setting agrees with HOGs
    [gridx gridy] = meshgrid((grid_spacing * 3 / 2 : grid_spacing : (size(im, 2) - grid_spacing)), ...
                             (grid_spacing * 3 / 2 : grid_spacing : (size(im, 1) - grid_spacing)));
    
    if type == 1 % HOG
        if feat_size ~= 2 * grid_spacing;
            error('Not supported.');
        end
        hog = features(im, grid_spacing);
        feat = hog(:, :, 1 : 31); 
        
    elseif type == 2 % SIFT 
        feat = double(dense_sift(sameAsHOG(im, feat_size), feat_size, grid_spacing));
        
    elseif type == 3 % HOG + COLORNAME
        if feat_size ~= 2 * grid_spacing;
            error('Not supported.');
        end
        
        hog = features(im, grid_spacing);
        hog = hog(:, :, 1 : 31);
        
        colorname = imresize(im2c(im), [size(hog, 1) size(hog, 2)], 'bilinear');
        
        feat = cat(3, colorname, hog);
        
    elseif type == 4 % SIFT + COLORNAME
        I = sameAsHOG(im, feat_size);
        if size(I, 3) == 1
            I = repmat(I, [1 1 3]);
        end
        
        sift = dense_sift(I, feat_size, grid_spacing);
        sift = double(sift);
        dim = feat_size / grid_spacing;
        colorname = imresize(im2c(I), [size(sift, 1) size(sift, 2)] + dim - 1, 'bilinear');
        colorname = imfilter(colorname, ones(dim));
        colorname = colorname(floor(dim / 2) : end - ceil(dim / 2), ...
                              floor(dim / 2) : end - ceil(dim / 2), :);
        colorname = bsxfun(@rdivide, colorname, sum(colorname, 3));
        
        feat = cat(3, colorname, sift);
        
    elseif type == 5 % HOG non oriented
        if feat_size ~= 2 * grid_spacing;
            error('Not supported.');
        end
        hog = features(im, grid_spacing);
        feat = hog(:, :, 19 : 27);
        
    else
        error('Wrong type');
    end
end

% Resize img so that dense_sift returns the same number of feature as
% "features"
function I = sameAsHOG(I, feat_size)
    rm = feat_size/8;
    if rm ~= round(rm)
        error('Patch size should be a multiple of 8');
    end
    I = I((1+rm):(end-rm), (1+rm):(end-rm), :);
end