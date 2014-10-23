//
//  MapViewController.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/26/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CLLocationManager.h>
#import "MapDirectionsViewController.h"
#import "UICGDirections.h"
#import "MapPopUpViewController.h"
#import "WorkOrderSummaryModel.h"
#import "ServiceLocationModel.h"

@interface MapViewController : UIViewController
<UIPopoverControllerDelegate,
MapDirectionsDelegate,
MapPopUpDelegate>

//MapView
@property(nonatomic, strong)IBOutlet UIView *mapView;
@property(nonatomic, strong)MapDirectionsViewController *controller;
@property(nonatomic, strong)MapPopUpViewController *mapPopUpVC;
@property(nonatomic, strong)UIPopoverController *popOver;
@property(nonatomic, strong)NSMutableArray *workOrderSummaryArray;

// Offline View
@property(nonatomic, strong)IBOutlet UIView *noNetworkView;
@property(nonatomic, strong)IBOutlet UILabel *noNetworkLabel;
@property(nonatomic, strong)IBOutlet UIButton *reloadButton;

@end
