//
//  SFExpressionDAO.h
//  ServiceMaxMobile
//
//  Created by Aparna on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
#import "CommonServiceDAO.h"
@class SFExpressionModel;

@protocol SFExpressionDAO <CommonServiceDAO>

- (SFExpressionModel *) getExpressionBySFId:(NSString *)expSFId;

@end
