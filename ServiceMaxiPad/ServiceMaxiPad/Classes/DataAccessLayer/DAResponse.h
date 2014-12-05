//
//  DAResponse.h
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/22/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAResponse : NSObject {
    
    NSString *objectName;
    NSString *statusCode;
    NSString *statusMessage;
    NSArray  *objectData;
}

@property(nonatomic,retain) NSString *objectName;
@property(nonatomic,retain) NSString *statusCode;
@property(nonatomic,retain) NSString *statusMessage;
@property(nonatomic,retain) NSArray  *objectData;

- (NSDictionary *)dictionaryRepresenation;

@end
