//
//  ObjectNameFieldValueDAO.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectNameFieldValueModel.h"

@protocol ObjectNameFieldValueDAO <NSObject>

- (NSArray * )fetchObjectNameFieldValueByFields:(NSArray *)fieldNames andCriteria:(id)criteria;
@end
