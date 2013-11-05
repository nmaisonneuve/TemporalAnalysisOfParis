
function generate_html_view(clusters, imgs)


%generate image patches
extract_patches_from_position([clusters.nn], imgs);

% save clusters.json
savejson('results/clusters.json',clusters);
end
