//
//  SourceUpdateConfig.h
//  ServiceMaxMobile
//
//  Created by Shravya shridhar on 1/1/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SourceUpdateConfig : NSObject {
    
    NSString *identifier;
    NSString *sourceObjectName;
    NSString *targetObjectName;
    NSString *sourceFieldName;
    NSString *targetFieldname;
    NSString *actionType;
    NSString *displayValue;
    NSString *settingId;
    NSString *processId;
}

@property(nonatomic,retain) NSString *identifier;
@property(nonatomic,retain) NSString *sourceObjectName;
@property(nonatomic,retain) NSString *targetObjectName;
@property(nonatomic,retain) NSString *sourceFieldName;
@property(nonatomic,retain) NSString *targetFieldname;
@property(nonatomic,retain) NSString *actionType;
@property(nonatomic,retain) NSString *displayValue;
@property(nonatomic,retain) NSString *settingId;
@property(nonatomic,retain) NSString *processId;
@end
