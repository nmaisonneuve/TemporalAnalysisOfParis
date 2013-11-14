function patch = patch_to_struct(patch_row)
    patch = struct();          
    patch.img_id = patch_row(1);
    patch.x1 = patch_row(2);
    patch.x2 = patch_row(3);
    patch.y1 = patch_row(4);
    patch.y2 = patch_row(5);
end
