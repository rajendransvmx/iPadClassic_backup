//
//  BaseSFWizardComponent.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   WizardComponentModel.m
 *  @class  WizardComponentModel
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

#import "WizardComponentModel.h"
#import "ResponseConstants.h"

@implementation WizardComponentModel 

@synthesize localId;
@synthesize wizardId;
@synthesize actionDescription;
@synthesize expressionId;
@synthesize processId;
@synthesize actionType;
@synthesize performSync;
@synthesize className;
@synthesize methodName;
@synthesize wizardStepId;
@synthesize sequence;
@synthesize wizardComponentId;
@synthesize actionName;

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
    wizardId = nil;
    actionDescription = nil;
    expressionId = nil;
    processId = nil;
    actionType = nil;
    performSync = nil;
    className = nil;
    methodName = nil;
    wizardStepId = nil;
    wizardComponentId = nil;
    actionName = nil;
}

+ (NSDictionary *)getMappingDictionary
{
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kWizardCompModule,@"wizardId",kWizardCompId,@"wizardComponentId",kWizardCompDescription,@"actionDescription",kWizardCompSubModule,@"expressionId",kWizardCompProcess,@"processId",kWizardCompActionType,@"actionType",kWizardCompSequence,@"sequence",kWizardCompName,@"actionName",nil];
    
    return mapDictionary;
}

@end