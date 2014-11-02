//
//  SFMPageLayout.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 12/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageLayout.h"

@implementation SFMPageLayout

- (NSArray *)getAllHeaderLayoutFields
{
    return [self.headerLayout getAllHeaderLayoutFields];
}

- (NSArray *)getPageFieldsForDetailLayoutComponent:(NSString *)componentId
{
    for (SFMDetailLayout *detailLayout in self.detailLayouts) {
        if ([detailLayout.processComponentId isEqualToString:componentId] ){
            return detailLayout.detailSectionFields;
        }
    }
    return nil;
}

@end
