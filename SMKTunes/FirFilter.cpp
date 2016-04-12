#include "FirFilter.hpp"
#include <stdlib.h>
/**
@brief コンストラクタ
*/
CFirFilter::CFirFilter(){
	dimension = 0;
	buf = NULL;
	coef = NULL;
	current = 0;
}
/*
@brief デストラクタ
*/
CFirFilter::~CFirFilter(){
	if(buf != NULL){
		free(buf);
	}
	if(coef != NULL){
		free(coef);
	}
}
/**
@brief 次数の設定
@param[in] dim 次数
*/
void CFirFilter::SetDimension(int dim){
	if(dim < 1){
		return;
	}
	dimension = dim;
	buf = (double*)::calloc((size_t)dimension,sizeof(double));
	coef = (double*)::calloc((size_t)dimension,sizeof(double));
	current = 0;
	ClearBuffer();
	for(int i=0;i<dimension;i++){
		coef[i] = 0.0;
	}
}
/**
@brief フィルタ出力の計算
@param[in] signal 入力信号
@return 出力信号
*/
double CFirFilter::PushInput(double signal){
	buf[current] = signal;
	int i;
	double output = 0.0;
	if(current == dimension-1){
		output = 0.0;
		for(i=0;i<dimension;i++){
			output += buf[dimension-1-i]*coef[i];
		}
		current = 0;
	}else{
		output = 0.0;
		for(i=0;i<=current;i++){
			output += buf[current-i]*coef[i];
		}
		for(i=0;i<dimension-current-1;i++){
			output += buf[dimension-1-i]*coef[current+1+i];
		}
		current++;
	}
	return output;

}

double* CFirFilter::getFilterCoefficients(){
    return coef;
}
/**
@brief 保持している入力信号のバッファをクリア
*/
void CFirFilter::ClearBuffer(){
	if(dimension < 1){
		return;
	}
	for(int i=0;i<dimension;i++){
		buf[i] = 0.0;
	}
	current = 0;
}

