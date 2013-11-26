//
//  SMZKSHelper.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 11/20/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "SMZKSHelper.h"
#import "ZKServerSwitchboard.h"

/***  ZKS Field Constants ******/

NSString * const kZKSObjectName = @"ObjectName";
NSString * const kZKSFieldName  = @"Name";
NSString * const kZKSFieldDataBlobBody = @"Body";
NSString * const kZKSFieldParentId  = @"ParentId";
NSString * const kZKSFieldLocalId  = @"localId";
NSString * const kZKSAttachmentFieldIsPrivate = @"isPrivate";


@implementation SMZKSHelper

static dispatch_once_t _sharedInstanceGuard;
static SMZKSHelper *_instance;




#pragma mark - init/setup

- (id)init
{
    self = [super init];
    
    if (self)
    {
     // Do nothing now :]
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
}


#pragma mark - singleton

+ (SMZKSHelper *)sharedInstance {
    dispatch_once(&_sharedInstanceGuard,
                  ^{
                      _instance = [[SMZKSHelper alloc] init];
                  });
    return _instance;
}



- (void)createRecordWithParameters:(NSDictionary *)paramDictionary delegate:(id)delegate andSelector:(SEL)delegateSelector
{
    
    NSString *objectName = [paramDictionary objectForKey:kZKSObjectName];
    NSString *localId = [paramDictionary objectForKey:kZKSFieldLocalId];
    
    NSMutableDictionary *localParametersDict = [[NSMutableDictionary alloc] initWithDictionary:paramDictionary];
    
    // Ohh We got Object Name lets remove from param Dict
    
    [localParametersDict removeObjectForKey:kZKSObjectName];
    
    // Removing Local Id, since it is not part of request
    [localParametersDict removeObjectForKey:kZKSFieldLocalId];
    
    NSArray *keys =  [localParametersDict allKeys];
    
    ZKSObject * obj = [[ZKSObject alloc] initWithType:objectName];
    
    for (NSString *key in keys)
    {
        if (nil != key)
        {
            NSString *value = [localParametersDict objectForKey:key];
            if (nil != value)
            {
                [obj setFieldValue:value field:key];
            }
        }
    }
    
    NSArray * array = [[NSArray alloc] initWithObjects:obj, nil];
    [[ZKServerSwitchboard switchboard] create:array
                                       target:delegate
                                     selector:delegateSelector
                                      context:localId];
    
    [ZKServerSwitchboard switchboard].logXMLInOut =YES;
    
    [array release];
    [localParametersDict release];
    
}


@end
