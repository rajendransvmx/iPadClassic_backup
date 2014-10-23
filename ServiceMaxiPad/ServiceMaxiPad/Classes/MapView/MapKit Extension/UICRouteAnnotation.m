//
//  UICRouteAnnotation.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UICRouteAnnotation.h"

@implementation UICRouteAnnotation

@synthesize coordinate;
@synthesize workOrder;
@synthesize title;
@synthesize annotationType;
@synthesize image, latitude, longitude;
@synthesize index;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)aTitle annotationType:(UICRouteAnnotationType)type
{
	self = [super init];
	if (self != nil)
    {
		self.coordinate = coord;
        self.latitude = [NSNumber numberWithDouble:coord.latitude];
        self.longitude = [NSNumber numberWithDouble:coord.longitude];
		self.title = aTitle;
		self.annotationType = type;
	}
	return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)aTitle annotationType:(UICRouteAnnotationType)type index:(NSInteger)indexCount workOrderSummary:(WorkOrderSummaryModel*)workOrderObj
{
    self = [super init];
    if (self != nil)
    {
        self.coordinate = coord;
        self.latitude = [NSNumber numberWithDouble:coord.latitude];
        self.longitude = [NSNumber numberWithDouble:coord.longitude];
        self.title = aTitle;
        self.annotationType = type;
        self.index = indexCount;
        self.workOrder = workOrderObj;
    }
    return self;
}

-(void)setWorkOrder:(WorkOrderSummaryModel *)workOrderObj {
    
    workOrder = workOrderObj;
    if ([workOrderObj.priority integerValue] == PriorityHigh) {
        self.image  = [UIImage imageNamed:@"map_prioritypin"];
    }
    else {
         self.image  = [UIImage imageNamed:@"map_nonprioritypin"];
    }
}

- (CLLocationCoordinate2D)coordinate;
{
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

- (void)dealloc {
    
    title = nil;
    image = nil;
    latitude = nil;
    longitude = nil;
    workOrder = nil;
    
}


@end
