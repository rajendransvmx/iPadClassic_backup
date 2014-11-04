//
//  SFMPageLayout.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 12/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SFMPageLayout.h
 *  @class  SFMPageLayout
 *
 *  @brief Holds the page layout information (Header and Detail).
 *
 *  @author Radha S
 *  
 *  @bug No known bugs.
 *  
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 **/

#import <Foundation/Foundation.h>
#import "SFMHeaderLayout.h"
#import "SFMDetailLayout.h"

@interface SFMPageLayout : NSObject

@property(nonatomic, strong) SFMHeaderLayout * headerLayout;
@property(nonatomic, strong) NSArray * detailLayouts;

- (NSArray *)getAllHeaderLayoutFields;
- (NSArray *)getPageFieldsForDetailLayoutComponent:(NSString *)componentId;

@end
