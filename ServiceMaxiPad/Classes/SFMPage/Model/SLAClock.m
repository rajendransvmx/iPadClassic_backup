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

@property(nonatomic,strong) NSString *restorationInternalBy;
@property(nonatomic,strong) NSString *resolutionInternalBy;
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
            _resolutionInternalBy = [slaDictonary objectForKey:kSLAResolutionInternal];
            _restorationInternalBy = [slaDictonary objectForKey:kSLARestorationInternal];
            _restorationCustomerBy = [slaDictonary objectForKey:kSLARestorationCustomer];
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
   // return [self getTimerValue:self.restorationCustomerBy];
    
    NSString *time = [self getRestorationTimeOnSettings];
    
    return [self getTimerValue:time];
}

- (NSString *)getResolutionTime
{
   // return [self getTimerValue:self.resolutionCustomerBy];
    NSString *time = [self getResolutionTimeOnSettings];
    
    return [self getTimerValue:time];
}

- (NSDateComponents *)getRestorationTimerValue
{
    self.shouldStartResotorationTimer = NO;
    
    NSString *time = [self getRestorationTimeOnSettings];
    
    NSDateComponents *components = nil;
    
    if ([self.actualRestoration length] > 0) {
        components = [self getTimeValue:[self getdateFromString:self.actualRestoration]
                   endTime:[self getdateFromString:time]];
    }
    else if (self.isClockPaused ) {
       components = [self getTimeValue:[self getdateFromString:self.pausedTime]
                   endTime:[self getdateFromString:time]];
    }
    else {
       components = [self getTimeValue:[NSDate date]
                   endTime:[self getdateFromString:time]];
        self.shouldStartResotorationTimer = YES;
    }
    return components;
}

- (NSDateComponents *)getResolutionTimerValue
{
    self.shouldStartResolutionTimer = NO;
    
    NSString *time = [self getResolutionTimeOnSettings];
    
    NSDateComponents *components = nil;
    
    if ( (![self.actualResolution isKindOfClass:[NSNull class]]) && [self.actualResolution length] > 0) {
        components = [self getTimeValue:[self getdateFromString:self.actualResolution]
                                endTime:[self getdateFromString:time]];
    }
    else if (self.isClockPaused ) {
        components = [self getTimeValue:[self getdateFromString:self.pausedTime]
                                endTime:[self getdateFromString:time]];
    }
    else {        
        components = [self getTimeValue:[NSDate date]
                                endTime:[self getdateFromString:time]];
        self.shouldStartResolutionTimer = YES;
    }
    return components;
}

- (NSString *)getRestorationTimeOnSettings
{
    NSString *time = self.restorationCustomerBy;
    
    if (!self.isCustomerCommitment) {
        time = self.restorationInternalBy;
    }
    
    return time;
}


- (NSString *)getResolutionTimeOnSettings
{
    NSString *time = self.resolutionCustomerBy;
    
    if (!self.isCustomerCommitment) {
        time = self.resolutionInternalBy;
    }
    
    return time;
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
    //if ((![self.resolutionCustomerBy isKindOfClass:[NSNull class]]) && [self.resolutionCustomerBy length] > 0) {
    
    NSString *timeValue = [self getResolutionTimeOnSettings];
    
    if ([timeValue length] > 0) {
        
        if (![DateUtil iSDeviceTime24HourFormat]){
            NSDate *date = [self getdateFromString:timeValue];
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
    //if ((![self.restorationCustomerBy isKindOfClass:[NSNull class]]) && [self.restorationCustomerBy length] > 0) {
    
    NSString *timeValue = [self getRestorationTimeOnSettings];
    
    if ([timeValue length] > 0) {
        
        if (![DateUtil iSDeviceTime24HourFormat]){
            NSDate *date = [self getdateFromString:timeValue];
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
