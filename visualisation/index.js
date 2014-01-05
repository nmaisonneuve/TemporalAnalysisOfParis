var template;
var level_template;
var list_scale_template;
var list_images_template;
var filter;
var ranking ='purity';
var group ='size';



display_list_images = function (images){
  images = images.slice(1,15);
 return _.template(list_images_template,{exp: experiment_name, images:images});
}

visualize_list_clusters = function(clusters){
  clusters = _.sortBy(clusters, function(cluster) {
    switch (ranking) {
    case 'purity': return - cluster.purity
    case 'frequency': return -cluster.frequency
    case 'mean': return -cluster.mean
    }
  });
  nb = Math.min(200, clusters.length);
  html ="";
  // 1 and not 0 , to remove the centroid
  for (var i  = 0 ; i < nb ; i++){
    cluster = clusters[i];
    html += _.template(template,{exp: experiment_name, cluster: cluster});
  }
  return html;
}

visualize_v1 = function(clusters){
  $("#clusters").empty();
  html = visualize_list_clusters(clusters);
  $("#clusters").append(html);
}

visualize = function(clusters){
  if (group == 'size')
    visualize_v2(clusters);
  else
    visualize_v1(clusters);
}
// v1 +  grouped by patch scale level
visualize_v2 = function(clusters){


  groups = group_by_levels(clusters);

  // we create the level menu
  levels = _.keys(groups);
  sorted_levels = _.sortBy(levels, function(level) {return -level;});
  html_levels_menu = _.template(level_template,{levels: sorted_levels, groups: groups});
  $("#scale_menu").html( html_levels_menu);

  $("#clusters").empty();
  for (var i  = 0 ; i < sorted_levels.length ; i++){
    level = sorted_levels[i];
    clusters_level = groups[level];
    html = _.template(list_scale_template,{scale_idx: i, scale: level, clusters:clusters_level});
    $("#clusters").append(html);
  }
}

function group_by_levels (clusters){
 return _.groupBy(clusters, function(cluster){ return cluster.centroid.size });
}


$(function() {
  // load templates
  template = $("#list_cluster_template").html();
  level_template = $("#levels_template").html();
  list_scale_template = $("#list_clusters_scale_template").html();
  list_images_template = $("#list_images_template").html();

  detecting_period();

  filter = getParameterByName('filter');
  if (filter != '') {
    filter = filter.split(',');
    filter = _.map(filter,function(id) {return parseInt(id)});
  }else{
   filter = []; 
  }
  

 

  $(".group").click(function(event){
    group = $(this).data('group');
    visualize(clusters);
  });

  $(".sort").click(function(event){
    ranking = $(this).data('sort');
    console.log('sorting by '+ranking);
    visualize(clusters);
  });


  
  $("#clusters").on("click", ".morevisible", function(event){
    cluster_id = $(this).data('cluster');
    $("#more_visible_"+cluster_id).toggle();
  });

  $("#cooccurrence_image_link").attr('href',"clustering_cooccurrences.html?experiment="+experiment_name+"&context=image");
  $("#cooccurrence_overlap_link").attr('href',"clustering_cooccurrences.html?experiment="+experiment_name+"&context=area");

  console.log(experiment_name);
  $.getJSON("../results/"+experiment_name+"/candidates.json", function(_clusters) {
    clusters = _clusters;
    if (filter.length > 0){
      clusters = _.filter(clusters, function(cluster){
       return filter.indexOf(cluster.id)>-1; 
      });
    }
    visualize(clusters);       
  });
});