//
//  SFMDetailLayout.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 12/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMDetailLayout.h"
#import "Utility.h"
#import "StringUtil.h"


@implementation SFMDetailLayout

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self != nil) {
        
        _objectName = [dictionary objectForKey:kPageDetailObjectName];
        _name = [dictionary objectForKey:kPageDetailObjectLabel];
        _pageLayoutId = [dictionary objectForKey:kPageDetailLayoutId];
        _dtlLayoutId = [dictionary objectForKey:kPageDetailLayoutId];
        _headerReferenceField = [dictionary objectForKey:kPageDetailHeaderRefField];
        _noOfColumns = [[dictionary objectForKey:kPageDetailNumberOfColumns] boolValue];
        
        NSNumber *allowNewLines = [dictionary objectForKey:kPageDetailAllowNewLines];
        if ([Utility isItTrue:[allowNewLines stringValue] ]) {
            _allowNewLines = YES;
        }
        
        NSNumber *allowDeleteLines = [dictionary objectForKey:kPageDetailAllowDeleteLines];
        if ([Utility isItTrue:[allowDeleteLines stringValue] ]) {
            _allowDeleteLines = YES;
        }

        
        /*Multi-add configuration info*/
        _multiAddSearchField = [dictionary objectForKey:kPageDetailMultiAddSearch];
        _multiAddSearhObject = [dictionary objectForKey:kPageDetailMultiaddSearchObject];
        if (![StringUtil isStringEmpty:_multiAddSearhObject]) {
            _allowMultiAddConfig = YES;
        }


        /* Get all fields */
        NSArray *fields  = [dictionary objectForKey:kPageDetailFieldsArray];
        if ([fields isKindOfClass:[NSArray class]] && [fields count] > 0) {
            NSArray *pageFields= [self getPageFieldsArray:fields];
            _detailSectionFields = pageFields;
            
        }
    }
    return self;
}

- (NSArray *)getPageFieldsArray:(NSArray *)pageFieldArray{
    
    NSMutableArray *fieldsArray = [[NSMutableArray alloc]init];
    for (int counter = 0; counter  < [pageFieldArray count]; counter++) {
        NSDictionary *pageDictionary = [pageFieldArray objectAtIndex:counter];
        if (pageDictionary != nil && [pageDictionary count] > 0) {
            SFMPageField *aPageField = [[SFMPageField alloc] initWithDictionary:pageDictionary];
            if (aPageField != nil) {
                [fieldsArray addObject:aPageField];
            }
        }
    }
    if ([fieldsArray count] > 0) {
        return fieldsArray;
    }
    return nil;
}

@end
