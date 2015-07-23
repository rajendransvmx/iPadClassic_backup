    //
//  PushNotificationManager.m
//  ServiceMaxiPad
//
//  Created by Sahana on 04/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "PushNotificationManager.h"
#import "ViewControllerFactory.h"
#import "PushNotificationUtility.h"
#import "PageEditViewController.h"
#import "SNetworkReachabilityManager.h"
#import "SFMPageViewController.h"
#import "SFMPageViewManager.h"
#import "PushNotificationHeaders.h"
#import "TagConstant.h"
#import "TagManager.h"
#import "StringUtil.h"
#import "SyncErrorConflictService.h"


#define PushNotificationProcessRequest     @"PushNotificationProcessRequest"
#define kUpdateEventNotification @"UpdateEventOnNotification"


@interface PushNotificationManager ()

@property (nonatomic, strong) PushNotificationQueue * notificationQueue;
@property (nonatomic) NotificationScreenState notificationScreenState;

@property (nonatomic, strong) PushNotificationWebServiceHelper *webServiceHelper;

@property (nonatomic, strong) NotificationTrackerVC *notificationViewController;
@property (nonatomic, strong) PushNotificationModel *finalModel;
@property (nonatomic) UserActionPresentedOn presentingViewControllerType;

@end


@implementation PushNotificationManager


+(instancetype)sharedInstance{
    
    static  id object = nil;
    
   static dispatch_once_t predicate;
   dispatch_once(&predicate, ^{
      
     object  = [[super alloc] initInstance];
   });
    return object;
}

-(instancetype)initInstance{
    
    self = [super init];
  
    if(self.notificationQueue == nil){
        self.notificationQueue = [[PushNotificationQueue alloc] init];
    }
    
    if(self.webServiceHelper == nil){
        self.webServiceHelper = [[PushNotificationWebServiceHelper alloc] init];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(externalFlowCompleted)
                                                 name:PushNotificationProcessRequest
                                               object:nil];
    return self;
}
- (void) showAlertFor:(AlertMessageStyle)messageStyle withCustomMessage:(NSString *)message{
    
    NSString *titleString = @"";
    NSString *messageString = message;
    switch (messageStyle) {
        case AlertMessageStyleInvalidPayload:
            titleString = [[TagManager sharedInstance]tagByName:kTag_ServiceMax];
            if (messageString == nil || messageString.length == 0) {
                messageString = [[TagManager sharedInstance]tagByName:kTag_InvalidNotification];
            }
            break;
        case AlertMessageStyleNoInternet:
            titleString = [[TagManager sharedInstance]tagByName:kTag_ServiceMax];
            if (messageString == nil || messageString.length == 0) {
            messageString = [[TagManager sharedInstance]tagByName:kTag_NetworkUnavailable];
            }
            break;
        case AlertMessageGeneral:
            titleString = [[TagManager sharedInstance]tagByName:kTag_ServiceMax];
            if (messageString == nil || messageString.length == 0) {
                messageString = [[TagManager sharedInstance]tagByName:kTag_RemoteAccessRevokedMsg];
            }
            break;
        case AlertMessageStyleConflictsFound:
            titleString = [[TagManager sharedInstance]tagByName:kTag_ServiceMax];
            if (messageString == nil || messageString.length == 0) {
                messageString = @"Please resolve conflicts to download the record.";
            }
            break;
            
        default:
            break;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString message:messageString delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil] ;
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    
}
-(void)loadNotification:(NSDictionary *)notificationDict{
    
    @synchronized([self class])
    {
        
        //will be checking the user org is valid or not
        PushNotificationModel *model  = [[PushNotificationModel alloc] initWithDictionary:notificationDict];

        //Commnet below 3 lines once we get real data from server
        //(model.sfId.length > 0)
        if(![StringUtil isStringEmpty:model.sfId])
             {
                 SyncErrorConflictService *conflictService = [[SyncErrorConflictService alloc]init];
                NSString *ObjectName = [PushNotificationUtility getObjectForSfId:model.sfId];
                 BOOL isConflictFound =   [conflictService isConflictFoundForObjectWithOutType:ObjectName withSfId:model.sfId];//
                 if (isConflictFound)//there is conflict
                 {
                     //SyncErrorConflictService
                     [self showAlertFor:AlertMessageStyleConflictsFound withCustomMessage:nil];

                     //show alert and dont start donwload
                 }
                 else
                 {
                     model.requestType = NotificationRequestTypeDownload;
                     [self addRequestToNotificationQueue:model];
                 }
                 
        }
        else {
            //ERROR
            
            BOOL processRequest = [[NotificationRuleManager sharedInstance] shouldprocessNotificationRequest];
            if(processRequest){
                [self showAlertFor:AlertMessageStyleInvalidPayload withCustomMessage:nil];
                
            }
        }
    }
}

-(void)addRequestToNotificationQueue:(PushNotificationModel *)model
{
    @synchronized([self class])
    {
        [self.notificationQueue addRequestToQueue:model];
        //process the queue
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (![[SNetworkReachabilityManager sharedInstance] isNetworkReachable]){
                
                 [self showAlertFor:AlertMessageStyleNoInternet withCustomMessage:nil];
            }
            [self processRequestQueue];
        });
    }
}

-( PushNotificationModel * )getNextRequestForPrevReq:(PushNotificationModel * )currentRequest{
    @synchronized([self class])
    {
        PushNotificationModel * model = [self.notificationQueue getNextRequestForCurrentRequest:currentRequest];
        return model;
    }
}

-( PushNotificationModel * )getNextRequestToBeDownloaded
{
    @synchronized([self class])
    {
        PushNotificationModel * model = [self.notificationQueue getNextRequestToBeDownloaded];
        return model;
    }
}

-(void)processRequestQueue
{
    @synchronized([self class])
    {
        
        BOOL processRequest = [[NotificationRuleManager sharedInstance] shouldprocessNotificationRequest];
        
        PushNotificationModel * nextReq = [self getNextRequestToBeDownloaded];
        
        if(processRequest && nextReq != nil){
            
            // if(processRequest && nextReq.requestType == NotificationRequestTypeDownload)
           /* if([self.notificationQueue shouldProcessTheNextRequest] || self.notificationScreenState != NotificationScreenStateUserAction)
            {
                 [self startDownloadRequest:nextReq];
            }*/
            
            if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]){
                
                if(self.notificationScreenState != NotificationScreenStateUserAction)
                {
                    [self startDownloadRequest:nextReq];
                }
            }
        }
        else
        {
            
        }
    }
}


-(void)startDownloadRequest:(PushNotificationModel *)notificationModel
{
    //check for queue Status whether to process with the next request
    @synchronized([self class])
    {
    
        if(self.notificationScreenState == NotificationScreenStateHidden){
           
            [self presentNotificationScreenWithRequest:notificationModel];
            
            [self makeWebServiceRequest:notificationModel];

        }
        else if (self.notificationScreenState == NotificationScreenStateVisible){
            //Notify the VC
        }
        
    }
    
}
-(void)makeWebServiceRequest:(PushNotificationModel *)notificationModel
{
    @synchronized([self class])
    {
        notificationModel.requestStatus = NotificationRequestStateDownloadStarted;
        [self.notificationViewController downloadProgressForNotification:notificationModel];
        
        
        [self.webServiceHelper startDownloadRequest:notificationModel];
    }
}


-(void)setNotificationScreenStatus:(NotificationScreenState)state{
    self.notificationScreenState = state;
}


-(void)presentNotificationScreenWithRequest:(PushNotificationModel * )currentRequest
{
    @synchronized([self class])
    {
        [self performSelectorOnMainThread:@selector(presentViewController) withObject:nil waitUntilDone:YES];
    }
    
}

-(void)presentViewController
{
    // Get rootView Controller
    // present Notification Screen on the Root View Controller
    if(self.notificationViewController == nil){
        self.notificationViewController = [ViewControllerFactory createViewControllerByContext:ViewControllerPushNotification];
    }
    
    UIViewController * rootViewController = [self geTopViewController];
    
    if([self isParentEditScreen:rootViewController])
    {
        [self setUserActionFor:UserActionPresentedOnEditScreen];
    }
    else
    {
        [self setUserActionFor:UserActionPresentedOnNonEditScreen];
    }
    self.notificationScreenState = NotificationScreenStateVisible;
    
    /*UIViewController *topVc = [self topViewControllerTest];
     NSArray * array = [topVc childViewControllers];
     
     for (UIViewController * vc  in array) {
     UIViewController * presented = [self topViewControllerWithRootViewController:vc];
     //NSLog(@"Popover presented");
     if(presented.modalPresentationStyle == UIModalPresentationPopover ){
     [presented dismissViewControllerAnimated:YES completion:^{
     
     }];
     break;
     
     }
     }*/
    
    
    //  [self topViewControllerWithRootViewController:<#(UIViewController *)#>]
    
    /*if ([topVc popoverPresentationController]) {
     //NSLog(@"Popover presented");
     [topVc dismissViewControllerAnimated:YES completion:^{
     
     }];
     }*/
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:POP_OVER_DISMISS object:nil];
    [rootViewController presentViewController: self.notificationViewController  animated:YES completion:^{
        
        //set the notification screen state as visible.
    }];
    

}

-(void)setUserActionFor:(UserActionPresentedOn)parent
{
    @synchronized([self class]){
        
        self.presentingViewControllerType = parent;
    }
}

-(BOOL)isParentEditScreen:(UIViewController *)controller
{
    @synchronized([self class])
    {
       return  [PushNotificationUtility isEditViewController:controller];
    }
    
}

-(UIViewController *)geTopViewController
{
    /*UIWindow * window = [[UIApplication sharedApplication]keyWindow];
    UIViewController * rootVc = [window rootViewController];*/
    @synchronized([self class])
    {
        UIViewController * topVc =  [PushNotificationUtility getTopViewController];
        return topVc;
    }
}
-(UIViewController *)getRootViewController
{
    @synchronized([self class])
    {
        UIViewController * rootVc = [PushNotificationUtility getRootViewController];
        return rootVc;
    }
}


-(ViewControllerType)getViewControllerTypeForViewController:(UIViewController *)viewController
{
    @synchronized([self class])
    {
        return [PushNotificationUtility getRootViewControllerType:viewController];
    }
}

-(UIViewController *)getCalendarViewController
{
    @synchronized([self class])
    {
        UIViewController * calendarVc =  [PushNotificationUtility getCalendarViewController];
        
        return calendarVc;
    }
}

-(void)removeViewControllersFromCalendarViewController:(UIViewController *)viewController
{
    @synchronized([self class])
    {
        [PushNotificationUtility removeViewControllersFromNavStack:viewController];
    }
}

-(void)deleteRequestsFromQueue:(NSArray *)requests{
    
    @synchronized([self class])
    {
        [self.notificationQueue removeRequestsFromQueue:requests];
    }
}

-(void)externalFlowCompleted{
    
    @synchronized([self class])
    {
        [self performSelectorOnMainThread:@selector(test) withObject:self waitUntilDone:NO];
       // [self processRequestQueue];
    }
}

-(void)test
{
    [self performSelector:@selector(processRequestQueue) withObject:nil afterDelay:1.5];

}

-(void)updateRequestState:(PushNotificationModel * )currentRequest
{
    
}

-(void)deleteCompletedRequestsFromQueue
{
    @synchronized([self class]){
        [self.notificationQueue removeAllDownloadCompletedRequests];
    }
}

#pragma  mark - WebService Related Methods
- (void)callUserActionForModel:(PushNotificationModel *)currentRequest {
    //check the queue status for last Download completed  and make it user action state
    //Dismiss the  progress View controller
    // present User Action for request
    
    //currentRequest.requestStatus = NotificationRequestStateUserAction;
    
    [self presentUserActionForRequest:currentRequest];
}

- (void)handleError:(NSError *)error {
    [self deleteCompletedRequestsFromQueue];
    NSString *message = nil;
    if (error) {
        message = [error.userInfo objectForKey:SMErrorUserMessageKey];
    }
    [self showAlertFor:AlertMessageGeneral withCustomMessage:message];
}

-(void)downloadStatusForRequest:(PushNotificationModel * )currentRequest withError:(NSError *)error {
    
    @synchronized([self class])
    {
        PushNotificationModel * nextRequest = [self getNextRequestToBeDownloaded];
        
        [self.notificationViewController downloadProgressForNotification:currentRequest];

        if(currentRequest.requestStatus == NotificationRequestStateDownloadInProgress)
        {
            // notify notification UI for refresh
           // [self.notificationViewController downloadProgressForNotification:currentRequest];
        }
        else if (currentRequest.requestStatus == NotificationRequestStateDownloadCompleted  )
        {
            
           // [self.notificationViewController downloadProgressForNotification:currentRequest];

            if(nextRequest == nil ){ // [self.notificationQueue shouldShowUserActionForRequest:currentRequest]
                
                if([currentRequest.objectName isEqualToString:kEventObject ] || [currentRequest.objectName isEqualToString:kSVMXTableName])
                {
                    [[NSNotificationCenter defaultCenter]postNotificationName:kUpdateEventNotification object:nil];
                    
                }
                [self callUserActionForModel:currentRequest];
                [self deleteCompletedRequestsFromQueue];

            }
            else
            {
                [self makeWebServiceRequest:nextRequest];
            }
            
            // notify notification UI for refresh
        }
        else if (currentRequest.requestStatus == NotificationRequestStateDownloadFailed || currentRequest.requestStatus == NotificationRequestStateNetworkNotReachable){
            
            if([self.notificationQueue checkForLastRequest:currentRequest])             //check for last request
            {
                // get the last succesfull request which has been downloaded and present user action
                PushNotificationModel * model = [self.notificationQueue getLastDownloadCompletedRequest];
               // if( model != nil &&[self.notificationQueue shouldShowUserActionForRequest:model])
                if( model != nil )
                {
                    //Dismiss the  progress View controller
                    [self callUserActionForModel:model];
                    [self deleteCompletedRequestsFromQueue];
                }
                else
                {
                    [self dismissNotificationViewController];

                    [self handleError:error];
                }
            }
            else if(nextRequest != nil)
            {
                [self makeWebServiceRequest:nextRequest];
            }
            else
            {
                [self dismissNotificationViewController];
                [self handleError:error];
            }
        }
        else if (currentRequest.requestStatus == NotificationRequestStateNetworkNotReachable){
            //Dismiss the  progress View controller
            [self deleteCompletedRequestsFromQueue];
            [self showAlertFor:AlertMessageStyleNoInternet withCustomMessage:error.description];
            [self dismissNotificationViewController];
        }
    }
}

-(void)dismissViewOnMainThread {
    
    [self.notificationViewController dismissViewControllerAnimated:YES completion:^{
    
    }];
    self.notificationViewController = nil;
}
-(void)dismissNotificationViewController
{
    @synchronized([self class])
    {
        self.notificationScreenState = NotificationScreenStateHidden;

        [self performSelectorOnMainThread:@selector(dismissViewOnMainThread) withObject:nil waitUntilDone:YES];
    }
}

-(void)presentUserActionForRequest:(PushNotificationModel *)notificationModel
{
    @synchronized([self class])
    {
        NSArray * options = nil;
        
        if([self isNotificationScreenPresentedOnEditViewController]){
            options = [[NSArray alloc] initWithObjects:[[TagManager sharedInstance]tagByName:kTag_SaveAndView],@"View",[[TagManager sharedInstance]tagByName:kTagCancelButton], nil];
        }
        else
        {
            options = [[NSArray alloc] initWithObjects:@"View",[[TagManager sharedInstance]tagByName:kTagCancelButton], nil];
        }
        
        self.notificationScreenState = NotificationScreenStateUserAction;
        
        [self.notificationViewController presentuserActionForRequest:notificationModel presentingMode:self.presentingViewControllerType];
    }
}


-(BOOL)isNotificationScreenPresentedOnEditViewController
{
    @synchronized([self class])
    {
//        UIViewController * parentViewController = [self geTopViewController];
//
//        BOOL editVc = [PushNotificationUtility isEditViewController:parentViewController];
        if(self.presentingViewControllerType == UserActionPresentedOnEditScreen){
            return YES;
        }

        return NO;
    }
}

-(void)onSelectionOfUserAction:(NotificationUserActionState)action forRequest:(PushNotificationModel *)model{
 
    @synchronized([self class])
    {
        self.notificationScreenState = NotificationScreenStateHidden;
        
        [self.notificationViewController dismissViewControllerAnimated:YES completion:^{
            
            if(action == NotificationUSerActionSaveAndView)
            {
                self.finalModel = model;
                //save sfm page
                //dismiss sfm page
                [self saveProcess];
            }
            else if (action == NotificationUserActionView){
                
                self.finalModel = model;
                [self presentViewProcessForFinalRequest];
            }
            else if (action == NotificationUserActionCancel){
                //dismiss Notification screen
                
                [self test];
            }
        }];
        
        self.notificationViewController = nil;
    }
}



-(id)getViewProcessForRequest:(PushNotificationModel *)reqModel
{
    return nil;
}

-(void)presentViewProcessForFinalRequest
{
    @synchronized([self class])
    {
        [self performSelectorOnMainThread:@selector(presentSFmPage) withObject:self waitUntilDone:YES];
    }
}

-(void)presentSFmPage
{
    if(self.finalModel == nil){
        return ;
    }
    
    BOOL viewProcessAvailable = YES;
    
    //HS Fix for defect - 017600
    //localId
    //NSString *ObjectName = [PushNotificationUtility getObjectForSfId:self.finalModel.sfId];
   // NSString *localId = [PushNotificationUtility getLocalIdForSfId:self.finalModel.sfId objectName:self.finalModel.objectName];
    
    
    if(self.finalModel.objectName == nil){
        self.finalModel.objectName = [PushNotificationUtility getObjectForSfId:self.finalModel.sfId];
    }
    
    NSString *localId = [PushNotificationUtility getLocalIdForSfId:self.finalModel.sfId objectName:self.finalModel.objectName];
    //Fix ends here

    if(localId == nil)
    {
        [self noViewProcessAvaibleAlert];
        return;
    }
    
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc] init];
    // SFMPageViewManager *pageManager = [[SFMPageViewManager alloc] initWithObjectName:@"SVMXC__Service_Order__c" recordId:@"97EBA23E-0862-442E-8F8E-83BB40670AF0"];
    
    SFMPageViewManager *pageManager = [[SFMPageViewManager alloc] initWithObjectName:self.finalModel.objectName recordId:localId];
    NSError *error = nil;
    viewProcessAvailable = [pageManager isValidProcess:pageManager.processId error:&error];
    
    //popToRootViewControllerAnimated
    if(viewProcessAvailable){
        UIViewController * rootVc = [self getRootViewController];
        ViewControllerType vcType =  [self getViewControllerTypeForViewController:rootVc];
        
        UIViewController * topviewController = [self topViewControllerTest];
        BOOL editView = [PushNotificationUtility isModallyPresented:topviewController];
        if(editView){
            [topviewController dismissViewControllerAnimated:NO completion:^{
            }];
        }
        
        
        if(vcType == CalendarViewController){
            //dismiss all view controllerts presented
            [self removeViewControllersFromCalendarViewController:rootVc];
        }
        else
        {
            
            
            [PushNotificationUtility selectCalendarViewController];
            UIViewController * calendarVc = [self getCalendarViewController]; //*****     //move to calendar view controller ****///
            [self removeViewControllersFromCalendarViewController:calendarVc];  //dismiss all view controllerts presented
        }
        
        UIViewController * calendarVc = [self getCalendarViewController];
        pageViewController.sfmPageView = [pageManager sfmPageView];
        [calendarVc.navigationController pushViewController:pageViewController animated:YES];
    }
    else
    {
        //show alert for no view process available
        [self noViewProcessAvaibleAlert];
    }

}


-(void)noViewProcessAvaibleAlert
{
    @synchronized([self class])
    {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTag_ServiceMax]message:[[TagManager sharedInstance]tagByName:kTag_NoViewLayoutForObject] delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}

-(BOOL)saveProcess
{
    @synchronized([self class])
    {
        UIViewController *viewController =  [self geTopViewController];
        
        if([viewController isKindOfClass:[PageEditViewController class]])
        {
            //iPad
            PageEditViewController * pageEdit = (PageEditViewController *)viewController;
           // [pageEdit saveFromPushNotification];
            if([pageEdit respondsToSelector:@selector(saveFromPushNotification)]){
                [pageEdit performSelectorOnMainThread:@selector(saveFromPushNotification) withObject:nil waitUntilDone:YES];
            }
        }
        return YES;
    }
}

-(void)onEditSaveCompletion:(NotificationEditSaveStatus)saveStatus
{
    @synchronized([self class])
    {
        if(saveStatus == NotificationEditSaveStatusSuccess){
        
            [self presentViewProcessForFinalRequest];
        }
        else if (saveStatus == NotificationEditSaveStatusFailure){
        }
    }
}

-(void)onEditSaveSuccess{
    @synchronized([self class])
    {
        [self presentViewProcessForFinalRequest];
        
    }
}


- (UIViewController*)topViewControllerTest {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}


#pragma End

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PushNotificationProcessRequest object:nil];
}

@end
