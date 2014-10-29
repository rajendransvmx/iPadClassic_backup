//
//  UICGPolyline.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface UICGPolyline : NSObject {
	NSDictionary *dictionaryRepresentation;
	NSMutableArray *routePoints;
	NSInteger vertexCount;
	NSInteger length;
}

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;
@property (nonatomic, strong, readonly) NSMutableArray *routePoints;
@property (nonatomic, readonly) NSInteger vertexCount;
@property (nonatomic, readonly) NSInteger length;

+ (UICGPolyline *)polylineWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (CLLocation *)vertexAtIndex:(NSInteger)index;

@end
