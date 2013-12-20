//
//  EventAnnotation.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 21/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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

- (void) setEvent:(NSString *)_event subEvent:(NSString *)_subEvent Latitude:(double)_latitude Longitude:(double)_longitude
{
    event = [_event retain];
    subEvent = [_subEvent retain];
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
