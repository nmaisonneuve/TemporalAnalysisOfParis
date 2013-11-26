rows = clusters_co(:,1);
cols = clusters_co(:,2);
w = clusters_co(:,3);
thres= 0.2;
to_remove =find(w < thres);
new_w = w;
new_w(to_remove) = 0;

A = sparse([rows; cols],[cols; rows],[new_w; new_w]);
A = full(A);
write_matrix_to_pajek(A,'./data/test.net','weighted',true,'directed',false);