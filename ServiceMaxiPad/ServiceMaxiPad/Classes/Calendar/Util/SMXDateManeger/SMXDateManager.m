//
//  SMXDateManager.m
/**
 *  @file   FILE_NAME.m
 *  @class  CLASS_NAME
 *
 *  @brief  This class will provide .....
 *
 *
 *
 *  @author  AUTHOR_NAME
 *
 *  @bug     No known bugs
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SMXDateManager.h"

@implementation SMXDateManager

@synthesize currentDate;
@synthesize timeZone;

+ (id)sharedManager {
    static SMXDateManager *sharedDateManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDateManager = [[self alloc] init];
    });
    return sharedDateManager;
}

- (id)init {
    if (self = [super init]) {
        currentDate = [NSDate date];
        timeZone = [NSTimeZone localTimeZone];
    }
    return self;
}

- (void)dealloc {
}

-(NSDate *)currentDate
{
    
    //    return currentDate;
    
    //    NSLog(@"get currentDate: %@", currentDate);
    
    return currentDate;
}

- (void)setCurrentDate:(NSDate *)_currentDate {
    
    //    NSLog(@"_currentDate: %@", _currentDate);
    
    //    if (currentDate) {
    //            [currentDate release];
    //    }
    
    //    currentDate = [_currentDate retain];
    
    currentDate = _currentDate;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DATE_MANAGER_DATE_CHANGED object:_currentDate];
}

@end
