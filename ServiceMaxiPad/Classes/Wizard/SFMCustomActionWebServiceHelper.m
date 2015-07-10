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
#import "SFMPageEditManager.h"
#import "StringUtil.h"

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
        
        /* This model contents required information for making web-service Body, We are storing into [CacheManager sharedInstance], later removing after completion */
        CustomActionWebserviceModel *customActionWebserviceModel = [[CustomActionWebserviceModel alloc] init];
        customActionWebserviceModel.className = self.wizardCompModel.className;
        customActionWebserviceModel.methodName = self.wizardCompModel.methodName;
        customActionWebserviceModel.sfmPage = self.sfmPage;
        customActionWebserviceModel.processId = self.wizardCompModel.processId;
        [[CacheManager sharedInstance] pushToCache:customActionWebserviceModel byKey:kCustomWebServiceAction];
    }
    return self;
}

-(void)initiateCustomWebServiceWithDelegate:(id)delegate
{
    /* Adding category name for Webservice call, based on category we are making requestType */
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeCustomWebServiceCall
                                             requestParam:nil
                                           callerDelegate:delegate];
    
    [[TaskManager sharedInstance] addTask:taskModel];
}

-(void)initiateCustomWebServiceForAfterBeforeWithDelegate:(id)delegate
{
    /* Adding category name for Webservice call, based on category we are making requestType */
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeCustomWebServiceAfterBeforeCall
                                             requestParam:nil
                                           callerDelegate:delegate];
    
    [[TaskManager sharedInstance] addTask:taskModel];
}

-(id)initWithSFMPageRequestData:(NSString *)requestData requestType:(int)requestType
{
    
    // requestType: 1-After Insert, 2-Before Update, 3-After Update
    SFMPage *lSFMPage =  [self getTheSFMPage:requestData];
    NSString *theClassNameMethodName = nil;
    if (lSFMPage) {
        theClassNameMethodName = [self theURL:lSFMPage.process.pageLayout.headerLayout.pageLevelEvents andRequestType:requestType];

    }
    
    NSString *headerId = [lSFMPage getHeaderSalesForceId];

    if (!theClassNameMethodName || !theClassNameMethodName.length || !headerId || headerId.length!=18) {
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        self.sfmPage = lSFMPage;

        CustomActionWebserviceModel *customActionWebserviceModel = [[CustomActionWebserviceModel alloc] init];
        customActionWebserviceModel.className = theClassNameMethodName;
        customActionWebserviceModel.methodName = @"";
        customActionWebserviceModel.processId = nil;
        customActionWebserviceModel.sfmPage = self.sfmPage;
        [[CacheManager sharedInstance] pushToCache:customActionWebserviceModel byKey:kCustomWebServiceAction];
    }
    return self;
}

-(SFMPage *)getTheSFMPage:(NSString *)requestParameters
{
    NSArray *requestArray = [requestParameters componentsSeparatedByString:@","];
    
    if(requestArray.count==3)
    {
        SFMPageEditManager *manager = [[SFMPageEditManager alloc] initWithObjectName:[requestArray objectAtIndex:0] recordId:[requestArray objectAtIndex:1] processSFId:[requestArray objectAtIndex:2]];
    
        SFMPage *page = [manager theSFMPagewithObjectName:[requestArray objectAtIndex:0] andRecordID:[requestArray objectAtIndex:1]  andProcessID:[requestArray objectAtIndex:2]];
        return page;
    }
    
    return nil;
}

-(NSString *)theURL:(NSArray *)thePageLevelEvent andRequestType:(int)requestType
{
    
    NSString *theURL = nil;
    for (NSDictionary *tempDict in thePageLevelEvent) {
        NSString *eventCallType = [tempDict objectForKey:kPageEventCallType];
        NSString *eventType = [tempDict objectForKey:kPageEventType];
        
        if ([eventCallType isEqualToString:@"WEBSERVICE"]) {

            if ([StringUtil containsString:kAfterSaveInsertKey inString:eventType] && requestType==1) {
                theURL = [tempDict objectForKey:kPageTargetCall];
            }
            else if ([StringUtil containsString:kBeforeSaveProcessKey inString:eventType] && requestType==2) {
                theURL = [tempDict objectForKey:kPageTargetCall];

            }
            else if ([StringUtil containsString:kAfterSaveProcessKey inString:eventType] && requestType==3) {
                theURL = [tempDict objectForKey:kPageTargetCall];

            }

        }
    }
    
    return theURL;
}

@end
