//
//  BaseSFWizard.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFWizardModel.m
 *  @class  SFWizardModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SFWizardModel.h"
#import "ResponseConstants.h"

@implementation SFWizardModel

@synthesize localId;
@synthesize objectName;
@synthesize wizardId;
@synthesize expressionId;
@synthesize wizardDescription;
@synthesize wizardName;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

- (void)dealloc
{
    objectName = nil;
	wizardId = nil;
    expressionId = nil;
    wizardDescription = nil;
    wizardName = nil;
}

+ (NSDictionary *) getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:KwizardSourceObjName,@"objectName",kWizardSfId,@"wizardId",KwizardSubmodule,@"expressionId",kWizardSfId,@"wizardId",KwizardDescription,@"wizardDescription",KwizardName,@"wizardName", nil];
    
    return mapDictionary;
}

+ (NSDictionary *) getMappingDictionaryForWizardLayout {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:KwizardSourceObjName,@"objectName",kWizardDispatchProcessId,@"wizardId",KwizardSubmodule,@"expressionId",kWizardSfId,@"wizardId",KwizardDescription,@"wizardDescription",KwizardName,@"wizardName",kWizardLayoutRow,@"wizardLayoutColumn",kWizardlayoutColumn,@"wizardLayoutRow",nil];
    
    return mapDictionary;
}

@end