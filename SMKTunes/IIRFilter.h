//
//  LowpassFilter.h
//  SwiftSigP
//
//  Created by Kalanyu Zintus-art on 4/21/16.
//  Copyright © 2016 KoikeLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IIRFilter : NSObject

- (id)initWithNumeratorCoefficients:(double *)num andDenominatorCoefficients:(double *)den withOrder:(int)order andNumberOfChannels:(int) noOfChannels;
- (double)pushData:(double)data ToFilterChannel:(int)channel;

@end