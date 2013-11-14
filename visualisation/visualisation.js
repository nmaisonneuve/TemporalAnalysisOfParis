var template;
var experience_name = 'exp1';
visualize = function(clusters){
  $("#clusters").empty();
  for (var i  = 0 ; i < clusters.length ; i++){
    cluster = clusters[i];
    cluster.id = i + 1;
    console.log(cluster);
    var d = _.template(template,{exp: experience_name, cluster: cluster});
    $("#clusters").append(d);
  }
}
 
$(function() {
  template = $("#cluster_template").html();

  $.getJSON("../results/"+experience_name+"/clusters_knn.json", function(_clusters) {
    clusters = _clusters;
    visualize(clusters);   
  });
});