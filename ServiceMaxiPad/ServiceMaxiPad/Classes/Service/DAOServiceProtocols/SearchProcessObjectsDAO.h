//
//  SearchProcessObjectsDAO.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
@class SFMSearchProcessModel;

@protocol SearchProcessObjectsDAO <CommonServiceDAO>

- (NSArray *)getAllObjectApiNames;
- (NSArray *)getAllObjectApiNamesFor:(SFMSearchProcessModel*)processModel;

@end