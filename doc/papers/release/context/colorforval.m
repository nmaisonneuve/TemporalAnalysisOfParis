function res=colorforval(val)
  val2=min(abs(val),1);
  if(val<0)
    res=htmlcolor([1, 1-val2, 1-val2]);
  else
    res=htmlcolor([1-val2, 1, 1-val2]);
  end
end
