//
//  SFWizardService.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFWizardDAO.h"
#import "CommonServices.h"

@interface SFWizardService : CommonServices<SFWizardDAO>

- (NSMutableArray *)getWizardsForObjcetName:(NSString *)objectName andRecordId:(NSString *)recordId;

@end
