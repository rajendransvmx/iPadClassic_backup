//
//  SFObjectDAO.h
//  ServiceMaxMobile
//
//  Created by shravya on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "SFObjectModel.h"

@protocol SFObjectDAO <CommonServiceDAO>
-(NSArray *)getDistinctObjects;
- (SFObjectModel *)getSFObjectInfo:(id)criteria fieldName:(NSArray *)fielNames;
- (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria;

@end
