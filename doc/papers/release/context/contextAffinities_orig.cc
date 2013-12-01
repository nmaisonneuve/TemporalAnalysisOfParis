#include "mex.h"
#include <algorithm>
#include <cmath>

using std::max;
double computeOverlap(double a_x1, double a_y1, double a_x2, double a_y2, double b_x1,double b_y1,double b_x2,double b_y2){
  double isectx=std::min(a_x2,b_x2)-std::max(a_x1,b_x1);
  if(isectx<0)
    return 0;
  double isecty=std::min(a_y2,b_y2)-std::max(a_y1,b_y1);
  if(isecty<0)
    return 0;
  double isectarea=isectx*isecty;
  double a_area=(a_x2-a_x1)*(a_y2-a_y1);
  double b_area=(b_x2-b_x1)*(b_y2-b_y1);
  return isectarea/(a_area+b_area-isectarea);
}

double scoreMatch(double* rects1, double* weights1, int len1, double* rects2, double* weights2, int len2, double* outdata, int outlen, int idx){
  int i=(int)(outdata[idx]);
  int j=(int)(outdata[idx+outlen]);
  double xscale=(rects1[len1*2+i]-rects1[i])/(rects2[len2*2+j]-rects2[j]);
  double yscale=(rects1[len1*3+i]-rects1[len1+i])/(rects2[len2*3+j]-rects2[len2+j]);
  double xtrans=rects1[i]-rects2[j]*xscale;
  double ytrans=rects1[i+len1]-rects2[j+len2]*yscale;
  double score=0;
  for(int k = 0; k<outlen; ++k){
    int ctx_i=(int)(outdata[k]);
    int ctx_j=(int)(outdata[k+outlen]);
    double ovl=computeOverlap(rects1[ctx_i],rects1[ctx_i+len1],rects1[ctx_i+2*len1],rects1[ctx_i+3*len1],
                              rects2[ctx_j]*xscale+xtrans,
                              rects2[ctx_j+len2]*yscale+ytrans,
                              rects2[ctx_j+2*len2]*xscale+xtrans,
                              rects2[ctx_j+3*len2]*yscale+ytrans);
    //score+=sqrt(weights1[ctx_i]*weights2[ctx_j]*weights1[i]*weights2[j]*rects1[i+4*len1]*rects2[j+4*len2]*max(rects1[ctx_i+4*len1]-.28,0.0)*max(rects2[ctx_j+4*len2]-.28,0.0))*ovl*ovl;//(1-(1-ovl)*(1-ovl));
    score+=sqrt(weights1[ctx_i]*weights2[ctx_j]*rects1[i+4*len1]*rects2[j+4*len2]*max(rects1[ctx_i+4*len1]-.28,0.0)*max(rects2[ctx_j+4*len2]-.28,0.0))*ovl*ovl;//(1-(1-ovl)*(1-ovl));
    //mexPrintf("sc:%f\n",score);
    //mexEvalString("drawnow;");
  }
  return (score);
}

void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
  //mexPrintf("entered mexfn\n");
  //mexEvalString("drawnow;");
  double* rects1=((double*)mxGetPr(prhs[0]));
  double* rects2=((double*)mxGetPr(prhs[1]));
  double* weights1=((double*)mxGetPr(prhs[2]));
  double* weights2=((double*)mxGetPr(prhs[3]));
  int len1 = *(mxGetDimensions(prhs[0]));
  int len2 = *(mxGetDimensions(prhs[1]));
  int i=0,j=0;
  int matches=0;
  while(i<len1&&j<len2){
    //mexPrintf("%f,%f\n",rects1[len1*5+i],rects2[len2*5+j]);
    if(rects1[len1*5+i]==rects2[len2*5+j]){
      //mexPrintf("match\n");
      
      double val=rects1[len1*5+i];
      int i_orig=i;
      int j_orig=j;
      while(i<len1 && rects1[(++i)+len1*5]==val);
      while(j<len2 && rects2[(++j)+len2*5]==val);
      matches+=(i-i_orig)*(j-j_orig);
    }else if(rects1[len1*5+i]<rects2[len2*5+j]){
      ++i;
    }else{
      ++j;
    }
  }
  int out[2];
  out[0]=matches;
  out[1]=3;
  //mexPrintf("%d\n",matches);
  //mexEvalString("drawnow;");
  plhs[0]=mxCreateNumericArray(2, out, mxDOUBLE_CLASS, mxREAL);
  double* outdata=((double*)mxGetPr(plhs[0]));
  int outlen=matches;
  i=0;j=0;
  matches=0;
  while(i<len1&&j<len2){
    //mexPrintf("%d,%d\n",i,j);
    //mexEvalString("drawnow;");
    if(rects1[len1*5+i]==rects2[len2*5+j]){
      double val=rects1[len1*5+i];
      int j_orig=j;
      while(i<len1 && rects1[i+len1*5]==val){
        for(int j_tmp=j_orig; j_tmp<len2&&rects2[j_tmp+len2*5]==val;++j_tmp){
          //mexPrintf("%d\n",matches);
          outdata[matches]=i;
          //mexPrintf("%d\n",matches+outlen);
          outdata[matches+outlen]=j_tmp;
          ++matches;
          j=j_tmp;
        }
        ++i;
      }
    }else if(rects1[len1*5+i]<rects2[len2*5+j]){
      ++i;
    }else{
      ++j;
    }
  }
  for(int i=0; i<outlen; ++i){
    outdata[i+outlen*2]=scoreMatch(rects1,weights1,len1,rects2,weights2,len2,outdata,outlen,i);
  }
  for(int i = 0; i<outlen*2; ++i){
    ++outdata[i];//convert to matlab indexing
  }

}


