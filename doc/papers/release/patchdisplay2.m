ds_html{end+1}=sprintf('<html>\n');
ds_html{end+1}=sprintf('<head>\n');
ds_html{end+1}=sprintf('<script type="text/javascript">\n');
ds_html{end+1}=sprintf('\n');
ds_html{end+1}=sprintf('  var _gaq = _gaq || [];\n');
ds_html{end+1}=sprintf('  _gaq.push([''_setAccount'', ''UA-32372780-1'']);\n');
ds_html{end+1}=sprintf('  _gaq.push([''_trackPageview'']);\n');
ds_html{end+1}=sprintf('\n');
ds_html{end+1}=sprintf('  (function() {\n');
ds_html{end+1}=sprintf('    var ga = document.createElement(''script''); ga.type = ''text/javascript''; ga.async = true;\n');
ds_html{end+1}=sprintf('    ga.src = (''https:'' == document.location.protocol ? ''https://ssl'' : ''http://www'') + ''.google-analytics.com/ga.js'';\n');
ds_html{end+1}=sprintf('    var s = document.getElementsByTagName(''script'')[0]; s.parentNode.insertBefore(ga, s);\n');
ds_html{end+1}=sprintf('  })();\n');
ds_html{end+1}=sprintf('\n');
ds_html{end+1}=sprintf('</script>\n');
ds_html{end+1}=sprintf('</head>\n');
ds_html{end+1}=sprintf('<body>\n');
ds_html{end+1}=sprintf('<table>\n');
ds_html{end+1}=sprintf('');
 
if(~isfield(argv,'ovlweights'))
  argv.ovlweights=zeros(size(argv.dets(:,[])));
end
[dets,posinpatchimg,ovlweights,detid]=distributeby(argv.dets,(1:size(argv.dets,1))',argv.ovlweights,argv.dets(:,6));
if(isfield(argv,'detrord'))
  [~,idxord]=ismember(argv.detrord,detid);
else
  idxord=1:numel(detid);
  argv.detrord=detid;
end
if(~isfield(argv,'message'))
  argv.message=repmat({''},numel(argv.detrord),1);
end
gbz=dsload('ds.conf.gbz{ds.conf.currimset}');
imgs=dsload('.ds.imgs{ds.conf.currimset}');
if(~isfield(gbz,'imgsurl'))
  gbz.imgsurl='';
end
for(i=1:numel(idxord)) 
ds_html{end+1}=sprintf('  <tr><td> ');
ds_html{end+1}=num2str([i]);
ds_html{end+1}=sprintf(': <br/></td>\n');
ds_html{end+1}=sprintf('  ');
if(idxord(i) ~= 0)
    curdets=dets{idxord(i)};
    curpos=posinpatchimg{idxord(i)};
    curwt=ovlweights{idxord(i)};
    [~,ord]=sort(curdets(:,5),'descend');
    for(j=1:size(curdets,1)) 
ds_html{end+1}=sprintf('      <td>\n');
ds_html{end+1}=sprintf('        <a href="');
if(isfield(argv,'url'))
ds_html{end+1}=sprintf('');
ds_html{end+1}=num2str([argv.url{curpos(ord(j))}]);
ds_html{end+1}=sprintf('');
else
ds_html{end+1}=sprintf('');
ds_html{end+1}=num2str([gbz.imgsurl]);
ds_html{end+1}=sprintf('/');
ds_html{end+1}=num2str([imgs.fullname{curdets(ord(j),7)}]);
ds_html{end+1}=sprintf('');
end
ds_html{end+1}=sprintf('">\n');
ds_html{end+1}=sprintf('          <img src="patchimg[]/');
ds_html{end+1}=num2str([curpos(ord(j))]);
ds_html{end+1}=sprintf('.jpg"/>\n');
ds_html{end+1}=sprintf('        </a>\n');
ds_html{end+1}=sprintf('      </td>\n');
ds_html{end+1}=sprintf('    ');
end
  end
ds_html{end+1}=sprintf('  </tr>\n');
ds_html{end+1}=sprintf('');
end
ds_html{end+1}=sprintf('      \n');
ds_html{end+1}=sprintf('</table>\n');
ds_html{end+1}=sprintf('</body></html>\n');
ds_reshtml=cell2mat(ds_html);
ds_html=[];
