//
//  SyncErrorConflictDAO.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 17/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import"CommonServiceDAO.h"

@protocol SyncErrorConflictDAO <CommonServiceDAO>

- (BOOL)isConflictFoundForObject:(NSString*)objectName withSfId:(NSString*)sfId;
- (BOOL)isConflictFoundForObjectWithOutType:(NSString*)objectName withSfId:(NSString*)sfId; //For Pulse app


- (NSString *)fetchExistingModifiedFieldsJsonFromConflictTableForSfId:(NSString*)sfId andObjectName:(NSString *)objectName;
@end
