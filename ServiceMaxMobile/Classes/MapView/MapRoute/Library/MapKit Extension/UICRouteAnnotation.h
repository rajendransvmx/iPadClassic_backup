//
//  UICRouteAnnotation.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum UICRouteAnnotationType
{
	UICRouteAnnotationTypeStart,
	UICRouteAnnotationTypeEnd,
	UICRouteAnnotationTypeWayPoint,
    UICRouteAnnotationTypeRecentVisits,
    UICRouteAnnotationTypeUserLocation,
} UICRouteAnnotationType;

@interface UICRouteAnnotation : NSObject<MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	UICRouteAnnotationType annotationType;
    
    // My customization
    UIImage *image;
    NSNumber *latitude;
    NSNumber *longitude;
    
    // WorkOrder details
    NSDictionary * workOrder;
    NSUInteger index;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic) UICRouteAnnotationType annotationType;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;

@property (nonatomic, retain) NSDictionary * workOrder;
@property NSUInteger index;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord 
				   title:(NSString *)aTitle 
		  annotationType:(UICRouteAnnotationType)type;

@end