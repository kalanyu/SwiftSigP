//
//  LowpassFilter.m
//  SwiftSigP
//
//  Created by Kalanyu Zintus-art on 4/21/16.
//  Copyright © 2016 KoikeLab. All rights reserved.
//

#import "IIRFilter.h"
#import "IirFilter.hpp"
#include <stdio.h>
#include <time.h>
#include <new> //use to standard placement form of new
#include <math.h>

@interface IIRFilter()
@property CIirFilter* iirFilters;
@end

@implementation IIRFilter

- (id)initWithNumeratorCoefficients:(double *)num andDenominatorCoefficients:(double *)den withOrder:(int)order andNumberOfChannels:(int)noOfChannels {
    self = [super init];
    if (self) {
        _iirFilters = static_cast<CIirFilter *>(::operator new(sizeof(CIirFilter) * noOfChannels));
        for (size_t i = 0; i < noOfChannels; i++) {
            ::new (&_iirFilters[i]) CIirFilter(num, den, order);
        }
    }
    return self;
}

- (double)pushData:(double)data ToFilterChannel:(int)channel {
    return _iirFilters[channel].PushInput(data);;
}

- (void)dealloc {
    delete _iirFilters;
}

@end
