//
//  UICGDirections.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UICGDirections.h"
#import "UICGRoute.h"
#import "NSDictionary+JSONString.h"

@implementation UICGDirections
@synthesize routes;
@synthesize delegate;
@synthesize polyline;
@synthesize distance;
@synthesize duration;
@synthesize status;
@synthesize isInitialized;
@synthesize googleMapsAPI;

- (id)init {
	self = [super init];
	if (self != nil) {
		self.googleMapsAPI = [[UICGoogleMapsAPI alloc] init];
		self.googleMapsAPI.delegate = self;
	}
	return self;
}

- (void)dealloc {
    
    googleMapsAPI.delegate = nil;
	googleMapsAPI = nil;
    delegate = nil;
    routes  = nil;
    polyline = nil;
    distance = nil;
    duration = nil;
    status = nil;
}

- (void)makeAvailable {
	[self.googleMapsAPI makeAvailable];
}


// V3:KRI
// ***** Modified MAIN parser code for google javascript api v3 *****

- (void)goolgeMapsAPI:(UICGoogleMapsAPI *)goolgeMapsAPI didGetObject:(NSObject *)object
{
	NSDictionary *dictionary = (NSDictionary *)object;
	NSArray *routeDics = [dictionary objectForKey:@"routes"];
    if (self.routes) {
        [self.routes removeAllObjects];
        self.routes = nil;
    }
	self.routes = [[NSMutableArray alloc] initWithCapacity:[routeDics count]];
	
    for (NSDictionary *routeDic in routeDics) {
		[self.routes addObject:[UICGRoute routeWithDictionaryRepresentation:routeDic]];
	}
    
    self.distance = [dictionary objectForKey:@"distance"];
	self.duration = [dictionary objectForKey:@"duration"];
	self.status = [dictionary objectForKey:@"status"];
	self.polyline = [UICGPolyline polylineWithDictionaryRepresentation:[routeDics objectAtIndex:0]];
	
	if ([self.delegate respondsToSelector:@selector(directionsDidUpdateDirections:)]) {
		[self.delegate directionsDidUpdateDirections:self];
	}
    dictionary = nil;
    routeDics = nil;
    
}

- (void)goolgeMapsAPI:(UICGoogleMapsAPI *)goolgeMapsAPI didFailWithMessage:(NSString *)message {
    
	if ([self.delegate respondsToSelector:@selector(directions:didFailWithMessage:)]) {
		[self.delegate directions:self didFailWithMessage:message];
        SXLogError(@"Google maps api failed:%@",message);
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
	isInitialized = YES;
	
    if ([self.delegate respondsToSelector:@selector(directionsDidFinishInitialize:)]) {
		[self.delegate directionsDidFinishInitialize:self];
	}

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
	if ([self.delegate respondsToSelector:@selector(directions:didFailInitializeWithError:)]) {
		[self.delegate directions:self didFailInitializeWithError:error];
        SXLogError(@"Google maps api initialization failed = %@",error.localizedDescription);
	}
    
}


// If no waypoints are given then loadWithStartPoint will take start and end point and depict the route
// param : startPoint or origin (technicians start point)
// param : endpoint or destination
// param : options for driving mode can be specified here. (obv. DRIVING for now)
- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(UICGDirectionsOptions *)options {
    
    NSMutableDictionary *finalDictionary = [[NSMutableDictionary alloc] init];
    [finalDictionary setObject:startPoint forKey:@"origin"];
    [finalDictionary setObject:endPoint forKey:@"destination"];
    
    NSString *requestDataString = [finalDictionary jsonStringWithPrettyPrint:YES];
    NSString *executableString = [NSString stringWithFormat:@"route1(%@);",requestDataString];
    
    [self.googleMapsAPI stringByEvaluatingJavaScriptFromString:executableString];
    
    finalDictionary = nil;
    requestDataString = nil;
    executableString = nil;
    
}

// V3:KRI
// Function which takes the list of waypoints with neccesary UICGDirectionsOptions
// param : waypoints or workorder points
// param : options for driving mode can be specified here. (obv. DRIVING for now)
- (void)loadFromWaypoints:(NSArray *)waypoints options:(UICGDirectionsOptions *)options {
    
    NSMutableDictionary *finalDictionary = [[NSMutableDictionary alloc] init];
    NSInteger waypointsCount = [waypoints count];
    NSMutableArray *wayPointsArray = [[NSMutableArray alloc] initWithCapacity:waypointsCount];
    
    for (int counter = 1; (counter < waypointsCount && (counter != (waypointsCount -1))); counter ++)
    {
        NSString *loc = [waypoints objectAtIndex:counter];
        NSMutableDictionary *waypt = [NSMutableDictionary dictionary];
        [waypt setObject:loc forKey:@"location"];
        [waypt setObject:[NSNumber numberWithBool:true] forKey:@"stopover"];
        [wayPointsArray addObject:waypt];
        loc = nil;
        waypt = nil;
    }
    
    [finalDictionary setObject:wayPointsArray forKey:@"waypoints"];
    
    NSString *fromString = [waypoints objectAtIndex:0];
    NSString *destString = [waypoints lastObject];
    [finalDictionary setObject:fromString forKey:@"origin"];
    [finalDictionary setObject:destString forKey:@"destination"];
    fromString = nil;
    destString = nil;
    
    NSString *requestDataString = [finalDictionary jsonStringWithPrettyPrint:YES];
    NSString *executableString = [NSString stringWithFormat:@"route1(%@);",requestDataString];
    [self.googleMapsAPI stringByEvaluatingJavaScriptFromString:executableString];
    finalDictionary = nil;
    wayPointsArray = nil;
 
}

- (NSInteger)numberOfRoutes {
	return [self.routes count];
}

- (UICGRoute *)routeAtIndex:(NSInteger)index {
	return [self.routes objectAtIndex:index];
}

@end
