//
//  IncrementalSyncRequestParamHelper.h
//  ServiceMaxMobile
//
//  Created by Sahana on 10/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IncrementalSyncHelper.h"
#import "RequestParamModel.h"

@interface IncrementalSyncRequestParamHelper : NSObject

@property(nonatomic,strong)NSMutableArray               *putInsertRecords;

@property(nonatomic, strong) IncrementalSyncHelper      *incrSyncHelper;

- (id)initWithRequestIdentifier:(NSString *)requestIndetifier;


- (RequestParamModel * )createSyncParamters:(NSDictionary *)lastIndexDict
                                 andContext:(NSDictionary *)contextDicticonary;
@end


#define kOneCallSyncIdLimit 150