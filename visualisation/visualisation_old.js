compare_cluster = function(a, b) {
  return (a.entropy > b.entropy) ? 1 : -1;
};

pre_processing = function(clusters) {
  period = [];
  // pre-processing
  $.each(clusters, function(idx, cluster) {
    period[cluster.dominance] << cluster
  });
  return period;
};

visualize = function(period) {
  $.each([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], function(idx, period) {
    period_clusters = period[period_idx].sort(compare_cluster);
  })
};

$(function() {

  var template = $("#list_images").html();
  $.getJSON("./results/20/clusters.json", function(data) {
    period_clusters = pre_processing(data);
    visualize(period_clusters);
  });
});