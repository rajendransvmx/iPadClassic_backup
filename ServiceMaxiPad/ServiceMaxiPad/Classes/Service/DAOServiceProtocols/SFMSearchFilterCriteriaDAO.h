//
//  SFSearchFilterCriteriaDAO.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
@class SFMSearchFilterCriteriaModel;

@protocol SFMSearchFilterCriteriaDAO <CommonServiceDAO>

- (NSArray *)fetchExpressionComponentForExpressionId:(NSString *)expressionId;

@end
