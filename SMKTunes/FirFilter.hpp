/*! @file
@brief FIR�t�B���^
@author Masato WATANABE
*/

#pragma once
#include "Filter.hpp"
class CFirFilter : public CFilter{
protected:
	double *buf;	// ���͂��ꂽ�M����ێ�����o�b�t�@
public:
    int current;	// �ŐV�̓��͂̏ꏊ�B(�����O�o�b�t�@�Ƃ��Ďg�����߂ɕK�v)
    int dimension;	// ����
    double *coef;	// �t�B���^�W�� (= �C���p���X����)
	CFirFilter();
	virtual ~CFirFilter();
	void SetDimension(int);
	virtual double PushInput(double);
	virtual void ClearBuffer();
    double* getFilterCoefficients();
};