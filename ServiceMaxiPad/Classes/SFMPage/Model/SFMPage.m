//
//  SFMPage.m
//  ServiceMaxMobile
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPage.h"
#import "SFMRecordFieldData.h"
#import "StringUtil.h"

@implementation SFMPage

- (id)initWithObjectName:(NSString *)newObjectName andRecordId:(NSString *)newRecordId {
    
    self = [super init];
    if (self != nil) {
        self.objectName = newObjectName;
        self.recordId = newRecordId;
    }
    return self;
}

- (id)initWithSourceObjectName:(NSString *)srcObjectName andSourceRecordId:(NSString *)srcRecordId
{
    if (self = [super init]) {
        _sourceObjectName = srcObjectName;
        _sourceRecordId = srcRecordId;
    }
    return self;
}


- (NSArray *)getHeaderLayoutFields
{
    NSArray * fields = [self.process.pageLayout getAllHeaderLayoutFields];
    return fields;
}

- (NSString *)getHeaderSalesForceId {
   SFMRecordFieldData *field = [self.headerRecord objectForKey:kId];
    return field.internalValue;
}

- (SFMRecordFieldData *)getHeaderFieldDataForName:(NSString *)fieldName
{
    if (fieldName != nil) {
        return [self.headerRecord objectForKey:fieldName];
    }
    return nil;
   
}

- (BOOL)isAttachmentEnabled {
    
    SFProcessComponentModel *model =  [self.process getProcessComponentOfType:kTarget];
    return model.enableAttachment;
}

-(BOOL)areChildRecordsSynced{
    if ([StringUtil isStringNotNULL:[self getHeaderSalesForceId]] && [[self getHeaderSalesForceId] length]>0) {
        NSDictionary *dict = self.detailsRecord;
        if (!dict) //if there is no chaild then no need to check for sfId.
        {
            return YES;
        }
        for (NSString *pocessId in [dict allKeys]) {
            NSArray *childList = [dict objectForKey:pocessId];
            for (NSDictionary *records in childList) {
                SFMRecordFieldData *recordFieldDataChild = [records objectForKey:kId];
                if (recordFieldDataChild)
                {
                    NSString *SFMId = recordFieldDataChild.internalValue;
                    if ([StringUtil isStringNotNULL:SFMId] && [SFMId length]>0)
                    {
                        
                    }
                    else
                    {
                        return NO;
                    }
                }
            }
        }
    }
    else
    {
        return NO;
    }
    return YES;
}

@end
