//
//  UICRouteAnnotation.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "WorkOrderSummaryModel.h"

typedef NS_ENUM(NSUInteger, UICRouteAnnotationType)
{
	UICRouteAnnotationTypeTechAddress,
	UICRouteAnnotationTypeWayPoint,
    UICRouteAnnotationTypeUserLocation,
};

@class WorkOrderSummaryModel;

@interface UICRouteAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	UICRouteAnnotationType annotationType;
    
    // My customization
    UIImage *image;
    NSNumber *latitude;
    NSNumber *longitude;
    
    // WorkOrder details
    WorkOrderSummaryModel *workOrder;
    NSUInteger index;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) UICRouteAnnotationType annotationType;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@property (nonatomic, strong) WorkOrderSummaryModel *workOrder;
@property (nonatomic, assign) NSUInteger index;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord 
				   title:(NSString *)aTitle 
		  annotationType:(UICRouteAnnotationType)type;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)aTitle annotationType:(UICRouteAnnotationType)type index:(NSInteger)indexCount workOrderSummary:(WorkOrderSummaryModel*)workOrderObj;

@end
