//
//  LinkedSfmProcessDAO.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 08/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "LinkedSfmProcessModel.h"

@protocol LinkedSfmProcessDAO <CommonServiceDAO>

- (NSArray * )fetchLinkedProcessInfoByFields:(NSArray *)fieldNames
                                 andCriteria:(NSArray *)criteria
                               andExpression:(NSString *)expression;
@end
