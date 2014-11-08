//
//  MapDirectionsViewController.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UICGDirections.h"
#import "UICRouteAnnotation.h"

extern NSInteger const kTechAnnotationIndex;

@protocol MapDirectionsDelegate <NSObject>

@optional
- (void) mapDirectionDidLoad;
- (void) customCallOutForAnnotation:(UICRouteAnnotation *)annotationObject AtPosition:(CGPoint)point forAnnotationView:(MKAnnotationView*)annotationView;


@end


@interface MapDirectionsViewController : UIViewController<MKMapViewDelegate, UICGDirectionsDelegate>
{
    id <MapDirectionsDelegate> __weak delegate;
	MKMapView *routeMapView;
	UICGDirections *directions;
	NSString *startPoint;
	NSString *endPoint;
	NSArray *wayPoints;
	UICGTravelModes travelMode;
    CGRect frame;
    NSArray * workOrderArray;
}
@property (nonatomic, strong) MKMapView *routeMapView;
@property (nonatomic, weak) id <MapDirectionsDelegate> delegate;
@property (nonatomic, copy) NSString *startPoint;
@property (nonatomic, copy) NSString *endPoint;
@property (nonatomic, copy) NSString *techAddressString;
@property (nonatomic, strong) NSArray *wayPoints;
@property (nonatomic) UICGTravelModes travelMode;
@property (nonatomic, strong) UICGDirections *directions;
@property (nonatomic) CGRect frame;
@property (nonatomic, strong) NSArray * workOrderArray;

- (void)update;
- (void)zoomToFitMapAnnotations:(MKMapView*)aMapView;
- (void)moveToCurrentLocation:(id)sender;

@end

