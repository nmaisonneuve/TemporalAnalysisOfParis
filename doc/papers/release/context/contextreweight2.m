ds_html{end+1}=sprintf('<html><body>\n');
ds_html{end+1}=sprintf('<table>\n');
ds_html{end+1}=sprintf('');
bx=argv.allgtboxes;
[~,impos]=ismember(argv.alldata(:,[7 8 9]),[bx.imidx bx.flip bx.boxid]);
[detsbyid,scorebyid,patchidx,detr]=distributeby(argv.alldata,argv.detscore,(1:numel(argv.detscore))',argv.alldata(:,6));

for(i=1:numel(argv.tokeep))
  [~,idx]=ismember(argv.tokeep(i),detr);
  if(idx==0)
    continue;
  end
  [~,ord]=sort(scorebyid{idx},'descend');
  ord=ord(round((0:49)/49*(numel(ord)-1)+1))
  dets=detsbyid{idx}(ord,:);
  scores=scorebyid{idx}(ord);
  patchidx2=patchidx{idx}(ord);
  [~,imid]=ismember(dets(:,[7 8 9]),[bx.imidx bx.flip bx.boxid],'rows');
  
ds_html{end+1}=sprintf('<tr><td><a ');
if(isfield(argv,'detrurl'))
ds_html{end+1}=sprintf(' href="');
ds_html{end+1}=num2str([argv.detrurl{i}]);
ds_html{end+1}=sprintf('" ');
end
ds_html{end+1}=sprintf('>');
ds_html{end+1}=num2str([argv.tokeep(i)]);
ds_html{end+1}=sprintf('</a></td>');
  for(j=1:numel(ord))
ds_html{end+1}=sprintf('    <td style="');
if(j==1||ord(j-1)~=ord(j))
ds_html{end+1}=sprintf('border:solid 2px #');
ds_html{end+1}=num2str([colorforval(scores(j))]);
ds_html{end+1}=sprintf('');
else
ds_html{end+1}=sprintf('border-bottom:solid 1px #000');
end
ds_html{end+1}=sprintf('">\n');
ds_html{end+1}=sprintf('      ');
 if(j==1||ord(j-1)~=ord(j)) 
ds_html{end+1}=sprintf('        ');
if(isfield(ds,'imgctxhtml'))
ds_html{end+1}=sprintf('          <a href="');
ds_idxstr=patchidx2(j);
ds_html{end+1}=dsreldiskpath(['ds.imgctxhtml' '{' num2str(ds_idxstr) '}'],outdirpath);
if(numel(ds_html{end})>0),ds_html{end}=ds_html{end}{1};else,ds_html{end}='';end
ds_html{end+1}=sprintf('">\n');
ds_html{end+1}=sprintf('        ');
else
ds_html{end+1}=sprintf('          <a href="');
ds_idxstr=imid(j);
ds_html{end+1}=dsreldiskpath(['ds.myimg' '{' num2str(ds_idxstr) '}'],outdirpath);
if(numel(ds_html{end})>0),ds_html{end}=ds_html{end}{1};else,ds_html{end}='';end
ds_html{end+1}=sprintf('">\n');
ds_html{end+1}=sprintf('        ');
end
ds_html{end+1}=sprintf('      <img src="');
ds_idxstr=patchidx2(j);
ds_html{end+1}=dsreldiskpath(['ds.patchimg' '{' num2str(ds_idxstr) '}'],outdirpath);
if(numel(ds_html{end})>0),ds_html{end}=ds_html{end}{1};else,ds_html{end}='';end
ds_html{end+1}=sprintf('" \n');
ds_html{end+1}=sprintf('      title="');
ds_html{end+1}=num2str([dets(j,5)]);
ds_html{end+1}=sprintf(' ');
ds_html{end+1}=num2str([scores((j))]);
ds_html{end+1}=sprintf('" \n');
ds_html{end+1}=sprintf('      style="width:80px"/>\n');
ds_html{end+1}=sprintf('      </a>\n');
ds_html{end+1}=sprintf('      ');
 else 
ds_html{end+1}=sprintf(' &nbsp; ');
 end 
ds_html{end+1}=sprintf('    </td>\n');
ds_html{end+1}=sprintf('  ');
 end 
ds_html{end+1}=sprintf('  </tr>\n');
ds_html{end+1}=sprintf('');
 end 
ds_html{end+1}=sprintf('</body></html>\n');
ds_reshtml=cell2mat(ds_html);
ds_html=[];
