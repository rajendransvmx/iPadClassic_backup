
//
//  FirstDetailViewController.h
//  iService
//
//  Created by Samman Banerjee on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MapKit/MapKit.h"
#import "LocationPopOver.h"
#import "MapTableCell.h"
#import "CoreLocation/CLLocationManager.h"

#import "RouteController.h"

#import "MapDirectionsViewController.h"
#import "UICGDirections.h"
#import "ImageCacheClass.h"

@protocol MapViewDelegate;

@class UICRouteOverlayMapView;

@interface FirstDetailViewController : UIViewController
<UIPopoverControllerDelegate,
UITableViewDelegate,
UITableViewDataSource,
MKMapViewDelegate,
UICGDirectionsDelegate,
MapDirectionsDelegate,
LocationPopOverDelegate,
CLLocationManagerDelegate,
MKReverseGeocoderDelegate>
{
    id <MapViewDelegate> delegate;
    AppDelegate * appDelegate;
    UIToolbar * toolbar;
    NSMutableArray *mapAnnotations;
    IBOutlet MKMapView * routeMapView;

    IBOutlet UITableView * tableView;
    IBOutlet UIView * mapView;
    
    BOOL willShowMap;
    
    RouteController * routeView;
    IBOutlet UILabel * directionLabel;
    
    JobViewController * jvc;
    
    // Job Detail elements
    IBOutlet UILabel * WONumber;
    IBOutlet UITextView * WODescription;
    IBOutlet UILabel * contactName;
    IBOutlet UITextView * contactAddress;
    IBOutlet UILabel * contactEmail;
    IBOutlet UILabel * problemCode;
    IBOutlet UITextView * problemDescription;
    
    // iOSInterfaceObject
    iOSInterfaceObject * iOSObject;

    NSUInteger currentSelection;
    IBOutlet UIImageView * contactImage;
    IBOutlet UIActivityIndicatorView * imageActivity;
    NSDictionary * currentWorkOrderDetails;
    
    // Route Variables
    MapDirectionsViewController * controller;
    
    NSMutableArray *wayPointFields;
    UICRouteOverlayMapView *routeOverlayView;
	UICGDirections *diretions;
	NSString *startPoint;
	NSString *endPoint;
	NSMutableArray *wayPoints;
	UICGTravelModes travelMode;
    
    LocationPopOver * locationPop;
    UIPopoverController * popOver;
    
    // Recent Visits
    IBOutlet UIImageView * recentVisitBackground;
    IBOutlet UISwitch * recentVisitSwitch;
    NSString * currentDate;
    
    // Location Related
    CLLocationManager * locationManager;
    
    ImageCacheClass * imageCache;
    
    // Reverse Geocoding
    MKReverseGeocoder * reverseGeocoder;
    NSMutableString * currentLocation;
    
    BOOL isLoaded;
    
    // NSMutableArray * workOrderEventArray;
    NSMutableArray * eventsArray;
    
    NSDictionary * currentWorkOrderInfo;
    
    BOOL didRunOperation;
    
    //For Technician Address
    BOOL didQueryTechnician;
    BOOL didDebriefData;
    
}

@property (nonatomic, retain) id <MapViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) NSMutableArray *mapAnnotations;

@property (nonatomic, retain) iOSInterfaceObject * iOSObject;

@property (nonatomic, retain) NSString * currentDate;

- (IBAction) Help;
- (IBAction) ShowModal;
- (IBAction) viewJobDetail;

- (void) setJobDetailsForWorkOrder:(NSDictionary *)workOrder;

- (void) setJobDetailsForWorkOrder:(NSDictionary *)workOrder workOrderInfo:(NSDictionary *)workOrderInfo;

- (void) setContactImage;
- (void) queryImagesForAccount:(NSString *)companyId Contact:(NSString *)contactId;
// - (void) showDetails:(NSString *)string;//  Unused methods

// - (void) SetMap;//  Unused methods

- (NSUInteger) getPriorityColorByPriority:(NSString *)priority;
- (UIImage *) getImageForColorIndex:(NSUInteger)colorIndex;

- (NSArray *) getWorkOrderArray;

// Route Variables
@property (nonatomic, retain) NSString *startPoint;
@property (nonatomic, retain) NSString *endPoint;
@property (nonatomic, retain) NSArray *wayPoints;
@property (nonatomic) UICGTravelModes travelMode;

- (void)update;
- (void) setupMapView;
// recent visit uiswitch action
- (IBAction) didChangeRecentVisit:(id)sender;

// Location Related Methods
//- (void)startStandardUpdates;//  Unused methods
- (void) reverseGeocodeWithCoordinate:(CLLocation *)coordinate;

- (IBAction) launchSmartVan;

// Display user name
- (IBAction) displayUser:(id)sender;

#define ROW_HEIGHT                  58

@end

@protocol MapViewDelegate

@optional
//- (void) closeMapView;//  Unused methods

@end
