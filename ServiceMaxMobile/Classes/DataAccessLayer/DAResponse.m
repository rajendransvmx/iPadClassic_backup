//
//  DAResponse.m
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/22/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import "DAResponse.h"

@implementation DAResponse

@synthesize objectName;
@synthesize statusCode;
@synthesize statusMessage;
@synthesize objectData;

- (void)dealloc {
    [objectName release];
    [statusCode release];
    [statusMessage release];
    [objectData release];
    [super dealloc];
}

- (NSDictionary *)dictionaryRepresenation {
    
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
   
    if (objectName != nil) {
         [tempDictionary setObject:objectName forKey:@"objectName"];
    }
    if (statusCode != nil) {
        [tempDictionary setObject:statusCode forKey:@"statusCode"];
    }
    if (statusMessage != nil) {
          [tempDictionary setObject:statusMessage forKey:@"statusMessage"];
    }
  
    if (objectData != nil) {
        [tempDictionary setObject:objectData forKey:@"objectData"];
    }
    
    
    return [tempDictionary autorelease];
}


@end
