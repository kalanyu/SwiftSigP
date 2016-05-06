//
//  NIDAQreader.h
//  CPTTestApp
//
//  Created by Kalanyu Zintus-art on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//#import "KoikeFilter.h"
#import <Foundation/Foundation.h>
#import "NIDAQmxBase.h"

@protocol NIDAQreaderProtocol <NSObject>
- (void)incomingStream:(NSMutableArray *)data;
- (void)DAQerrorAppeared:(NSString *)error;
@end

@interface NIDAQreader : NSObject
{
    //ivar declaration no longer necessary for LLVM 4.0
    //By default, [...] accessor methods are synthesized automatically for you by the compiler, so you don’t need to do anything other than declare the property using @property in the class interface
    NSMutableArray *incomingData;
    NSMutableArray *normalizeBuffer;
    NSMutableArray *zscoreBuffer;
    NSMutableArray *zscoreParameters;
    NSMutableArray *normalizeParameters;
    
    id<NIDAQreaderProtocol> delegate;
    float64 sampleRate, currentIndex;
    int32 pointsToRead,  totalRead, noOfChannels, gainMultiplier;
    TaskHandle taskHandle;
    BOOL running;
    NSString *channels;
//    CKoikeFilter *koikeFilters;
    NSFileManager *fileManager;
//    NSFileHandle *fileHandle, *fileHandle2;
//    NSString *fileName, *fileName_raw;
    BOOL rectify;

}
@property (nonatomic, retain) id<NIDAQreaderProtocol> delegate;
@property (nonatomic, retain) NSMutableArray *incomingData;
@property float64 sampleRate;
@property int32 pointsToRead;
@property int32 totalRead;
@property int32 noOfChannels;
@property int32 gainMultiplier;
@property BOOL running, rectify, clipping;
@property (retain) NSString *channels;
@property (nonatomic, retain) NSMutableArray *normalizeBuffer;
@property (nonatomic, retain) NSMutableArray *zscoreBuffer;
@property (nonatomic, retain) NSMutableArray *zscoreParameters;
@property (nonatomic, retain) NSMutableArray *normalizeParameters;
@property (nonatomic, retain) NSMutableArray *normParCollection;
@property (nonatomic, retain) NSFileHandle *fileHandle, *fileHandle2;
@property (nonatomic, retain) NSString *fileName, *fileName_raw;


- (id)initWithNumberOfChannels:(int)numbers andSamplingRate:(int)samplingRate;
- (void)activateKoikefilterWithSamplingRate:(int)samplingRate;
- (void)activateLowpassFilterWithCoefficients:(double *)numerator andDenominator:(double *)denominator withOrder:(int)order;
- (BOOL)activateNormalizationWithBufferSize:(int)bsize;
- (BOOL)activateZscoreWithBufferSize:(int)bsize;
- (void)startCollection;
- (void)stop;
@end
