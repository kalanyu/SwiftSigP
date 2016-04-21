//
//  NIDAQreader.m
//  CPTTestApp
//
//  Created by Kalanyu Zintus-art on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NIDAQreader.h"
#import "IKoikeFilter.h"
#import "LowPassFilter.h"
#include <stdio.h>
#include <time.h>
#include <math.h>

#define DAQmxErrChk(functionCall) { if( DAQmxFailed(error=(functionCall)) ) { goto Error; } }
#define KFILTER_OFF 1
#define KFILTER_ON 2
#define LPFILTER_OFF 1
#define LPFILTER_ON 2
#define NORMALIZE_ON 1
#define NORMALIZE_WORKING 2
#define NORMALIZE_OFF 0
#define ZSCORE_ON 1
#define ZSCORE_WORKING 2
#define ZSCORE_OFF 0

@interface  NIDAQreader()
//private
@property (nonatomic, retain) IKoikeFilter* koikeFilters;
@property (nonatomic, retain) LowpassFilter* lowpassFilters;
@end

@implementation NIDAQreader
@synthesize delegate, incomingData, sampleRate, pointsToRead, totalRead, running, channels;
@synthesize noOfChannels;
@synthesize normalizeBuffer;
@synthesize normalizeParameters;
@synthesize zscoreBuffer;
@synthesize zscoreParameters;
@synthesize gainMultiplier;
@synthesize rectify;

//status definition and corresponding parameters
typedef enum processingStatus { deactivated, activated, processing } status;
status static kFilterStat;
status static lpFilterStat;
status static normalizeStat;
status static normalizeBufferSize;
status static zscoreStat;
status static zscoreBufferSize;


- (id)init {
    self = [super init];
    if (self) {
        self.incomingData = [NSMutableArray arrayWithObjects:
                             [NSMutableArray arrayWithCapacity:1000], 
                             [NSMutableArray arrayWithCapacity:1000],
                             [NSMutableArray arrayWithCapacity:1000],
                             [NSMutableArray arrayWithCapacity:1000],
                             nil];
        sampleRate = 2000;
        pointsToRead = 50;
        totalRead = 0;
        currentIndex = -5.0;
        rectify = YES;
        kFilterStat = deactivated;
        lpFilterStat = deactivated;
        _clipping = true;
    }
    return self;
}

- (id)initWithNumberOfChannels:(int)numbers andSamplingRate:(int)samplingRate
{
    self = [super init];
    if (self) {
        channels = @"";
        noOfChannels = numbers;
        self.incomingData = [NSMutableArray arrayWithCapacity:numbers];
        for (int i = 0; i < numbers; i++) {
            [self.incomingData addObject:[NSMutableArray arrayWithCapacity:1000]];
            if (numbers - i == 1) {
                channels = [channels stringByAppendingFormat:@"Dev1/ai%d",i];
            }
            else {
                channels = [channels stringByAppendingFormat:@"Dev1/ai%d, ",i];
            }
        }
//        [channels retain];
        //minimum is 60 fps
        sampleRate = samplingRate;
        pointsToRead = samplingRate / 50;
        totalRead = 0;
        currentIndex = -5.0;
        rectify = NO;
        kFilterStat = deactivated;
        lpFilterStat = deactivated;
        gainMultiplier = 1;
        _clipping = true;
    }
    return self;
}

// TODO: return raw and filtered
- (void)startCollection
{
    running = YES;
    // Task parameters
    int32       error = 0;
    taskHandle = 0;
    char        errBuff[2048]={'\0'};
//    t ime_t      startTime;

    // Channel parameters
    float64     min = -10.0;
    float64     max = 10.0;
    
    // Timing parameters
    char        clockSource[] = "OnboardClock";
    //    uInt64      samplesPerChan = 1000; not neccessary because its on cont mode
    
    // Data read parameters
    #define     bufferSize (uInt32) 6000
    float64     data[pointsToRead * noOfChannels];
    int32       pointsRead;
    float64     timeout = 5.0;

    fileManager = [NSFileManager defaultManager];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"kk_mm_ss"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    
    
    _fileName = [NSString stringWithFormat:@"%@/Desktop/EMGSensingData/%ld/%ld/%ld_%@_filtered.csv",NSHomeDirectory(),(long)dateComponents.year, dateComponents.month, dateComponents.day, [formatter stringFromDate:date]];
    _fileName_raw = [NSString stringWithFormat:@"%@/Desktop/EMGSensingData/%ld/%ld/%ld_%@_raw.csv",NSHomeDirectory(),(long)dateComponents.year, dateComponents.month, dateComponents.day, [formatter stringFromDate:date]];

    DAQmxErrChk (DAQmxBaseCreateTask("",&taskHandle));
    DAQmxErrChk (DAQmxBaseCreateAIVoltageChan(taskHandle,[channels cStringUsingEncoding:NSUTF8StringEncoding],"",DAQmx_Val_Cfg_Default,min,max,DAQmx_Val_Volts,NULL));
    DAQmxErrChk (DAQmxBaseCfgSampClkTiming(taskHandle,clockSource,sampleRate,DAQmx_Val_Rising,DAQmx_Val_ContSamps,0));
    DAQmxErrChk (DAQmxBaseCfgInputBuffer(taskHandle,0)); //use a 100,000 sample DMA buffer
    DAQmxErrChk (DAQmxBaseStartTask(taskHandle));
    NSLog(@"???");

    //calculate date & time for filename designation
    
    // This is where we designate the filename
    
    //begin: check the availability of the filename in order to create necessary files/folders
    if(![fileManager fileExistsAtPath:_fileName])
    {
        NSError *err;
        BOOL ret;
        if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/Desktop/EMGSensingData/%ld/%ld",NSHomeDirectory(),(long)dateComponents.year, dateComponents.month] isDirectory:&ret]) {
            [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/Desktop/EMGSensingData/%ld/%ld/",NSHomeDirectory(),(long)dateComponents.year, dateComponents.month] withIntermediateDirectories:YES attributes:nil error:&err];
            if (err) {
                NSLog(@"%@ %@",err, NSHomeDirectory());
            }
        }
        if([fileManager createFileAtPath:_fileName contents:nil attributes:nil] && [fileManager createFileAtPath:_fileName_raw contents:nil attributes:nil])
        {
            NSLog(@"new file created");
        }
        else
        {
            NSLog(@"file creation failed");
        }
    }
    if(!([fileManager fileExistsAtPath:_fileName] && [fileManager fileExistsAtPath:_fileName_raw]))
    {
        NSLog(@"file %@ and %@ not exist",_fileName, _fileName_raw);
    }
    else
    {
        NSLog(@"file %@ and %@ exists", _fileName, _fileName_raw);
    }
    //end: file checking
    
    
    //prepare file write by moving the cursor to the end of file
    _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_fileName_raw];
    [_fileHandle seekToEndOfFile];
    _fileHandle2 = [NSFileHandle fileHandleForUpdatingAtPath:_fileName];
    [_fileHandle2 seekToEndOfFile];
    
    [formatter setDateFormat:@"HH:mm:ss.SSS"];
    //initialize the sensor reading component and assign it to another thread

    // The loop will quit after 10 seconds
    
    //    startTime = time(NULL);

    while(running) {
        DAQmxErrChk (DAQmxBaseReadAnalogF64(taskHandle,pointsToRead,timeout,DAQmx_Val_GroupByChannel,data,pointsToRead * noOfChannels,&pointsRead,NULL));
        totalRead += pointsRead;
        NSDate *now = [NSDate date];
        NSString *strNow = [formatter stringFromDate:now];

        // Just print out the first 10 points of the last data read
        NSDictionary *incoming;
//        NSAutoreleasePool *pool;
//        pool = [[NSAutoreleasePool alloc] init];
        @autoreleasepool {
        for (int i = 0; i < pointsToRead; ++i)
        {
            
            NSString *fileWrite = @"";
            NSString *fileWriteFiltered = @"";
//            fileWrite = [NSString stringWithFormat:@"%@",strNow];
            fileWrite = [NSString stringWithFormat:@"%d",totalRead-pointsToRead+i+1];
            fileWriteFiltered = [NSString stringWithFormat:@"%d", totalRead-pointsToRead+i+1];
            fileWrite = [fileWrite stringByAppendingFormat:@",%@", strNow];
            fileWriteFiltered = [fileWriteFiltered stringByAppendingFormat:@",%@", strNow];
            for (int j = 0; j < noOfChannels; j++) {
                
                //preping string for file write (raw)

                
                double emgData = data[(pointsToRead*j)+i];
                
                if (zscoreStat == deactivated) {
                    [[zscoreBuffer objectAtIndex:j] addObject:[[NSNumber alloc] initWithDouble:emgData]];
                    if ([[zscoreBuffer objectAtIndex:j] count] == zscoreBufferSize)
                    {
                        double sum = 0;
                        for (NSNumber *sValue in [zscoreBuffer objectAtIndex:j]) {
                            sum += [sValue doubleValue];
                        }
                        sum /= zscoreBufferSize;
                        [zscoreParameters replaceObjectAtIndex:j withObject:[[NSNumber alloc] initWithDouble:sum]];
                        if (j+1 == noOfChannels) {
                            zscoreStat = activated;
                        }
                    }
                }
                
                if (zscoreStat == activated)
                {
                    emgData = (emgData - [[zscoreParameters objectAtIndex:j] doubleValue]);
                }
                
                double finalData = (rectify) ? fabs(emgData) : emgData;
                double rawData = finalData;
                
                //raw data after base align and rectification
                fileWrite = [fileWrite stringByAppendingFormat:@",%lf",rawData];
                
                if (normalizeStat == processing) {
                    [[normalizeBuffer objectAtIndex:j] addObject:[[NSNumber alloc] initWithDouble:finalData]];
                    if ([[normalizeBuffer objectAtIndex:j] count] == normalizeBufferSize)
                    {
                        int firstIndex = (sampleRate * 2 > normalizeBufferSize? 0: sampleRate * 2);
                        NSIndexSet *index =                         [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstIndex, normalizeBufferSize - firstIndex - 1)];

                        NSLog(@"%d %d %ld %@", firstIndex, normalizeBufferSize - firstIndex - 1, [normalizeBuffer count], index);
                        NSArray *selectedRange = [[normalizeBuffer objectAtIndex:j] objectsAtIndexes:index];
                        NSNumber *max = [[selectedRange sortedArrayUsingSelector:@selector(compare:)] lastObject];
                        
                        max = [NSNumber numberWithDouble: max.doubleValue * 0.7]; //70% of maximum voluntary contraction
                        
                        NSNumber *min = [[selectedRange sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:0];
                        double sum = 0;
                        for (NSNumber *sValue in selectedRange) {
                            sum += [sValue doubleValue];
                        }
                        sum /= [selectedRange count];
                        
                        double std = 0;
                        for (NSNumber *sValue in selectedRange) {
                            std += pow([sValue doubleValue] - sum,2);
                        }
                        std = sqrt(std / [selectedRange count]);
                        [normalizeParameters replaceObjectAtIndex:j withObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:sum], @"avg",min,@"min",max,@"max", [NSNumber numberWithDouble:std], @"std", nil]];
                        NSLog(@"%@",normalizeParameters);
                        if (j+1 == noOfChannels) {
                            normalizeStat = activated;
                        }
                    }
                }
                
                
                if (normalizeStat == activated) {
                    double min = [[[normalizeParameters objectAtIndex:j] valueForKey:@"min"] doubleValue];
                    double max = [[[normalizeParameters objectAtIndex:j] valueForKey:@"max"] doubleValue];
                    
                    finalData = ((finalData - (min))/((max) - (min))) * (1-0) + 0;
                }
                
                if (kFilterStat == deactivated) {
                    finalData = [_koikeFilters pushData:finalData ToFilterChannel:j];
                }
                
                fileWriteFiltered = [fileWriteFiltered stringByAppendingFormat:@",%lf",finalData];
                
                if (i ==  floor(sampleRate/60)) {
                    incoming = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithDouble:finalData],
                                @"y",[NSNumber numberWithFloat:currentIndex],@"x",[NSNumber numberWithDouble:rawData], @"rawy", strNow, @"timestamp", nil];
                    [[incomingData objectAtIndex:j] insertObject:incoming atIndex:0];
                }

            }
            
            [_fileHandle writeData:[[fileWrite stringByAppendingFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [_fileHandle2 writeData:[[fileWriteFiltered stringByAppendingFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];

            if (i ==  floor(sampleRate/60)) {
//                NSLog(@"delegate: incoming data %@", incomingData);
                [[self delegate] incomingStream:incomingData];
                currentIndex += 0.1f;
            }
            
            for (int j = 0; j < noOfChannels; j++) {
                [[incomingData objectAtIndex:j] removeAllObjects];
            }
        }

//        NSLog(@"%f",currentIndex);
//        NSLog(@"Time");

        }
//        [pool drain];
    }
    [_fileHandle closeFile];
    [_fileHandle2 closeFile];
    NSLog(@"fileClosed");
    
Error:
    if( DAQmxFailed(error) )
    {
//        NSLog(@"error %d",error);
        DAQmxBaseGetExtendedErrorInfo(errBuff,2048);
        NSLog(@"error %s",errBuff);
        [[self delegate] DAQerrorAppeared:[NSString stringWithCString:errBuff encoding:NSUTF8StringEncoding]];
    }
    if(taskHandle != 0)
    {
//        NSLog(@"error2");
        DAQmxBaseGetExtendedErrorInfo(errBuff,2048);
        long int stop;
        long int clear;
        long int reset;
        stop = DAQmxBaseStopTask (taskHandle);
        clear = DAQmxBaseClearTask (taskHandle);
        reset = DAQmxBaseResetDevice("Dev1");
        NSLog(@"%ld:stop %ld:clear %ld:reset %s:error", stop , clear, reset, errBuff);
        [[self delegate] DAQerrorAppeared:[NSString stringWithCString:errBuff encoding:NSUTF8StringEncoding]];
    }
}

- (void)activateKoikefilterWithSamplingRate:(int)samplingRate
{
    if (kFilterStat == deactivated) {
        //alloc a block of memory of C++ object arrays using ::operator new
        _koikeFilters = [[IKoikeFilter alloc] initWithSamplingRate:samplingRate andNumberOfChannels:noOfChannels];
        kFilterStat = activated;
    }
    else if(kFilterStat == activated)
    {
        kFilterStat = deactivated;
        _koikeFilters = nil;
    }
}

- (void)activateLowpassFilterWithCoefficients:(double *)numerator andDenominator:(double *)denominator withOrder :(int)order {
    if (lpFilterStat == deactivated) {
        //alloc a block of memory of C++ object arrays using ::operator new
        _lowpassFilters = [[LowpassFilter alloc] initWithNumeratorCoefficients:numerator andDenominatorCoefficients:denominator withOrder:order andNumberOfChannels:noOfChannels];
        lpFilterStat = activated;
    }
    else if(lpFilterStat == activated)
    {
        lpFilterStat = deactivated;
        _lowpassFilters = nil;
    }
}

- (BOOL)activateNormalizationWithBufferSize:(int)bsize
{
    if (normalizeStat == deactivated) {
        normalizeBufferSize = bsize;
//            NSLog(@"in");
            normalizeBuffer = [[NSMutableArray alloc] initWithCapacity:noOfChannels];
            normalizeParameters = [[NSMutableArray alloc] initWithCapacity:noOfChannels];
            for (int k = 0; k < noOfChannels; k++)
            {
                [normalizeBuffer addObject:[[NSMutableArray alloc] initWithCapacity:normalizeBufferSize]];
                [normalizeParameters addObject:[[NSDictionary alloc] init]];
            }
        normalizeStat = processing;
    }
    if (normalizeStat == activated) {
        normalizeStat = deactivated;
        [normalizeBuffer removeAllObjects];
        [normalizeParameters removeAllObjects];
        normalizeBuffer = nil;
        normalizeParameters = nil;
    }
    return normalizeStat;
}

- (BOOL)activateZscoreWithBufferSize:(int)bsize
{
    if (zscoreStat == deactivated) {
        zscoreBufferSize = bsize;
            NSLog(@"in");
            zscoreBuffer = [[NSMutableArray alloc] initWithCapacity:0];
            zscoreParameters = [[NSMutableArray alloc] initWithCapacity:0];
        
            for (int k = 0; k < noOfChannels; k++)
            {
                [zscoreParameters addObject:[[NSNumber alloc] initWithDouble:0]];
                [zscoreBuffer addObject:[[NSMutableArray alloc] initWithCapacity:0]];
            }
        zscoreStat = processing;
    }
    if (zscoreStat == activated)
    {
        zscoreStat = deactivated;
        [zscoreBuffer removeAllObjects];
        [zscoreParameters removeAllObjects];
        zscoreParameters = nil;
        zscoreBuffer = nil;
    }
    return zscoreStat;
}

- (void)stop
{
    running = NO;
}
@end
