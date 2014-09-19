//
//  UICGDirections.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICGDirectionsOptions.h"
#import "UICGRoute.h"
#import "UICGPolyline.h"
#import "UICGoogleMapsAPI.h"

@class UICGDirections;

@protocol UICGDirectionsDelegate<NSObject>
@optional
- (void)directionsDidFinishInitialize:(UICGDirections *)directions;
- (void)directions:(UICGDirections *)directions didFailInitializeWithError:(NSError *)error;
- (void)directionsDidUpdateDirections:(UICGDirections *)directions;
- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message;
@end

@interface UICGDirections : NSObject<UIWebViewDelegate> {
	id<UICGDirectionsDelegate> delegate;
	UICGoogleMapsAPI *googleMapsAPI;
	NSArray *routes;

    // V3:KRI We are not getting geocodes parameter in v3 anymore so we can make use of polyline instead
//	NSArray *geocodes;
	UICGPolyline *polyline;
	NSDictionary *distance;
	NSDictionary *duration;
	NSDictionary *status;
	BOOL isInitialized;
}

@property (nonatomic, assign) id<UICGDirectionsDelegate> delegate;
@property (nonatomic, retain) NSArray *routes;

// V3:KRI
//@property (nonatomic, retain) NSArray *geocodes;
@property (nonatomic, retain) UICGPolyline *polyline;
@property (nonatomic, retain) NSDictionary *distance;
@property (nonatomic, retain) NSDictionary *duration;
@property (nonatomic, retain) NSDictionary *status;
@property (nonatomic, readonly) BOOL isInitialized;

+ (UICGDirections *)sharedDirections;
- (id)init;
- (void)makeAvailable;

// V3:KRI This method can be eleminated as load() function and loadWithWaypoints() are eleminated.
//- (void)loadWithQuery:(NSString *)query options:(UICGDirectionsOptions *)options;
- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(UICGDirectionsOptions *)options;
- (void)loadFromWaypoints:(NSArray *)waypoints options:(UICGDirectionsOptions *)options;
- (void)clear;
- (NSInteger)numberOfRoutes;
- (UICGRoute *)routeAtIndex:(NSInteger)index;

// V3:KRI Geocodes are no more a param in V3
//- (NSInteger)numberOfGeocodes;
//- (NSDictionary *)geocodeAtIndex:(NSInteger)index;

@end
