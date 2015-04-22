//
//  OPDocFileUploader.m
//  ServiceMaxiPad
//
//  Created by Admin on 31/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "OPDocFileUploader.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "WebserviceResponseStatus.h"
#import "SyncManager.h"

@implementation OPDocFileUploader


+ (void)requestForUploadingOPDocFilewithTheCallerDelegate:(id)delegate;
{

    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeOpDoc
                                             requestParam:nil
                                           callerDelegate:delegate];
    
    [[TaskManager sharedInstance] addTask:taskModel];
}

+(void)requestForSubmittingHTMLAndSignatureDocumentwithTheCallerDelegate:(id)delegate
{


    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeSubmitDocument
                                             requestParam:nil
                                           callerDelegate:delegate];
    
    [[TaskManager sharedInstance] addTask:taskModel];
    
}

+(void)requestForGeneratingPDFwithTheCallerDelegate:(id)delegate
{


    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeGeneratePDF
                                             requestParam:nil
                                           callerDelegate:delegate];
    
   [[TaskManager sharedInstance] addTask:taskModel];
}

@end
