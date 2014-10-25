//
//  SFMPageField.m
//  ServiceMaxMobile
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageField.h"

@implementation SFMPageField

- (id)initWithDictionary:(NSDictionary *)pageFieldDict
{
    self = [super init];
    if (self) {
        
        _fieldName = [pageFieldDict objectForKey:kPageFieldApiName];
        _dataType = [pageFieldDict objectForKey:kPageFieldDataType];
        _relatedObjectName = [pageFieldDict objectForKey:kPageFieldRelatedObjectName];
        _isReadOnly = [[pageFieldDict objectForKey:kPageFieldReadOnly] boolValue];
        _isRequired = [[pageFieldDict objectForKey:kPageFieldRequired] boolValue];
        _isDependentPicklist = [pageFieldDict objectForKey:kDependentPicklist];
        
        _lookUpContext = [pageFieldDict objectForKey:kPageFieldLookupContext];
        _lookUpQueryField = [pageFieldDict objectForKey:kPageFieldLookupQuery];
        _namedSearch = [pageFieldDict objectForKey:kPageFieldRelatedObjectSearchId];

    }
    return self;
}


@end
