//
//  EventAnnotation.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 21/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface EventAnnotation : NSObject
<MKAnnotation>
{
    NSString * event, * subEvent;
    double latitude;
    double longitude;
}

- (void) setEvent:(NSString *) _event subEvent:(NSString *)_subEvent Latitude:(double) _latitude Longitude:(double) _longitude;
- (CLLocationCoordinate2D)coordinate;	
- (NSString *) EventName;	

@end
