//
//  SFMSearchFieldDAO.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
@class SFMSearchFieldModel;
@class SFMSearchObjectModel;
@protocol SFMSearchFieldDAO <CommonServiceDAO>

- (NSArray *)getAllFieldsForSearchObject:(SFMSearchObjectModel *)searchObject;

@end

