//
//  MapDirectionsViewController.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "MapDirectionsViewController.h"
#import "UICRouteOverlayMapView.h"
#import "UICRouteAnnotation.h"
#import "TagManager.h"
#import "LocationPingManager.h"
#import "LocationManager.h"

NSInteger const kTechAnnotationIndex = -1;

@interface MapDirectionsViewController ()

//Map view
@property (nonatomic, strong) UICRouteOverlayMapView *routeOverlayView;

@end


@implementation MapDirectionsViewController
@synthesize delegate;
@synthesize startPoint;
@synthesize endPoint;
@synthesize wayPoints;
@synthesize travelMode;
@synthesize directions;
@synthesize workOrderArray;
@synthesize frame;
@synthesize routeMapView;
@synthesize routeOverlayView;

-(void)setFrame:(CGRect)frameRect {
    
    frame = frameRect;
    self.view.frame = frameRect;
    self.routeMapView.frame = frameRect;
    self.routeOverlayView.frame = frameRect;
}

- (void)loadView 
{
	
    UIView * contentView = [[UIView alloc] initWithFrame:frame];
	self.view = contentView;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    if (!self.routeMapView) {
        self.routeMapView = [[MKMapView alloc] initWithFrame:self.view.frame];
        self.routeMapView.delegate = self;
        if (![[LocationPingManager sharedInstance] isLocationPingIsEnabledInServer])
            [[[LocationManager sharedInstance] locManager]  startUpdatingLocation];
        self.routeMapView.showsUserLocation = YES;
        self.routeMapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
	[self.view addSubview:self.routeMapView];
	
    if (!self.routeOverlayView) {
        self.routeOverlayView = [[UICRouteOverlayMapView alloc] initWithMapView:self.routeMapView];
        self.routeOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.directions = [[UICGDirections alloc] init];
        self.directions.delegate = self;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCurrentLocation) name:kLocationManagerNotificationAuthorizationChangedName object:nil];
	if (self.directions.isInitialized)
    {
		[self update];
	}
}

- (void)showCurrentLocation {
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(showCurrentLocation) withObject:nil waitUntilDone:YES];
        return;
    }
    self.routeMapView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)update
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
	UICGDirectionsOptions *options = [[UICGDirectionsOptions alloc] init];
	options.travelMode = travelMode;

    if (self.startPoint == nil)
        self.startPoint = @"";
    if (self.endPoint == nil)
        self.endPoint = @"";
    
	if ([self.wayPoints count])
    {
		NSArray *routePoints = [NSArray arrayWithObject:startPoint];
		routePoints = [routePoints arrayByAddingObjectsFromArray:wayPoints];
		routePoints = [routePoints arrayByAddingObject:endPoint];
		[directions loadFromWaypoints:routePoints options:options];
        routePoints = nil;
	}
    else
    {
		[self.directions loadWithStartPoint:self.startPoint endPoint:self.endPoint options:options];
        options = nil;
	}
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapDirectionDidLoad)]) {
        [self.delegate mapDirectionDidLoad];
    }

}

- (void)moveToCurrentLocation:(id)sender 
{
	[self.routeMapView setCenterCoordinate:[self.routeMapView.userLocation coordinate] animated:YES];
}


#pragma mark <UICGDirectionsDelegate> Methods

- (void)directionsDidFinishInitialize:(UICGDirections *)directions 
{
	[self update];
}


- (void)directions:(UICGDirections *)directions didFailInitializeWithError:(NSError *)error 
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance] tagByName:kTagMapDirectionFailed] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:nil otherButtonTitles:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk], nil];
	[alertView show];
    alertView = nil;
}


- (void)directionsDidUpdateDirections:(UICGDirections *)cgdirections
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// Overlay polylines
	UICGPolyline *polylineRoutePoints = [cgdirections polyline];
	NSArray *routePoints = [polylineRoutePoints routePoints];
	self.routeOverlayView.routes = routePoints;
    polylineRoutePoints = nil;
	
	// Add annotations
	UICRouteAnnotation *techAnnotation = [[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints objectAtIndex:0] coordinate]
                                                                                   title:startPoint
                                                                          annotationType:UICRouteAnnotationTypeTechAddress];
    techAnnotation.workOrder = nil;
    techAnnotation.index = kTechAnnotationIndex;
    routePoints = nil;
    
    NSMutableArray * latitudeList = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * longitudeList = [[NSMutableArray alloc] initWithCapacity:0];

	if ([self.wayPoints count])
    {
        NSInteger  kk = 0;
		for (NSInteger index = 0; index < [self.wayPoints count]; index++)
        {
			UICGRoute *route = [cgdirections routeAtIndex:0];
			CLLocation *location = [route endLocation];

            if (kk < [[route waypoints] count]) {
                location = [[route waypoints]objectAtIndex:kk];
              	kk++;
            }
            NSDictionary * endGeocode = [route endGeocode];
            NSString * address = [endGeocode objectForKey:@"address"];
            CLLocationCoordinate2D coord = [location coordinate];
            //NSLog(@"%@, %f, %f", address, coord.latitude, coord.longitude);

            if ([latitudeList containsObject:[NSNumber numberWithDouble:coord.latitude]])
            {
                if ([longitudeList containsObject:[NSNumber numberWithDouble:coord.longitude]])
                {
                    NSInteger latitudeIndex = [latitudeList indexOfObject:[NSNumber numberWithDouble:coord.latitude]];
                    NSInteger longitudeIndex = [longitudeList indexOfObject:[NSNumber numberWithDouble:coord.longitude]];
                    if (latitudeIndex == longitudeIndex)
                        continue;
                }
            }
            else
            {
                [latitudeList addObject:[NSNumber numberWithDouble:coord.latitude]];
                [longitudeList addObject:[NSNumber numberWithDouble:coord.longitude]];
            }
   
            UICRouteAnnotation *annotation = nil;
            annotation = [[UICRouteAnnotation alloc] initWithCoordinate:[location coordinate] title:address annotationType:UICRouteAnnotationTypeWayPoint index:index workOrderSummary:[self.workOrderArray objectAtIndex:index]];
			[self.routeMapView addAnnotation:annotation];
		}
        
        [latitudeList removeAllObjects];
        [longitudeList removeAllObjects];
        latitudeList = nil;
        longitudeList = nil;

	}
    
    if ([_techAddressString length])
        [self.routeMapView addAnnotations:[NSArray arrayWithObjects:techAnnotation, nil]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapDirectionDidLoad)]) {
        [self.delegate mapDirectionDidLoad];
    }
    [self zoomToFitMapAnnotations:self.routeMapView];
}


- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message 
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance] tagByName:kTagMapDirectionFailed] message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk], nil];
    [alertView show];
    alertView = nil;
}


#pragma mark <MKMapViewDelegate> Methods

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated 
{
	self.routeOverlayView.hidden = YES;
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated 
{
	self.routeOverlayView.hidden = NO;
    if ([self.wayPoints count] > 0)
    {
        NSArray * annotationArray = [self.routeMapView annotations];
        if ([annotationArray count] > 1)
        {
            UICRouteAnnotation *annotation = [annotationArray objectAtIndex:1];
            self.routeOverlayView.firstDestinationCoordinate = annotation.coordinate;
        }
    }
   
	[self.routeOverlayView setNeedsDisplay];
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"Selected annotation");
    CGPoint point = [self.routeMapView convertCoordinate:[(UICRouteAnnotation*)view.annotation coordinate] toPointToView:self.routeMapView];
    UICRouteAnnotation * annotationObject = (UICRouteAnnotation *)[view annotation];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customCallOutForAnnotation:AtPosition:forAnnotationView:)]) {
        [self.delegate customCallOutForAnnotation:annotationObject AtPosition:point forAnnotationView:view];
    }
    [self.routeMapView deselectAnnotation:view.annotation animated:NO];
}


- (void)deselectAnnotation:(id < MKAnnotation >)annotation animated:(BOOL)animated
{
    NSLog(@"Deselected annotation");
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{

}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	
    static NSString *identifier = @"RoutePinAnnotation";
	
	if ([annotation isKindOfClass:[UICRouteAnnotation class]])
    {
		MKAnnotationView *pinAnnotation = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(!pinAnnotation) {
			pinAnnotation = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		}
        pinAnnotation.image = [(UICRouteAnnotation *)annotation image];
        if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeTechAddress)
        {
            pinAnnotation.accessibilityValue = @"pin: techAddress";
            pinAnnotation.image = [UIImage imageNamed:@"map_homelocation_pin@2x"];
        }
        else
        {
            pinAnnotation.accessibilityValue = @"pin: waypoint";
        }
        pinAnnotation.centerOffset = CGPointMake(pinAnnotation.image.size.width/2, - pinAnnotation.image.size.height/2);
		pinAnnotation.enabled = YES;
        pinAnnotation.isAccessibilityElement = YES;
        pinAnnotation.canShowCallout = NO;
		return pinAnnotation;
	}
    else if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        MKAnnotationView *currentLocationAnnotation = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CurrentLocation"];
        currentLocationAnnotation.image = [UIImage imageNamed:@"map_CurrentLocation"];
        currentLocationAnnotation.centerOffset = CGPointMake(currentLocationAnnotation.image.size.width/2, - currentLocationAnnotation.image.size.height/2);
        currentLocationAnnotation.enabled = YES;
        currentLocationAnnotation.canShowCallout = YES;
        return currentLocationAnnotation;
    }
    else {
		return nil; 
	}
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
}


-(void)zoomToFitMapAnnotations:(MKMapView*)aMapView
{
    if([aMapView.annotations count] == 0)
        return;

    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(UICRouteAnnotation *annotation in  aMapView.annotations)
    {
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
        }
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    @try {
        region = [aMapView regionThatFits:region];
        [aMapView setRegion:region animated:YES];
    }
    @catch (NSException *exception) {
        
    }
    
    //[aMapView showAnnotations:aMapView.annotations animated:YES];
    
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self zoomToFitMapAnnotations:self.routeMapView];
}


-(void)dealloc
{
    if (![[LocationPingManager sharedInstance] isLocationPingIsEnabledInServer])
        [[[LocationManager sharedInstance] locManager]  stopUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationManagerNotificationAuthorizationChangedName object:nil];
    delegate = nil;
    startPoint = nil;
    endPoint = nil;
    wayPoints = nil;
    directions.delegate = nil;
    directions = nil;
    workOrderArray = nil;
    routeMapView.showsUserLocation = NO;
    [routeMapView removeFromSuperview];
    routeMapView.delegate = nil;
    routeMapView = nil;
    [routeOverlayView removeFromSuperview];
    routeOverlayView = nil;
}

@end
