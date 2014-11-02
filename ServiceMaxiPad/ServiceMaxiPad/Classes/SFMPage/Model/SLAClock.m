//
//  SLAClock.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SLAClock.h"
#import "DateUtil.h"
#import "DatabaseConstant.h"

@interface SLAClock ()

@property(nonatomic,strong) NSString *restorationCustomerBy;
@property(nonatomic,strong) NSString *resolutionCustomerBy;
@property(nonatomic,strong) NSString *actualRestoration;
@property(nonatomic,strong) NSString *actualResolution;
@property(nonatomic,strong) NSString *pausedTime;

@property(nonatomic,assign) BOOL isClockPaused;

@end

@implementation SLAClock


- (id)initWithDictionary:(NSDictionary *)slaDictonary
{
    if (self = [super init]) {
        
        if (slaDictonary != nil) {
            _restorationCustomerBy = [slaDictonary objectForKey:kSLARestoratorationCustomer];
            _resolutionCustomerBy = [slaDictonary objectForKey:kSLAResolutionCustomer];
            _actualRestoration = [slaDictonary objectForKey:kSLAActualRestoration];
            _actualResolution = [slaDictonary objectForKey:kSLAActualResolution];
            _pausedTime = [slaDictonary objectForKey:kSLAClockPauseTime];
            _isClockPaused = [[slaDictonary objectForKey:kSLAClockPaused] boolValue];
        }
        _shouldStartResolutionTimer = NO;
        _shouldStartResotorationTimer = NO;
    }
    return self;
}

- (NSString *)getRestorationTime
{
    return [self getTimerValue:self.restorationCustomerBy];
}

- (NSString *)getResolutionTime
{
    return [self getTimerValue:self.resolutionCustomerBy];
}

- (NSDateComponents *)getRestorationTimerValue
{
    NSDateComponents *components = nil;
    
    if ([self.actualRestoration length] > 0) {
        components = [self getTimeValue:[self getdateFromString:self.restorationCustomerBy]
                   endTime:[self getdateFromString:self.actualRestoration]];
    }
    else if (self.isClockPaused) {
       components = [self getTimeValue:[self getdateFromString:self.restorationCustomerBy]
                   endTime:[self getdateFromString:self.pausedTime]];
    }
    else {
       components = [self getTimeValue:[NSDate date]
                   endTime:[self getdateFromString:self.restorationCustomerBy]];
        self.shouldStartResotorationTimer = YES;
    }
    return components;
}

- (NSDateComponents *)getResolutionTimerValue
{
    NSDateComponents *components = nil;
    
    if ( (![self.actualRestoration isKindOfClass:[NSNull class]]) && [self.actualRestoration length] > 0) {
        components = [self getTimeValue:[self getdateFromString:self.resolutionCustomerBy]
                                endTime:[self getdateFromString:self.actualResolution]];
    }
    else if (self.isClockPaused) {
        components = [self getTimeValue:[self getdateFromString:self.resolutionCustomerBy]
                                endTime:[self getdateFromString:self.pausedTime]];
    }
    else {
        components = [self getTimeValue:[NSDate date]
                                endTime:[self getdateFromString:self.resolutionCustomerBy]];
        self.shouldStartResolutionTimer = YES;
    }
    return components;
}


- (NSDateComponents *)getTimeValue:(NSDate *)startTime endTime:(NSDate *)endTime
{
    NSDateComponents *components = nil;
    
    if (startTime != nil && endTime != nil) {
        NSTimeInterval startTimeInterval = [startTime timeIntervalSinceReferenceDate];
        NSTimeInterval endTimeInterval = [endTime timeIntervalSinceReferenceDate];
        
        if (endTimeInterval < startTimeInterval)
        {
            return nil;
        }
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        components = [gregorian components:unitFlags fromDate:startTime
                                                      toDate:endTime options:0];
    }
    return components;
}

- (NSString *)getResolutionTimeFormat
{
    if ( (![self.resolutionCustomerBy isKindOfClass:[NSNull class]]) && [self.resolutionCustomerBy length] > 0) {
        
        if (![DateUtil iSDeviceTime24HourFormat]){
            NSDate *date = [self getdateFromString:self.restorationCustomerBy];
            if (date) {
                NSString *format = [DateUtil stringFromDate:date inFormat:@"%p"];
                return format;
            }
        }
    }
    return @"";
}

- (NSString *)getRestorationTimeFormat
{
    if ((![self.restorationCustomerBy isKindOfClass:[NSNull class]]) && [self.restorationCustomerBy length] > 0) {
        
        if (![DateUtil iSDeviceTime24HourFormat]){
            NSDate *date = [self getdateFromString:self.restorationCustomerBy];
            if (date) {
                NSString *format = [DateUtil stringFromDate:date inFormat:@"%p"];
                return format;
            }
        }
    }
    return @"";
}

-(NSString *)getTimerValue:(NSString *)time
{
    NSDate *date = [self getdateFromString:time];
    NSString *format = @"";
    
    if (date) {
        
        if ([DateUtil iSDeviceTime24HourFormat]){
            format = @"%H:%M";
        }
        else{
            format = @"%I:%M";
        }
        NSString *dateString = [DateUtil stringFromDate:date inFormat:format]; //@"%H:%M:%S"
        return dateString;
    }
    return nil;
}

- (NSDate *)getdateFromString:(NSString *)dateString
{
    if ([dateString length] >0 ){
        NSDate *date = [DateUtil getDateFromDatabaseString:dateString];
        return date;
    }
    return nil;
    
}

- (BOOL)startResolutionTimer
{
    return self.shouldStartResolutionTimer;
}

- (BOOL)startResotorationTimer
{
    return self.shouldStartResotorationTimer;
}

@end
