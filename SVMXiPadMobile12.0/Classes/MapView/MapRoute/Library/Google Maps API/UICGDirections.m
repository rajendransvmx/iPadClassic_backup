//
//  UICGDirections.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGDirections.h"
#import "UICGRoute.h"
#import "JSON.h"

static UICGDirections *sharedDirections;

@implementation UICGDirections

@synthesize routes;
// V3:KRI
//@synthesize geocodes;
@synthesize delegate;
@synthesize polyline;
@synthesize distance;
@synthesize duration;
@synthesize status;
@synthesize isInitialized;

+ (UICGDirections *)sharedDirections {
	if (!sharedDirections) {
		sharedDirections = [[UICGDirections alloc] init];
	}
	return sharedDirections;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		googleMapsAPI = [[UICGoogleMapsAPI alloc] init];
		googleMapsAPI.delegate = self;
	}
	return self;
}

- (void)dealloc {
	[googleMapsAPI release];
	[routes release];
// V3:KRI
//	[geocodes release];
	[polyline release];
	[distance release];
	[duration release];
	[status release];
	[super dealloc];
}

- (void)makeAvailable {
	[googleMapsAPI makeAvailable];
}

// V3:KRI
// ***** Modified MAIN parser code for google javascript api v3 *****

- (void)goolgeMapsAPI:(UICGoogleMapsAPI *)goolgeMapsAPI didGetObject:(NSObject *)object
{
	NSDictionary *dictionary = (NSDictionary *)object;
    //NSString *jasonFormat = [dictionary JSONRepresentation];
    //NSLog(@"jason format %@",jasonFormat);
    
	NSArray *routeDics = [dictionary objectForKey:@"routes"];
	routes = [[NSMutableArray alloc] initWithCapacity:[routeDics count]];
	
    for (NSDictionary *routeDic in routeDics) {
		[(NSMutableArray *)routes addObject:[UICGRoute routeWithDictionaryRepresentation:routeDic]];
	}
//v2	self.geocodes = [dictionary objectForKey:@"geocodes"];
    
    self.distance = [dictionary objectForKey:@"distance"];
	self.duration = [dictionary objectForKey:@"duration"];
	self.status = [dictionary objectForKey:@"status"];

    // V3:KRI
	self.polyline = [UICGPolyline polylineWithDictionaryRepresentation:[routeDics objectAtIndex:0]];
    //[dictionary objectForKey:@"polyline"]];//v2
	
	if ([self.delegate respondsToSelector:@selector(directionsDidUpdateDirections:)]) {
		[self.delegate directionsDidUpdateDirections:self];
	}
}

- (void)goolgeMapsAPI:(UICGoogleMapsAPI *)goolgeMapsAPI didFailWithMessage:(NSString *)message {
	if ([self.delegate respondsToSelector:@selector(directions:didFailWithMessage:)]) {
		[self.delegate directions:self didFailWithMessage:message];
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
	}
}


//V3:KRI 

//- (void)loadWithQuery:(NSString *)query options:(UICGDirectionsOptions *)options {    
//    
//    // V3:KRI
//
//    NSString *someStr = [NSString stringWithFormat:@"loadDirections(%@, %@);", query, [options JSONRepresentation]];
//    [googleMapsAPI stringByEvaluatingJavaScriptFromString:someStr];
//	
//    NSLog(@"description 1 : %@",someStr);
//
//    
//}


// If no waypoints are given then loadWithStartPoint will take start and end point and depict the route
// param : startPoint or origin (technicians start point)
// param : endpoint or destination
// param : options for driving mode can be specified here. (obv. DRIVING for now)
- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(UICGDirectionsOptions *)options {
    
    NSMutableDictionary *finalDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    [finalDictionary setObject:startPoint forKey:@"origin"];
    [finalDictionary setObject:endPoint forKey:@"destination"];
    
    NSString *requestDataString = [finalDictionary JSONRepresentation];
    
    NSString *executableString = [NSString stringWithFormat:@"route1(%@);",requestDataString];
    
    [googleMapsAPI stringByEvaluatingJavaScriptFromString:executableString];

}

// V3:KRI
// Function which takes the list of waypoints with neccesary UICGDirectionsOptions
// param : waypoints or workorder points
// param : options for driving mode can be specified here. (obv. DRIVING for now)
- (void)loadFromWaypoints:(NSArray *)waypoints options:(UICGDirectionsOptions *)options {
    
    NSMutableDictionary *finalDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSMutableArray *wayPointsArray = [NSMutableArray array];
    
    NSInteger someCount = [waypoints count];
    for (int counter = 1; (counter < someCount && (counter != (someCount -1))); counter ++)
    {
        NSString *loc = [waypoints objectAtIndex:counter];
        NSMutableDictionary *waypt = [NSMutableDictionary dictionary];
        [waypt setObject:loc forKey:@"location"];
        [waypt setObject:[NSNumber numberWithBool:true] forKey:@"stopover"];
        [wayPointsArray addObject:waypt];
    }
    
    [finalDictionary setObject:wayPointsArray forKey:@"waypoints"];
    
     
    NSString *fromString = [waypoints objectAtIndex:0];
    NSString *destString = [waypoints lastObject];
    
    [finalDictionary setObject:fromString forKey:@"origin"];
    [finalDictionary setObject:destString forKey:@"destination"];
    
    NSString *requestDataString = [finalDictionary JSONRepresentation];
    NSString *executableString = [NSString stringWithFormat:@"route1(%@);",requestDataString];
    
    [googleMapsAPI stringByEvaluatingJavaScriptFromString:executableString];
 
}

- (void)clear {
	
}

- (NSInteger)numberOfRoutes {
	return [routes count];
}

- (UICGRoute *)routeAtIndex:(NSInteger)index {
	return [routes objectAtIndex:index];
}

// V3:KRI

//- (NSInteger)numberOfGeocodes {
//	return [geocodes count];
//}
//
//- (NSDictionary *)geocodeAtIndex:(NSInteger)index {
//	return [geocodes objectAtIndex:index];;
//}

@end
