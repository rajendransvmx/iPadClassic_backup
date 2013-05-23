//
//  UICGPolyline.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGPolyline.h"

@implementation UICGPolyline

@synthesize dictionaryRepresentation;
@synthesize routePoints;
@synthesize vertexCount;
@synthesize length;

+ (UICGPolyline *)polylineWithDictionaryRepresentation:(NSDictionary *)dictionary {
	UICGPolyline *polyline = [[UICGPolyline alloc] initWithDictionaryRepresentation:dictionary];
	return [polyline autorelease];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil) {
		dictionaryRepresentation = [dictionary retain];
        
//        if (!vertices || (NSNull *)vertices == [NSNull null]) {
//            vertices = [[dictionaryRepresentation objectForKey:@"k"] retain];
//        }
//        if (!vertices || (NSNull *)vertices == [NSNull null]) {
//            vertices = [[dictionaryRepresentation objectForKey:@"g"] retain];
//        }
        
        // V3:KRI
        if (!vertices || (NSNull *)vertices == [NSNull null]) {
            vertices = [[dictionaryRepresentation objectForKey:@"overview_path"] retain];//j
        }
        
        vertexCount = [vertices count];
		routePoints = [NSMutableArray arrayWithCapacity:vertexCount];
		for (NSDictionary *vertex in vertices) {
            // V3:KRI
            //V3New:Kri
			CLLocationDegrees latitude  = [[vertex objectForKey:@"jb"] doubleValue];//x hb to jb change v3
			CLLocationDegrees longitude = [[vertex objectForKey:@"kb"] doubleValue];//y ib to kb change v3
			CLLocation *location = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
			[routePoints addObject:location];
		}
	}
	return self;
}

- (void)dealloc {
	[dictionaryRepresentation release];
	[vertices release];
	[super dealloc];
}

- (CLLocation *)vertexAtIndex:(NSInteger)index {
	return [routePoints objectAtIndex:index];
}

- (void)insertVertexAtIndex:(NSInteger)index inLocation:(CLLocation *)location {
	//TODO
}

@end
