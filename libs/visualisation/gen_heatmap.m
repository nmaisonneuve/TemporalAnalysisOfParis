function im = gen_heatmap(im, patches)
   % im = rgb2gray(im);
    %im=repmat(rgb2gray(im),[1,1,3]);
    disp(size(im));
    % color map    
    cmp=colormap('jet');
    cmp = [[0 0 0 ]; cmp];
    max_weight = size(cmp,1) -1;
  
    % compute heatmap
    weight = 1 ; %(max_weight)/(size(patches,1));
    heatmap = zeros(size(im,1),size(im,2));
    for (i = 1: size(patches,1))
      heatmap(patches(i,1):patches(i,2),patches(i,3):patches(i,4)) = weight ...
        + heatmap(patches(i,1):patches(i,2),patches(i,3):patches(i,4));
    end
    
    % or we normalize after
    heatmap = heatmap .* (max_weight/max(max(heatmap)));
    heatmap = round(heatmap);
   for(chan=1:3)
    im(:,:,chan)=im(:,:,chan).*0.5 + reshape(cmp((heatmap+1),chan),size(heatmap)).*0.5;
   end
   
    %cmp(heatmap,chan)
    % transform to image
    
 % im=repmat(rgb2gray(im),[1,1,3]);
 % posheatmap=heatmap2jet(posheatmap*40000)*.5+im*.5;
 % negheatmap=heatmap2jet(negheatmap*40000)*.5+im*.5; 



end
    