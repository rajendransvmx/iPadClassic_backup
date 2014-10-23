//
//  UICRouteOverlayMapView.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface UICRouteOverlayMapView : UIView
{
	MKMapView *inMapView;
	NSArray *routes;
	UIColor *lineColor;
    CLLocationCoordinate2D firstDestinationCoordinate;
}

@property (nonatomic, strong) MKMapView *inMapView;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic) CLLocationCoordinate2D firstDestinationCoordinate;

- (id)initWithMapView:(MKMapView *)mapView;

@end
