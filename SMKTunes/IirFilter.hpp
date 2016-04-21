//
//  IirFilter.hpp
//  SwiftSigP
//
//  Created by Kalanyu Zintus-art on 4/21/16.
//  Copyright © 2016 KoikeLab. All rights reserved.
//  Cortesy of ECE3640 Lecture

#pragma once
#include "Filter.hpp"
class CIirFilter : public CFilter{
protected:
    double *previousInput; //f[k], or the input of the difference equations
    double *previousOutput; //y[k], or the output of the difference equations
    double *numCoefficients; //numerator, or b part in Matlab filter design outputs
    double *denCoefficients; //denCoefficients, or a part in Matlab filter design outputs
    int order; //filter order
public:
    CIirFilter();
    CIirFilter(double*, double*, int);
    virtual ~CIirFilter();
    void SetDimension(int);
    virtual double PushInput(double);
    virtual void ClearBuffer();
    double* getNumeratorCoefficients();
    double* getDenominatorCoefficients();
};