//
//  UICGRoute.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UICGRoute.h"

@interface UICGRoute ()

@property (nonatomic, strong) NSDictionary *dictionaryRepresentation;
@property (nonatomic) NSInteger numberOfSteps;
@property (nonatomic, strong) NSMutableArray *steps;
@property (nonatomic, strong) NSDictionary *distance;
@property (nonatomic, strong) NSDictionary *duration;
@property (nonatomic, strong) NSString *summaryHtml;
@property (nonatomic, strong) NSDictionary *startGeocode;
@property (nonatomic, strong) NSDictionary *endGeocode;
@property (nonatomic, strong) CLLocation *endLocation;
@property (nonatomic, assign) NSInteger polylineEndIndex;

@end

@implementation UICGRoute

@synthesize dictionaryRepresentation;
@synthesize numberOfSteps;
@synthesize steps;
@synthesize distance;
@synthesize duration;
@synthesize summaryHtml;
@synthesize startGeocode;
@synthesize endGeocode;
@synthesize endLocation;
@synthesize polylineEndIndex;
@synthesize waypoints;
@synthesize legsArray;

+ (UICGRoute *)routeWithDictionaryRepresentation:(NSDictionary *)dictionary {
	__autoreleasing UICGRoute *route = [[UICGRoute alloc] initWithDictionaryRepresentation:dictionary];
	return route;
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
    self = [super init];
	if (self != nil)
    {
		self.dictionaryRepresentation = dictionary;
        
        if (self.steps) {
            [self.steps removeAllObjects];
            self.steps = nil;
        }
        self.steps = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        NSArray *legs = [dictionaryRepresentation objectForKey:@"legs"];
        
        if(self.legsArray == nil) {
            NSArray *tempArr = [[NSArray alloc] init];
            self.legsArray = tempArr;
        }
        
        self.legsArray = legs;
        
        for (int counter = 0; counter < [legs count]; counter++) {
            
            NSDictionary *k = [legs objectAtIndex:counter];
            NSDictionary *endLocationDic = [k objectForKey:@"end_location"];
            CLLocationDegrees longitude = [[endLocationDic objectForKey:@"lngi" ] doubleValue];
            CLLocationDegrees latitude  = [[endLocationDic objectForKey:@"lati" ] doubleValue];
            self.endLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            self.summaryHtml = [k objectForKey:@"instructions"];
            self.distance = [k objectForKey:@"distance"]; //V3 change Distance to distance
            self.duration = [k objectForKey:@"duration"]; //v3 change Duration to duration
            [locations addObject:self.endLocation];
            k = nil;
            endLocationDic = nil;
        }
        
        self.waypoints = locations;
        locations = nil;
        legs = nil;
        
	}
	return self;
}


- (UICGStep *)stepAtIndex:(NSInteger)index 
{
	return [self.steps objectAtIndex:index];;
}

- (void)dealloc
{
    dictionaryRepresentation = nil;
    [steps removeAllObjects];
    steps = nil;
    distance = nil;
    duration = nil;
    summaryHtml = nil;
    startGeocode = nil;
    endGeocode = nil;
    endLocation = nil;
    waypoints = nil;
    legsArray = nil;
}

@end
