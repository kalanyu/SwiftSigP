#include "KoikeFilter.hpp"
#include <math.h>

CKoikeFilter::CKoikeFilter(int size) : bufferSize(size){
	SetDimension(bufferSize);
	double t;
	double sum = 0.0;
	int i;
	for(i=0;i<bufferSize;i++){
        coef[i] = 0;
        //time scale
        //to one maybe to flat?
		t = (1.0 / bufferSize)*i;
		coef[i] = 6.44*(exp(-10.8*t) - exp(-16.52*t));
		sum += coef[i];
        //NSLog(@"%lf %lf",coef[i], sum);
	}
	double sum_inv = 1.0/sum;
	for(i=0;i<bufferSize;i++){
		coef[i] *= sum_inv;
	}

	ClearBuffer();
}

CKoikeFilter::~CKoikeFilter(){
}

