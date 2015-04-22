//
//  SMZKSHelper.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 11/20/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZKSObject.h"



/***  ZKS Field Constants ******/

extern  NSString * const kZKSObjectName;
extern  NSString * const kZKSFieldName;
extern  NSString * const kZKSFieldDataBlobBody;
extern  NSString * const kZKSFieldParentId;
extern  NSString * const kZKSFieldLocalId;
extern  NSString * const kZKSAttachmentFieldIsPrivate;

@interface SMZKSHelper : NSObject

+ (SMZKSHelper *)sharedInstance;

- (void)createRecordWithParameters:(NSDictionary *)paramDictionary delegate:(id)delegate andSelector:(SEL)delegateSelector;

@end
