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
#import "SMXConstants.h"

@implementation SMXDateManager

@synthesize currentDate;
@synthesize timeZone;
@synthesize dictEvents;
@synthesize Collectiondelegate;
@synthesize selectedEvent;
@synthesize endDateWindow;
@synthesize startDateWindow;
@synthesize businessHours;

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
    
    currentDate = _currentDate;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DATE_MANAGER_DATE_CHANGED object:_currentDate];
}

-(void)setDictEvents:(NSMutableDictionary *)dictEventss{
    dictEvents=dictEventss;
}
-(NSMutableDictionary *)getdictEvents{
    return self.dictEvents;
}

-(void)updateEvent:(SMXEvent *)event fromActivityDate:(NSDate *)fromActivityDate toActivityDate:(NSDate *)toActivityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTim cellIndex:(int)fromIndex toIndex:(int)toIndex{
    if (fromIndex==toIndex) {
        
        /*if event changing within day, then we don't have to remove event and add into array*/
        event.ActivityDateDay=toActivityDate;
        event.dateTimeBegin=startTime;
        event.dateTimeEnd=endTim;
        event.dateTimeBegin_multi=startTime;
        event.dateTimeEnd_multi=endTim;
        NSMutableArray *fromList=[self.dictEvents objectForKey:fromActivityDate];
        
        /*sorting array with startDate*/
        NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimeBegin"
                                                                                       ascending:YES];
        NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithArray:[fromList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, nil]]];
        [self.dictEvents setObject:sortedArray forKey:fromActivityDate];
        [Collectiondelegate refreshCell:fromIndex Tocell:toIndex forEvent:event];
    }else{
        /*remove EventFromActivityDate*/
        NSMutableArray *fromList=[self.dictEvents objectForKey:fromActivityDate];
        [fromList removeObject:event];
        [self.dictEvents setObject:fromList forKey:fromActivityDate];
        
        /*Modifying event*/
        event.ActivityDateDay=toActivityDate;
        event.dateTimeBegin=startTime;
        event.dateTimeEnd=endTim;
        event.dateTimeBegin_multi=startTime;
        event.dateTimeEnd_multi=endTim;
        /*Add Evenet toDate*/
        NSMutableArray *toList=[self.dictEvents objectForKey:toActivityDate];
        if (toList==nil && [toList count]==0) {
            toList = [[NSMutableArray alloc] init];
        }
        [toList  addObject:event];
        
        /*sorting array with startDate*/
        NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimeBegin"
                                                                                       ascending:YES];
        NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithArray:[toList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, nil]]];
        [self.dictEvents setObject:sortedArray forKey:toActivityDate];
        [Collectiondelegate refreshCell:fromIndex Tocell:toIndex forEvent:event];
    }
}
-(void)setCollectiondelegate:(id)Collectiondelegates{
    Collectiondelegate=Collectiondelegates;
}
/*Here we are setting event daet window, event sud come in between only normal and multiday event*/
-(void)setStartDateWindow:(NSDate *)startDateWindow_loc{
    startDateWindow=startDateWindow_loc;
}
-(NSDate *)getStartDateWindow{
    return startDateWindow;
}
-(void)setEndDateWindow:(NSDate *)endDateWindow_loc{
    endDateWindow=endDateWindow_loc;
}
-(NSDate *)getEndDateWindow{
    return endDateWindow;
}

-(int )numberOfDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    startDate=[self removeHourMinSecon:startDate];
    endDate=[self removeHourMinSecon:endDate];
    if ((startDate !=nil) && (endDate!=nil)) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        int i=(int)components.day;
        if(i==0){
            NSDateComponents *Scomp = [self componentsOfDate:startDate];
            NSDateComponents *Ecomp = [self componentsOfDate:endDate];
            if (Scomp.day!=Ecomp.day) {
                return 1;
            }
        }
        return i+1;
    }
    return 0;
}
-(NSDate *)removeHourMinSecon:(NSDate *)date{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [cal components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[date dateByAddingTimeInterval:0*24*60*60]];
    comp.hour = 00;
    comp.minute = 00;
    comp.second = 00;
    //NSDate *sevenDaysAgo = [cal dateFromComponents:comp];// dateByAddingTimeInterval:numberOfDay*24*60*60];
    return [cal dateFromComponents:comp];
}
-(NSDateComponents *)componentsOfDate:(NSDate *)date {
    
    //Time zone change for weekview change, here we are considering system reagion.
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //  NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *comp0 = [calender components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth| NSHourCalendarUnit |
                               NSMinuteCalendarUnit fromDate:date];
    return comp0;
}
@end
