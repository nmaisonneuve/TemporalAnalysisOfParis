for (i = [ 9 10])
  data_file = sprintf('data/step2_exp_one_vs_all_period%d.mat',i);
  disp(data_file);
  load(data_file);
  if (max(unique(detections(:,2))) > size(imgs,1))
    update_data(i);
  end
end
  