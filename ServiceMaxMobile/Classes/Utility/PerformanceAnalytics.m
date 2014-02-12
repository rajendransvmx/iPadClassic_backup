//
//  PerformanceAnalytics.m
//  iService
//
//  Created by Vipindas on 2/27/13.
//
//

#import "PerformanceAnalytics.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@implementation PerformanceAnalytics

static PerformanceAnalytics *sharedPerformanceAnalytics = nil;

@synthesize nameToStartTimeDictionary, nameToEndTimeDictionary, nameToRecordCount, nameToTimeCountDictionary, names, codeName, description, createdRecords, deletedRecords, dbOperationCounterDictionary, dbVersion, dbMemoryRecords, isMonitoring;


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
        self.isMonitoring = NO;
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

- (long long int)getDBOperationCount
{

  long long int totalOperations = 0;
    
  if ((self.dbOperationCounterDictionary != nil)
      && ([self.dbOperationCounterDictionary count] > 0))
  {
    
      NSArray *dbNames  = [self.dbOperationCounterDictionary allKeys];
      
      // Mem_leak_fix - Vipindas 9493 Jan 18
      @autoreleasepool
      {
          for (NSString *dbName in dbNames)
          {
              NSArray *readings = [self.dbOperationCounterDictionary objectForKey:dbName];
              
              int totalReading = [readings count];
              if ( totalReading > 1)
              {
                  NSNumber *currentReading = [readings objectAtIndex:totalReading - 1];
                  NSNumber *previousReading = [readings objectAtIndex:totalReading - 2];
                  
                  int diff = [currentReading intValue] -  [previousReading intValue];
                  
                  totalOperations += diff;
                  SMLog(kLogLevelVerbose,@" %@   cur : %d  pre : %d  diff : %d", dbName, [currentReading intValue],  [previousReading intValue], diff);
              }
          }
      }
      
  }
   
  SMLog(kLogLevelVerbose,@" totalOperations : %lld ", totalOperations);
  return totalOperations;
}


- (void)observePerformanceForContext:(NSString *)contextName
                     andRecordCount:(long long int)count
{
    
    
    if (! self.isMonitoring)
    {
        // Ohh We are currently not monitoring
        return;
    }
    
    @synchronized([self class])
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
        
        // Mem_leak_fix - Vipindas 9493 Jan 18
        @autoreleasepool
        {
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
    }
}


- (void)completedPerformanceObservationForContext:(NSString *)context
                                   andRecordCount:(long long int)count
{
    if (! self.isMonitoring)
    {
        // Ohh We are currently not monitoring
        return;
    }
    
    @synchronized([self class])
    {
        if (self.nameToTimeCountDictionary == nil)
        {
            NSMutableDictionary *timeDictionary = [[NSMutableDictionary alloc] init];
            self.nameToTimeCountDictionary =  timeDictionary;
            [timeDictionary release];
        }
        
        // Mem_leak_fix - Vipindas 9493 Jan 18
        @autoreleasepool
        {
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
            
            storedReports = nil;
            // Reset all
            [self.nameToStartTimeDictionary removeObjectForKey:context];
            [self.nameToEndTimeDictionary removeObjectForKey:context];
            [self.nameToRecordCount removeObjectForKey:context];
        }
    }
}


- (void)generateStatics
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
    NSString     *build     = [infoPList objectForKey:@"CFBundleVersion"];
    NSString     *versionStr = [infoPList objectForKey:@"CFBundleShortVersionString"];

    NSDate   *timeNow       = [NSDate date];
    NSString *timeOfCreation    = [timeNow descriptionWithLocale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
    
    NSString *fileName   = [NSString stringWithFormat:@"%@_%@_%@_on_%@", self.codeName, appName, device, timeOfCreation];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"India Standard Time" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"," withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    [string1 appendFormat:@"\n    =============      Performance Analysis Report      ==============\n\n"];
    [string1 appendFormat:@"\n    File Name                                           :  %@", fileName];
    [string1 appendFormat:@"\n    Time of Creation                                    :  %@", timeOfCreation];
    [string1 appendFormat:@"\n    Application                                         :  %@ %@ - %@", appName, build, versionStr];
    [string1 appendFormat:@"\n    Device                                              :  %@ - iOS %@", device, version];
    [string1 appendFormat:@"\n    Device Name                                         :  %@", customName];
    [string1 appendFormat:@"\n    Code                                                :  %@", self.codeName];
    [string1 appendFormat:@"\n    Description                                         :  %@\n", self.description];
   
    [string1 appendFormat:@"\n    DB Version                                          :  %@", self.dbVersion];
    
    fileName = nil;
    timeOfCreation = nil;
    appName  = nil;
    build = nil;
    versionStr = nil;
    device = nil;
    version = nil;
    customName = nil;
    

    if (self.dbMemoryRecords != nil)
    {
        NSArray *keys = [self.dbMemoryRecords allKeys];
        
        @autoreleasepool
        {
            for (NSString *key in keys)
            {
                NSNumber *number = [dbMemoryRecords objectForKey:key];
                SMLog(kLogLevelVerbose,@" %@ : %lld", key, [number longLongValue]);
                if([key hasPrefix:@"Current"])
                {
                    [string1 appendFormat:@"\n    DB Current Memory Size                              :  %lld KB", [number longLongValue]];
                }
            }
        }
    }
    
    [string1 appendFormat:@"\n    ==================================================================\n"];
    [string1 appendFormat:@"\n\n\n"];
    
    if (self.names != nil)
    {
       NSArray *keys = self.names;
        
       // Mem_leak_fix - Vipindas 9493 Jan 18
        @autoreleasepool
        {
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
                        
                        NSString *timeTaken = [[NSString alloc] initWithFormat:@"%04g",recordTimeInterval];
                        NSString *text  = [[NSString alloc] initWithFormat:@"%@  %lld records in %@ s  --->  %02g rec/sec", fs, numberOfRecords,timeTaken, speed];
                        
                        [storedTexts addObject:text];
                        
                        [groupedEntry setObject:storedTexts forKey:[plittedStrings objectAtIndex:0]];
                        [text release];
                        [timeTaken release];
                        timeTaken = nil;
                        
                    }
                    else
                    {
                        [string appendFormat:@"\n"];
                        
                        NSString *timeTaken = [[NSString alloc] initWithFormat:@"%04g",recordTimeInterval];
                        
                        [string appendFormat:@"%@  %lld records in %@ s  --->  %02g rec/sec", fs, numberOfRecords,
                         timeTaken, speed];
                        [timeTaken release];
                        timeTaken = nil;
                    }
                }
                else
                {
                    [string1 appendFormat:@"\n"];
                    NSString *timeTaken = [[NSString alloc] initWithFormat:@"%02g\n", recordTimeInterval];
                    [string1 appendFormat:@"%@  - %@", fs, timeTaken];
                    [timeTaken release];
                    timeTaken = nil;
                }
            }
        } // Pool ends here
        
        // Grouped Key
        
        for (NSString *dictKey in [groupedEntry allKeys])
        {
            NSArray *texts = [groupedEntry objectForKey:dictKey];
            @autoreleasepool
            {
                for (NSString *text in texts)
                {
                    [string appendFormat:@"\n"];
                    [string appendString:text];
                }
            }
        }
       
        [groupedEntry  release];
        groupedEntry = nil;
        
        NSString *recordText1  = [@"Created records" stringByPaddingToLength:60
                                                                         withString:@" "
                                                                    startingAtIndex:0];

        NSString *recordText2  = [@"Deleted records" stringByPaddingToLength:60
                                                                 withString:@" "
                                                            startingAtIndex:0];


        NSString *recordText  = [@"Total number of records" stringByPaddingToLength:60
                                                                         withString:@" "
                                                                    startingAtIndex:0];
        
        NSString *recordText4  = [@"Total number of db operations" stringByPaddingToLength:60
                                                                         withString:@" "
                                                                    startingAtIndex:0];

        [string1 appendFormat:@"\n"];
        [string1 appendFormat:@"%@  - %lld", recordText1, self.createdRecords];
       
        [string1 appendFormat:@"\n"];
        [string1 appendFormat:@"%@  - %lld", recordText2, self.deletedRecords];
    
        [string1 appendFormat:@"\n"];
        [string1 appendFormat:@"%@  - %lld", recordText, totalNumberOfRecords];
      
        [string1 appendFormat:@"\n"];
        [string1 appendFormat:@"%@  - %lld", recordText4, [self getDBOperationCount]];
        
       SMLog(kLogLevelVerbose,@" %@ ",string);
       SMLog(kLogLevelVerbose,@" %@ \n %@", string1, string);
       [string release];
       [string1 release];
       string = nil;
       string1 = nil;
    }
    
    self.deletedRecords = 0;
    self.createdRecords = 0;
}


- (void)displayCurrentStatics
{
    @synchronized([self class])
    {
        if (! self.isMonitoring)
        {
            SMLog(kLogLevelVerbose,@" %@ ", @" Sorry! We are not monitoring now");
            NSLog(@" Sorry! We are not monitoring now");
            return;
        }
        
        // Mem_leak_fix - Vipindas 9493 Jan 18
        @autoreleasepool
        {
            [self generateStatics];
        }
    }
}

- (void)startAnalyticsWithCode:(NSString *)code
 andDescription:(NSString *)descriptionName
{
    self.isMonitoring = YES;
    self.description = descriptionName;
    self.codeName = code;
}


- (void)stopPerformAnalysis
{
    @synchronized([self class])
    {
        self.nameToStartTimeDictionary = nil;
        self.nameToEndTimeDictionary = nil;
        self.nameToRecordCount = nil;
        self.names = nil;
        self.nameToTimeCountDictionary = nil;
        
        @autoreleasepool
        {
            [self clearOperationCounter];
        }
        self.isMonitoring = NO;
    }
}

- (void)registerOperationCount:(int)count forDatabase:(NSString *)connectionName
{
    
    @synchronized([self class])
    {
        if (! self.isMonitoring)
        {
            // We are not monitoring
            return;
        }
        
        if (self.dbOperationCounterDictionary == nil)
        {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            self.dbOperationCounterDictionary = dictionary;
            [dictionary release];
        }
     
        // Mem_leak_fix - Vipindas 9493 Jan 18
        @autoreleasepool
        {
            NSArray *array = [self.dbOperationCounterDictionary objectForKey:connectionName];

            NSMutableArray *readings = nil;
            
            if (array == nil)
            {
                readings = [[NSMutableArray alloc] init];
            }
            else
            {
                readings = [[NSMutableArray alloc] initWithArray:array];
            }
            
            array = nil;
            
            
            SMLog(kLogLevelVerbose,@"[DBOPX] Reg Opcount for %@  - %d", connectionName, count);
            
            [readings addObject:[NSNumber numberWithInt:count]];
            
            [self.dbOperationCounterDictionary setObject:readings forKey:connectionName];
            
            [readings release];
            readings = nil;
        }
    }
}

- (void)clearOperationCounter
{
   if (self.dbOperationCounterDictionary != nil)
   {
       [self.dbOperationCounterDictionary removeAllObjects];
       self.dbOperationCounterDictionary = nil;
   }
    
    if (self.dbMemoryRecords != nil)
    {
        [self.dbMemoryRecords removeAllObjects];
        self.dbMemoryRecords = nil;
    }
}

- (void)recordDBMemoryUsage:(NSNumber *)memoryUsed perContext:(NSString *) context
{
   if (self.dbMemoryRecords == nil)
   {
       NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
       self.dbMemoryRecords = dict;
       [dict release];
   }
    
    // Mem_leak_fix - Vipindas 9493 Jan 18
    @autoreleasepool
    {
        NSDateFormatter* df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *result = [df stringFromDate:[NSDate date]];
        [df release];
        df = nil;
        
        NSString *key    = [[NSString alloc] initWithFormat:@"%@_%@", context, result];
        
        [self.dbMemoryRecords setObject:memoryUsed forKey:key];
        [key  release];
        key = nil;
    }
}

@end
