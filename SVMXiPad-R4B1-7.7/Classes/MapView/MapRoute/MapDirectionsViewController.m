//
//  MapDirectionsViewController.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "MapDirectionsViewController.h"
#import "UICRouteOverlayMapView.h"
#import "UICRouteAnnotation.h"
#import "EventAnnotation.h"
#import "RouteListViewController.h"

static NSString* const GMAP_ANNOTATION_SELECTED = @"gMapAnnontationSelected";

@implementation MapDirectionsViewController

@synthesize delegate;

@synthesize startPoint;
@synthesize endPoint;
@synthesize wayPoints;
@synthesize travelMode;
@synthesize diretions;

@synthesize additionalAnnotations;

@synthesize workOrderArray;
@synthesize frame;

- (void)dealloc
{
	[routeOverlayView release];
	[startPoint release];
	[endPoint release];
    [wayPoints release];
    [super dealloc];
}

- (void)loadView 
{
	// UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(142.0f, 26.0f, 732.0f, 440.0f)];
    // UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 728.0f, 436.0f)];
    UIView * contentView = [[UIView alloc] initWithFrame:frame];
	self.view = contentView;
	[contentView release];
	
	routeMapView = [[MKMapView alloc] initWithFrame:contentView.frame];
	routeMapView.delegate = self;
	routeMapView.showsUserLocation = YES;
	[contentView addSubview:routeMapView];
	[routeMapView release];
	
	routeOverlayView = [[UICRouteOverlayMapView alloc] initWithMapView:routeMapView];

	diretions = [UICGDirections sharedDirections];
	diretions.delegate = self;
    
    NSLog(@"%@", workOrderArray);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (diretions.isInitialized)
    {
		[self update];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) showRecentVisits:(NSArray *)_recentVisitsArray
{
    recentVisitsArray = [_recentVisitsArray copy];
    
    for (int i = 0; i < [recentVisitsArray count]; i++)
    {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[[[recentVisitsArray objectAtIndex:i] fields] objectForKey:SVMXCLATITUDE] doubleValue];
        coordinate.longitude = [[[[recentVisitsArray objectAtIndex:i] fields] objectForKey:SVMXCLONGITUDE] doubleValue];
        NSString * name = [[[recentVisitsArray objectAtIndex:i] fields] objectForKey:@"Name"];
        UICRouteAnnotation * annotation = [[UICRouteAnnotation alloc] initWithCoordinate:coordinate title:name annotationType:UICRouteAnnotationTypeRecentVisits];
        [additionalAnnotations addObject:annotation];
        [routeMapView addAnnotation:annotation];
        [annotation release];
    }
}

- (void)update
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	UICGDirectionsOptions *options = [[[UICGDirectionsOptions alloc] init] autorelease];
	options.travelMode = travelMode;

    // Added the 2 if statements to avoid crash in map view.
    // Steps of the crash reproduction without the following 2 lines
    // 1. Create sample data and login
    // 2. Go directly to Map View. Map view crashes as startPoint and endPoint are nil.
    // Trying to add the nil values to the routePoints array results in the crash.
    // This definitely is NOT a bug in the app, but in the SFDC implementation of "Create Sample Data", since the 
    // technician address (stored in AppDelegate) is not being filled in.
    if (startPoint == nil)
        startPoint = @"";
    if (endPoint == nil)
        endPoint = @"";
    
	if ([wayPoints count] > 0)
    {
		NSArray *routePoints = [NSArray arrayWithObject:startPoint];
		routePoints = [routePoints arrayByAddingObjectsFromArray:wayPoints];
		routePoints = [routePoints arrayByAddingObject:endPoint];
		[diretions loadFromWaypoints:routePoints options:options];
	}
    else
    {
		[diretions loadWithStartPoint:startPoint endPoint:endPoint options:options];
	}
    [delegate mapDirectionDidLoad];
}

- (void)moveToCurrentLocation:(id)sender 
{
	[routeMapView setCenterCoordinate:[routeMapView.userLocation coordinate] animated:YES];
}

- (void)addPinAnnotation:(id)sender 
{
	UICRouteAnnotation *pinAnnotation = [[[UICRouteAnnotation alloc] initWithCoordinate:[routeMapView centerCoordinate]
     																		  title:nil
    																 annotationType:UICRouteAnnotationTypeWayPoint] autorelease];
	[routeMapView addAnnotation:pinAnnotation];
}

- (void)showRouteListView:(id)sender
{
	RouteListViewController *controller = [[RouteListViewController alloc] initWithStyle:UITableViewStyleGrouped];
	controller.routes = diretions.routes;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentModalViewController:navigationController animated:YES];
	[controller release];
	[navigationController release];
}

#pragma mark <UICGDirectionsDelegate> Methods

- (void)directionsDidFinishInitialize:(UICGDirections *)directions 
{
	[self update];
}

- (void)directions:(UICGDirections *)directions didFailInitializeWithError:(NSError *)error 
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Directions" message:[error localizedFailureReason] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
	[alertView release];
}

- (void)directionsDidUpdateDirections:(UICGDirections *)directions 
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// Overlay polylines
	UICGPolyline *polyline = [directions polyline];
	NSArray *routePoints = [polyline routePoints];
	[routeOverlayView setRoutes:routePoints];
	
	// Add annotations
	UICRouteAnnotation *startAnnotation = [[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints objectAtIndex:0] coordinate]
																					title:startPoint
																		   annotationType:UICRouteAnnotationTypeStart];
    startAnnotation.workOrder = nil; // [workOrderArray objectAtIndex:0];
    startAnnotation.index = -1;

	UICRouteAnnotation *endAnnotation = [[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints lastObject] coordinate]
																					title:endPoint
																		   annotationType:UICRouteAnnotationTypeEnd];
    endAnnotation.workOrder = [workOrderArray lastObject];
    endAnnotation.index = [workOrderArray count]-1;
    
    // SAMMAN - BEGIN - Ensure duplicate addresses are not used
    
    NSMutableArray * latitudeList = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray * longitudeList = [[NSMutableArray alloc] initWithCapacity:0];
    
    // SAMMAN - END

	if ([wayPoints count] > 0)
    {
		NSInteger numberOfRoutes = [directions numberOfRoutes];
		for (NSInteger index = 0; index < numberOfRoutes-1; index++)
        {
			UICGRoute *route = [directions routeAtIndex:index];
			CLLocation *location = [route endLocation];
            NSDictionary * endGeocode = [route endGeocode];
            NSString * address = [endGeocode objectForKey:@"address"];
            CLLocationCoordinate2D coord = [location coordinate];
            NSLog(@"%@, %f, %f", address, coord.latitude, coord.longitude);
            // SAMMAN - BEGIN - Ensure duplicate addresses are not used
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
            
            // SAMMAN - Remove the below erroneous code, annotations don't always carry valid addresses.
//            if (![address isKindOfClass:[NSString class]])
//                continue;

            // SAMMAN - END
			UICRouteAnnotation *annotation = [[UICRouteAnnotation alloc] initWithCoordinate:[location coordinate]
																					   title:address
																			  annotationType:UICRouteAnnotationTypeWayPoint];
            annotation.workOrder = [workOrderArray objectAtIndex:index];
            annotation.index = index;
			[routeMapView addAnnotation:annotation];
            [annotation release];
		}
        
        // SAMMAN - BEGIN - Ensure duplicate addresses are not used
        // release addressList NOW
        [latitudeList removeAllObjects];
        [latitudeList release];
        [longitudeList removeAllObjects];
        [longitudeList release];
        // SAMMAN - END
        
	}
		
	// [routeMapView addAnnotations:[NSArray arrayWithObjects:startAnnotation, endAnnotation, nil]];
    [routeMapView addAnnotations:[NSArray arrayWithObjects:startAnnotation, nil]];
    [startAnnotation release];
    [endAnnotation release];
    [delegate mapDirectionDidLoad];
}

- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message 
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Directions" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
	[alertView release];
}

#pragma mark <MKMapViewDelegate> Methods

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated 
{
	routeOverlayView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated 
{
	routeOverlayView.hidden = NO;
    
    // SAMMAN - BEGIN
    if ([wayPoints count] > 0)
    {
        NSArray * annotationArray = [routeMapView annotations];
        if ([annotationArray count] > 1)
        {
            UICRouteAnnotation *annotation = [annotationArray objectAtIndex:1];
            routeOverlayView.firstDestinationCoordinate = annotation.coordinate;
        }
    }
    // SAMMAN - END
	[routeOverlayView setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSString *action = (NSString*)context;
    NSLog(@"Call Custom Callout");
    if([action isEqualToString:GMAP_ANNOTATION_SELECTED])
    {
        BOOL annotationAppeared = [[change valueForKey:@"new"] boolValue];
        // do something
        // if (annotationAppeared)
            // NSLog(@"MKAnnotationView Clicked = %d", annotationAppeared);
        
        CGPoint point = [routeMapView convertCoordinate:[object coordinate] toPointToView:self.view];
        // if (annotationAppeared)
            // NSLog(@"x = %f, y = %f", point.x, point.y);
        
        UICRouteAnnotation * annotationObject = (UICRouteAnnotation *)[object annotation];
        
        if (annotationAppeared)
        {
            [delegate customCallOutForAnnotation:annotationObject AtPosition:point];
            [routeMapView deselectAnnotation:annotationObject animated:YES];
        }
        else
        {
            // [delegate hideCustomCallOutForAnnotation:annotationObject AtPosition:point];
            // [routeMapView deselectAnnotation:annotationObject animated:YES];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"Selected annotation");
}

- (void)deselectAnnotation:(id < MKAnnotation >)annotation animated:(BOOL)animated
{
    NSLog(@"Deselected annotation");
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	static NSString *identifier = @"RoutePinAnnotation";
	
	if ([annotation isKindOfClass:[UICRouteAnnotation class]])
    {
		MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(!pinAnnotation) {
			pinAnnotation = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
		}
        
        pinAnnotation.animatesDrop = YES;
		pinAnnotation.enabled = YES;
		pinAnnotation.canShowCallout = YES;
		
		if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeStart)
        {
			pinAnnotation.pinColor = MKPinAnnotationColorRed;
            // Then later somewhere in your code, add the observer
            [pinAnnotation addObserver:self
                              forKeyPath:@"selected"
                                 options:NSKeyValueObservingOptionNew
                               context:GMAP_ANNOTATION_SELECTED];
            pinAnnotation.canShowCallout = NO;
		}
        else if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeEnd)
        {
			pinAnnotation.pinColor = MKPinAnnotationColorRed;
            // Then later somewhere in your code, add the observer
            [pinAnnotation addObserver:self
                            forKeyPath:@"selected"
                               options:NSKeyValueObservingOptionNew
                               context:GMAP_ANNOTATION_SELECTED];
            pinAnnotation.canShowCallout = NO;
		}
        else 
        {
			pinAnnotation.pinColor = MKPinAnnotationColorPurple;
            // Then later somewhere in your code, add the observer
            [pinAnnotation addObserver:self
                            forKeyPath:@"selected"
                               options:NSKeyValueObservingOptionNew
                               context:GMAP_ANNOTATION_SELECTED];
            pinAnnotation.canShowCallout = NO;
		}

		return pinAnnotation;
	}
    else if ([annotation isKindOfClass:[SFAnnotation class]])   // for City of San Francisco
    {
        static NSString* SFAnnotationIdentifier = @"SFAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[routeMapView dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
        if (!pinView)
        {
            MKPinAnnotationView *annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                                   reuseIdentifier:SFAnnotationIdentifier] autorelease];
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.animatesDrop = YES;
            annotationView.canShowCallout = NO;
            
            // Then later somewhere in your code, add the observer
            [annotationView addObserver:self
                             forKeyPath:@"selected"
                                options:NSKeyValueObservingOptionNew
                                context:GMAP_ANNOTATION_SELECTED];
            
            UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            rightButton.titleLabel.text = @"Hello";
            rightButton.frame = CGRectMake(0, 0, 73, 43);
            
            rightButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            
            
            [rightButton addTarget:self
                            action:@selector(showDetails:) 
                  forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
            
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    else {
		return nil; // [routeMapView viewForAnnotation:routeMapView.userLocation];
	}
}

@end
