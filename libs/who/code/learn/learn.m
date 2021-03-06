function model = learn(model,warped)
% model = learn(name,model,warped)
% warped is set of image patches.
% name is name of model.
% model can be left empty, in which case it is initialized and background statistics loaded.
% Learn model by linear discriminant analysis
if(isempty(model))
  fprintf('\nWARNING empty model');
	model=empty_model([3 3 3]);
	load(bg_file_name);
	model.bg=bg;
	f=features(double(warped{1}),8);
	model.w=f;
	model.maxsize=[size(model.w,1) size(model.w,2)];
end



[ny,nx,nf] = size(model.w);
fprintf('\nmodel %d %d %d', [ny,nx,nf]);
nf = nf - 1;

[R,neg] = whiten(model.bg,nx,ny);
% Cache features
num  = length(warped);
feats = zeros(ny*nx*nf,num);
for i = 1:num,
  im   = warped{i};
 % imshow(im);
 % pause();
  
  feat = features(double(im),model.sbin);
%   fprintf('\nnormal features');
%   showHOG(feat);
%   pause;
   feat = feat(:,:,1:end-1);
%   f1=R'\(feat(:)-neg);
%   f1=reshape(f1,[ny nx nf]);
%   f1(:,:,end+1)=0;
%   fprintf('\nwihtened features');
%   showHOG(f1);
%   pause;
  feats(:,i) = feat(:);
end

pos = mean(feats,2);

[R,neg] = whiten(model.bg,nx,ny);
w=R\(R'\(pos-neg));
s=w'*feats;
[s,i]=sort(s, 'descend');
i=i(1:min(10, length(i)));
%pos=mean(feats(:,i),2);


w = reshape(R\(R'\(pos-neg)),[ny nx nf]);
%w=pos-neg;
% Add in occlusion feature
w = reshape(w,[ny nx nf]);
w(:,:,end+1) = 0;  
model.w = w;

