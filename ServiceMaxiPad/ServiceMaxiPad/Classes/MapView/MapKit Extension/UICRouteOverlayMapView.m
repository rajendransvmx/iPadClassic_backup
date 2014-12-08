//
//  UICRouteOverlayMapView.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UICRouteOverlayMapView.h"
#import "UICGRoute.h"

@implementation UICRouteOverlayMapView
@synthesize inMapView;
@synthesize routes;
@synthesize lineColor;
@synthesize firstDestinationCoordinate;

- (id)initWithMapView:(MKMapView *)mapView
{
	self = [super initWithFrame:CGRectMake(0.0f, 0.0f, mapView.frame.size.width, mapView.frame.size.height)];
    
	if (self != nil)
    {
		self.inMapView = mapView;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		[self.inMapView addSubview:self];
	}
	
	return self;
}


- (void)drawRect:(CGRect)rect
{
	if(!self.hidden && self.routes != nil && self.routes.count > 0)
    {
		CGContextRef context = UIGraphicsGetCurrentContext();
        self.lineColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
		
		CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
		CGContextSetRGBFillColor(context, 0.0f, 0.0f, 1.0f, 1.0f);
		
		CGContextSetLineWidth(context, 4.0f);
		
		for(int i = 0; i < self.routes.count; i++)
        {
            CLLocation * route = [self.routes objectAtIndex:i];
            //NSLog(@"%f, %f", route.coordinate.latitude, route.coordinate.longitude);
            //NSLog(@"%f, %f", firstDestinationCoordinate.latitude, firstDestinationCoordinate.longitude);
            if (
                (route.coordinate.latitude == firstDestinationCoordinate.latitude)
                &&
               (route.coordinate.longitude == firstDestinationCoordinate.longitude) 
                )
                 self.lineColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
            
			CLLocation* location = [self.routes objectAtIndex:i];
			CGPoint point = [self.inMapView convertCoordinate:location.coordinate toPointToView:self];
			
			if(i == 0)
            {
				CGContextMoveToPoint(context, point.x, point.y);
			} 
            else 
            {
				CGContextAddLineToPoint(context, point.x, point.y);
			}
		}
		
		CGContextStrokePath(context);
	}
}

- (void)setRoutes:(NSArray *)routePoints
{
	if (self.routes != routePoints)
    {
		routes = routePoints;
		CLLocationDegrees maxLat = -90.0f;
		CLLocationDegrees maxLon = -180.0f;
		CLLocationDegrees minLat = 90.0f;
		CLLocationDegrees minLon = 180.0f;
		
		for (int i = 0; i < routes.count; i++)
        {
			CLLocation *currentLocation = [routes objectAtIndex:i];
			if(currentLocation.coordinate.latitude > maxLat) 
            {
				maxLat = currentLocation.coordinate.latitude;
			}
			if(currentLocation.coordinate.latitude < minLat) 
            {
				minLat = currentLocation.coordinate.latitude;
			}
			if(currentLocation.coordinate.longitude > maxLon) 
            {
				maxLon = currentLocation.coordinate.longitude;
			}
			if(currentLocation.coordinate.longitude < minLon) 
            {
				minLon = currentLocation.coordinate.longitude;
			}
		}
		
		MKCoordinateRegion region;
		region.center.latitude     = (maxLat + minLat) / 2;
		region.center.longitude    = (maxLon + minLon) / 2;
		region.span.latitudeDelta  = maxLat - minLat;
		region.span.longitudeDelta = maxLon - minLon;
        
		[self.inMapView setRegion:region animated:YES];
		[self setNeedsDisplay];
	}
}

- (void)dealloc {
    inMapView = nil;
    routes = nil;
    lineColor = nil;
}

@end
