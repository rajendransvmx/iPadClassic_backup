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
    return dictEvents;
}

-(void)updateEvent:(SMXEvent *)event fromActivityDate:(NSDate *)fromActivityDate toActivityDate:(NSDate *)toActivityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTim cellIndex:(int)fromIndex toIndex:(int)toIndex{
    
    
    if (fromIndex==toIndex) {
        
        /*if event changing within day, then we don't have to remove event and add into array*/
        event.ActivityDateDay=toActivityDate;
        event.dateTimeBegin=startTime;
        event.dateTimeEnd=endTim;
        NSMutableArray *fromList=[dictEvents objectForKey:fromActivityDate];
        
        /*sorting array with startDate*/
        NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimeBegin"
                                                                                       ascending:YES];
        NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithArray:[fromList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, nil]]];
        [dictEvents setObject:sortedArray forKey:fromActivityDate];
        [Collectiondelegate refreshCell:fromIndex Tocell:toIndex forEvent:event];
    }else{
        /*remove EventFromActivityDate*/
        NSMutableArray *fromList=[dictEvents objectForKey:fromActivityDate];
        [fromList removeObject:event];
        [dictEvents setObject:fromList forKey:fromActivityDate];
        
        /*Modifying event*/
        event.ActivityDateDay=toActivityDate;
        event.dateTimeBegin=startTime;
        event.dateTimeEnd=endTim;
        
        /*Add Evenet toDate*/
        NSMutableArray *toList=[dictEvents objectForKey:toActivityDate];
        if (toList==nil && [toList count]==0) {
            toList = [[NSMutableArray alloc] init];
        }
        [toList  addObject:event];
        
        /*sorting array with startDate*/
        NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimeBegin"
                                                                                       ascending:YES];
        NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithArray:[toList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, nil]]];
        [dictEvents setObject:sortedArray forKey:toActivityDate];
        [Collectiondelegate refreshCell:fromIndex Tocell:toIndex forEvent:event];
    }
}
-(void)updateDayEvent:(SMXEvent *)event ActivityDate:(NSDate *)toActivityDate andStartTime:(NSDate *)startTime withEndTime:(NSDate *)endTim cellIndex:(int)fromIndex{
    
    /*Modifying event*/
    event.ActivityDateDay=toActivityDate;
    event.dateTimeBegin=startTime;
    event.dateTimeEnd=endTim;
    
    /*Add Evenet toDate*/
    NSMutableArray *toList=[dictEvents objectForKey:toActivityDate];
    if (toList==nil && [toList count]==0) {
        toList = [[NSMutableArray alloc] init];
    }
    [toList  addObject:event];
    
    /*sorting array with startDate*/
    NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimeBegin"
                                                                                   ascending:YES];
    NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithArray:[toList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, nil]]];
    [dictEvents setObject:sortedArray forKey:toActivityDate];
}
-(void)setCollectiondelegate:(id)Collectiondelegates{
    Collectiondelegate=Collectiondelegates;
}
@end
