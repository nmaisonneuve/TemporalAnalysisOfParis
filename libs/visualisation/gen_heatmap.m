function im = gen_heatmap(im, patches)
   % im = rgb2gray(im);
    %im=repmat(rgb2gray(im),[1,1,3]);
 
    % color map    
    cmp=colormap('jet');
    cmp = [[0 0 0 ]; cmp];
    max_weight = size(cmp,1) -1;
    
    [width, height] = patch_size(patches);
    % compute heatmap
    weight = 1 ; %(max_weight)/(size(patches,1));
    width = size(im,2);
    height = size(im,1);
    heatmap = zeros(height,width);
    % crop ??!
    patches(:,4) = min( width, patches(:,4));
    
    for (i = 1: size(patches,1))
     % fprintf('\n patches %d, %d max(%d), %d %d max (%d)', patches(i,1), patches(i,2), size(im,1), patches(i,3),patches(i,4),size(im,2));
      % crop ?!
      
      heatmap(patches(i,1):patches(i,2),patches(i,3):patches(i,4)) = weight ...
        + heatmap(patches(i,1):patches(i,2),patches(i,3):patches(i,4));
    end
    
    % or we normalize after
    heatmap = heatmap .* (max_weight/max(max(heatmap)));
    heatmap = round(heatmap);
   for(chan=1:3)
    im(:,:,chan)=im(:,:,chan).*0.5 + reshape(cmp((heatmap+1),chan),size(heatmap)).*0.5;
   end



end
    