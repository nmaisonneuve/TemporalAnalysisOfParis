
function generate_html_view(clusters, imgs)

a = [clusters.centroid];
oldField = 'imidx';
newField = 'img_id';
[a.(newField)] = a.(oldField);
a = rmfield(a,oldField);

%generate image patches
extract_patches_from_position([a], imgs);


%generate image patches
extract_patches_from_position([clusters.nn], imgs);

% save clusters.json
savejson('',clusters,'results/clusters.json');
end
