//
//  PushNotificationWebServiceHelper.m
//  ServiceMaxiPad
//
//  Created by Sahana on 06/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "PushNotificationWebServiceHelper.h"
#import "RequestParamModel.h"
#import "DODHelper.h"
#import "CacheManager.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "WebserviceResponseStatus.h"
#import "AlertMessageHandler.h"
#import "TagManager.h"

#import "ParserFactory.h"
#import "FlowDelegate.h"
#import "PushNotificationManager.h"
#import "SNetworkReachabilityManager.h"
#import "PushNotificationUtility.h"


#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface PushNotificationWebServiceHelper() <FlowDelegate>

@property (nonatomic, strong) NSMutableArray * requestsArray ;
@property (nonatomic,strong)NSMutableDictionary *notificationRequestDict;
@property (nonatomic,strong)PushNotificationModel *mNotificationModel;
@end


@implementation PushNotificationWebServiceHelper


-(void)startDownloadRequest:(PushNotificationModel *)notificationModel
{
 
    
    if ( IDIOM == IPAD ) {
        /* do something specifically for iPad. */
    }
    else {
        /* do something specifically for iPhone or iPod touch. */
    }
    
    if(notificationModel.objectName == nil){
      notificationModel.objectName = [PushNotificationUtility getObjectForSfId:notificationModel.sfId];
    }
    
    if( notificationModel.objectName == nil || notificationModel.sfId == nil){
        self.mNotificationModel.requestStatus = NotificationRequestStateDownloadFailed;
        [[PushNotificationManager sharedInstance] downloadStatusForRequest:self.mNotificationModel withError:nil];
        return;
    }
 
    [[CacheManager sharedInstance]  pushToCache:notificationModel.objectName byKey:@"searchObjectName"];
    [[CacheManager sharedInstance]  pushToCache:notificationModel.sfId byKey:@"searchSFID"];

    
    self.mNotificationModel = notificationModel;
    
    //check for reachability
    if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        self.mNotificationModel.requestStatus = NotificationRequestStateDownloadInProgress;
        [[PushNotificationManager sharedInstance]downloadStatusForRequest:self.mNotificationModel withError:nil];
        
//        RequestParamModel * requestParam = nil;
//        NSArray *requestParams = [self fetchRequestParametersForAPNSRequest:notificationModel];
//        if([requestParams count] > 0)
//        {
//            requestParam =  [requestParams objectAtIndex:0];
//        }
        
        TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeAPNSDOD
                                                 requestParam:nil
                                               callerDelegate:self];
        
        [[TaskManager sharedInstance] addTask:taskModel];
    }
    else
    {
        self.mNotificationModel.requestStatus = NotificationRequestStateNetworkNotReachable;
        [[PushNotificationManager sharedInstance] downloadStatusForRequest:self.mNotificationModel withError:nil];
    }
    
}

-(void)addNotificationRequest:(PushNotificationModel *)notificationModel
{
    if (self.notificationRequestDict == nil) {
        self.notificationRequestDict = [NSMutableDictionary new];
    }
    [self.notificationRequestDict setObject:notificationModel forKey:notificationModel.notificationId];
    
}

-(void)cancelAllDownloads
{
  
}


-(void)downloadCompletedForRequest:(PushNotificationModel *)notificationModel
{
    
    
}

-(void)notifyManagerDownloadStateForRequest:(PushNotificationModel *)notificationModel
{
    
    
}




#pragma mark - End
#pragma mark - Flow Delegate methods
- (void)flowStatus:(id)status {
    
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeAPNSDOD:
            {
                if  (st.syncStatus == SyncStatusSuccess)
                {
                    //[self downloadedSuccessfully];
//                    PushNotificationModel *notificationModel = [[PushNotificationModel alloc]init];
//                    notificationModel.requestStatus = NotificationRequestStateDownloadInProgress;
                    
                    self.mNotificationModel.requestStatus = NotificationRequestStateDownloadCompleted;

                }
                else if (st.syncStatus == SyncStatusFailed  || st.syncStatus ==  SyncStatusNetworkError)
                {
                    //[self downloadFailedWithError:st.syncError];
                    self.mNotificationModel.requestStatus = NotificationRequestStateDownloadFailed;
                }
                else
                {
                    self.mNotificationModel.requestStatus = NotificationRequestStateDownloadFailed;
                }
                
                break;
            }
            default:
                break;
        }
        [[PushNotificationManager sharedInstance]   downloadStatusForRequest:self.mNotificationModel withError:st.syncError];

    }
}


- (void)downloadedSuccessfully {
    
   
    
}

- (void)downloadFailedWithError:(NSError *)error {
    
    if (error) {
        [[AlertMessageHandler sharedInstance] showCustomMessage:[error errorEndUserMessage]
                                                   withDelegate:nil
                                                            tag:0
                                                          title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
        
    }
}

/*
 key = Object_Name
 value = Event
 valueMap
 key = Record_Id
 value = 00UF000000Ruqal
*/

- (NSArray *)fetchRequestParametersForAPNSRequest:(PushNotificationModel *)notificationModel
{
    NSArray *resultArray;
    
    
    NSString *objectName = notificationModel.objectName;
    NSString *recordId = notificationModel.sfId;
    
    
    NSMutableDictionary *valueMapForObject = [[NSMutableDictionary alloc]initWithCapacity:0];
    [valueMapForObject setObject:@"Object_Name" forKey:kSVMXKey];
    [valueMapForObject setObject:objectName forKey:kSVMXValue];
    
    
    
    NSMutableDictionary *valueMap_RecordId = [[NSMutableDictionary alloc]initWithCapacity:0];
    [valueMap_RecordId setObject:@"Record_Id" forKey:kSVMXKey];
    [valueMap_RecordId setObject:recordId forKey:kSVMXValue];
    
    
    NSArray *valueMapArray  = [NSArray arrayWithObjects:valueMap_RecordId,nil];
    [valueMapForObject setObject:valueMapArray forKey:kSVMXSVMXMap];
    
    
    RequestParamModel *reqParModel = [[RequestParamModel alloc]init];
    
    reqParModel.valueMap = @[valueMapForObject];
    
    resultArray = @[reqParModel];
    
    return resultArray;
}



@end
