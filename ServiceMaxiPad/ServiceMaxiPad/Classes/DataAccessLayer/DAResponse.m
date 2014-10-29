//
//  DAResponse.m
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/22/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import "DAResponse.h"

@implementation DAResponse

- (NSDictionary *)dictionaryRepresenation {
    
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
   
    if (self.objectName != nil) {
         [tempDictionary setObject:self.objectName forKey:@"objectName"];
    }
    if (self.statusCode != nil) {
        [tempDictionary setObject:self.statusCode forKey:@"statusCode"];
    }
    if (self.statusMessage != nil) {
          [tempDictionary setObject:self.statusMessage forKey:@"statusMessage"];
    }
  
    if (self.objectData != nil) {
        [tempDictionary setObject:self.objectData forKey:@"objectData"];
    }
    
    
    return tempDictionary;
}


@end
