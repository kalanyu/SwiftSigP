//
//  iKoikeFilter.m
//  CPTTestApp
//
//  Created by Kalanyu Zintus-art on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "IKoikeFilter.h"
#import "KoikeFilter.hpp"
#include <stdio.h>
#include <time.h>
#include <new> //use to standard placement form of new
#include <math.h>

@interface IKoikeFilter()

@property CKoikeFilter* koikeFilters;

@end

@implementation IKoikeFilter

- (id)initWithSamplingRate:(int)samplingRate andNumberOfChannels:(int)noOfChannels {
    self = [super init];
    if (self) {
        _koikeFilters = static_cast<CKoikeFilter *>(::operator new(sizeof(CKoikeFilter) * noOfChannels));
        for (size_t i = 0; i < noOfChannels; i++) {
            ::new (&_koikeFilters[i]) CKoikeFilter(samplingRate);
        }
    }
    return self;
}

- (double)pushData:(double)data ToFilterChannel:(int)channel {
    return _koikeFilters[channel].PushInput(data);;
}

- (void)dealloc {
    delete _koikeFilters;
}

@end
