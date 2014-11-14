//
//  UICGStep.m
//  ServiceMaxMobile
//
//  Created by Anoop on 9/15/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UICGStep.h"

@interface UICGStep ()

@property (nonatomic, strong) NSDictionary *dictionaryRepresentation;
@property (nonatomic, strong) NSString *descriptionHtml;
@property (nonatomic, strong) NSDictionary *distance;
@property (nonatomic, strong) NSDictionary *duration;

@end

@implementation UICGStep

@synthesize dictionaryRepresentation;
@synthesize descriptionHtml;
@synthesize distance;
@synthesize duration;

+ (UICGStep *)stepWithDictionaryRepresentation:(NSDictionary *)dictionary {
	__autoreleasing UICGStep *step = [[UICGStep alloc] initWithDictionaryRepresentation:dictionary];
	return step;
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	
    self = [super init];
	
    if (self != nil) {
        
		self.dictionaryRepresentation = dictionary;
		self.descriptionHtml = [dictionaryRepresentation objectForKey:@"instructions"];
		self.distance = [dictionaryRepresentation objectForKey:@"distance"];
		self.duration = [dictionaryRepresentation objectForKey:@"duration"];
	
    }
	return self;
}

- (void)dealloc {
    
    dictionaryRepresentation = nil;
    descriptionHtml = nil;
    distance = nil;
    duration = nil;
    
}


@end
