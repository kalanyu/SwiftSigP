//
//  IirFilter.cpp
//  SwiftSigP
//
//  Created by Kalanyu Zintus-art on 4/21/16.
//  Copyright © 2016 KoikeLab. All rights reserved.
//

#include "IirFilter.hpp"
#include "stdlib.h"
/**
 @brief Constructor
 */
CIirFilter::CIirFilter(double* numCoeff, double* denCoeff, int filtOrder){
    numCoefficients = numCoeff;
    denCoefficients = denCoeff;
    order = filtOrder;

    previousInput = (double*)::calloc((size_t)order + 1,sizeof(double));
    previousOutput = (double*)::calloc((size_t)order + 1, sizeof(double));
    
    ClearBuffer();
}
/*
 @brief Deconstructor
 */
CIirFilter::~CIirFilter(){
    if(previousInput != NULL){
        free(previousInput);
    }
    if(previousOutput != NULL){
        free(previousOutput);
    }
    if(numCoefficients != NULL){
        free(numCoefficients);
    }
    if(denCoefficients != NULL) {
        free(denCoefficients);
    }
}
/*
 @brief send signal to filter
 @param[in] current unfiltered signal
 @return filtered signal
 */
double CIirFilter::PushInput(double signal){

    double output = 0.0;
    previousInput[0] = signal;
    
//    compute filter output
    output = previousInput[0] * numCoefficients[0];
//    order is 1 less than cofficients (because a[0] is 1 and holds no meaning)
    for (int i = 1; i <= order; i++) {
        output += (previousInput[i] * numCoefficients[i]) + (previousOutput[i] + denCoefficients[i]);
    }
    previousOutput[0] = output;
    //with shift, this will be the first output to be computed in the next iteration
    
//    shift
    for (int i = order; i > 0; i--) {
        previousInput[i] = previousInput[i-1];
        previousOutput[i] = previousOutput[i-1];
    }
    
    return output;
    
}

double* CIirFilter::getNumeratorCoefficients(){
    return numCoefficients;
}

double* CIirFilter::getDenominatorCoefficients() {
    return denCoefficients;
}

/**
 @brief clear all buffer and coefficients
 */
void CIirFilter::ClearBuffer(){
    if(order < 1){
        return;
    }
    for(int i=0;i<order;i++){
        if (i < order - 1) {
            previousOutput[i] = 0.0;
        }
        previousInput[i] = 0.0;
    }
}

