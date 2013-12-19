% to test stuff

config();


for (i = [6])
  clearvars -except i;
  data_file = sprintf('data/step2_exp_one_vs_all_period%d.mat',i);
  fprintf('\n time period %d',i);
  load(data_file);
  step3_ranking;
  step_visualisation;
  step4_cooccurence_analysis;
end




