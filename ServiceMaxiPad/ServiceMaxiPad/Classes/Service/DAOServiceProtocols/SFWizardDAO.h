//
//  SFWizardDAO.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@class SFWizardModel;

@protocol SFWizardDAO <CommonServiceDAO>

-(void)updateWizardWithModelArray:(NSArray*)modelArray;

@end
