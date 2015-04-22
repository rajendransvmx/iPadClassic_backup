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
#import "SMXEvent.h"


#define DATE_MANAGER_DATE_CHANGED @"br.com.SMXCalendar.DateManager.DateChanged"
#define DATE_MANAGER_DATE_CHANGED_KEY @"br.com.SMXCalendar.DateManager.DateChanged.Key"
@protocol SMXDateManagerDelegate
@optional
-(void)refreshCell:(int )fromCell Tocell:(int )toCell forEvent:(SMXEvent *)event;
@end
@interface SMXDateManager : NSObject<SMXDateManagerDelegate>

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSTimeZone *timeZone;
@property (nonatomic, strong) NSMutableDictionary *dictEvents;
@property (nonatomic,assign)id Collectiondelegate;
@property (nonatomic, strong) SMXEvent *selectedEvent;

+ (id)sharedManager;
-(void)updateEvent:(SMXEvent *)event fromActivityDate:(NSDate *)fromActivityDate toActivityDate:(NSDate *)toActivityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTim cellIndex:(int)fromIndex toIndex:(int)toIndex;
-(NSMutableDictionary *)getdictEvents;
-(void)setCollectiondelegate:(id)Collectiondelegate;
@end
