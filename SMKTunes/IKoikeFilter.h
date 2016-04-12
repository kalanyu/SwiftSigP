//
//  iKoikeFilter.h
//  CPTTestApp
//
//  Created by Kalanyu Zintus-art on 12/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IKoikeFilter : NSObject

- (id)initWithBufferSize: (int)bsize andNumberOfChannels: (int)noOfChannels;
- (double)pushData:(double)data ToFilterChannel:(int)channel;

@end