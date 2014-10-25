//
//  SFMHeaderSection.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 12/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMHeaderSection.h"

@implementation SFMHeaderSection

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self != nil) {
        
        _isSLAClock = [[dictionary objectForKey:kPageHeaderSLAClock] boolValue];
        _noOfColumns = [[dictionary objectForKey:kPageHeaderSectionColumns] integerValue];
        _title = [dictionary objectForKey:kPageHeaderSectionTitle];
        
        NSArray *fields = [dictionary objectForKey:kPageHeaderSectionsFields];
        
        NSArray * headerFields = [self getPageFieldsArray:fields];
        
        if (fields != nil) {
            _sectionFields = headerFields;
        }
    }
    return self;
}

- (NSArray *)getPageFieldsArray:(NSArray *)pageFieldArray{
    
    NSMutableArray *fieldsArray = [[NSMutableArray alloc]init];
    for (NSDictionary * pageDictionary in pageFieldArray ) {
        if (pageDictionary != nil && [pageDictionary count] > 0) {
            SFMPageField *aPageField = [[SFMPageField alloc] initWithDictionary:pageDictionary];
            if (aPageField != nil) {
                [fieldsArray addObject:aPageField];
            }
        }
    }
    return fieldsArray;
}

- (BOOL)isSectionSLAClock
{
    return self.isSLAClock;
}

- (SFMPageField *)pageFieldForField:(NSString *)fieldName
{
    SFMPageField *pageFieldData = nil;
    
    for (SFMPageField *pageField in self.sectionFields) {
        
        if ([fieldName isEqualToString:pageField.fieldName]) {
            pageFieldData = pageField;
            break;
        }
    }
    return pageFieldData;
}
@end
