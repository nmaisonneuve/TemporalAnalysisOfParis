ds_html{end+1}=sprintf('<html><body>\n');
ds_html{end+1}=sprintf('');
for(i=1:numel(argv.patchidx))
ds_html{end+1}=sprintf('  <img src="../patchimg[]/');
ds_html{end+1}=num2str([argv.patchidx(i)]);
ds_html{end+1}=sprintf('.jpg" style="width:50px;height:50px;position:fixed;top:');
ds_html{end+1}=num2str([argv.pos(i,2)*1000]);
ds_html{end+1}=sprintf('px;left:');
ds_html{end+1}=num2str([argv.pos(i,1)*1000]);
ds_html{end+1}=sprintf('px"/>\n');
ds_html{end+1}=sprintf('');
end
ds_html{end+1}=sprintf('</body></html>\n');
ds_reshtml=cell2mat(ds_html);
ds_html=[];
