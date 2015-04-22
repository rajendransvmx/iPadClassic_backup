//
//  UICGRoute.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGRoute.h"

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
	UICGRoute *route = [[UICGRoute alloc] initWithDictionaryRepresentation:dictionary];
	return [route autorelease];
}
// V3:KRI
// Updated way of retrieving Data

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil)
    {
		dictionaryRepresentation = [dictionary retain];
        
        steps = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *locations = [[NSMutableArray alloc] init];
                
        // V3:KRI
        NSArray *legs = [dictionaryRepresentation objectForKey:@"legs"];// @"k"];  //Shrinivas - Code Changed
        
        if(self.legsArray == nil) {
            NSArray *tempArr = [[NSArray alloc] init];
            self.legsArray = tempArr;
            [tempArr release];
        }
        
        self.legsArray = legs;
        
        for (int counter = 0; counter < [legs count]; counter++) {
            
             NSDictionary *k = [legs objectAtIndex:counter];
             NSArray *stepDics = [k objectForKey:@"steps"];
            for (NSDictionary *stepDic in stepDics) {
               // [(NSMutableArray *)steps addObject:[UICGStep stepWithDictionaryRepresentation:stepDic]];
            }
            
            // V3:KRI
            NSDictionary *endLocationDic = [k objectForKey:@"end_location"];
            
            //hb and ib for business purpose. if you are using publey key its again different
            //V3New:Kri
            CLLocationDegrees longitude = [[endLocationDic objectForKey:@"lngi" ] doubleValue];//[coordinates objectAtIndex:0]
            CLLocationDegrees latitude  = [[endLocationDic objectForKey:@"lati" ] doubleValue];//[coordinates objectAtIndex:1]
            endLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            summaryHtml = [k objectForKey:@"instructions"];
            //V3New:Kri
            distance = [k objectForKey:@"distance"]; //V3 change Distance to distance
            duration = [k objectForKey:@"duration"]; //v3 change Duration to duration

            
            [locations addObject:endLocation];
            
        }
        
        self.waypoints = locations;
        [locations release];
        locations = nil;
       
        // V3:KRI
        //endGeocode = [dictionaryRepresentation objectForKey:@"pr"];
		//startGeocode = [dictionaryRepresentation objectForKey:@"qr"];
		
		
        // SMLog(kLogLevelVerbose,@"## %@", summaryHtml);
		//polylineEndIndex = [[k objectForKey:@"polylineEndIndex"] integerValue];
	}
	return self;
}

- (void)dealloc {
	[dictionaryRepresentation release];
	[steps release];
	[distance release];
	[duration release];
	[summaryHtml release];
	[startGeocode release];
	[endGeocode release];
	[endLocation release];
    [waypoints release];
    [legsArray release];
	[super dealloc];
}

- (UICGStep *)stepAtIndex:(NSInteger)index 
{
	return [steps objectAtIndex:index];;
}

@end
