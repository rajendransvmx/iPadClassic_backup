//
//  UICGStep.h
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface UICGStep : NSObject {
	NSDictionary *dictionaryRepresentation;
	NSString *descriptionHtml;
	NSDictionary *distance;
	NSDictionary *duration;
}

@property (nonatomic, strong, readonly) NSDictionary *dictionaryRepresentation;
@property (nonatomic, strong, readonly) NSString *descriptionHtml;
@property (nonatomic, strong, readonly) NSDictionary *distance;
@property (nonatomic, strong, readonly) NSDictionary *duration;

+ (UICGStep *)stepWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;

@end
