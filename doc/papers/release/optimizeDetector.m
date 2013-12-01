% [ wOut outLabels ] = newClassifier( X, Y, wIn, beta1, beta2, lambda, stepsz, blockSize, maxIter, lfun, ldash )
% Inputs
% X    - dxn input n d dimensional vectors, last dimension should be all ones
% Y    - nx1 vector of labels, postive values for positive examples
% wIn  - dx1 vector with previous classifer weight vector
% beta1, beta2 - scalar parameters in score function defaults are 1 and 0
% respectively
% lambda - regularization rate default is 0.01;
% stepsz  - step size multiplier, can be a schedule default is 0.01
% blockSize - number of samples in a stochastic update step default 100
% maxIter   - max number of iterations (there is a stopping criterion also
% hardcoded in)
% lfun      - L(w'x) L function pointer, default is sigmoid
% ldash     - L'(w'x) L gradient function pointer, default is sigmoidDash
%
% Outputs
% wOut      - output classifier weight vector
% outLabels - sigmoid(w'X)

function [ wOut outLabels miscstate ] = doGradDescentActive( X, Y, wIn ,miscstate,fig)
%dsload('ds.dispoutpath');
%if(dsfield('ds.dispoutpath') && rand<.002)
if(~exist('miscstate','var'))
  miscstate=struct();
end
if(dsfield(miscstate,'savews'))
    try
      save([dsload('.ds.conf.dispoutpath') '/data' num2str(miscstate.savews)]);
    catch
      %not that important...just give up
    end
    miscstate=rmfield(miscstate,'savews');
    %save([dsload('ds.dispoutpath') '/data' num2str(round(rand*10000))]);
end
if(~exist('fig','var') && dsfield(miscstate,'patches'))
    miscstate=rmfield(miscstate,'patches');
end
if(isfield(miscstate,'roundid'))
  roundid=miscstate.roundid;
  miscstate=rmfield(miscstate,'roundid');
else
  roundid=-1;
end

global ds;
%X(:,end+1)=X(:,1482);
%X(:,end+1)=X(:,1482);
%X(:,end+1)=X(:,1482);
%X(:,end+1)=X(:,1482);
%Y(end+1:end+1)=1;
%miscstate.alpha(end+1:end+1)=0;
%miscstate.patches(end+1:end+1)=repmat(miscstate.patches(1482),1,1);
disp([num2str(size(X,2)) 'points, ' num2str(sum(Y>0)) ' pos'])
try

  %if(dsfield(miscstate,'alpha'))
  %  alpha=miscstate.alpha;
  %else
  %  alpha=zeros(size(X,2),1);
  %  alpha(1)=1;
  %end
  %size(alpha)
wIn(end)=wIn(end)+1;


debug = false;

n = size(X,2);
if (~all(X(end,:) == 1))
    fprintf('Appending row of ones to feature vector\n');
    X = [X; ones(1, n)];
end
d = size(X,1);
disp('v2')
minneg=10;%.33/1000;%UNCOMMENT WAS .5 THIS IS NOT RIGHT!
if(sum(Y<=0)==0)
  wOut=wIn(:);%X(:,Y==1);
  outLabels=(wOut(:)')*X;
  return
end
if((sum(Y>0)==1) || (isfield(miscstate,'weights')&&sum(miscstate.weights)==0) || (roundid>0 && roundid<=3))
  wOut=wIn(:);%X(:,Y==1);
  if(isempty(X))
    scores=[];
    return;
  end
  scores=(wOut(:)')*X;
  negs=scores(Y<=0);
  toadd=fminsearch(@(x) (sum(x+negs((x+negs)>0))-minneg)^2,0,optimset('tolX',eps))
  wOut(end)=wOut(end)+toadd;
  scores=scores+toadd;
  toadd=.0001-min(max(scores(Y<=0)),max(scores(Y>0)));
  toadd=max(0,toadd);
  wOut(end)=wOut(end)+toadd;
  outLabels=scores+toadd;
  outLabels=outLabels-1;
  wOut(end)=wOut(end)-1;
  return;
end
  wendscale=10;
  wIn(end)=(wIn(end))*wendscale;
  X(end,:)=X(end,:)/wendscale;
wtdecay=0

%optargs = {[] 0 1 0.0001 1 100 1000 @sigmoid @sigmoidDash};
%optargs(1:numel(varargin)) = varargin;
%[wIn beta1 beta2 lambda stepsz blockSize maxIter lfun ldash] = optargs{:};
beta1=0;
beta2=0;
if(dsfield(ds,'conf','params','lambda'))
    lambda=ds.conf.params.lambda;
end
if(dsfield(ds,'conf','params','stepSize'))
    stepsz=ds.conf.params.stepSize/10;
end
if(dsfield(ds,'conf','params','projstepsz'))
    projstep=ds.conf.params.projstepsz;
else
    projstep=.1;
end
if(dsfield(ds,'conf','params','maxIter'))
    maxIter=ds.conf.params.maxIter;
end
if(dsfield(ds,'conf','params','scoreFun'))
    lfun=ds.conf.params.scoreFun;
end
if(dsfield(ds,'conf','params','scoreDeriv'))
    ldash=ds.conf.params.scoreDeriv;
end
if(dsfield(ds,'conf','params','blockSize'))
    blockSize=ds.conf.params.blockSize;
end
if(dsfield(ds,'conf','params','wtdecay'))
    wtdecay=ds.conf.params.wtdecay;
end
if(dsfield(ds,'conf','params','nrmlambda'))
  nrmlambda=ds.conf.params.nrmlambda;
else
  nrmlambda=.1;
end
if(dsfield(ds,'conf','params','minneg'))
  minneg=ds.conf.params.minneg;
else
  minneg=1;
end

%if (isempty(wIn))
%    wIn = zeros(d,1,class(X));
%end

if(size(X,1)>size(X,2))
    X=X(1:end-1,:);
    [B,~]=qr(X);
    B=B(:,1:size(X,2));
    %B=orth(X);
    X=(B')*X;
    X(end+1,:)=1/wendscale;
    b=wIn(end);
    wIn=((wIn(1:end-1)')*B)';
    wIn(end+1)=b;
    trans=1;
else
    trans=0;
end
%if (blockSize > n || blockSize <= 0)
%    blockSize = n;
%end

%if (numel(stepsz) == 1)
%    stepsz = stepsz * ones(maxIter,1);
%end


Y = Y(:);
%w2=miscstate.weights(2:end);
%miscstate.weights(1)=miscstate.weights(1)*.7+.3*sum(w2(Y(2:end)>0).^2)/sum(w2(Y(2:end)>0));
if(dsbool(ds.conf.params,'useweightsinopt')&&dsfield(miscstate,'weights'))
  weights=miscstate.weights(:)';
  size(Y)
  size(weights)
  weights=weights./max(weights(Y<=0));
  weights(Y<=0)=1;;
  weights(Y>0)=weights(Y>0)/10;
  %w2=weights(2:end);%UNCOMMENT
  %weights(1)=max(w2(Y(2:end)>0));%UNCOMENT
else
  weights=ones(size(Y))';
  if(dsbool(ds.conf.params,'posweight'))
    weights(Y==1)=ds.conf.params.posweight;
  end
end
stepszalpha=stepsz*2000/sum(weights);
%alphaorig=alpha;
%fail=1;
%while(fail)

%  alpha=alphaorig;

  w = wIn;

  score = zeros(maxIter,1);
  step  = zeros(maxIter,1);

  %Xplus = X(:,Y > 0);

  %stepsz(end-99:end) = stepsz(end-99) * ( 0.95 .^ (0:99) );

  %fail=0;
  zkm1=w;
  zkm2=zkm1;
  zpenlagkm1=0;
  zpenlagkm2=zpenlagkm1;
  znrmlagkm1=0;
  znrmlagkm2=znrmlagkm1;
  bestscr=-Inf;
  bestw=w;
  histw = [];
  histpt = [];
  tic

  slack     = zeros(size(Y));
  deltaw    = 0;
  w_orig=w;
  stopflag=0;
  toofewmemberspen=.001;
        gamma=100;
        lambda=1000;
  nrmlag=0;
  
  penlag=0/0;

  a=0;
  drp=ones(size(Y));
  if(dsfield(miscstate,'drop'))
    drp(miscstate.drop)=0;
  end
  drp=drp==1;
  nprods=0;
  i=0;
  nfails=0;
  nrmstepdecay=.1;
  nquadmins=0;
  while(nprods<maxIter*3 && nrmstepdecay > 1e-8 && nquadmins<10)
     i=i+1;
      %wX = w'*X;
      %slack = slack - deltaw;
      activeSet = ones(size(X(:,1)));%slack <= 0;
      if (sum(activeSet) < size(X,2)/3)
          wX = -zeros(1,numel(Y))-.022;
          wX(activeSet) = w'*X(:,activeSet);
      else
          wX = w'*X;
      end
      nprods=nprods+1;
      if(i==1)
        negs=wX(Y<=0);
        negweights=weights(Y<=0);
        toadd=fminsearch(@(x) ((x+negs((x+negs)>0))*negweights((x+negs)>0)'-minneg)^2,0,optimset('tolX',eps))
        w(end)=w(end)+toadd*wendscale;
        wX=wX+toadd;
      end
      %disp('wx787')
      %disp(wX(787))
      %min(wX)
      %sum(activeSet)
      %pause(.1);

      %alphaset=((wX'>-1.02 & Y<=0) | (wX'>-1 & Y>0));
      %if(i<=500)
      %alphaset=(alpha~=0);
        while(sum(weights(drp & (wX)'>0 & Y<=0).*(wX(drp & (wX)'>0 & Y<=0)))==0)
          disp('too few members, fixing bias...');
          nfails=nfails+1;
          if(nfails>100000)
               save([dsload('.ds.conf.dispoutpath') '/biasfail' num2str(floor(rand*1000))]);
               error('too many bias fails');
          end
          toadd=.01;
          %toadd=-.99999-min(max(wX(Y>0)),max(wX(Y<=0)));
          wX=wX+toadd;
          w(end)=w(end)+toadd*wendscale;
        end
      %if(1)%mod(i,5)==1)
      %  toadd=fminsearch(@(x) -sum(weights(drp & (wX+x)'>-1 & Y>0).*(wX(drp & (wX+x)'>-1 & Y>0)+x+1))/sum(weights(drp & (wX+x)'>-1 & Y<=0).*(wX(drp & (wX+x)'>-1 & Y<=0)+x+1))+toofewmemberspen.*mylog2(sum(weights(drp & (wX+x)'>-1 & Y<=0).*(wX(drp & (wX+x)'>-1 & Y<=0)+x+1))-minneg),0,optimset('tolX',eps));%-...
            %sum(abs(alpha(alphaset))'.*mylog((wX(alphaset)+x+1+.02*(Y(alphaset)'<=0))*gamma))/lambda,0,optimset('tolX',eps));
            %lambda*log(alpha(((wX+x)'>-1.02 & Y<=0) | ((wX+x)'>-1 & Y>0)).*
            %          (wX(((wX+x)'>-1.02 & Y<=0) | ((wX+x)'>-1 & Y>0))+x+1+.02*(Y(((wX+x)'>-1.02 & Y<=0) | ((wX+x)'>-1 & Y>0))'<=0))*gamma));
      %  w(end)=w(end)+toadd;
      %  wX=wX+toadd;
      %end
      %end

      %if(wX(1)<-1)
      %  disp('failed');
      %  else
      %    fail=1;
      %    weights(1)=weights(1)*1.5;
      %    break
      %  end
      %end
      %slack(activeSet) = -0.022-wX(activeSet);

      %fprintf('%g %g\n',sum(activeSet), max(slack))
      %fw = classifierScore(wX,Y,beta1,beta2,lfun); %-.5*lambda*sum(w(1:end-1).^2);
      %if(fw>bestscr)
      %    bestscr=fw;
      %    bestw=w;
      %end
      lfull = wX.*weights;%lfun(wX(drp)).*weights(drp);
      lfull(wX<0)=0;
      ldashfull = sign(lfull).*weights;%ldash(wX(drp)).*weights(drp);
      onSet  = lfull' > 0;
      contribIdx = Y(drp)>0; % for hinge
      %   contribIdx = logical(Y); % for logistic
      %this line does not make sense....
      %   fdashfull = sum(bsxfun(@times, ldashfull(contribIdx), X(:,contribIdx)), 2);
          
      %fden   = sum(lfull((~contribIdx) & onSet))  + beta2;
      
      %lplus = sum(lfull(contribIdx & onSet));
      lminus = sum(lfull((~contribIdx) & onSet));
      ldashplus  = X(:,contribIdx& onSet) * ldashfull(contribIdx & onSet)' ; %sum(bsxfun(@times, ldashfull(contribIdx & onSet), X(:,contribIdx & onSet)) , 2);
      %ldashminus = X(:,(~contribIdx) & onSet) * ldashfull((~contribIdx) & onSet)' ;% sum(bsxfun(@times, ldashfull(~contribIdx & onSet), X(:,~contribIdx & onSet)) , 2);
      %if(isnan(penlag))
      %  penlag=ldashplus(end)/ldashminus(end);
      %end
      %penlagapprox=ldashplus(end)/ldashminus(end);
      %ldashminus=ldashminus*penlag;
      %THIS IS (PROBABLY) NOT RIGHT! this should be multiplied by 2
      ldashnrm=w*nrmlambda;
      ldashnrm(end)=0;
      %if(lminus<1)
      %  lminus=.5+lminus*lminus/2;
      %  ldashminus=ldashminus*lminus;
      %  fden=lminus;
      %end
      projspace=X(:,(~contribIdx) & onSet)*weights((~contribIdx) & onSet)';
      nprods=nprods+1;
      projspace=projspace/norm(projspace);
      nabla=ldashplus-ldashnrm;
      nabla = nabla-projspace*(nabla'*projspace);%ldashplus-ldashminus-ldashnrm;%( (lminus+beta2)*ldashplus - lplus*ldashminus ) / (fden*fden);
      normquad=-[sum(nabla(1:end-1).^2),sum(2.*w(1:end-1).*nabla(1:end-1)),sum(w(1:end-1).^2)]*nrmlambda;
      ldashplusquad=ldashplus'*nabla;
      %THIS IS (PROABBLY) NOT RIGHT! new derivation shows ldashplusquad and
      %normquad should probably have same sign...i.e. should be a negative
      %in front of normquad(2)...actually it's fine
      quadmin=(normquad(2)+ldashplusquad)/(-2*normquad(1));
      %nabla=nabla+toofewmemberspen./max(lminus-minneg,.00001).^2*ldashminus;
      %nablapenlag=lminus-minneg;
      %nablanrmlag=norm(w(1:end-1))-1;
      dall=nabla'*X;
      nprods=nprods+1;
      dall=-wX./dall;
      dall(dall<0)=Inf;
      [dall,dallidx]=sort(dall,'ascend');
      %toavg=max(2,min(find(cumsum(dall)>.0001)));
      %[zercross,zercrossidx]=mink(dall,2);
      %step=mean([dall(1) dall(toavg)]);%.75*zercross(1)+.25*zercross(2);
      step=projstep;
      wold = w;
      %step
      %quadmin
      %if(i>100)
      %  keyboard
      %end
      %THIS IS NOT RIGHT! taking the quadmin step may still cause sign changes...
      if(step<quadmin)
        nquadmins=0;
        w=w+nabla*step;
        nrmstep=norm(nabla*step);
        negWx=w'*X(:,(~contribIdx));
        while(sum(weights(~contribIdx).*negWx)==0)
          disp('too few members, fixing bias...');
          nfails=nfails+1;
          if(nfails>100000)
               save([dsload('.ds.conf.dispoutpath') '/biasfail' num2str(floor(rand*1000))]);
               error('too many bias fails');
          end
          toadd=.01;
          %toadd=-.99999-min(max(wX(Y>0)),max(wX(Y<=0)));
          negwX=negwX+toadd;
          w(end)=w(end)+toadd*wendscale;
        end
        negweight=weights(~contribIdx);
        totneg=negWx(negWx>0)*negweight(negWx>0)';
        neggt0=~contribIdx;
        neggt0(~contribIdx)=negWx>0;
        nprojs=1;
        a=Inf;
        while(1)%abs(totneg-minneg)>.0000001)
          projdir=X(:,neggt0)*weights(neggt0)';
          nprods=nprods+1;
          dnegs=projdir'*X(:,(~contribIdx));
          nprods=nprods+1;
          zer=(minneg-totneg)./(dnegs(neggt0(~contribIdx))*weights(neggt0)');
          if(zer<0)
            projdir=-projdir;
            zer=-zer;
            dnegs=-dnegs;
          end

          signchg=-negWx./dnegs;
          signchg(signchg<=.00000001)=Inf;
          %disp(['' num2str(min(signchg))])
          w2=w+projdir*zer;
          %newwx=w2'*X;
          %newwx(neggt0)*weights(neggt0)'
          if(min(signchg)<zer && zer>1e-10)
            nprojs=nprojs+1;
            [msc,idx]=min(signchg);
            %totneg=totneg+(dnegs(neggt0(~contribIdx))*weights(neggt0)')*msc;
            %nmmmn=totneg-minneg
            fContribIdx=find(~contribIdx);
            wXidx=fContribIdx(idx);
            w2=w+projdir*msc;
            w=w+projdir*msc;
            newwx=w2'*X;
            nprods=nprods+1;
            negWx=newwx(~contribIdx);

            
            b=newwx(neggt0)*weights(neggt0)'-minneg;
            neggt0(wXidx)=~neggt0(wXidx);
            totneg=newwx(neggt0)*weights(neggt0)';
            %if(abs(b)>abs(a)+1e-4)
            %  keyboard
            %end
            a=b;
            %keyboard
          else
            w=w+projdir*zer;
            %totneg-minneg
            %keyboard
            break;
          end
        end
        if(nprojs>1)
          %disp(['warning: projected ' num2str(nprojs) ' times this round']);
          %keyboard
        end
      else
        w=w+nabla*quadmin;
        nrmstep=norm(nabla*quadmin);
        nquadmins=nquadmins+1;
        %disp('quadmin');
        %keyboard
      end
      nrmstepdecay=nrmstepdecay*.9+nrmstep*.1;
      %penlag
      %nablapenlag
      %ldashminus(end)

      
      %     nabla = nabla / size(Xplus,2);
      
      
      nrm = norm(nabla);
      %step(i)=nrm;
      
  %          w = w + stepsz(i) * (nabla - regterm); %no momentum
      
  %    with momentum
      if(exist('alpha','var'))
        %alphaset=((wX'>-1.02 & Y<=0) | (wX'>-1 & Y>0));
        %flipmask=((Y(alphaset)>0)*2-1);
        %Xsel=X(1:end-1,alphaset);
        %Xalpha=Xsel*alpha(alphaset);
        %tic;
        %  ((Xalpha)'*Xsel)/norm(Xalpha)^3;
        %a=a+toc
        %dWdalpha=-(Xalpha)*((Xalpha)'*Xsel)/norm(Xalpha)^3+Xsel/norm(Xalpha);%Xsel
        %wXflr=max((wX(alphaset)+1+.02*(Y(alphaset)'<=0))*gamma,.00001);
        %nabla=nabla+[Xsel*(abs(alpha(alphaset))./(wXflr')); sum(abs(alpha(alphaset))./(wXflr'))]*gamma/lambda;%nabla is dscore/dw
        %nablaalpha=(-(nabla(1:end-1))'*(Xalpha)*((Xalpha)'*Xsel)/norm(Xalpha)^3+(nabla(1:end-1))'*Xsel/norm(Xalpha))'; %=nabla*dwdalpha
        %nablaalpha=nablaalpha+sign(alpha(alphaset)).*mylog((wX(alphaset)+1+.02*(Y(alphaset)'<=0))*gamma)'/lambda;
        %nablaalpha(Y(alphaset)>0)=nablaalpha(Y(alphaset)>0)-0/lminus;
        %mask=zeros(size(alpha));
        %mask(alphaset)=1;
        %if(0)
        %z=mask;
        %z(alphaset)=flipmask.*ProjectOntoSimplex(flipmask.*(alpha(alphaset)+stepszalpha*nablaalpha),1);
        %zkm2=zkm1.*mask;
        %zkm1=z.*mask;
        %alphaold=alpha;
        %alpha=mask;
        %alpha(alphaset)=flipmask.*ProjectOntoSimplex(flipmask.*(zkm1(alphaset)+(i-1)/(i+2)*(zkm1(alphaset)-zkm2(alphaset))),1);%accelerated generalized gradient method; note that 
                                                                                                         %z variables here correspond to x in the formulas; alpha/w correspond
                                                                                                         %to the y.
        %else
        %  alpha(alphaset)=ProjectOntoSimplex(alpha(alphaset)+stepsz*nablaalpha,1);
        %end
        %alpha(alpha>0)=alpha(alpha>0)+(1-norm(alpha,1))/sum(alpha>0);%if we dropped something out, we can have norm(alpha,1)<1
        %wold = w;
        %w(1:end-1)=(Xsel*alpha(alphaset));
        %w(1:end-1)=w(1:end-1)/norm(w(1:end-1));
        %if(i==501)
        %  zbkm1=w(end);
        %  zbkm2=w(end);
        %end
        %if(i>500)
        %  zb=w(end)+stepsz*nabla(end);;
        %  zbkm2=zbkm1;
        %  zbkm1=zb;
        %  w(end)=zbkm1+(i-1)/(i+2)*(zbkm1-zbkm2);%w(end)+stepsz*nabla(end);
        %end
        
        %keyboard
        %end
      else
        %regterm=w(1:end-1);
        %sum(abs(regterm));
        %sum(abs(nabla));
        %regterm(end)=0;
        %wold = w;
        %w = w + stepsz * nabla;
        %z = w + stepsz * nabla;
        %z=z/norm(z);
        %zkm2=zkm1;
        %zkm1=z;
        %try
        %w=zkm1+(i-1)/(i+2)*(zkm1-zkm2);
        %catch,keyboard;end
        %nrmlag=nrmlag+stepsz*nablanrmlag;
        %znrmlag=nrmlag+stepsz*nablanrmlag;
        %znrmlagkm2=znrmlagkm1;
        %znrmlagkm1=znrmlag;
        %nrmlag=znrmlagkm1+(i-1)/(i+2)*(znrmlagkm1-znrmlagkm2);
        %penlag=penlag+stepsz*nablapenlag;
        %zpenlag=penlag+stepsz*100*nablapenlag;
        %zpenlagkm2=zpenlagkm1;
        %zpenlagkm1=zpenlag;
        %penlag=zpenlagkm1+(i-1)/(i+2)*(zpenlagkm1-zpenlagkm2);
        %if(nrmlag<0)
        %  disp(['warning:nrmlag=' num2str(nrmlag)]);
        %  nrmlag=0;
        %end
        %if(penlag<0)
        %  disp(['warning:penlag=' num2str(penlag)]);
        %  penlag=0;
        %end
        

        %w(1:end-1)=w(1:end-1)/norm(w(1:end-1));
        
      end
      nrmw=(norm(w(1:end-1)));
      deltaw = norm(w-wold)*sqrt(2);
      
      if (debug)
          %  [~,ord]=sort(wX(:),'descend');
          %  figure(55);
          %  for(i=1:10)
          %    subplot(1,10,i);
          %    imagesc(miscstate.patches{ord(i)});
          %    title(num2str(wX(ord(i))));
          %    drawnow;
          %  end
          %end
          score(i)=fw;
          if(fw<bestscr)
          end
      end
      %anglechange=getangle(w_orig(end)+1)<acos(dot(w_orig(1:end-1),w(1:end-1)))+getangle((w(end)+1)*norm(w(1:end-1)))/2;
      anglechange=getangle((w_orig(end)/wendscale)/norm(w_orig(1:end-1)))*.5>getangle((w(end)/wendscale)/norm(w(1:end-1)))-acos(dot(w_orig(1:end-1),w(1:end-1))/(norm(w(1:end-1))*norm(w_orig(1:end-1))));
      angorig=getangle((w_orig(end)/wendscale)/norm(w_orig(1:end-1)));
      angnew=getangle((w(end)/wendscale)/norm(w(1:end-1)));
      angdiffval=acos(dot(w_orig(1:end-1),w(1:end-1))/(norm(w(1:end-1))*norm(w_orig(1:end-1))));
      bignabla=abs(nabla(end))>50;
      %keyboard
      if(anglechange&&~dsbool(ds.conf.params,'nocheck'))%||bignabla)
        if(anglechange)
          disp(['iteration ' num2str(i) ': changed too much, killing momentum']);
        else
          disp('nabla(end) too large');
        end
        %alpha=alphaold;
        w=wold;
        z=w;
        zkm1=z;
        zkm2=z;
        zpenlag=penlag;
        zpenlagkm1=zpenlag;
        zpenlagkm2=zpenlag;
        znrmlag=nrmlag;
        znrmlagkm1=znrmlag;
        znrmlagkm2=znrmlag;

        if(anglechange&&stopflag) 
          disp('optimization wants to leave safe zone.  returning to get more patches.');
          break;
        end
        stopflag=1;
      else
        stopflag=0;
      end
      if(mod(i,10)==0||nprods>=maxIter*3)
        disp(['done: ' num2str(i) ' ' num2str(toc) ' seconds']);
        disp(['lminus:' num2str(lminus)]);
        %disp(['max alpha:' num2str(max(alpha))]);
        %disp(['nnonzero:' num2str(sum(alpha~=0))]);
        %td=alpha(alpha~=0);
        %[~,idx2]=sort(td,'descend');
        %idx=find(alpha~=0);
        disp(['w_end:' num2str(w(end))]);
        disp(['ang_orig:' num2str(angorig)]);
        disp(['ang_new:' num2str(angnew)]);
        disp(['ang_dot:' num2str(angdiffval)]);
        disp(['nabla_end:' num2str(nabla(end))]);
        disp(['nrmstep:' num2str(nrmstep)]);
        disp(['step:' num2str(step)]);
        disp(['quadmin:' num2str(quadmin)]);
        %disp(['penlag:' num2str(penlag)]);
        %disp(['penlag aprox:' num2str(penlagapprox)]);
        %disp(['nrmlag:' num2str(nrmlag)]);
        %disp(['nablaalpha_max:' num2str(max(nablaalpha))]);
        %disp(['nablaalpha_min:' num2str(min(nablaalpha))]);
        %disp(['alphapenalty:' num2str(log(max(wX+1,.000001))*alpha)]);
        disp(['norm w:' num2str(nrmw)]);
        %disp(['w_end adjustment:' num2str(toadd)]);
        disp(['active wX (pos neg): (' num2str(sum(wX(:)>0 & Y(:)>0)) ' ' num2str(sum(wX(:)>0 & Y(:)<=0)) ')']);
        %if(numel(idx2)>80)
        %  idx2=idx2([1:40 end-39:end]);
        %end
        %disp(['alpha:' num2str(td(idx2)')]);
        %disp(['idx:' num2str(idx(idx2)')]);
        if(exist('fig','var') && dsfield(miscstate,'patches'))
          %figure(1);
          %clf;
          %for(m=1:numel(idx2))
          %  subplot(4,20,m);
          %  imagesc(miscstate.patches{idx(idx2(m))});
          %  xlabel(td(idx2(m)));
          %end
          [~,idx2]=sort(wX,'descend');
          idx2=idx2(:)';
          disp(num2str(idx2(1:20)));
          figure(fig);
          clf;
          for(m=1:min(80,numel(idx2)))
            subplot(4,20,m);
            imagesc(miscstate.patches{idx2(m)});
            xlabel(wX(idx2(m)));
            title(miscstate.weights(idx2(m)));
          end
          drawnow
          nabla(1:5)
        end
      end
  end
  disp(['made it through ' num2str(i) ' rounds']);
%end
wX = w'*X;
negs=wX(Y<=0);
%toadd=fminsearch(@(x) (sum(x+negs((x+negs)>0))-minneg)^2,0,optimset('tolX',eps))
negweights=weights(Y<=0);
toadd=fminsearch(@(x) ((x+negs((x+negs)>0))*negweights((x+negs)>0)'-minneg)^2,0,optimset('tolX',eps))
w(end)=w(end)+toadd*wendscale;
wX=wX+toadd;
outLabels=wX;
%fw = classifierScore(wX,Y,beta1,beta2,lfun);%-.5*lambda*norm(w(1:end-1))^2;
%if(fw>bestscr)
%    bestscr=fw;
%    bestw=w;
%end
%miscstate.alpha=alpha;
%disp([num2str(sum(alpha~=0)) ' nonzero alphas'])

wOut = w;%bestw;

if(trans);
    b=wOut(end);
    wOut(end)=[];
    wOut=B*wOut;
    wOut(end+1)=b;
end
wOut(end)=(wOut(end))/wendscale;
wOut(end)=wOut(end)-1;
outLabels=outLabels-1;

if (debug)
    figure(3);plot(score(1:i));title('Classifier Score');xlabel('Iterations');
    figure(4);plot(step(1:i),'r');title('Gradient ascent step magnitude');xlabel('Iterations');
    %keyboard
end
%if (nargout > 1)
%    outLabels = (w'*X);
%end
catch ex;dsprinterr;end
end

function res=getangle(a)
  res=acos(-a);
end
function res=mylog(a)
  res=zeros(size(a));
  res(a>.00001)=log(a(a>.00001));
  res(a<=.00001)=log(.00001)+100000*(a(a<=.00001)-.00001);
end
function res=mylog2(a)
  res=zeros(size(a));
  res(a>0)=1./(a(a>0));
  res(a<=0)=Inf;%log(.001)+100000*(a(a<=.00001)-.00001);
end
