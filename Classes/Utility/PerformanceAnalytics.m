//
//  PerformanceAnalytics.m
//  iService
//
//  Created by Vipindas on 2/27/13.
//
//

#import "PerformanceAnalytics.h"

extern void SVMXLog(NSString *format, ...);

@implementation PerformanceAnalytics

static PerformanceAnalytics *sharedPerformanceAnalytics = nil;

@synthesize nameToStartTimeDictionary, nameToEndTimeDictionary, nameToRecordCount, nameToTimeCountDictionary, names, codeName, description, createdRecords, deletedRecords;


+ (PerformanceAnalytics*)sharedInstance
{
    if (sharedPerformanceAnalytics == nil)
    {
        @synchronized(self)
        {
            sharedPerformanceAnalytics = [[super allocWithZone:NULL] init];
        }
    }
    return sharedPerformanceAnalytics;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release {
    // never release
}

- (id)autorelease {
    return self;
}


/***   */


- (void)addCreatedRecordsNumber:(long long int)records
{
    self.createdRecords += records;
}


- (void)addDeletedRecordsNumber:(long long int)records
{    
    self.deletedRecords += records;
}


- (void)observePerformanceForContext:(NSString *)contextName
                     andRecordCount:(long long int)count
{
    if (self.nameToStartTimeDictionary == nil)
    {
        NSMutableDictionary *startTimeDictionary = [[NSMutableDictionary alloc] init] ;
        self.nameToStartTimeDictionary =  startTimeDictionary;
        [startTimeDictionary release];
    }
    
    
    if (self.nameToEndTimeDictionary == nil)
    {
        NSMutableDictionary *endTimeDictionary = [[NSMutableDictionary alloc] init] ;
        self.nameToEndTimeDictionary =  endTimeDictionary;
        [endTimeDictionary release];
    }
    
    
    if (self.nameToRecordCount == nil)
    {
        NSMutableDictionary *recordCountDictionary = [[NSMutableDictionary alloc] init] ;
        self.nameToRecordCount =  recordCountDictionary;
        [recordCountDictionary release];
    }
    
    if (self.names == nil)
    {
        NSMutableArray *tempNames = [[NSMutableArray alloc] init] ;
        self.names =  tempNames;
        [tempNames release];
    }
    
    
    if ([self.nameToStartTimeDictionary objectForKey:contextName] == nil)
    {
        NSDate *currentDate = [NSDate date];
        
        if ([self.names indexOfObject:contextName] == NSNotFound)
        {
            [self.names addObject:contextName];
        }
        
        [self.nameToStartTimeDictionary setObject:currentDate forKey:contextName];
        [self.nameToEndTimeDictionary setObject:currentDate forKey:contextName];
        [self.nameToRecordCount setObject:[NSNumber numberWithLongLong:count] forKey:contextName];
    }
    else
    {
        NSDate *currentDate = [NSDate date];
        [self.nameToEndTimeDictionary setObject:currentDate forKey:contextName];
        
        NSNumber *existCount =  (NSNumber *) [self.nameToRecordCount objectForKey:contextName];
        long long newCount = [existCount longLongValue] + count;
        [self.nameToRecordCount setObject:[NSNumber numberWithLongLong:newCount] forKey:contextName];
    }
}


- (void)completedPerformanceObservationForContext:(NSString *)context
                                   andRecordCount:(long long int)count
{
    if (self.nameToTimeCountDictionary == nil)
    {
        NSMutableDictionary *timeDictionary = [[NSMutableDictionary alloc] init];
        self.nameToTimeCountDictionary =  timeDictionary;
        [timeDictionary release];
    }
    
    NSMutableArray *storedReports = [self.nameToTimeCountDictionary objectForKey:context];
    
    if (storedReports == nil)
    {
        storedReports = [NSMutableArray arrayWithCapacity:0];
    }
    
    
    NSDate *startDate =  [self.nameToStartTimeDictionary objectForKey:context];
    
    if (startDate == nil)
    {
        // No valid entry. Lets stops here
        return;
    }
    
    NSDate *endDate   =  [self.nameToEndTimeDictionary objectForKey:context];
    
    if ([startDate compare:endDate] == NSOrderedSame)
    {
        endDate = [NSDate date];
    }
   
    NSNumber *existCount =  (NSNumber *) [self.nameToRecordCount objectForKey:context];
    long long newCount = [existCount longLongValue] + count;
    
    NSTimeInterval  timeDiff = [endDate timeIntervalSinceDate:startDate];
    NSNumber *totalTime    = [NSNumber numberWithDouble:timeDiff];
    NSNumber *totalRecords = [NSNumber numberWithLongLong:newCount];
    
    NSArray *report = [NSArray arrayWithObjects:totalRecords, totalTime, nil];
    
    [storedReports addObject:report];
    
    [self.nameToTimeCountDictionary setObject:storedReports forKey:context];
    
    // Reset all
    [self.nameToStartTimeDictionary removeObjectForKey:context];
    [self.nameToEndTimeDictionary removeObjectForKey:context];
    [self.nameToRecordCount removeObjectForKey:context];
}


- (void)displayCurrentStatics
{
    NSMutableString *string  = [[NSMutableString alloc] init];
    NSMutableString *string1 = [[NSMutableString alloc] init];
    
    NSMutableDictionary *groupedEntry = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    long long int totalNumberOfRecords = self.createdRecords + self.deletedRecords;

    NSString *customName    = [[UIDevice currentDevice] name];
    NSString *device        = [[UIDevice currentDevice] model];
    NSString *version       = [[UIDevice currentDevice] systemVersion];
    
    NSDictionary *infoPList = [[NSBundle mainBundle] infoDictionary];
    NSString     *appName   = [infoPList objectForKey:@"CFBundleDisplayName"];

    NSDate   *timeNow       = [NSDate date];
    //NSString *codeName      = @"PA2005";
    //NSString *description   = @"Incremental Sync optmztn -  Testing ";
    
    NSString *timeOfCreation    = [timeNow descriptionWithLocale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
    
    NSString *fileName          = [NSString stringWithFormat:@"%@_%@_%@_on_%@", self.codeName, appName, device, timeOfCreation];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"India Standard Time" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"," withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    [string1 appendFormat:@"\n    =============      Performance Analysis Report      ==============\n\n"];
    [string1 appendFormat:@"\n    File Name                                           :  %@", fileName];
    [string1 appendFormat:@"\n    Time of Creation                                    :  %@", timeOfCreation];
    [string1 appendFormat:@"\n    Application                                         :  %@", appName];
    [string1 appendFormat:@"\n    Device                                              :  %@ - iOS %@", device, version];
    [string1 appendFormat:@"\n    Device Name                                         :  %@", customName];
    [string1 appendFormat:@"\n    Code                                                :  %@", self.codeName];
    [string1 appendFormat:@"\n    Description                                         :  %@\n", self.description];
    [string1 appendFormat:@"\n    ==================================================================\n"];
    [string1 appendFormat:@"\n\n\n"];
    
    if (self.names != nil)
    {
        NSArray *keys = self.names;
        
       for (NSString *key in keys)
       {
           [self completedPerformanceObservationForContext:key andRecordCount:0];
           
           NSMutableArray *records = [[self nameToTimeCountDictionary] objectForKey:key];
           
           NSTimeInterval recordTimeInterval = 0.0;
           long long int  numberOfRecords    = 0;
           
           for (NSArray *record in records)
           {
               if ([record objectAtIndex:0] != nil)
               {
                  numberOfRecords  += [[record objectAtIndex:0] longLongValue];
                   
                   if ([record objectAtIndex:1] != nil)
                   {
                       recordTimeInterval += [[record objectAtIndex:1] doubleValue];
                   }
               }
           }
        
           
           double  speed = numberOfRecords / recordTimeInterval;
           
           NSString *fs  = [key stringByPaddingToLength:60
                                             withString:@" "
                                        startingAtIndex:0];
           
           if (numberOfRecords > 0)
           {
                //totalNumberOfRecords += numberOfRecords;
        
               NSRange range = [key rangeOfString:@":"];
               
               if (range.length > 0)
               {
                   NSArray *plittedStrings = [key componentsSeparatedByString:@":"];
                   
                   NSMutableArray *storedTexts = [groupedEntry objectForKey:[plittedStrings objectAtIndex:0]];

                   if( storedTexts == nil)
                   {
                       storedTexts = [NSMutableArray array];
                   }
                   
                   NSString *text  = [NSString stringWithFormat:@"%@  %lld records in %@ s  --->  %02g rec/sec", fs, numberOfRecords,
                                        [NSString stringWithFormat:@"%04g",recordTimeInterval], speed];
                   
                   [storedTexts addObject:text];
                   
                   [groupedEntry setObject:storedTexts forKey:[plittedStrings objectAtIndex:0]];
               }
               else
               {
                [string appendFormat:@"\n"];
                [string appendFormat:@"%@  %lld records in %@ s  --->  %02g rec/sec", fs, numberOfRecords,
                [NSString stringWithFormat:@"%04g",recordTimeInterval], speed];
               }
           }
           else
           {
               [string1 appendFormat:@"\n"];
               [string1 appendFormat:@"%@  - %@", fs, [NSString stringWithFormat:@"%02g\n", recordTimeInterval]];
           }
        }
        
        
        // Grouped Key
        
        for (NSString *dictKey in [groupedEntry allKeys])
        {
            NSArray *texts = [groupedEntry objectForKey:dictKey];
            
            for (NSString *text in texts)
            {
                [string appendFormat:@"\n"];
                [string appendString:text];
            }
        }
       
        NSString *recordText1  = [@"Created records" stringByPaddingToLength:60
                                                                         withString:@" "
                                                                    startingAtIndex:0];

        NSString *recordText2  = [@"Deleted records" stringByPaddingToLength:60
                                                                 withString:@" "
                                                            startingAtIndex:0];


        NSString *recordText  = [@"Total number of records" stringByPaddingToLength:60
                                                                         withString:@" "
                                                                    startingAtIndex:0];

        [string1 appendFormat:@"\n"];
        [string1 appendFormat:@"%@  - %lld", recordText1, self.createdRecords];
       
        [string1 appendFormat:@"\n"];
        [string1 appendFormat:@"%@  - %lld", recordText2, self.deletedRecords];
        
        
       [string1 appendFormat:@"\n"];
       [string1 appendFormat:@"%@  - %lld", recordText, totalNumberOfRecords];
        
       SMLog(string);
       NSLog(@" %@ \n %@", string1, string);
       [string release];
       [string1 release];
    }
    
    self.deletedRecords = 0;
    self.createdRecords = 0;
}



- (void)setCode:(NSString *)code
 andDescription:(NSString *)descriptionName
{
    self.description = descriptionName;
    self.codeName = code;
}

/*- (void)displayCurrentStatics
 {
 SMLog(@" =============      Performance Report    ==============");
 NSMutableString *string = [[NSMutableString alloc] init];
 NSMutableString *string1 = [[NSMutableString alloc] init];
 
 [string appendFormat:@"\n\n --------------------------------------------- \n"];
 [string appendFormat:@"\n\n\n"];
 
 if (self.nameToStartTimeDictionary != nil)
 {
 NSArray *keys = self.names; //[self.nameToStartTimeDictionary allKeys];
 
 for (NSString *key in keys)
 {
 NSDate *startDate =  [self.nameToStartTimeDictionary objectForKey:key];
 NSDate *endDate   =  [self.nameToEndTimeDictionary objectForKey:key];
 NSNumber *number  =  (NSNumber *)[self.nameToRecordCount objectForKey:key];
 
 NSTimeInterval  timeDiff = [endDate timeIntervalSinceDate:startDate];
 
 double  speed = [number longLongValue] / timeDiff;
 
 NSString *fs  = [key stringByPaddingToLength:60
 withString:@" "
 startingAtIndex:0];
 
 
 if ([number longLongValue] > 0)
 {
 [string appendFormat:@"\n"];
 
 //           [string appendFormat:@"%@  %lld records in %@  --->  %02g records/sec", key, [number longLongValue],
 //         [NSString stringWithFormat:@"%04g",timeDiff], speed];
 
 [string appendFormat:@"%@  %lld records in %@ s  --->  %02g rec/sec", fs, [number longLongValue],
 [NSString stringWithFormat:@"%04g",timeDiff], speed];
 
 }
 else
 {
 // [string appendFormat:@"%@ sec taken to complete the operation %@ ", [NSString stringWithFormat:@"%02g",timeDiff],  key];
 
 [string1 appendFormat:@"\n"];
 [string1 appendFormat:@"%@  - %@", fs, [NSString stringWithFormat:@"%02g\n", timeDiff]];
 }
 }
 
 SMLog(string);
 NSLog(@" %@ \n %@", string1, string);
 [string release];
 [string1 release];
 }
 }
*/

- (void)stopPerformAnalysis
{
    self.nameToStartTimeDictionary = nil;
    self.nameToEndTimeDictionary = nil;
    self.nameToRecordCount = nil;
    self.names = nil;
    self.nameToTimeCountDictionary = nil;
}

- (void)removeContext:(NSString *)contextName
{
 
}

@end
