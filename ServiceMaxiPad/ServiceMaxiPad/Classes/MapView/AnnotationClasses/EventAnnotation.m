//
//  EventAnnotation.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 21/08/10.
//  Updated by Anoopsaai Ramani on 11/09/14.
//  Copyright 2014 ServiceMax. All rights reserved.
//

#import "EventAnnotation.h"


@implementation EventAnnotation

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = latitude;
    theCoordinate.longitude = longitude;
    return theCoordinate; 
}

/**
 * @name  setEvent
 *
 * @author Anil Kumar
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */


- (void) setEvent:(NSString *)_event subEvent:(NSString *)_subEvent Latitude:(double)_latitude Longitude:(double)_longitude
{
    event = _event;
    subEvent = _subEvent;
    latitude = _latitude;
    longitude = _longitude;
}

- (NSString *) EventName
{
    return event;
}

- (NSString *)title
{
    return event;
}

// optional
- (NSString *)subtitle
{
    return subEvent;
}

@end
