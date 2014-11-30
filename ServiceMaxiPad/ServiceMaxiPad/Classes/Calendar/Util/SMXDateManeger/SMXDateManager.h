//
//  SMXDateManager.h
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

#import <Foundation/Foundation.h>


#define DATE_MANAGER_DATE_CHANGED @"br.com.SMXCalendar.DateManager.DateChanged"
#define DATE_MANAGER_DATE_CHANGED_KEY @"br.com.SMXCalendar.DateManager.DateChanged.Key"

@interface SMXDateManager : NSObject

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSTimeZone *timeZone;
+ (id)sharedManager;

@end
