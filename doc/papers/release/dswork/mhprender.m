function mhprender(mhpfile,outpath,argv)
  try
  if(~exist('argv','var'))
    argv=struct();
  end
  global ds;
  global ds_html;
  ds_html={};
  dsup(outpath,'');
  absoutpath=dsabspath(outpath);
  %mfile=dsdiskpath(outpath,true);
  %mfile=mfile{1};
  mhpfile=which(mhpfile);
  mhpfid=fopen(mhpfile);
  if(~mhpfid)
    mhpfile=[mhpfile '.mhp']
    mhpfile=which(mhpfile);
    mhpfid=fopen(mhpfile);
  end
  %if(~dshassuffix(mfile,'html'))
  %  error('result must be an html');
  %end
  %mfile(end-3:end)=[];
  %mfile=[mfile 'm'];
  mfile=mhpfile;
  mfile=[mhpfile(1:end-3) 'm']
  %stupid vectorized version gets rid of whitespace
  %lines = textscan(mhpfid,'%s','Delimiter','\n');
  %lines=lines{1};
  lines={};
  while(true)
    lin=fgets(mhpfid);
    if(~ischar(lin))
      break;
    end
    lin(end)=[];
    %disp(lin)
    lines{end+1}=lin;
  end
  fclose(mhpfid);
  state='html';
  lin='';
  outl={};
  outi=numel(outl)+1;
  i=0;
  while(i<numel(lines)||(~isempty(lin)))
    if(isempty(lin))
      i=i+1;
      lin=lines{i};
    end
    if(strcmp(state,'html'))
      if(strcmp(state,'html'))
        outl{outi}='ds_html{end+1}=sprintf(''';
      end
      pos=strfind(lin,'<%');
      if(isempty(pos))
        outl{outi}=[outl{outi} escape(lin) '\n'');'];
        outi=outi+1;
        lin='';
      else
        outl{outi}=[outl{outi} escape(lin(1:pos-1)) ''');'];
        lin=lin(pos+2:end);
        outi=outi+1;
        if(numel(lin)>1&&(lin(1)=='='||lin(1)=='~'))
          typechar=lin(1);
          fin=strfind(lin,'%>')
          if(isempty(fin))
            error(['line ' numestr(i) ': un-terminated <%' lin(1)]);
          end
          toparse=lin(2:fin(1)-1);
          lin=lin(fin(1)+2:end);
          if(typechar=='~')
            outl=[outl parse_dsref(toparse,i)];
          else
            outl=[outl parse_var(toparse,i)];
          end
          if(isempty(lin))
            outl{end+1}='ds_html{end+1}=sprintf(''\n'');';
          end
          outi=numel(outl)+1;
        else
          state='matlab';
        end
      end
    else%state=matlab
      pos=strfind(lin,'%>');
      if(isempty(pos))
        pos=length(lin)+1;
      else
        state='html';
      end
      outl{outi}=lin(1:pos(1)-1);
      outi=outi+1;
      lin=lin(pos(1)+2:end);
    end
  end
  outl{end+1}='ds_reshtml=cell2mat(ds_html);';
  outl{end+1}='ds_html=[];';
  mfdir=dir(mfile);
  mhpfdir=dir(mhpfile);
  if(isempty(mfdir)||(mfdir.datenum<mhpfdir.datenum))
    mfid=fopen(mfile,'w');
    fprintf(mfid,'%s\n',outl{:});
    fclose(mfid);
  end
  disp('run')
  rehash;
  dotpos=find(absoutpath=='.');
  outdirpath=absoutpath(1:dotpos(end)-1);
  slashpos=find(mfile=='/');
  if(~isempty(slashpos))
    mfile=mfile(slashpos(end)+1:end);
  end
  htmlout=runfile(mfile(1:end-2),argv,outdirpath);
  disp('donerun')
  dsup(outpath,htmlout);
  catch ex,dsprinterr;end
end

function res=parse_dsref(toparse,lineno)
  pos=strfind(toparse,'{');
  res={};
  idxind='';
  if(~isempty(pos))
    fin=strfind(toparse,'}');
    if(isempty(fin))
      error(['line ' num2str(lineno) ': un-terminated { in <%~']);
    end
    idxstr=toparse(pos(1)+1:fin(end)-1);
    toparse=toparse(1:pos(1)-1);
    trail=toparse(fin(end)+1:end);
    if(~regexp(trail,'^\s*$'))
      error(['line ' num2str(lineno) ': trailing characters in <%~']);
    end
    res{1}=['ds_idxstr=' idxstr ';']
    idxind=' ''{'' num2str(ds_idxstr) ''}''';
  end
  res{end+1}=['ds_html{end+1}=dsreldiskpath([''' toparse '''' idxind '],outdirpath);'];
  res{end+1}=['if(numel(ds_html{end})>0),ds_html{end}=ds_html{end}{1};else,ds_html{end}='''';end'];
end

function res=parse_var(toparse,lineno)
  res{1}=['ds_html{end+1}=num2str([' toparse ']);'];
end

function str=escape(str)
  str=strrep(str,'\','\\');
  str=strrep(str,'''','''''');
  str=strrep(str,'%','%%');
end

function ds_reshtml=runfile(mfile,argv,outdirpath)
try
  global ds_html;
  global ds;
  eval(['clear ' mfile]);
  rehash;
  eval(mfile);
catch ex,dsprinterr;end
end
