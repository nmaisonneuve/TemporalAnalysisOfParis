%split up the rows of may according to bins--i.e. numel(bins)==size(mat,1). 
%binid contains all unique elements of bins.
%res contains one cell for each unique value of bins; each of these cells res{j} contains
%all rows mat(i,:) for which bins(i)==binid(j).
function [varargout]=distributeby(varargin)
  %order='ascend';
  order=1;
  if(ischar(varargin{end})&&strcmp('descend',varargin{end}))
    %order='descend';
    order=-1;
    varargin(end)=[];
  end
  if(ischar(varargin{end})&&strcmp('ascend',varargin{end}))
    varargin(end)=[];
  end
  bins=varargin{end};
  mat=varargin(1:end-1);
  binid=sortrows(unique(bins,'rows'),(1:size(bins,2))*order);
  [~,idx]=ismember(bins,binid,'rows');
  [~,ord]=sort(idx);
  counts=histc(idx,1:size(binid,1));
  for(i=1:numel(mat))
    if(isstruct(mat{i}))
      fns=fieldnames(mat{i});
      restmp=cell(numel(counts),numel(fns));
      for(j=1:numel(fns))
        field=mat{i}.(fns{j});
        field=field(ord,:);
        restmp(:,j)=mat2cell(field,counts,size(field,2));
      end
      restmp=cell2struct(restmp,fns,2);
      varargout{i}=num2cell(restmp);
      %restmp=mat2cell(restmp,ones(numel(counts),1),size(restmp,2));
      %fn=fieldnames(mat{i});
      %restmp=cellfun(@(x) cell2struct(
    else
      res=mat{i}(ord,:);
      varargout{i}=mat2cell(res,counts,size(res,2));
    end
  end
  varargout{end+1}=binid;
  if(nargout>numel(varargout))
    varargout{end+1}=mat2cell(ord(:),counts,1);
  end
end
