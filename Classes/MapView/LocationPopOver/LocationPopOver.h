//
//  LocationPopOver.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 21/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationPopOverDelegate

@optional
- (void) showDrivingDirectionsForAnnotationIndex:(NSUInteger)annotationIndex;
- (void) showJobDetailsForAnnotationIndex:(NSUInteger)annotationIndex;

@end


@interface LocationPopOver : UIViewController
{
    id <LocationPopOverDelegate> delegate;

    UIPopoverController * popOver;
    
    IBOutlet UILabel * workOrderLabel, * workOrderDetailLabel;
    IBOutlet UITextView * workOrderContactText;
    
    IBOutlet UIButton * jobDetailsButton;
    IBOutlet UIButton * drivingDirectionsButton;
    
    NSString * workOrder;
    NSString * workOrderDetail;
    NSString * workOrderContact;
    
    NSUInteger annotationIndex;
    
    IBOutlet UIView * homeLocationView;
    IBOutlet UITextView * homeLocationAddress;
    
    IBOutlet UIButton * homeLocationDrivingDirections;
	
	IBOutlet UILabel *_homeLocation;
}

@property (nonatomic, retain) id <LocationPopOverDelegate> delegate;


@property (nonatomic, retain) UIPopoverController * popOver;

@property (nonatomic, retain) NSString * workOrder;
@property (nonatomic, retain) NSString * workOrderDetail;
@property (nonatomic, retain) NSString * workOrderContact;

@property NSUInteger annotationIndex;

- (IBAction) DrivingDirections;
- (IBAction) JobDetails;
- (void) disableJobDetail;

@end
