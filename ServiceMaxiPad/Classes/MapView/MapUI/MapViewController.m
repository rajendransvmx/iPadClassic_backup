//
//  MapViewController.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/26/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "MapViewController.h"
#import "SFAnnotation.h"
#import "UICRouteOverlayMapView.h"
#import "UICRouteAnnotation.h"
#import "Reachability.h"
#import "MapHelper.h"
#import "SNetworkReachabilityManager.h"
#import "WorkOrderSummaryModel.h"
#import "ServiceLocationModel.h"
#import "TagManager.h"
#import "SFMPageManager.h"
#import "SFMPageViewController.h"
#import "SFMPageViewManager.h"
#import <MapKit/MapKit.h>
#import "NonTagConstant.h"
#import "TechnicianServiceLayer.h"
#import "WebserviceResponseStatus.h"
#import "AlertMessageHandler.h"
#import "AlertMessageHandler.h"
#import "MBProgressHUD.h"
#import "SyncManager.h"
#import "AppManager.h"
#import "StringUtil.h"
#import "PushNotificationHeaders.h"


@interface MapViewController ()

@property(nonatomic, strong) MKAnnotationView *annotationView;
@property(nonatomic, strong) MBProgressHUD *HUD;
@property(nonatomic, strong) UIAlertView *technicianAlert;

- (void)setUpMapViewFromAddress:(NSString*)technicianAddress;
- (void)showNoNetworkView;
- (void)refreshMap:(BOOL)isDBFetch;
- (void)reloadMap:(BOOL)isDBFetch;
- (void)showWOSummaryPopOver:(UICRouteAnnotation*)annotationObject atPoint:(CGPoint)point;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSyncFinished:) name:kDataSyncStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMap:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetchTechnicianDetails:) name:KNotificationTechnicianDetails object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFetchTechnicianAddress:) name:KNotificationTechnicianAddress object:nil];
    [self reloadMap:[self.workOrderSummaryArray count] ? NO : YES];
    
    [self registerForPopOverDismissNotification];
}

- (void)dataSyncFinished:(NSNotification*)object
{
    [self reloadMap:YES];
}

#pragma mark -
#pragma mark Technician Notification Methods

-(void)didFetchTechnicianDetails:(NSNotification*)notification {
    
    NSDictionary *techDetails = notification.object;
    @try {
        NSString *technicianId = [[[techDetails objectForKey:@"records"] lastObject] objectForKey:kId];
        [MapHelper requestTechnicianAddressForId:technicianId andCallerDelegate:self];
    }
    @catch (NSException *exception) {
        SXLogError(@"Technician ID not valid. %@",exception.description);
    }
}

-(void)didFetchTechnicianAddress:(NSNotification*)notification {
    
    NSDictionary *techAddress = notification.object;
    @try {
        ServiceLocationModel *technicianLocation = [[ServiceLocationModel alloc] initWithAddressDictionary:[[techAddress objectForKey:@"records"] lastObject]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[AppManager sharedInstance] currentSelectedTab] == 0 || [[AppManager sharedInstance] currentSelectedTab] == 1)
            {
                if (![technicianLocation isValidAddress]) {
                    [[AlertMessageHandler sharedInstance] showCustomMessage:[[TagManager sharedInstance]tagByName:kTag_UnableFetchTechnicianAddress] withDelegate:self tag:kTechAnnotationIndex title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
                }
            }
        });
        [self performSelectorOnMainThread:@selector(setUpMapViewFromAddress:) withObject:[technicianLocation serviceLocation] waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        SXLogError(@"Technician address not valid. %@",exception.description);
    }
}

#pragma mark -
#pragma mark FlowNode Delegate Methods

- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *responseStatus = (WebserviceResponseStatus*)status;
        
        if(responseStatus.category == CategoryTypeTechnicianDetails ||
           responseStatus.category == CategoryTypeTechnicianAddress)
        {
            if (responseStatus.syncStatus == SyncStatusInCancelled ||
                responseStatus.syncStatus == SyncStatusRefreshTokenFailedWithError ||
                responseStatus.syncStatus == SyncStatusNetworkError ||
                responseStatus.syncStatus == SyncStatusConflict ||
                responseStatus.syncStatus == SyncStatusFailed)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[AppManager sharedInstance] currentSelectedTab] == 0 || [[AppManager sharedInstance] currentSelectedTab] == 1)
                    {
                        if (![self.technicianAlert isVisible])
                        {
                            self.technicianAlert = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] message:[NSString stringWithFormat:@"%@ \n %@", [[TagManager sharedInstance]tagByName:kTag_UnableFetchTechnicianAddress],[responseStatus.syncError errorEndUserMessage]] delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil];
                            [self.technicianAlert show];
                            [self performSelectorOnMainThread:@selector(setUpMapViewFromAddress:) withObject:nil waitUntilDone:NO];
                        }
                    }
                    [self removeActivityAndLoadingLabel];
                });
                SXLogError(@"Technician details:address failed.");
            }
        }
    }
}

#pragma mark -
#pragma mark UI

- (void)addActivityAndLoadingLabel
{
    if ([[AppManager sharedInstance] hasTokenRevoked])
    {
        [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired message:nil andDelegate:self];
        return;
    }
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.HUD];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
    }
    self.HUD.labelText = [[TagManager sharedInstance]tagByName:kTagLoading];
    [self.HUD show:YES];
        
}

- (void)removeActivityAndLoadingLabel;
{
    if (self.HUD) {
        [self.HUD hide:YES];
        self.HUD = nil;
    }
}

- (IBAction)reloadButtonTapped:(UIButton *)sender {
    [self reloadMap:NO];
}

- (void)reloadMap:(BOOL)isDBFetch {
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        [self refreshMap:isDBFetch];
        
    }
    else {
        [self showNoNetworkView];
    }
}

- (void)refreshMap:(BOOL)isDBFetch {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[AppManager sharedInstance] currentSelectedTab] == 0 || [[AppManager sharedInstance] currentSelectedTab] == 1)
        {
            [self addActivityAndLoadingLabel];
        }
        self.noNetworkView.hidden = YES;
        if (isDBFetch) {
            self.workOrderSummaryArray = [NSMutableArray arrayWithArray:[MapHelper workOrderSummaryArrayOfCurrentDay:self.selectedDate]];
        }
    });
    [MapHelper requestTechnicianIdWithTheCallerDelegate:self];
}

- (void)showNoNetworkView {
    
    [self removeWOPopOver];
    self.noNetworkView.hidden = NO;
    self.noNetworkLabel.text = [[TagManager sharedInstance] tagByName:kTagMapOfflineText];
}

- (void)setUpMapViewFromAddress:(NSString*)technicianAddress {
    
    [self removeActivityAndLoadingLabel];
    if (self.controller) {
        [self.controller willMoveToParentViewController:nil];
        [self.controller.view removeFromSuperview];
        self.controller.delegate = nil;
        [self.controller removeFromParentViewController];
        self.controller = nil;
    }
    self.controller = [MapDirectionsViewController new];
    self.controller.delegate = self;
    
    NSMutableArray *addressArrayWaypoints = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *removedWorkOrders = [[NSMutableArray alloc] initWithCapacity:0];
    
    @try {
        NSMutableArray *workOrdersArray = [self.workOrderSummaryArray mutableCopy];
        
        for (WorkOrderSummaryModel *workOrder in workOrdersArray)
        {
            if ([workOrder.serviceLocationModel isValidAddress])
            {
                [addressArrayWaypoints addObject: workOrder.serviceLocationModel.serviceLocation];
            }
            else
            {
                if ([self.workOrderSummaryArray containsObject:workOrder]) {
                    [self.workOrderSummaryArray removeObject:workOrder];
                    [removedWorkOrders addObject:workOrder.name];
                }
            }
        }
        if ([[AppManager sharedInstance] currentSelectedTab] == 0 || [[AppManager sharedInstance] currentSelectedTab] == 1)
        {
            [MapHelper showMissingAddressWorkOrders:removedWorkOrders];
        }
        
        if (![StringUtil isStringEmpty:technicianAddress]) {
            self.controller.techAddressString = technicianAddress;
            self.controller.startPoint = self.controller.endPoint = technicianAddress;
        }
        else if ([addressArrayWaypoints count]) {
            self.controller.startPoint = [addressArrayWaypoints objectAtIndex:0];
            self.controller.endPoint = [addressArrayWaypoints lastObject];
        }
        
        self.controller.wayPoints = addressArrayWaypoints;
        self.controller.travelMode = UICGTravelModeDriving;
        self.controller.workOrderArray = self.workOrderSummaryArray;
        
        if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
            
            [self addChildViewController:self.controller];
            [self.controller setFrame:self.mapView.frame];
            [self.mapView addSubview:self.controller.view];
            [self.controller didMoveToParentViewController:self];
        }
        else {
            [self showNoNetworkView];
        }
    }@catch (NSException *exp)
    {
        SXLogError(@"Invalid annotation type passed for map. %@",exp.description);
    }
}

#pragma mark -
#pragma mark MapPopOver Delegate Methods

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if( (popoverController == self.popOver) && (self.popOver != nil) )
    {
        self.mapPopUpVC = nil;
        self.popOver = nil;
        _annotationView = nil;
    }
}


#pragma mark -
#pragma mark Rotation support

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self rotatePopover];
}

- (void)rotatePopover {
    [self removeWOPopOver];
    /*
    // TODO: Adjust popover frame, why frame is not getting adjusted ned help :(
    if (self.popOver) {
        [_annotationView setNeedsDisplay];
        CGPoint point = [self.controller.routeMapView convertCoordinate:[_annotationView.annotation coordinate] toPointToView:self.controller.routeMapView];
        [self.popOver presentPopoverFromRect:CGRectMake(point.x, point.y, 0, 0) inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
     */
}

- (void)removeWOPopOver {
    
    if([self.popOver isPopoverVisible]) {
        [self.popOver dismissPopoverAnimated:NO];
    }
    if(self.popOver  != nil)
    {
        self.popOver.delegate = nil;
        self.popOver  = nil;
    }
}

#pragma mark -
#pragma mark MapPopUpDelegate support

- (void) customCallOutForAnnotation:(UICRouteAnnotation *)annotationObject AtPosition:(CGPoint)point forAnnotationView:(MKAnnotationView *)annotationView
{
    _annotationView = annotationView;
    [self showWOSummaryPopOver:annotationView.annotation atPoint:point];
}


- (void)showWOSummaryPopOver:(UICRouteAnnotation*)annotationObject atPoint:(CGPoint)point {
    
    if ([annotationObject isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    
    if (annotationObject.index == kTechAnnotationIndex)
    {
        //TODO : Tech home location
        return;
    }
    
    @try {
        WorkOrderSummaryModel * workOrder = [annotationObject workOrder];
        
        if(self.mapPopUpVC != nil)
        {
            self.mapPopUpVC.delegate = nil;
            self.mapPopUpVC  = nil;
        }
        UIStoryboard *mapStoryBoard = [UIStoryboard storyboardWithName:@"Map" bundle:[NSBundle mainBundle]];
        self.mapPopUpVC = [mapStoryBoard instantiateViewControllerWithIdentifier:@"MapPopUpViewController"];
        self.mapPopUpVC.delegate = self;
        self.mapPopUpVC.workOrderSummaryModel = workOrder;
        self.mapPopUpVC.workOrderSummaryModel.serviceLocationModel.latLonCoordinates = [annotationObject coordinate];
        [self removeWOPopOver];
        self.popOver = [[UIPopoverController alloc] initWithContentViewController:self.mapPopUpVC];
        self.popOver.delegate = self;
        [self.popOver presentPopoverFromRect:CGRectMake(point.x, point.y, 0, 0) inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    @catch (NSException *exp) {
        // TODO : Show Alert
    }
    
}

- (void) showJobDetailsForAnnotationIndex:(WorkOrderSummaryModel*)woSummaryModel
{
    [self removeWOPopOver];
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc] init];
    SFMPageViewManager *pageManager = [[SFMPageViewManager alloc] initWithObjectName:kWorkOrderTableName recordId:woSummaryModel.localId];
    pageViewController.sfmPageView = [pageManager sfmPageView];
    [self.navigationController pushViewController:pageViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma memory management

- (void)dealloc {
    
    if (_controller) {
        [_controller willMoveToParentViewController:nil];
        [_controller.view removeFromSuperview];
        _controller.delegate = nil;
        [_controller removeFromParentViewController];
        _controller = nil;
    }
    if([_popOver isPopoverVisible]) {
        [_popOver dismissPopoverAnimated:NO];
    }
    if(_popOver)
    {
        _popOver.delegate = nil;
        _popOver  = nil;
    }
    _mapPopUpVC = nil;
    _annotationView = nil;
    _mapView = nil;
    _workOrderSummaryArray = nil;
    _noNetworkView = nil;
    _noNetworkLabel = nil;
    _reloadButton = nil;
    _technicianAlert = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDataSyncStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotificationTechnicianDetails object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotificationTechnicianAddress object:nil];
    
    [self deregisterForPopOverDismissNotification];
    
}

-(void)registerForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissPopover)
                                                 name:POP_OVER_DISMISS
                                               object:nil];
}

-(void)deregisterForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POP_OVER_DISMISS object:nil];
}

- (void)dismissPopover
{
    [self performSelectorOnMainThread:@selector(dismissPopoverIfNeeded) withObject:self waitUntilDone:YES];
}


- (void)dismissPopoverIfNeeded
{
    if ([self.popOver isPopoverVisible] &&
        self.popOver) {
        
        [self.popOver dismissPopoverAnimated:YES];
        self.popOver = nil;
    }
}



@end
