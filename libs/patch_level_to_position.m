% compute the actual pixel position of the patch in the image
% using the pyramid computed for a given image
% and using patch info e.g. level + indexes pos
function pos = patch_level_to_position(patches, pyramid, params)


[prSize, pcSize, ~] = getCanonicalPatchHOGSize(params);
canoSc = pyramid.canonicalScale;

level = patches(:,1);
x1 = patches(:,2);
y1 = patches(:,3);

level_scale = pyramid.scales(level)';
tmp = pyramid.sbins * level_scale / canoSc;  
xoffset = floor((x1 - 1) .* tmp) + 1;
yoffset = floor((y1 - 1) .* tmp) + 1;
l_p_1 = round((pcSize + 2) * tmp) - 1;
l_p_2 = round((prSize + 2) * tmp) - 1;

pos = [xoffset (xoffset + l_p_1) yoffset (yoffset+ l_p_2)];


end