
function [ wOut outLabels miscstate ] = doGradDescentActive( X, Y, wIn ,weights,roundid,fig)
global ds;
disp([num2str(size(X,2)) ' points, ' num2str(sum(Y>0)) ' pos'])
try
Y = Y(:);

dsload('ds.round.lambda');
if(dsfield(ds,'round','lambda'))
    nrmlambda=ds.round.lambda;
elseif(dsfield(ds,'conf','params','lambda'))
    nrmlambda=ds.conf.params.lambda;
else
    nrmlambda=.002;
end
if(dsfield(ds,'conf','params','stepsize'))
    stepsize=ds.conf.params.stepsize;
else
    stepsize=.1;
end
if(dsfield(ds,'conf','params','optimizationComputeLimit'))
    optimizationComputeLimit=ds.conf.params.optimizationComputeLimit;
end
dsload('ds.round.epsilon');
if(dsfield(ds,'round','epsilon'))
  epsilon=ds.round.epsilon;
elseif(dsfield(ds,'conf','params','epsilon'))
  epsilon=ds.conf.params.epsilon;
else
  epsilon=1;
end


if (~all(X(end,:) == 1))
    fprintf('Appending row of ones to feature vector\n');
    X = [X; ones(1, size(X,2))];
end

if(sum(Y<=0)==0)
  error('no negative points!');
end


if(roundid>-1 && roundid<=3)
  wOut=wIn(:);
  if(isempty(X))
    scores=[];
    return;
  end
  scores=(wOut(:)')*X;
  negs=scores(Y<=0);
  toadd=fminsearch(@(x) (sum(x+negs((x+negs)>0))-epsilon)^2 +1e10*(sum((x+negs)>0)==0),0,optimset('tolX',eps))
  wOut(end)=wOut(end)+toadd;
  scores=scores+toadd;
  toadd=.0001-min(max(scores(Y<=0)),max(scores(Y>0)));
  toadd=max(0,toadd);
  wOut(end)=wOut(end)+toadd;
  outLabels=scores+toadd;
  wOut(end)=wOut(end);
  return;
end

if(size(X,1)>size(X,2))
    X=X(1:end-1,:);
    [B,~]=qr(X);
    B=B(:,1:size(X,2));
    X=(B')*X;
    X(end+1,:)=1;
    b=wIn(end);
    wIn=((wIn(1:end-1)')*B)';
    wIn(end+1)=b;
    ranqr=1;
else
    ranqr=0;
end


if(~exist('weights','var'))
  weights=ones(size(Y));
  if(dsbool(ds.conf.params,'posweight'))
    weights(Y==1)=ds.conf.params.posweight;
  end
end
weights=weights(:)';

w = wIn;

w_orig=w;

nprods=0;
i=0;
nfails=0;
nrmstep=Inf;
nquadmins=0;
while(nprods<optimizationComputeLimit && nrmstep > 1e-8 && nquadmins<10)
    i=i+1;
    wX = w'*X;
    nprods=nprods+1;

    while(sum(weights((wX)'>0 & Y<=0).*(wX((wX)'>0 & Y<=0)))==0)
      disp('too few members, fixing bias...');
      nfails=nfails+1;
      if(nfails>100000)
          save([dsload('.ds.conf.dispoutpath') '/biasfail' num2str(floor(rand*1000))]);
          error('too many bias fails');
      end
      toadd=.01;
      wX=wX+toadd;
      w(end)=w(end)+toadd;
    end
    
    if(i==1)
      negs=wX(Y<=0);
      negweights=weights(Y<=0);
      toadd=fminsearch(@(x) ((x+negs((x+negs)>0))*negweights((x+negs)>0)'-epsilon)^2 +1e10*(sum((x+negs)>0)==0),0,optimset('tolX',eps))
      w(end)=w(end)+toadd;
      wX=wX+toadd;
    end

    lfull = wX.*weights;
    lfull(wX<0)=0;
    ldashfull = sign(lfull).*weights;
    onSet  = lfull' > 0;
    contribIdx = Y>0;

    lminus = sum(lfull((~contribIdx) & onSet));
    ldashplus  = X(:,contribIdx& onSet) * ldashfull(contribIdx & onSet)'; 
    %THIS IS (PROBABLY) NOT RIGHT! this should be multiplied by 2...done
    ldashnrm=2*w*nrmlambda;
    ldashnrm(end)=0;
    projspace=X(:,(~contribIdx) & onSet)*weights((~contribIdx) & onSet)';
    nprods=nprods+1;
    projspace=projspace/norm(projspace);
    nabla=ldashplus-ldashnrm;
    nabla = nabla-projspace*(nabla'*projspace);
    normquad=-[sum(nabla(1:end-1).^2),sum(2.*w(1:end-1).*nabla(1:end-1)),sum(w(1:end-1).^2)]*nrmlambda;
    ldashplusquad=ldashplus'*nabla;
    %THIS IS (PROABBLY) NOT RIGHT! new derivation shows ldashplusquad and
    %normquad should probably have same sign...i.e. should be a negative
    %in front of normquad(2)...actually it's fine
    quadmin=(normquad(2)+ldashplusquad)/(-2*normquad(1));
    if(quadmin<-1e-8)
      error('quadmin was negative!');
    end
    if(quadmin<0)
      quadmin=0;
    end
    if(isnan(quadmin))
      error('quadmin was nan');
    end
    dall=nabla'*X;
    nprods=nprods+1;
    dall=-wX./dall;
    dall(dall<0)=Inf;
    [dall,dallidx]=sort(dall,'ascend');
    step=stepsize/sum(weights(contribIdx&onSet));
    wold=w;
    %THIS IS NOT RIGHT! taking the quadmin step may still cause sign changes...
    if(step<quadmin)
      nquadmins=0;
      w=w+nabla*step;
      nrmstep=norm(nabla*step);
      negWx=w'*X(:,(~contribIdx));
      while(sum(weights(~contribIdx).*negWx)==0)
        disp('too few members after step, fixing bias...');
        nfails=nfails+1;
        if(nfails>100000)
            save([dsload('.ds.conf.dispoutpath') '/biasfail' num2str(floor(rand*1000))]);
            error('too many bias fails');
        end
        toadd=.01;
        negwX=negwX+toadd;
        w(end)=w(end)+toadd;
      end
      negweight=weights(~contribIdx);
      totneg=negWx(negWx>0)*negweight(negWx>0)';
      neggt0=~contribIdx;
      neggt0(~contribIdx)=negWx>0;
      nprojs=0;
      while(1)
        if(mod(nprojs,20)==0)
          projdir=X(:,neggt0)*weights(neggt0)';
          nprods=nprods+1;
          if(nprojs>0)
            negWx=w'*X(:,(~contribIdx));
            nprods=nprods+1;
          end
        end
        dnegs=projdir'*X(:,(~contribIdx));
        nprods=nprods+1;
        zer=(epsilon-totneg)./(dnegs(neggt0(~contribIdx))*weights(neggt0)');
        if(zer<0)
          projdir=-projdir;
          zer=-zer;
          dnegs=-dnegs;
        end

        signchg=-negWx./dnegs;
        signchg(signchg<=1e-8)=Inf;
        if(min(signchg)<zer && zer>1e-10)
          nprojs=nprojs+1;
          [msc,idx]=min(signchg);
          fContribIdx=find(~contribIdx);
          wXidx=fContribIdx(idx);
          w=w+projdir*msc;
          negWx=negWx+dnegs*msc;
          newwx=zeros(size(wX));
          newwx(~contribIdx)=negWx;
          if(neggt0(wXidx))
            projdir=projdir-X(:,wXidx)*weights(wXidx);
          else
            projdir=projdir+X(:,wXidx)*weights(wXidx);
          end
          neggt0(wXidx)=~neggt0(wXidx);
          totneg=newwx(neggt0)*weights(neggt0)';
        else
          w=w+projdir*zer;
          break;
        end
      end
    else
      w=w+nabla*quadmin;
      nrmstep=norm(nabla*quadmin);
      disp('quadminned');
    end
    nrmw=(norm(w(1:end-1)));
    
    anglechange=getangle(w(end),w(1:end-1))*.5>getangle(w_orig(end),w_orig(1:end-1))-acos(dot(w_orig(1:end-1),w(1:end-1))/(norm(w(1:end-1))*norm(w_orig(1:end-1))));
    anglechange=anglechange || getangle(w_orig(end),w_orig(1:end-1))*.5>getangle(w(end),w(1:end-1))-acos(dot(w_orig(1:end-1),w(1:end-1))/(norm(w(1:end-1))*norm(w_orig(1:end-1))));
    angorig=getangle(w_orig(end),w_orig(1:end-1));
    angnew=getangle(w(end),w(1:end-1));
    angdiffval=acos(dot(w_orig(1:end-1),w(1:end-1))/(norm(w(1:end-1))*norm(w_orig(1:end-1))));
    if(anglechange&&~dsbool(ds.conf.params,'nocheck'))
      w=wold;
      if(anglechange) 
        disp('optimization wants to leave safe zone.  returning to get more patches.');
        break;
      end
    end
    if(mod(i,10)==0||nprods>=optimizationComputeLimit)
      disp(['done: ' num2str(i) ' ' num2str(toc) ' seconds']);
      disp(['lminus:' num2str(lminus)]);
      disp(['w_end:' num2str(w(end))]);
      disp(['ang_orig:' num2str(angorig)]);
      disp(['ang_new:' num2str(angnew)]);
      disp(['ang_dot:' num2str(angdiffval)]);
      disp(['nabla_end:' num2str(nabla(end))]);
      disp(['nrmstep:' num2str(nrmstep)]);
      disp(['step:' num2str(step)]);
      disp(['quadmin:' num2str(quadmin)]);
      disp(['norm w:' num2str(nrmw)]);
      disp(['active wX (pos neg): (' num2str(sum(wX(:)>0 & Y(:)>0)) ' ' num2str(sum(wX(:)>0 & Y(:)<=0)) ')']);
    end
end
disp(['made it through ' num2str(i) ' rounds']);
wX = w'*X;
outLabels=wX;
if(sum(outLabels>0)<2)
  error('too few patches in cluster...');
end

wOut = w;

if(ranqr);
    b=wOut(end);
    wOut(end)=[];
    wOut=B*wOut;
    wOut(end+1)=b;
end
wOut(end)=(wOut(end));
catch ex;dsprinterr;end
end

function res=getangle(bias,vec)
  res=acos(-bias/norm(vec));
end
