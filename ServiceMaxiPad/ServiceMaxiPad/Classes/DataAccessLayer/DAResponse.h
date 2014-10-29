//
//  DAResponse.h
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/22/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAResponse : NSObject

@property(nonatomic,strong) NSString *objectName;
@property(nonatomic,strong) NSString *statusCode;
@property(nonatomic,strong) NSString *statusMessage;
@property(nonatomic,strong) NSArray  *objectData;

- (NSDictionary *)dictionaryRepresenation;

@end
