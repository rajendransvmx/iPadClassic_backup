//
//  MapViewController.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/26/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "MapViewController.h"
#import "SFAnnotation.h"
#import "BridgeAnnotation.h"
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
#import "SFMViewPageManager.h"
#import <MapKit/MapKit.h>
#import "NonTagConstant.h"

@interface MapViewController ()

@property(nonatomic, strong) MKAnnotationView *annotationView;

- (void)setupMapView;
- (void)showNoNetworkView;
- (void)refreshMap;
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

-(void)didInternetConnectionChange {
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        
        [self refreshMap];
        
    }
    else {
        [self showNoNetworkView];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // TODO : Add datasynccompleted notification to refresh map
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange) name:kReachabilityChangedNotification object:nil];
    [self refreshMap];
}

- (IBAction)reloadButtonTapped:(UIButton *)sender {
    [self refreshMap];
}

- (void)showNoNetworkView {
    
    [self removeWOPopOver];
    self.noNetworkView.hidden = NO;
    self.noNetworkLabel.text = [[TagManager sharedInstance] tagByName:kTagMapOfflineText];
}

- (void)refreshMap {
    
    self.workOrderSummaryArray = [NSMutableArray arrayWithArray:[MapHelper workOrderSummaryArrayOfCurrentDay]];
    [self setupMapView];
    
}

- (void) setupMapView
{
    if (self.controller) {
        [self.controller willMoveToParentViewController:nil];
        [self.controller.view removeFromSuperview];
        self.controller.delegate = nil;
        [self.controller removeFromParentViewController];
        self.controller = nil;
    }
    self.controller = [MapDirectionsViewController new];
    self.controller.delegate = self;
    
    //todo: technician address
    /*
    NSString *techAddress = [[MapHelper getTechnicianAddress] serviceLocation];
    if ([techAddress length]) {
        self.controller.startPoint = self.controller.endPoint = techAddress;
    }
    */
    NSMutableArray *addressArrayWaypoints = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *removedWorkOrders = [[NSMutableArray alloc] initWithCapacity:0];
    
    @try {
        
        for (int i = 0; i < [self.workOrderSummaryArray count]; i++)
        {
            WorkOrderSummaryModel *workOrder = [self.workOrderSummaryArray objectAtIndex:i];
            ServiceLocationModel *serviceLocationModel = workOrder.serviceLocationModel;
            if ([serviceLocationModel isValidAddress]) {
                [addressArrayWaypoints addObject:serviceLocationModel.serviceLocation];
            }
            else {
                [self.workOrderSummaryArray removeObjectAtIndex:i];
                [removedWorkOrders addObject:workOrder.name];
            }
        }
        [MapHelper showMissingAddressWorkOrders:removedWorkOrders];
        
        if ([addressArrayWaypoints count]) {
            self.controller.startPoint = [addressArrayWaypoints objectAtIndex:0];
            self.controller.endPoint = [addressArrayWaypoints lastObject];
        }
        self.controller.wayPoints = addressArrayWaypoints;
        self.controller.travelMode = UICGTravelModeDriving;
        self.controller.workOrderArray = self.workOrderSummaryArray;
        
        if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
            
            [self addChildViewController:self.controller];
            self.controller.frame = self.mapView.frame;
            [self.mapView addSubview:self.controller.view];
            [self.controller didMoveToParentViewController:self];
            self.noNetworkView.hidden = YES;
        }
        else {
            [self showNoNetworkView];
        }
    }@catch (NSException *exp)
    {
        
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
        
        if (annotationObject.index == kTechAnnotationIndex)
        {
            //TODO : Tech home location
        }
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
    SFMViewPageManager *pageManager = [[SFMViewPageManager alloc] initWithObjectName:kWorkOrderTableName recordId:woSummaryModel.localId];
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
    
}

@end
