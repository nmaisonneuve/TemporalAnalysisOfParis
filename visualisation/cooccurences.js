var template;

visualize = function(clusters){
  $("#clusters").empty();
  // sort cluster by the number of members
 clusters = _.sortBy(clusters, function(cluster){ return -cluster.nn.length; });
  for (var i  = 0 ; i < clusters.length ; i++){
    cluster = clusters[i];
    //cluster.id = i + 1;
    console.log(cluster);
    var d = _.template(template,{exp: experiment_name, cluster: cluster});
    $("#clusters").append(d);
  }
}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

$(function() {
  template = $("#list_cluster_template").html();
  experiment_name = getParameterByName('experiment');
   console.log(experiment_name);
  if (experiment_name == '')
    experiment_name = 'exp1';
  $("#experiment_id").html("experiment "+experiment_name);

  console.log(experiment_name);
  $.getJSON("../results/"+experiment_name+"/cooccurrence/cooccurrences.json", function(_clusters) {
    clusters = _clusters;
    visualize(clusters);   
  });
});