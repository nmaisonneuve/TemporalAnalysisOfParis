var template;
var context ;


visualize_list_clusters = function(clusters){
  nb = Math.min(300, clusters.length);
  html ="";
  $("#clusters").empty();
  // 1 and not 0 , to remove the centroid
  for (var i  = 0 ; i < nb ; i++){
    cluster = clusters[i];
    if (!(cluster.members instanceof Array))
    cluster.members = [cluster.members];
    cluster.id = i+1;
     html = _.template(template,{exp: experiment_name, cluster: cluster, context:context});
    $("#clusters").append(html);
  }
}

$(function() {
  // load templates
  template = $("#list_cluster_template").html();

  given_period = detecting_period();

  context = getParameterByName('context');
  if (context == '') {
    context = 'image';
  }

  $("#context_"+context).addClass('current_period');

  $("#context_image").attr('href',"?experiment="+experiment_name+"&context=image");
  $("#context_area").attr('href',"?experiment="+experiment_name+"&context=area");

  $.getJSON("../results/"+experiment_name+"/cooccurrence/"+context+"/clusters.json", function(_clusters) {
    clusters = _clusters;  
    visualize_list_clusters(clusters);
  });
});