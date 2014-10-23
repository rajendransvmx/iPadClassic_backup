//
//  EventAnnotation.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 21/08/10.
//  Updated by Anoopsaai Ramani on 11/09/14.
//  Copyright 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface EventAnnotation : NSObject <MKAnnotation>
{
    NSString * event, * subEvent;
    double latitude;
    double longitude;
}

- (void) setEvent:(NSString *) _event subEvent:(NSString *)_subEvent Latitude:(double) _latitude Longitude:(double) _longitude;
- (CLLocationCoordinate2D)coordinate;	
- (NSString *) EventName;	

@end
