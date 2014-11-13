//
//  UICGDirections.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
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

@interface UICGDirections : NSObject<UIWebViewDelegate>
{
    id<UICGDirectionsDelegate> __weak delegate;
	UICGoogleMapsAPI *googleMapsAPI;
	NSMutableArray *routes;
	UICGPolyline *polyline;
	NSDictionary *distance;
	NSDictionary *duration;
	NSDictionary *status;
	BOOL isInitialized;
}

@property (nonatomic, weak) id<UICGDirectionsDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *routes;
@property (nonatomic, strong) UICGPolyline *polyline;
@property (nonatomic, strong) NSDictionary *distance;
@property (nonatomic, strong) NSDictionary *duration;
@property (nonatomic, strong) NSDictionary *status;
@property (nonatomic, strong) UICGoogleMapsAPI *googleMapsAPI;
@property (nonatomic, readonly) BOOL isInitialized;

- (id)init;
- (void)makeAvailable;
- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(UICGDirectionsOptions *)options;
- (void)loadFromWaypoints:(NSArray *)waypoints options:(UICGDirectionsOptions *)options;
- (NSInteger)numberOfRoutes;
- (UICGRoute *)routeAtIndex:(NSInteger)index;

@end
