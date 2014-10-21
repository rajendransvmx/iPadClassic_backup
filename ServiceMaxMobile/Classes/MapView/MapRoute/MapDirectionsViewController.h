//
//  MapDirectionsViewController.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UICGDirections.h"
#import "UICRouteAnnotation.h"
#import "iOSInterfaceObject.h"

// Additional Map Annotations
#import "SFAnnotation.h"

@protocol MapDirectionsDelegate

@optional
- (void) mapDirectionDidLoad;
- (void) customCallOutForAnnotation:(UICRouteAnnotation *)annotationObject AtPosition:(CGPoint)point;
@end


@class UICRouteOverlayMapView;

@interface MapDirectionsViewController : UIViewController<MKMapViewDelegate, UICGDirectionsDelegate>
{
    id <MapDirectionsDelegate> delegate;

	MKMapView *routeMapView;
	UICRouteOverlayMapView *routeOverlayView;
	UICGDirections *diretions;
	NSString *startPoint;
	NSString *endPoint;
	NSArray *wayPoints;
	UICGTravelModes travelMode;
    
    CGRect frame;

    // Additional Map Annotations
    NSMutableArray * additionalAnnotations;
    SFAnnotation * sfannotation1, * sfannotation2, * sfannotation3;
    
    
    // Recent Visits
    NSMutableArray * recentVisitsArray;
    
    // Work Order array
    NSArray * workOrderArray;
}

@property (nonatomic, retain) id <MapDirectionsDelegate> delegate;

@property (nonatomic, retain) NSString *startPoint;
@property (nonatomic, retain) NSString *endPoint;
@property (nonatomic, retain) NSArray *wayPoints;
@property (nonatomic) UICGTravelModes travelMode;
@property (nonatomic, retain) UICGDirections *diretions;

@property CGRect frame;

@property (nonatomic, retain) NSArray * workOrderArray;

- (void)update;

- (void) showRecentVisits:(NSArray *)_recentVisitsArray;

@property (nonatomic, retain) NSMutableArray * additionalAnnotations;

@end

