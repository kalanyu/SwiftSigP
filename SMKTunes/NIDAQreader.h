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
    NSFileHandle *fileHandle, *fileHandle2;
    NSString *fileName, *fileName_raw;
    BOOL rectify;
    BOOL clipping;

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
@property (nonatomic, retain) NSFileHandle *fileHandle, *fileHandle2;
@property (nonatomic, retain) NSString *fileName, *fileName_raw;


- (id)initWithNumberOfChannels:(int)numbers andSamplingRate:(int)samplingRate;
- (void)activateKoikefilterWithBuffersize:(int)bsize;
- (BOOL)activateNormalizationWithBufferSize:(int)bsize;
- (BOOL)activateZscoreWithBufferSize:(int)bsize;
- (void)startCollection;
- (void)stop;
@end
