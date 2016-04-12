/*! @file
@brief FIRフィルタ
@author Masato WATANABE
*/

#pragma once
#include "Filter.hpp"
class CFirFilter : public CFilter{
protected:
	double *buf;	// 入力された信号を保持するバッファ
public:
    int current;	// 最新の入力の場所。(リングバッファとして使うために必要)
    int dimension;	// 次数
    double *coef;	// フィルタ係数 (= インパルス応答)
	CFirFilter();
	virtual ~CFirFilter();
	void SetDimension(int);
	virtual double PushInput(double);
	virtual void ClearBuffer();
    double* getFilterCoefficients();
};