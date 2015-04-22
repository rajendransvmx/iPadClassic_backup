//
//  SFMWizardComponentDAO.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@protocol SFMWizardComponentDAO <CommonServiceDAO>

- (void)getWizardComponentsForWizards:(NSMutableArray *)wizardArray recordId:(NSString *)recordId;
-(void)updateWizardComponentWithModelArray:(NSArray*)modelArray;

@end
