
//
//  FirstDetailViewController.m
//  iService
//
//  Created by Samman Banerjee on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FirstDetailViewController.h"
#import "iServiceAppDelegate.h"
#import "SFAnnotation.h"
#import "BridgeAnnotation.h"
#import "UICRouteOverlayMapView.h"
#import "UICRouteAnnotation.h"
#import "RouteListViewController.h"
#import "EventViewController.h"
#import "HTMLBrowser.h"
#import "DateTimeFormatter.h"
#import "LocalizationGlobals.h"
#import "About.h"
#import "Reachability.h"
#import "DataBase.h"
#import "ZKSforce.h"
extern void SVMXLog(NSString *format, ...);

@implementation FirstDetailViewController

@synthesize delegate;

@synthesize iOSObject;

@synthesize startPoint;
@synthesize endPoint;
@synthesize wayPoints;
@synthesize travelMode;

static NSString * const GMAP_ANNOTATION_SELECTED = @"gMapAnnontationSelected";

@synthesize toolbar;
@synthesize mapAnnotations;

@synthesize currentDate;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
    }
    
    return self;
}

- (IBAction) displayUser:(id)sender
{
    UIButton * button = (UIButton *)sender;
    About * about = [[[About alloc] initWithNibName:@"About" bundle:nil] autorelease];
    UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:about];
    [popover setContentViewController:about animated:YES];
    [popover setPopoverContentSize:about.view.frame.size];
    popover.delegate = self;
    [popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark -
#pragma mark MapDirectionsDelegate Method

- (void) mapDirectionDidLoad
{
    recentVisitBackground.alpha = 0.0;
    recentVisitSwitch.alpha = 0.0;
    [self.view bringSubviewToFront:recentVisitBackground];
    [self.view bringSubviewToFront:recentVisitSwitch];
}

- (void) customCallOutForAnnotation:(UICRouteAnnotation *)annotationObject AtPosition:(CGPoint)point;
{
    NSDictionary * workOrder = [annotationObject workOrder];
    
    //SMLog(@"%@", workOrder);
    locationPop = [[[LocationPopOver alloc] initWithNibName:@"LocationPopOver" bundle:nil] autorelease];
    locationPop.delegate = self;
    locationPop.workOrder = [workOrder objectForKey:OBJECTLABEL];
    NSString * str = [workOrder objectForKey:ADDITIONALINFO];
    if (str != nil)
        str = [str stringByReplacingOccurrencesOfString:[appDelegate.wsInterface.tagsDictionary objectForKey:MAP_POPOVER_TITLE] withString:@""];
    locationPop.workOrderDetail = str;
    
    NSMutableString * address = nil;
    address = [[[NSMutableString alloc] initWithCapacity:0] autorelease];

    NSString * woStreet = nil, * woCity = nil, * woState = nil, * woZip = nil, * woCountry = nil;
    woStreet = [[workOrder objectForKey:STREET] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:STREET]]:@"";
    if ([woStreet length] > 0)
        [address appendString:woStreet];
    woCity = [[workOrder objectForKey:CITY] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:CITY]]:@"";
    if ([woCity length] > 0)
    {
        if ([address length] > 0)
            [address appendString:[NSString stringWithFormat:@", %@", woCity]];
        else
            [address appendString:[NSString stringWithFormat:@"%@", woCity]];
    }
    woState = [[workOrder objectForKey:STATE] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:STATE]]:@"";
    if ([woState length] > 0)
    {
        if ([address length] > 0)
            [address appendString:[NSString stringWithFormat:@", %@", woState]];
        else
            [address appendString:[NSString stringWithFormat:@"%@", woState]];
    }
    woZip = [[workOrder objectForKey:ZIP] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:ZIP]]:@"";
    if ([woZip length] > 0)
    {
        if ([address length] > 0)
            [address appendString:[NSString stringWithFormat:@", %@", woZip]];
        else
            [address appendString:[NSString stringWithFormat:@"%@", woZip]];
    }
    woCountry = [[workOrder objectForKey:COUNTRY] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:COUNTRY]]:@"";
    if ([woCountry length] > 0)
    {
        if ([address length] > 0)
            [address appendString:[NSString stringWithFormat:@", %@", woCountry]];
        else
            [address appendString:[NSString stringWithFormat:@"%@", woCountry]];
    }
    
    locationPop.workOrderContact = address;

    if (annotationObject.index == -1)
    {
        locationPop.workOrder = [appDelegate.wsInterface.tagsDictionary objectForKey:MAP_HOMELOC_TITLE];
        locationPop.workOrderContact = appDelegate.technicianAddress;
        locationPop.view.frame = CGRectMake(point.x, point.y-126, locationPop.view.frame.size.width, locationPop.view.frame.size.height);
    }
    else
        locationPop.view.frame = CGRectMake(point.x, point.y-149, locationPop.view.frame.size.width, locationPop.view.frame.size.height);

    locationPop.annotationIndex = annotationObject.index;
    
    popOver = [[[UIPopoverController alloc] initWithContentViewController:locationPop] autorelease];
    popOver.delegate = self;
    [popOver setPopoverContentSize:locationPop.view.frame.size];
    
    locationPop.popOver = popOver;
    [popOver presentPopoverFromRect:locationPop.view.frame inView:mapView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    //SMLog(@"%f, %f", point.x, point.y);
    //SMLog(@"%f, %f", popOver.contentViewController.view.frame.origin.x, popOver.contentViewController.view.frame.origin.y);
//    [locationPop release];
}

#pragma mark -
#pragma mark LocationPopOver Delegate Methods

- (void) showJobDetailsForAnnotationIndex:(NSUInteger)annotationIndex
{
    // set the selected item first
    if (annotationIndex <= 1)
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    else
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:annotationIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [tableView.delegate tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:annotationIndex inSection:0]];
    [self viewJobDetail];
    
    [popOver dismissPopoverAnimated:YES];
}

- (void) showDrivingDirectionsForAnnotationIndex:(NSUInteger)annotationIndex
{
    if (routeView != nil)
    {
        [routeView scrollToSection:[NSNumber numberWithUnsignedInt:annotationIndex]];
        return;
    }
    routeView = [[RouteController alloc] initWithNibName:@"RouteController" bundle:nil];
    routeView.directionArray = controller.diretions.routes;
    // Form the workOrderArray to be passed to routeView
    // The workOrderArray should have the WorkOrder numbers and the corresponding addresses
    routeView.workOrderArray = [self getWorkOrderArray];
    routeView.view.frame = CGRectMake(15, 367, 253, 361);
    routeView.view.alpha = 0.0;
    [self.view addSubview:routeView.view];
    [UIView beginAnimations:@"displayDirections" context:nil];
    [UIView setAnimationDuration:0.3];
    routeView.view.alpha = 1.0;
    directionLabel.alpha = 1.0;
    [UIView commitAnimations];
    
    [routeView scrollToSection:[NSNumber numberWithUnsignedInt:annotationIndex]];
    
    [popOver dismissPopoverAnimated:YES];
}

- (NSArray *) getWorkOrderArray
{
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSArray * keys = [NSArray arrayWithObjects:@"WorkOrderNumber", @"WorkOrderAddress", nil];
    
    for (int i = 0; i < [appDelegate.workOrderEventArray count]; i++)
    {        
        NSMutableString * address = nil;
        
        NSString * woStreet = nil, * woCity = nil, * woState = nil, * woZip = nil, * woCountry = nil;
        
        address = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
        NSDictionary * workOrder = [appDelegate.workOrderEventArray objectAtIndex:i];
        woStreet = [[workOrder objectForKey:STREET] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:STREET]]:@"";
        if ([woStreet length] > 0)
            [address appendString:woStreet];
        woCity = [[workOrder objectForKey:CITY] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:CITY]]:@"";
        if ([woCity length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woCity]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woCity]];
        }
        woState = [[workOrder objectForKey:STATE] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:STATE]]:@"";
        if ([woState length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woState]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woState]];
        }
        woZip = [[workOrder objectForKey:ZIP] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:ZIP]]:@"";
        if ([woZip length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woZip]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woZip]];
        }
        woCountry = [[workOrder objectForKey:COUNTRY] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:COUNTRY]]:@"";
        if ([woCountry length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woCountry]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woCountry]];
        }
        
        //SMLog(@"adddress = %@", address);
        
//        NSString * str = [[appDelegate.workOrderEventArray objectAtIndex:i] objectForKey:ADDITIONALINFO];
//        if (str != nil)
//            str = [str stringByReplacingOccurrencesOfString:[appDelegate.wsInterface.tagsDictionary objectForKey:MAP_POPOVER_TITLE] withString:@""];
        NSString * workOrderNumber = @"";
        workOrderNumber  = ([[appDelegate.workOrderInfo objectAtIndex:i] objectForKey:NAME])?[[appDelegate.workOrderInfo objectAtIndex:i]objectForKey:NAME]:@"";
        NSArray *objects = [NSArray arrayWithObjects:workOrderNumber,address, nil];
        //SMLog(@"%@", objects);
        NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [array addObject:dict];
        
    }
    
    // Add home location details
    NSArray * homeObjects = [NSArray arrayWithObjects:[appDelegate.wsInterface.tagsDictionary objectForKey:MAP_HOMELOC_TITLE], appDelegate.technicianAddress, nil];
    NSDictionary * homeDict = [NSDictionary dictionaryWithObjects:homeObjects forKeys:keys];
    [array addObject:homeDict];
    
    return array;
}

#pragma mark -
#pragma mark RecentVisit Action
- (IBAction) didChangeRecentVisit:(id)sender;
{
    UISwitch * recentVisit = (UISwitch *)sender;
    if (recentVisit.on)
    {
        
    }
    else
    {
        // hide additional map annotations
        // [controller hideAdditionalAnnotations];
    }

}

// queryRecentVisitsForDate Callback
- (void) didQueryRecentVisitsForDate:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSArray * recentVisitsArray = [result records];
    [controller showRecentVisits:recentVisitsArray];
}

#pragma mark -
#pragma mark View lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [routeMapView release];
    routeMapView = nil;
    [tableView release];
    tableView = nil;
    [mapView release];
    mapView = nil;
    [directionLabel release];
    directionLabel = nil;
    [WONumber release];
    WONumber = nil;
    [WODescription release];
    WODescription = nil;
    [contactName release];
    contactName = nil;
    [contactAddress release];
    contactAddress = nil;
    [contactEmail release];
    contactEmail = nil;
    [problemCode release];
    problemCode = nil;
    [problemDescription release];
    problemDescription = nil;
    [contactImage release];
    contactImage = nil;
    [imageActivity release];
    imageActivity = nil;
    [recentVisitBackground release];
    recentVisitBackground = nil;
    [recentVisitSwitch release];
    recentVisitSwitch = nil;
    
	[super viewDidUnload];
	
	self.toolbar = nil;
    
    appDelegate.didMapViewUnload = YES;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if (iOSObject == nil)
        iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    eventsArray = [[NSMutableArray alloc] initWithArray:appDelegate.wsInterface.eventArray];
    //SMLog(@"%@", eventsArray);
    
    if (imageCache == nil)
        imageCache = [[ImageCacheClass alloc] init];
    
    currentLocation = nil;
    
    currentSelection = 0;
    didQueryTechnician = FALSE;
    didDebriefData = FALSE;
    
    if (appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate goOnlineIfRequired];
        
        
        DataBase* dat= [[DataBase alloc]init];
        if (appDelegate.loggedInUserId == nil)
            appDelegate.loggedInUserId = [dat getLoggedInUserId:appDelegate.username];
        [dat release];
        
        ZKUserInfo * userinfo = [[ZKServerSwitchboard switchboard] userInfo];
        
        NSString * userId = [userinfo userId];
        
        if ((appDelegate.loggedInUserId == nil) || ([appDelegate.loggedInUserId length] > 0))
            appDelegate.loggedInUserId = userId;
        
        
        NSString * _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Service_Group__c, SVMXC__Inventory_Location__c  FROM SVMXC__Service_Group_Members__c WHERE SVMXC__Salesforce_User__c = '%@'", appDelegate.loggedInUserId];
        SMLog(@"%@", appDelegate.loggedInUserId);
        
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(initDebriefData:error:context:) context:nil];
    }
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
    {
        //SMLog(@"Mapview initDebrief in while loop");
        if (!appDelegate.isInternetConnectionAvailable)
        {
            [self setContactImage];
            //[appDelegate displayNoInternetAvailable];
            break;
        }
        if (didQueryTechnician && didDebriefData)
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        //SMLog(@"3");
    }
    
    

    [self setJobDetailsForWorkOrder:[appDelegate.workOrderEventArray objectAtIndex:0] workOrderInfo:[appDelegate.workOrderInfo objectAtIndex:0]];
    
    tableView.backgroundColor = [UIColor clearColor];
    
    [self setupMapView];
    
    if (diretions.isInitialized)
    {
		[self update];
	}
    
    [self.view bringSubviewToFront:tableView];
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        SMLog(@"Map Internet Reachable");
        [self setupMapView];
        [self setContactImage];
    }
    else
    {
                
        SMLog(@"Map Internet Not Reachable");
        if (didRunOperation)
        {
            [imageActivity stopAnimating];
            //[appDelegate displayNoInternetAvailable];
            didRunOperation = NO;
        }
    }
}


- (IBAction) Help;
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.helpString = @"map-view.html";
    [self presentModalViewController:help animated:YES];
    [help release];
}

- (void) setupMapView
{
    didRunOperation = YES;
    
    controller = [[MapDirectionsViewController alloc] init];
    controller.frame = mapView.bounds;
    SMLog(@"%f, %f, %f, %f", mapView.bounds.origin.x,mapView.bounds.origin.y,mapView.bounds.size.width, mapView.bounds.size.height);
    controller.delegate = self;

    NSMutableString * address = nil;

    controller.startPoint = controller.endPoint = appDelegate.technicianAddress;

    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * woStreet = nil, * woCity = nil, * woState = nil, * woZip = nil, * woCountry = nil;
    
    for (int i = 0; i < [appDelegate.workOrderEventArray count]; i++)
    {
        address = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
        NSDictionary * workOrder = [appDelegate.workOrderEventArray objectAtIndex:i];
        woStreet = [[workOrder objectForKey:STREET] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:STREET]]:@"";
        if ([woStreet length] > 0)
            [address appendString:woStreet];
        woCity = [[workOrder objectForKey:CITY] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:CITY]]:@"";
        if ([woCity length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woCity]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woCity]];
        }
        woState = [[workOrder objectForKey:STATE] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:STATE]]:@"";
        if ([woState length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woState]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woState]];
        }
        woZip = [[workOrder objectForKey:ZIP] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:ZIP]]:@"";
        if ([woZip length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woZip]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woZip]];
        }
        woCountry = [[workOrder objectForKey:COUNTRY] isKindOfClass:[NSString class]]?[NSString stringWithFormat:@"%@", [workOrder objectForKey:COUNTRY]]:@"";
        if ([woCountry length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woCountry]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woCountry]];
        }
        
        //SMLog(@"adddress = %@", address);
        [array addObject:address];
    }

    //SMLog(@"addressarray = %@", array);
    
    controller.wayPoints = array; 
    
    wayPoints = array;

    //SMLog(@"%@", controller.wayPoints);
    
    controller.travelMode = UICGTravelModeDriving;
    controller.workOrderArray = appDelegate.workOrderEventArray;

    if (appDelegate.isInternetConnectionAvailable )
    {
        [mapView addSubview:controller.view];
    }
    else
    {
        UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(100, 150, 500, 100)];
        message.backgroundColor = [UIColor clearColor];
        message.text = [appDelegate.wsInterface.tagsDictionary objectForKey:map_offline_display_text];
        message.textColor = [UIColor whiteColor];
        [mapView addSubview:message];
        
        [message release];
    }
}

- (void) setJobDetailsForWorkOrder:(NSDictionary *)workOrderDetails workOrderInfo:(NSDictionary *)workOrderInfo
{
    if (workOrderDetails == nil)
        return;
    currentWorkOrderDetails = workOrderDetails;
    
    currentWorkOrderInfo = workOrderInfo;
    
    WONumber.text = [workOrderInfo objectForKey:NAME];
    contactName.text = [workOrderInfo objectForKey:SVMXC__CONTACT_NAME];
    contactEmail.text = [workOrderInfo objectForKey:SVMXC__CONTACT_EMAIL];
    contactAddress.text = [workOrderInfo objectForKey:SVMXC__CONTACT_PHONE];
    problemDescription.text = [workOrderInfo objectForKey:SVMXC__PROBLEM_DESCRIPTION];
    WODescription.text = [workOrderInfo objectForKey:SVMXC__ORDER_TYPE];

    [imageActivity startAnimating];
    [self setContactImage];
    
}

- (void) setContactImage
{
    NSString * contactId = [currentWorkOrderInfo objectForKey:SVMXC__CONTACT__C];
    [self queryImagesForAccount:nil Contact:contactId];
}

- (void) queryImagesForAccount:(NSString *)companyId Contact:(NSString *)contactId
{
    NSString * _query;
    //Shrinivas --> Contact Picture Offline Implementation
    if(!appDelegate.isInternetConnectionAvailable){
        NSString * imageDataString = [appDelegate.calDataBase retrieveContactImageDataFromDb:contactId];
        contactImage.image = [UIImage imageWithData:[Base64 decode:imageDataString]];
        if (contactImage.image == nil)
        {
            contactImage.image = [UIImage imageNamed:@"user.png"];
        }
        [imageActivity stopAnimating];
        return;
    }
    
    if (contactId != nil)
    {
        _query = [[NSString stringWithFormat:@"SELECT ParentId, Body FROM Attachment Where ParentId IN ('%@') AND Name LIKE '%%PICTURE%%'", contactId] retain]; // AND Name LIKE '%%PICTURE%%'
        
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didQueryContactImagesForAccount:error:context:) context:nil];
        
        [_query release];
    }
    
    if (companyId != nil)
    {
        _query = [[NSString stringWithFormat:@"SELECT ParentId, Body FROM Attachment Where ParentId IN ('%@') AND Name LIKE '%%PICTURE%%'", companyId] retain]; // AND Name LIKE '%%PICTURE%%'
        
        // SMLog(@"%@", _query);
        
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didQueryCompanyImagesForAccount:error:context:) context:nil];
        
        [_query release];
    }
    
    if ((companyId == nil) && (contactId == nil))
        [imageActivity stopAnimating];
}

- (void) didQueryContactImagesForAccount:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSString * contactId = [currentWorkOrderInfo objectForKey:SVMXC__CONTACT__C];
    NSArray * array = [result records];

    if ([array count] == 0)
    {
        contactImage.image = [UIImage imageNamed:@"blank.png"];
        [imageActivity stopAnimating];
        return;
    }

    ZKSObject * obj = [array objectAtIndex:0];
    NSString * imageDataString = [[obj fields] objectForKey:@"Body"];

    //Shrinivas --> Contact Picture Offline Implementation
    if ([imageDataString length] > 0){
        [appDelegate.calDataBase insertContactImageIntoDatabase:contactId andContactImageData:imageDataString];
    }
      
    contactImage.image = [UIImage imageWithData:[Base64 decode:imageDataString]];
    if (contactImage.image == nil)
    {
        contactImage.image = [UIImage imageNamed:@"user.png"];
    }
    
    [imageActivity stopAnimating];
}

- (void)update
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	UICGDirectionsOptions *options = [[[UICGDirectionsOptions alloc] init] autorelease];
	options.travelMode = UICGTravelModeDriving; // travelMode;
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
}

- (void)moveToCurrentLocation:(id)sender
{
	[routeMapView setCenterCoordinate:[routeMapView.userLocation coordinate] animated:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
}

#pragma mark <UICGDirectionsDelegate> Methods

- (void)directionsDidFinishInitialize:(UICGDirections *)directions
{
	[self update];
}

- (void)directions:(UICGDirections *)directions didFailInitializeWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSString * mapDirections = [appDelegate.wsInterface.tagsDictionary objectForKey:MAP_DIRECTIONS_FAILED];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:mapDirections message:[error localizedFailureReason] delegate:nil cancelButtonTitle:nil otherButtonTitles:alert_ok, nil];
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
	UICRouteAnnotation * startAnnotation = [[[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints objectAtIndex:0] coordinate]
																					title:startPoint
																		   annotationType:UICRouteAnnotationTypeStart] autorelease];
	UICRouteAnnotation * endAnnotation = [[[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints lastObject] coordinate]
                                                                                  title:endPoint
                                                                         annotationType:UICRouteAnnotationTypeEnd] autorelease];
	if ([wayPoints count] > 0)
    {
		NSInteger numberOfRoutes = [directions numberOfRoutes];
		for (NSInteger index = 0; index < numberOfRoutes; index++)
        {
			UICGRoute *route = [directions routeAtIndex:index];
			CLLocation *location = [route endLocation];
			UICRouteAnnotation *annotation = [[[UICRouteAnnotation alloc] initWithCoordinate:[location coordinate]
																					   title:[[route endGeocode] objectForKey:@"address"]
																			  annotationType:UICRouteAnnotationTypeWayPoint] autorelease];
			[routeMapView addAnnotation:annotation];
		}
	}
    
	[routeMapView addAnnotations:[NSArray arrayWithObjects:startAnnotation, endAnnotation, nil]];
}

- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSString * mapDirections = [appDelegate.wsInterface.tagsDictionary objectForKey:MAP_DIRECTIONS_FAILED];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:mapDirections message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:alert_ok, nil];
	[alertView show];
	[alertView release];
}

#pragma mark -
#pragma mark Managing the popover

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem
{    
    // Add the popover button to the toolbar.
    NSMutableArray *itemsArray = [toolbar.items mutableCopy];
    // [itemsArray insertObject:barButtonItem atIndex:0];
    [toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}

- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem
{    
    // Remove the popover button from the toolbar.
    NSMutableArray *itemsArray = [toolbar.items mutableCopy];
    [itemsArray removeObject:barButtonItem];
    [toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}

#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    }
    else
        if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
            
        }
        else
            return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
    [toolbar release];
    [mapAnnotations release];
    [routeMapView release];
    [tableView release];

    if (routeView != nil)
        [routeView release];
    [directionLabel release];
    [WONumber release];
    [WODescription release];
    [contactName release];
    [contactAddress release];
    [contactEmail release];
    [problemCode release];
    [problemDescription release];

    [contactImage release];
    [imageActivity release];
    if (currentWorkOrderDetails != nil)
        [currentWorkOrderDetails release];

    if (controller != nil)
        [controller release];

    if (wayPointFields != nil)
        [wayPointFields release];

    [routeOverlayView release];
	[startPoint release];
	[endPoint release];
    [wayPoints release];

    [recentVisitBackground release];
    [recentVisitSwitch release];

    [imageCache release];

    [super dealloc];
}

- (IBAction) ShowModal
{
    
    /*if (!appDelegate.isInternetConnectionAvailable)
    {
        [imageActivity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    isLoaded = NO;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) viewJobDetail
{
    
    [imageActivity startAnimating];
    if (appDelegate.sfmPageController != nil)
    {
        [appDelegate.sfmPageController release];
        appDelegate.sfmPageController = nil;
    }
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:NO];
    
       
    NSString * process = [currentWorkOrderDetails objectForKey:PROCESSID];
    appDelegate.sfmPageController.processId = [currentWorkOrderDetails objectForKey:PROCESSID];
    appDelegate.sfmPageController.objectName = [currentWorkOrderDetails objectForKey:OBJECTAPINAME];
    appDelegate.sfmPageController.recordId = [currentWorkOrderDetails objectForKey:WHATID];
    
    appDelegate.sfmPageController.objectName = [currentWorkOrderDetails objectForKey:OBJECTAPINAME];
    NSString * object_name = [currentWorkOrderDetails objectForKey:OBJECTAPINAME];
    
    NSString * recordId =  [currentWorkOrderDetails objectForKey:WHATID];
    if(recordId == nil || [recordId length] == 0)
    {
        NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:cal_day_week_view_view_Id];
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
        NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        
        UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
        [alert1 show];
        [alert1 release];
        return;
    }
    
    NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:[currentWorkOrderDetails objectForKey:WHATID] tableName:object_name];
    appDelegate.sfmPageController.recordId = local_id;
    
      
    
    appDelegate.sfmPageController.activityDate = [currentWorkOrderDetails objectForKey:ACTIVITYDATE];
    appDelegate.sfmPageController.accountId = [currentWorkOrderDetails objectForKey:ACCOUNTID];
    appDelegate.sfmPageController.topLevelId = [currentWorkOrderDetails objectForKey:TOPLEVELID];
    
    NSString * objectAPIName = [currentWorkOrderDetails objectForKey:OBJECTAPINAME];
    if ([objectAPIName isEqualToString:@"service_order__c"])
        objectAPIName = [NSString stringWithFormat:@"%@__%@",SVMX_ORG_PREFIX,objectAPIName];
    objectAPIName = [objectAPIName uppercaseString];
    
       
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        [appDelegate.SFMPage release];
        appDelegate.SFMPage = nil;
    }

    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    didRunOperation = YES;
   
    didRunOperation = NO;
    
    
    processInfo * pinfo =  [appDelegate getViewProcessForObject:object_name record_id:local_id processId:appDelegate.sfmPageController.processId isswitchProcess:FALSE];
    BOOL process_exist = pinfo.process_exists;
    
    //check For view process
    if(process_exist)
    {
         appDelegate.sfmPageController.processId = pinfo.process_id;
        [appDelegate.sfmPageController.detailView view];
       
        [self presentModalViewController:appDelegate.sfmPageController animated:YES];
        [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
    }
    else
    {
        //NO_VIEW_PROCESS 
        
        NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
        NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];

        
        UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
        [alert1 show];
        [alert1 release];
        return;
    }

    [appDelegate.sfmPageController release];
    [imageActivity stopAnimating];
}

#pragma mark -
#pragma mark Touches

#pragma mark -
#pragma mark JobViewControllerDelegate Methods

- (void) ShowOtherView
{
    isLoaded = NO;
    [self performSelector:@selector(ShowModal) withObject:nil afterDelay:0.1];
}

- (void) closeJobView
{
    [jvc dismissModalViewControllerAnimated:YES];
    // [jobView release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [appDelegate.workOrderEventArray count];
}

- (MapTableCell *) createCustomCellWithId:(NSString *) cellIdentifier
{
	NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"MapTableCell" owner:self options:nil];
	NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
	MapTableCell * customCell = nil;
	
    NSObject* nibItem = nil;
	
    while ( (nibItem = [nibEnumerator nextObject]) != nil)
	{
		if ( [nibItem isKindOfClass: [MapTableCell class]])
		{
			customCell = (MapTableCell *) nibItem;
			if ([customCell.reuseIdentifier isEqualToString:cellIdentifier ])
				break; // OneTeamUS We have a winner
			else
				customCell = nil;
		}
	}
	return customCell;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString * CellIdentifier = @"MapTableCell";
    
    MapTableCell * cell = (MapTableCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createCustomCellWithId:CellIdentifier];
    }
    
    
    NSString * str = [[appDelegate.workOrderEventArray objectAtIndex:indexPath.row] objectForKey:ADDITIONALINFO];
    if (str != nil)
        str = [str stringByReplacingOccurrencesOfString:[appDelegate.wsInterface.tagsDictionary objectForKey:MAP_POPOVER_TITLE] withString:@""];
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
    NSString * event = [NSString stringWithFormat:@"%@", str];
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate * date = nil;
    NSString * timing;
    

    NSDictionary * dict = [appDelegate.workOrderEventArray objectAtIndex:row];
    // START TIME
    NSDate * startime = [dict objectForKey:STARTDATETIME];
    SMLog(@"%@", startime);
    
      // First convert the time to local
    NSString * woStartTiming = [dateFormatter stringFromDate:startime];
    SMLog(@"%@", woStartTiming);
  

    // Then extract the actual time
    woStartTiming = [woStartTiming substringFromIndex:11];
    SMLog(@"%@", woStartTiming);
   
    
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    date = [dateFormatter dateFromString:woStartTiming];
    SMLog(@"%@", date);
    [dateFormatter setDateFormat:@"hh:mm a"];
    woStartTiming = [dateFormatter stringFromDate:date];
    SMLog(@"%@", woStartTiming);
    
    // END TIME
    NSDate * endtime = [dict objectForKey:ENDDATETIME];
    SMLog(@"%@", endtime);
    
     // First convert the time to local
    NSString * woEndTiming = [dateFormatter stringFromDate:endtime];
    SMLog(@"%@", woEndTiming);
    
    //radha
    NSString * colorCode = [appDelegate.calDataBase getColorCodeForPriority:[dict objectForKey:WHATID]];
    UIColor * color = [appDelegate colorForHex:colorCode];
    
    // DURATION
    NSString * duration = [dict objectForKey:DURATIONINMIN];
    
    timing = [NSString stringWithFormat:@"%@ %@ %@ (%@ %@)", woStartTiming, [appDelegate.wsInterface.tagsDictionary objectForKey:MAP_WO_TO], woEndTiming,  duration, [appDelegate.wsInterface.tagsDictionary objectForKey:MAP_WO_MINUTES]];

    [cell setCellLabel:event Color:color Timing:timing];

    return cell;
}


- (NSUInteger) getPriorityColorByPriority:(NSString *)priority
{
    if ([priority isKindOfClass:[NSString class]])
    {
        if ([priority isEqualToString:@"High"])
            return cRED;
        if ([priority isEqualToString:@"Medium"])
            return cBLUE;
        if ([priority isEqualToString:@"Low"])
            return cGREEN;
    }
    return cPURPLE;
}

- (UIImage *) getImageForColorIndex:(NSUInteger)colorIndex
{
    switch (colorIndex) {
        case cBLUE:
            // return [UIImage imageNamed:@"blue-event-highlighter.png"];
            return [UIImage imageNamed:@"event-blue.png"];
        case cBROWN:
            // return [UIImage imageNamed:@"brown-event-highlighter.png"];
            return [UIImage imageNamed:@"event-brown.png"];
        case cGREEN:
            // return [UIImage imageNamed:@"green-event-highlighter.png"];
            return [UIImage imageNamed:@"event-green.png"];
        case cORANGE:
            // return [UIImage imageNamed:@"orange-event-highlighter.png"];
            return [UIImage imageNamed:@"event-orange.png"];
        case cPINK:
            // return [UIImage imageNamed:@"pink-event-highlighter.png"];
            return [UIImage imageNamed:@"event-violet.png"];
        case cPURPLE:
            // return [UIImage imageNamed:@"purple-event-highlighter.png"];
            return [UIImage imageNamed:@"event-violet.png"];
        case cRED:
            // return [UIImage imageNamed:@"red-event-highlighter.png"];
            return [UIImage imageNamed:@"event-red.png"];
        case cYELLOW:
            // return [UIImage imageNamed:@""];
            return [UIImage imageNamed:@"event-lightbrown.png"];
        default:
            break;
    }
    return nil;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;                                              
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.

    NSUInteger row = [indexPath row];

    [self setJobDetailsForWorkOrder:[appDelegate.workOrderEventArray objectAtIndex:row] workOrderInfo:[appDelegate.workOrderInfo objectAtIndex:row]];
    
    [self setContactImage];
    currentSelection = row;
}

#pragma mark -
#pragma mark Location Related Methods

- (void)startStandardUpdates
{
    // Check if location services are available
    // [CLLocationManager locationServicesEnabled];
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    [locationManager locationServicesEnabled];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;
    
    [locationManager startUpdatingLocation];
}

#pragma mark -
#pragma mark Delegate method from the CLLocationManagerDelegate protocol.

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    // NSDate* eventDate = newLocation.timestamp;
    // NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    // if (abs(howRecent) < 15.0)
    {
        // SMLog(@"latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        
        // Immediately use reverse geocoder to find out current location
        [self reverseGeocodeWithCoordinate:newLocation];
    }
    // else skip the event and process the next one.
}

#pragma mark -
#pragma mark - MKReverseGeocoder

- (void) reverseGeocodeWithCoordinate:(CLLocation *)coordinate
{
    reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate.coordinate];
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];
}

#pragma mark -
#pragma mark - MKReverseGeocoder delegate

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    // SMLog(@"Reverse Geocoder error = %@", error.description);
    MKPlacemark * placemark = geocoder.placemark;
    //SMLog(@"%@", placemark.addressDictionary);
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    // SMLog(@"Address Dictionary = %@", [placemark addressDictionary]);
    //SMLog(@"The geocoder has returned: %@", [placemark addressDictionary]);
    NSDictionary * placeMarkDict = [placemark addressDictionary];
    
    NSArray * formattedAddressLines = [placeMarkDict objectForKey:@"FormattedAddressLines"];
    
    // currentLocation = @"Apple Inc, Cupertino, CA, United States";
    
    for (int i = 0; i < [formattedAddressLines count]; i++)
    {
        if (!currentLocation)
            currentLocation = [[NSMutableString alloc] initWithCapacity:0];
        [currentLocation appendString:[formattedAddressLines objectAtIndex:i]];
        if (i < [formattedAddressLines count] - 1)
            [currentLocation appendString:@", "];
    }

    currentLocation = [[NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@",
                        [placeMarkDict objectForKey:@"Street"],
                        [placeMarkDict objectForKey:@"SubAdministrativeArea"],
                        [placeMarkDict objectForKey:@"City"],
                        [placeMarkDict objectForKey:@"Country"],
                        [placeMarkDict objectForKey:@"CountryCode"],
                        [placeMarkDict objectForKey:@"State"],
                        [placeMarkDict objectForKey:@"Thouroughfare"]
                        ] retain];
    //SMLog(@"%@", currentLocation);
}

#pragma mark - Launch SmartVan

- (IBAction) launchSmartVan
{
    HTMLBrowser * htmlBrowser = [[HTMLBrowser alloc] initWithURLString:@"http://www.thesmartvan.com"];
    htmlBrowser.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    htmlBrowser.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentModalViewController:htmlBrowser animated:YES];
    [htmlBrowser release];
}

#pragma mark - Query For Technicianaddress
- (void) initDebriefData:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (!appDelegate.isInternetConnectionAvailable)
    {
        return;
    }
    
    NSArray * array = [result records];
    SMLog(@"hello hi = %@",array);
        
    for (int i = 0; i < [array count]; i++)
	{
		ZKSObject * obj = [array objectAtIndex:i];
        
        SMLog(@"SVMXC__Service_Group__c = %@", [[obj fields] objectForKey:@"SVMXC__Service_Group__c"]);
        if (appDelegate.appServiceTeamId != nil)
        {
            [appDelegate.appServiceTeamId release];
            appDelegate.appServiceTeamId = nil;
        }
		appDelegate.appServiceTeamId = [[[obj fields] objectForKey:@"SVMXC__Service_Group__c"] retain];
        
        if (appDelegate.appTechnicianId != nil)
        {
            [appDelegate.appTechnicianId release];
            appDelegate.appTechnicianId = nil;
        }
        appDelegate.appTechnicianId = [[[obj fields] objectForKey:@"Id"] retain];
	}
    
    NSString * _query = [NSString stringWithFormat:@"Select SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c FROM SVMXC__Service_Group_Members__c WHERE Id = '%@'", appDelegate.appTechnicianId];
    SMLog(@"my query = %@",_query);
    
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didQueryTechnician:error:context:) context:nil];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
    {
        //SMLog(@"Mapview initDebrief in while loop");
        if (!appDelegate.isInternetConnectionAvailable)
        {
            break;
        }
        if (didQueryTechnician)
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        //SMLog(@"3");
    }
    
    didDebriefData = YES;
}
- (void) didQueryTechnician:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSArray * array = [result records];
    
    if ([array count] > 0)
    {
        ZKSObject * obj = [array objectAtIndex:0];
        NSDictionary * dict = [obj fields];
        
        NSMutableString * address = nil;
        address = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
        
        NSString * woStreet = [[dict objectForKey:@"SVMXC__Street__c"] isKindOfClass:[NSString class]]?[dict objectForKey:@"SVMXC__Street__c"]:@"";
        NSString * woCity = [[dict objectForKey:@"SVMXC__City__c"] isKindOfClass:[NSString class]]?[dict objectForKey:@"SVMXC__City__c"]:@"";
        NSString * woState = [[dict objectForKey:@"SVMXC__State__c"] isKindOfClass:[NSString class]]?[dict objectForKey:@"SVMXC__State__c"]:@"";
        NSString * woZip = [[dict objectForKey:@"SVMXC__Zip__c"] isKindOfClass:[NSString class]]?[dict objectForKey:@"SVMXC__Zip__c"]:@"";
        NSString * woCountry = [[dict objectForKey:@"SVMXC__Country__c"] isKindOfClass:[NSString class]]?[dict objectForKey:@"SVMXC__Country__c"]:@"";
        
        if ([woStreet length] > 0)
            [address appendString:woStreet];
        
        if ([woCity length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woCity]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woCity]];
        }
        
        if ([woState length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woState]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woState]];
        }
        
        if ([woZip length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woZip]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woZip]];
        }
        
        if ([woCountry length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woCountry]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woCountry]];
        }
        
        appDelegate.technicianAddress = address;
        
        SMLog(@"Technician Address = %@", appDelegate.technicianAddress);
    }
    else
        appDelegate.technicianAddress = @"";  
    
    didQueryTechnician = YES;
}


@end
