classdef WFilter < handle
     properties (SetAccess = protected)
       maxfsize; %[y x]    
       featdim;
       submu;
       submuN;
       subsigma;
       subsigmaN;
       
       featureFun;
       
       fsize;
       invSig;
       mu;
    end
    
    methods (Access = public)
        function obj = WFilter(maxfsize, featureFun, mu0)
            maxfsize = abs(maxfsize);
            if numel(maxfsize) == 1
                maxfsize = [maxfsize maxfsize];
            end  
            obj.maxfsize = maxfsize;
            
            obj.subsigma = [];
            
            if ~exist('featureFun', 'var')
                obj.featureFun = @myfeatpyramid;
            end
            
            if exist('mu0', 'var')
                obj.init(length(mu0));
                obj.submu = reshape(mu0, 1, obj.featdim);
                obj.submuN = 1;
            else
                obj.submu = [];
            end
        end
        
        function processImage(obj, img)
            if ~exist('featureFun', 'var')
                featureFun = [];
            end
            if isa(img, 'uint8')
                img = double(img) / 255;
            end
                
            pyra = obj.featureFun(img);            
            for i = 1 : length(pyra.feat)
                obj.processFeaturesMu(pyra.feat{i});
            end

            % HACK : compute the covariance with the current value of mu
            newmu = obj.submu / obj.submuN;
            for i = 1 : length(pyra.feat)                
                obj.processFeaturesSigma(pyra.feat{i}, newmu);
            end
        end
        
        function processDirectory(obj, path, start)
            f = dir(fullfile(path, '*.jpg'));
            nimg = length(f);
            if ~exist('start', 'var')
                start = 1;
            end                
            for i = start : nimg
                fprintf('Processing image %d/%d...\n', i, nimg);
                img = double(imread(fullfile(path, f(i).name))) / 255;
                obj.processImage(img);
            end
        end
        
        function [sig mu] = getCovMean(obj, filterSize) % filterSize = [y x]
            mu = repmat(reshape(obj.submu / obj.submuN, [1 1 length(obj.submu)]), filterSize);
            mu = reshape(mu, numel(mu), 1);
            
            sig = cell(filterSize(2));
            for i = 1 : filterSize(2)
                sig{i} = cell(filterSize(1));
                for j = 1 : filterSize(1)
                    sig{i}{j} = cell(filterSize(2));
                    for u = 1 : filterSize(2)
                        sig{i}{j}{u} = cell(filterSize(1));
                        for v = 1 : filterSize(1)                                                        
                            dx = u - i;
                            dy = v - j;
                            if dy < 0  % using symetry of covariance matrix
                                dy = -dy;
                                dx = -dx;
                                transp = true;  
                            elseif dy == 0 && dx < 0
                                dx = -dx;
                                transp = true;  
                            else
                                transp = false;  
                            end
                           
                            if dy > obj.maxfsize(1) || abs(dx) > obj.maxfsize(2)
                                %subSig = zeros(obj.featdim, obj.featdim);
                                dy = min(dy, obj.maxfsize(1));
                                dx = max(min(dx, obj.maxfsize(2)), -obj.maxfsize(2));
                                subSig = obj.subsigma{dy + 1, dx + obj.maxfsize(2) + 1} / ...
                                         obj.subsigmaN(dy + 1, dx + obj.maxfsize(2) + 1);
                            else
                                subSig = obj.subsigma{dy + 1, dx + obj.maxfsize(2) + 1} / ...
                                         obj.subsigmaN(dy + 1, dx + obj.maxfsize(2) + 1);
                            end                                                      
                            
                            if transp
                                sig{i}{j}{u}{v} = subSig';
                            else
                                sig{i}{j}{u}{v} = subSig;
                            end
                        end
                        sig{i}{j}{u} = cat(2, sig{i}{j}{u}{:});                        
                    end
                    sig{i}{j} = cat(2, sig{i}{j}{:});
                end
                sig{i} = cat(1, sig{i}{:});
            end
            sig = cat(1, sig{:});      
            
            assert(sum(sum(abs(sig - sig'))) < 1e-4);
            
            % permute sig
            index = reshape(1 : obj.featdim, [1 1 obj.featdim]);
            [indexX indexY] = meshgrid(0 : (filterSize(2) - 1), 0 : (filterSize(1) - 1));            
            indexXY = (indexY + indexX * filterSize(1)) * obj.featdim;            
            indexXY = repmat(indexXY, [1 1 obj.featdim]);
            index = bsxfun(@plus, indexXY, index);
            index = reshape(index, 1, numel(index));                                  
            sig = sig(index, index);
            
            % Regularize
            sig = sig + 0.0001 * eye(length(index));            
            sig = (sig + sig') / 2;
        end
        
        function filter = filter2classifLDA(obj, filter)      
            [h w d] = size(filter);
            assert(d == obj.featdim);
            if isempty(obj.fsize) || ~isempty(find([h w] ~= obj.fsize, 1))
                [sig obj.mu] = obj.getCovMean([h w]);
                obj.invSig = inv(sig);
                obj.fsize = [h w];
            end
            filter = reshape(filter, h * w * d, 1); 
            filter = obj.invSig * (filter - obj.mu);
            filter = reshape(filter, [h w d]);        
        end
        
        function obj = saveobj(obj)
            obj.fsize = [];
            obj.invSig = [];
            obj.mu = [];
        end            
    end
        
    methods (Access = private)
        function init(obj, featdim)
            obj.featdim = featdim;
            obj.submu = zeros(1, featdim);
            obj.submuN = 0;
            obj.subsigma = cell(obj.maxfsize(1) + 1, 2 * obj.maxfsize(2) + 1);
            obj.subsigmaN = zeros(obj.maxfsize(1) + 1, 2 * obj.maxfsize(2) + 1);
            for i = 0 : obj.maxfsize(1)
                if i == 0
                    for j = obj.maxfsize(2) : (2 * obj.maxfsize(2))
                        obj.subsigma{i + 1, j + 1} = zeros(featdim, featdim);
                    end
                else
                    for j = 0 : (2 * obj.maxfsize(2))
                        obj.subsigma{i + 1, j + 1} = zeros(featdim, featdim);
                    end
                end
            end
        end
                
        function processFeaturesMu(obj, feat)
            [h w d] = size(feat);
            if isempty(obj.subsigma)
                obj.init(d);
            end
            obj.submu = obj.submu + sum(reshape(feat, h * w, d), 1);
            obj.submuN = obj.submuN + h * w;
        end
        
        function processFeaturesSigma(obj, feat, mu)
            [h w d] = size(feat);
            if isempty(obj.subsigma)
                obj.init(d);
            end
            
            feat = bsxfun(@minus, feat, reshape(mu, [1 1 d]));
            mh = min(h - 1, obj.maxfsize(1));
            mw = min(w - 1, obj.maxfsize(2));
            for dy = 0 : mh
                j = 1 + dy;
                fy1 = feat(1 : (end - dy), :, :);
                fy2 = feat((1 + dy) : end, :, :);  
                
                if dy == 0
                    start = 0;
                else
                    start = -mw;
                end
                for dx = start : mw
                    i = 1 + dx + obj.maxfsize(2);
                    fx1 = fy1(:, max(1, 1 - dx) : min(w, w - dx), :);
                    fx2 = fy2(:, max(1, 1 + dx) : min(w, w + dx), :);
                    
                    hh = size(fx1, 1);
                    ww = size(fx1, 2);
                    fx1 = reshape(fx1, hh * ww, d)';
                    fx2 = reshape(fx2, hh * ww, d);                    
                    
                    obj.subsigma{j, i} = obj.subsigma{j, i} + fx1 * fx2;
                    obj.subsigmaN(j, i) = obj.subsigmaN(j, i) + hh * ww;
                end
            end
        end               
    end
end