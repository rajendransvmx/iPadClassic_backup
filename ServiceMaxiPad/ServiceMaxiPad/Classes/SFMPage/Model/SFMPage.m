//
//  SFMPage.m
//  ServiceMaxMobile
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPage.h"
#import "SFMRecordFieldData.h"

@implementation SFMPage

- (id)initWithObjectName:(NSString *)newObjectName andRecordId:(NSString *)newRecordId {
    
    self = [super init];
    if (self != nil) {
        self.objectName = newObjectName;
        self.recordId = newRecordId;
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


@end
