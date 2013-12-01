function val=invertdistributeby(val,ord)
  val=cell2mat(val);
  val(cell2mat(ord),:)=val;
end
