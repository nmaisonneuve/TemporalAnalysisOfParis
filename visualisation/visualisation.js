var template;

visualize = function(clusters){
  $("#clusters").empty();
  for (var i  = 0 ; i < clusters.length ; i++){
    cluster = clusters[i];
    cluster.id = i + 1;

    var d = _.template(template,{cluster: cluster});
    $("#clusters").append(d);
  }
}
 
$(function() {
  template = $("#cluster_template").html();

  $.getJSON("../results/clusters.json", function(_clusters) {
    clusters = _clusters;
    visualize(clusters);   
  });
});