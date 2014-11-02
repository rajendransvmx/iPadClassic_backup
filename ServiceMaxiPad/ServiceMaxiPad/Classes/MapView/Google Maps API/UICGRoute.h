//
//  UICGRoute.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UICGStep.h"

@interface UICGRoute : NSObject {
	NSDictionary *dictionaryRepresentation;
	NSInteger numberOfSteps;
	NSMutableArray *steps;
	NSDictionary *distance;
	NSDictionary *duration;
	NSString *summaryHtml;
	NSDictionary *startGeocode;
	NSDictionary *endGeocode;
	CLLocation *endLocation;
	NSInteger polylineEndIndex;
    NSArray   *waypoints;
}

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;
@property (nonatomic, readonly) NSInteger numberOfSteps;
@property (nonatomic, strong, readonly) NSMutableArray *steps;
@property (nonatomic, strong, readonly) NSDictionary *distance;
@property (nonatomic, strong, readonly) NSDictionary *duration;
@property (nonatomic, strong, readonly) NSString *summaryHtml;
@property (nonatomic, strong, readonly) NSDictionary *startGeocode;
@property (nonatomic, strong, readonly) NSDictionary *endGeocode;
@property (nonatomic, strong, readonly) CLLocation *endLocation;
@property (nonatomic, assign, readonly) NSInteger polylineEndIndex;
@property (nonatomic,strong)  NSArray   *waypoints;
@property (nonatomic, strong) NSArray   *legsArray;


+ (UICGRoute *)routeWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (UICGStep *)stepAtIndex:(NSInteger)index;

@end
