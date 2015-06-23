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


@implementation SFMCustomActionWebServiceHelper
@synthesize className;
@synthesize methodName;
@synthesize objectName;
@synthesize objectFieldId;
@synthesize objectFieldname;

static WizardComponentModel *wizardCom;
static CustomActionWebserviceModel *customActionWebserviceModel;
- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //Initialization
        
    }
    return self;
}

-(void)addModelToTaskMaster{
    customActionWebserviceModel = [[CustomActionWebserviceModel alloc] init];
    customActionWebserviceModel.className=className;
    customActionWebserviceModel.methodName=methodName;
    customActionWebserviceModel.objectName=objectName;
    customActionWebserviceModel.ObjectFieldName=objectFieldname;
    customActionWebserviceModel.objectFieldId=objectFieldId;
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeCustomWebServiceCall
                                             requestParam:nil
                                           callerDelegate:self];
    
    [[TaskManager sharedInstance] addTask:taskModel];
}

#pragma mark FLOW DELEGATE
- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        if (st.syncStatus == SyncStatusSuccess) {
            
        }
        else if (st.syncStatus == SyncStatusFailed)
        {
            
        }
    }
}
+(void)setcustomActionWebserviceModel:(CustomActionWebserviceModel *)WizardComponentModel{
    customActionWebserviceModel=WizardComponentModel;
}
+(CustomActionWebserviceModel *)getCustomActionWebServiceHelper{
    return customActionWebserviceModel;
}


@end
