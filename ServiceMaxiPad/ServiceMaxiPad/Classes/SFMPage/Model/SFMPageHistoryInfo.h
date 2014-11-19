//
//  SFMPageHistoryInfo.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 16/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFMPageHistoryInfo : NSObject

@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *problemDescription;
@property(nonatomic,strong) NSString *createdDate;

-(id)initWithDictionary:(NSDictionary *)dataDict;
- (void)updateCreatedDateToUserRedableFormat;

@end
