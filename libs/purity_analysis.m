function candidates = purity_analysis(candidates, detections, imgs, positive_label)

  top_k = 500;
  min_k = 20;
  tic;
  candidates.('pur_hist');
  parfor i = 1:numel(candidates)
    fprintf('\nComputing purity analysis for candiate %d ', candidates(i).id);
    NN_patches_idx = find(detections(:, 1) == candidates(i).id);
    [~ , ord] = mink(detections(NN_patches_idx, 3), top_k);
    img_idx = detections(NN_patches_idx(ord),2);
    labels = [imgs(img_idx).label];
    labels = labels == positive_label;
    candidates(i).pur_hist = cumsum(labels)./(1:numel(labels));
    candidates(i).pur_hist = candidates(i).pur_hist(min_k:end);
  end
  toc;
 % t = candidates;
 % t_idx = find([t.purity] >= .9);
 % hold all;
 % for(i = t_idx)
 %     plot(t(i).pur_hist)
 % end
end

