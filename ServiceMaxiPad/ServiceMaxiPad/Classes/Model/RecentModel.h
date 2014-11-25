//
//  RecentModel.h
//  ServiceMaxiPad
//
//  Created by Shubha S on 30/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentModel : NSObject

@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *localId;
@property(nonatomic, strong) NSString *createdDate;
@property(nonatomic, strong) NSString *nameFieldValue;

- (id)initWithObjectName:(NSString *)objName
             andRecordId:(NSString *)recordId;

@end
