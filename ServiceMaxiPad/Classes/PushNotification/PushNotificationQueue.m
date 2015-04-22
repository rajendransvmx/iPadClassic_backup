//
//  NotificationQueue.m
//  ServiceMaxiPad
//
//  Created by Sahana on 04/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "PushNotificationQueue.h"





@interface PushNotificationQueue ()

@property (nonatomic, strong) NSMutableArray * queue;
@end


@implementation PushNotificationQueue


-(void)addRequestToQueue:(PushNotificationModel *)reqModel
{
    
    if(self.queue == nil){
        self.queue = [[NSMutableArray alloc] init];
    }
    [self.queue addObject:reqModel];
}

-(PushNotificationModel *)getNextRequestForCurrentRequest:(PushNotificationModel * )PreviousReq
{
    PushNotificationModel * nextReq = nil;
    
    NSUInteger index = 0;
    
    if( PreviousReq != nil && [self.queue containsObject:PreviousReq])
    {
        index = [self.queue indexOfObject:PreviousReq] + 1;
    }
    
    if( index < [self.queue count]){
      nextReq = [self.queue objectAtIndex:index];
    }
    
    return nextReq;
}

-(PushNotificationModel *)getNextRequestToBeDownloaded
{
    for (PushNotificationModel * model in self.queue) {
        if(model.requestStatus == NotificationRequestStateUnknown){
            return model;
        }
    }
    return nil;
}

-(void)removeReqFromQueue:(PushNotificationModel *)requestModel
{
    [self.queue removeObject:requestModel];
}

-(void)removeRequestsFromQueue:(NSArray *)requestsArray
{
    for (PushNotificationModel * model in requestsArray) {
        [self.queue removeObject:model];
    }
}

//-(PushNotificationQueueStatus)getQueueState;
//{
//    
//    for (PushNotificationModel * model in self.queue) {
//        
//        switch (model.requestStatus) {
//            case NotificationRequestStateUnknown:
//                break;
//            case NotificationRequestStateDownloadInProgress:
//                break;
//            case NotificationRequestStateDownloadStarted:
//                break;
//            case NotificationRequestStateDownloadCompleted:
//                break;
//            case NotificationRequestStateUserAction:
//              //  return PushNotificationQueueStatusPresentUserAction;
//                break;
//            default:
//                break;
//        }
//  
//    }
//    
//    //return PushNotificationQueueStatusDownloadNotStarted;
//}


-(BOOL)shouldProcessTheNextRequest
{
    for (PushNotificationModel * model in self.queue) {
        if(model.requestStatus == NotificationRequestStateUserAction){
            return NO;
        }
    }
    return YES;
}

-(BOOL)shouldShowUserActionForRequest:(PushNotificationModel *)notificationModel
{
    
    int requestStatusCounter = 0, requestTypeCounter = 0;
    for (PushNotificationModel * model in self.queue) {
        
        //Number of  requests of action type Doqnload   should be equal to NotificationRequestStateDownloadCompleted
        if(model.requestStatus == NotificationRequestStateDownloadCompleted  || model.requestStatus == NotificationRequestStateDownloadFailed ){
            
            requestStatusCounter++;
        }
        
        if(model.requestType == NotificationRequestTypeDownload){
            
            requestTypeCounter++;
        }
        
    }
    
    
    if(requestStatusCounter == requestTypeCounter){
        return YES;
    }
    return NO;
}

-(PushNotificationModel *)getLastDownloadCompletedRequest
{
    NSInteger counter = [self.queue count] - 1;
    
    for (NSInteger i = counter; i >=0 ; i--) {
        
        PushNotificationModel * model =  [self.queue objectAtIndex:i];
        if(model.requestStatus == NotificationRequestStateDownloadCompleted)
        {
            return model;
        }
    }
    
    return nil;
    
}

-(BOOL)checkForLastRequest:(PushNotificationModel *)currentReqModel;
{
    NSInteger counter = [self.queue count] - 1;
    
    NSInteger requestCounter = 0;
    for (NSInteger i = counter; i  >= 0 ; i--) {
        
        PushNotificationModel * model =  [self.queue objectAtIndex:i];
        if(model.requestType == NotificationRequestTypeDownload){
            if([model isEqual:currentReqModel])
            {
                requestCounter ++;
                break;
            }
        }
    }
    if(requestCounter == 1){
        return YES;
    }
    return NO;
}

-(void)removeAllDownloadCompletedRequests
{
    
    NSMutableArray * removedObjects = [NSMutableArray array];
    for (PushNotificationModel * model in self.queue) {
        if(model.requestStatus == NotificationRequestStateDownloadCompleted || model.requestStatus == NotificationRequestStateDownloadFailed || model.requestStatus == NotificationRequestStateNetworkNotReachable )
        {
            [removedObjects addObject:model];
        }
    }
    
    [self removeRequestsFromQueue:removedObjects];
}

@end
