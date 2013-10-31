
patch = [1 1 1];

function pos = patch_position(patch, pyramid, params)


[prSize, pcSize, ~] = getCanonicalPatchHOGSize(params);
canoSc = pyramid.canonicalScale;

level = patch(:,1);
level_scale = img_pyramid.scales(level);
x1 = patch(:,2);
y1 = patch(:,3);
xoffset = floor((x1 - 1) * pyramid.sbins * level_scale / canoSc) + 1;
yoffset = floor((y1 - 1) * pyramid.sbins * level_scale / canoSc) + 1;
 

levelPatch = getLevelPatch(prSize, pcSize, level, pyramid);
pos = levelPatch + [xoffset xoffset yoffset yoffset];
 
end
