var template;
var period_label = {"1": "< 1800",
"2":"1801-1850",
"3":"1851-1914",
"5": "1915-1939",
"6":"1940-1967",
"7":"1968-1975",
"8":"1976-1981",
"9":"1982-1989",
"10":"1990-1999",
"11": "2000 >=",
"0": "unknown"};

visualize = function(clusters){
  $("#clusters").empty();
  nb = Math.min(300, clusters.length);
  for (var i  = 0 ; i < nb ; i++){
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
  template = $("#cluster_template").html();
  experiment_name = getParameterByName('experiment');
   console.log(experiment_name);
  if (experiment_name == '') {
    experiment_name = 'exp1';
  }
  matching = experiment_name.match(/exp_one_vs_all_period(\d+)/);
  console.log(matching);
  if (matching != null)
   given_period = period_label[matching[1]];
  else{
    given_period ='unknown';
  }

  $("#experiment_id").html("Experiment : "+experiment_name);
  $("#period_id").html(given_period);

  console.log(experiment_name);
  $.getJSON("../results/"+experiment_name+"/nn/clusters_knn.json", function(_clusters) {
    clusters = _clusters;
    visualize(clusters);   
  });
});