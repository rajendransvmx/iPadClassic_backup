//
//  UICGPolyline.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UICGPolyline.h"

@interface UICGPolyline ()

@property (nonatomic, strong) NSDictionary *dictionaryRepresentation;
@property (nonatomic, strong) NSMutableArray *routePoints;
@property (nonatomic, readwrite) NSInteger vertexCount;
@property (nonatomic, readwrite) NSInteger length;
@property (nonatomic, strong)  NSArray *vertices;

@end

@implementation UICGPolyline

@synthesize dictionaryRepresentation;
@synthesize routePoints;
@synthesize vertexCount;
@synthesize length;

+ (UICGPolyline *)polylineWithDictionaryRepresentation:(NSDictionary *)dictionary {
	__autoreleasing UICGPolyline *polyline = [[UICGPolyline alloc] initWithDictionaryRepresentation:dictionary];
	return polyline;
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	
    self = [super init];
	
    if (self != nil) {
        
		self.dictionaryRepresentation = dictionary;
        
        if (!_vertices || (NSNull *)_vertices == [NSNull null]) {
            _vertices = [dictionaryRepresentation objectForKey:@"overview_path"];
        }
        
        self.vertexCount = [_vertices count];
		self.routePoints = [NSMutableArray arrayWithCapacity:vertexCount];
        
		for (NSDictionary *vertex in _vertices) {
			CLLocationDegrees latitude  = [[vertex objectForKey:@"lat"] doubleValue];
			CLLocationDegrees longitude = [[vertex objectForKey:@"lng"] doubleValue];
			CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
			[self.routePoints addObject:location];
		}
        
	}
	return self;
}


- (CLLocation *)vertexAtIndex:(NSInteger)index {
    
	return [self.routePoints objectAtIndex:index];

}

-(void)dealloc {
    dictionaryRepresentation = nil;
    [routePoints removeAllObjects];
    routePoints = nil;
}


@end
