function res=genflips(data)
  data.boxid=(1:numel(data.imidx))';
  res={data;data};
  res{1}.flip=false(size(data.imidx));
  res{2}.flip=true(size(data.imidx));
  res=effstrcell2mat(res);
end
