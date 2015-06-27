//
//  SFMCustomActionWebServiceHelper.m
//  ServiceMaxiPad
//
//  Created by Apple on 22/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFMCustomActionWebServiceHelper.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "WebserviceResponseStatus.h"
#import "CacheManager.h"
#import "CacheConstants.h"

@implementation SFMCustomActionWebServiceHelper

static CustomActionWebserviceModel *customActionWebserviceModel;

-(id)initWithSFMPage:(SFMPage *)sfmPageModel
     wizardComponent:(WizardComponentModel*)wizardModel
{
    self = [super init];
    if (self)
    {
        self.sfmPage = sfmPageModel;
        self.wizardCompModel = wizardModel;
        CustomActionWebserviceModel *customActionWebserviceModel = [[CustomActionWebserviceModel alloc] init];
        customActionWebserviceModel.className = self.wizardCompModel.className;
        customActionWebserviceModel.methodName = self.wizardCompModel.methodName;
        customActionWebserviceModel.sfmPage = self.sfmPage;
        [[CacheManager sharedInstance] pushToCache:customActionWebserviceModel byKey:kCustomWebServiceAction];
    }
    return self;
}

-(void)initiateCustomWebServiceWithDelegate:(id)delegate
{
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeCustomWebServiceCall
                                             requestParam:nil
                                           callerDelegate:delegate];
    
    [[TaskManager sharedInstance] addTask:taskModel];
}


@end
