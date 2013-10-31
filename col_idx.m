% from a column name get the column idx
function idx = col_idx(column_names, column_name)
  idx = find((strcmp(column_names,column_name)));
end