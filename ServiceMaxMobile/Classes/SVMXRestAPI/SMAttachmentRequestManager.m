//
//  SMRestAPIManager.m
//  iService
//
//  Created by Vipindas on 11/17/13.
//
//

#import "SMAttachmentRequestManager.h"
#import "SMAttachmentModel.h"
#import "SMSalesForceRestAPI.h"
#import "AppDelegate.h"
#import "SVMXSystemUtility.h"
#import "SVMXSystemConstant.h"
#import "AttachmentDatabase.h"
#import "SMZKSHelper.h"
#import "AttachmentUtility.h"


static dispatch_once_t _sharedInstanceGuard;
static SMAttachmentRequestManager *_instance;

@interface SMAttachmentRequestManager()

- (NSString *)getRootFolderForSavingAttachments;
- (BOOL)saveAttachmentData:(SMRestRequest *)request inFileName:(NSString *)fileName;
- (BOOL)updateAttachmentRequestStatus:(ATTACHMENT_STATUS)status forRecordId:(NSString *)localId;
- (void)removeAttachmentFromTrailerTable:(NSString *)localId;

// Manage sync Notfication - Obser
- (void)registerForServiceMaxSyncNotification;
- (void)deregisterForServiceMaxSyncNotification;

- (void)completedActionService:(NSString *)localId;

- (void)cancelCurrentRequestSinceSyncInProgress;
- (void)restartUnfinishedRequest;


- (void)handleError:(NSError *)error forAttachmentId:(NSString *)attachmentId andActionType:(NSString *)actionType;
- (void)handleError:(NSError *)error forAttachmentId:(NSString *)attachmentId parentId:(NSString *)parentId andActionType:(NSString *)actionType;

- (void)replaceCancelledRequestObject;

@end

@implementation SMAttachmentRequestManager

@synthesize requestDictionary;
@synthesize requestQueue;
@synthesize processCurrentStatus;
@synthesize processNextStatus;
@synthesize currentActiveModel;
@synthesize hasScheduledJob;


- (id)init
{
    return [SMAttachmentRequestManager sharedInstance];
    
}

- (void)testMyQueue:(NSString *)context
{
    NSString *s = @"nil";
    
    if (nil!= currentActiveModel)
    {
        s  = [currentActiveModel description];
    }
    
//    NSLog(@"%@ [  cur:%d, next:%d, actmod - %@ ]   { %@ : %@ } \n",context, self.processCurrentStatus, self.processNextStatus, s, [self.requestQueue description], [self.requestDictionary description]);
}

- (id)initializeAttachmentRequestManager
{
    self = [super init];
    
    if (self)
    {
        self.requestDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        self.requestQueue      =  [NSMutableArray arrayWithCapacity:0];
        self.processNextStatus = ActionStatus_Completed;
        self.processCurrentStatus = ActionStatus_Completed;
        // Vipin - 9167
        self.hasScheduledJob = NO;
        [self registerForServiceMaxSyncNotification];
    }
    return self;

}

+ (SMAttachmentRequestManager *)sharedInstance
{
    dispatch_once(&_sharedInstanceGuard,
                  ^{
                      _instance = [[SMAttachmentRequestManager alloc] initializeAttachmentRequestManager];
                  });
    return _instance;
}


- (void)dealloc
{
    [self deregisterForServiceMaxSyncNotification];
    [super dealloc];
}

#pragma mark Request Queue Management
// Vipin - 9167
- (void)addToProcessQueue:(SMAttachmentModel *)model
{

    @synchronized([self class])
    {
        // Will be last entry in the Queue
        
        // localId
        if ([self.requestDictionary objectForKey:model.localId] != nil)
        {
            // Will be changing localid and entry to...
            if ([[self.currentActiveModel localId] isEqualToString:model.localId])
            {
                // Modify local Id
                self.currentActiveModel.localId = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                [self.requestDictionary setObject:self.currentActiveModel forKey:self.currentActiveModel.localId];
                
                // Add new entry Queue
                [self.requestDictionary setObject:model forKey:model.localId];
                [self.requestQueue insertObject:model atIndex:0];
            }
        }
        else
        {
            [self.requestDictionary setObject:model forKey:model.localId];
            [self.requestQueue insertObject:model atIndex:0];
        }
    }
}

- (void)removeFromProcessQueue:(SMAttachmentModel *)model
{
    @synchronized([self class])
    {
        [self.requestQueue removeObject:model];
        [self.requestDictionary removeObjectForKey:model.localId];
    }
}


#pragma mark Requst Cancellation Management

- (void)processCancelledRequest:(SMRestRequest *)request
{// Vipin - 9167

    if ([self.currentActiveModel.request isEqual:request])
    {
        NSString *localId = self.currentActiveModel.localId;
        [self completedActionService:localId];
    }
    else
    {
       // NSLog(@"Cancelleation : Current request not matching with activeRequest, Ohh it is bad :( ");
    }
}


- (void)replaceCancelledRequestObject
{
    
    self.currentActiveModel.request = nil;
    
    self.currentActiveModel.statusCode = ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE;
    
    SMSalesForceRestAPI  *sfRestApi =  [SMSalesForceRestAPI sharedInstance];
    
    SMRestRequest *restRequest = [sfRestApi requestForRetrieveBlobWithObjectType:@"Attachment"
                                                                        objectId:currentActiveModel.sfId
                                                                       fieldName:@"Body"];
    restRequest.parseResponse = NO;
    
    currentActiveModel.request = restRequest;
    
    [self.requestDictionary setObject:self.currentActiveModel forKey:self.currentActiveModel.localId];
    
    // Vipin - 9167
    SMAttachmentModel *model = [self.requestQueue lastObject];
    
    if (![model isEqual:currentActiveModel])
    {
        int index = [self.requestQueue count];
        
        if (index >  0)
        {
            index = index - 1;
        }
        
        [self.requestQueue  replaceObjectAtIndex:index withObject:self.currentActiveModel];
    }
}


- (BOOL)cancelAttachmentRequestByLocalId:(NSString *)localId
{
    BOOL hasCancelled = NO;
    // Vipin - 9167
    if (self.currentActiveModel != nil)
    {
        if ([[self.currentActiveModel localId] isEqualToString:localId])
        {
            // Request in progress
            if (self.currentActiveModel.request != nil)
            {
                self.processCurrentStatus = ActionStatus_Cancelled_By_User;
                self.processNextStatus    = ActionStatus_Cancelled_By_User;
                self.currentActiveModel.request.shouldCancel = YES;
                hasCancelled = YES;
            }
        }
    }
    
    if (! hasCancelled)
    {
        // Lets search in the RequestQueue
        if ((self.requestDictionary != nil) && ([self.requestDictionary count] > 0))
        {
            SMAttachmentModel *model = [self.requestDictionary objectForKey:localId];
            if (nil !=  model)
            {
                // Found it, removing safely
                if ( (self.requestQueue != nil) && ([self.requestQueue count] >0))
                {
                    // Vipin - 9167
                    
                    [self removeFromProcessQueue:model];
                    [self removeAttachmentFromTrailerTable:localId];
                }
                hasCancelled = YES;
            }
        }
    }
    
    return hasCancelled;
}


#pragma mark Uploading process

- (void)startUploadingAttachment:(SMAttachmentModel *)model
{
    
    NSDictionary * paramDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Attachment", kZKSObjectName,
                                model.localId, kZKSFieldLocalId,
                                model.fileName, kZKSFieldName,
                                model.parentSfId, kZKSFieldParentId,
                                model.encodeDataForUploading, kZKSFieldDataBlobBody,
                                model.isPrivate,  kZKSAttachmentFieldIsPrivate, nil];
    
    [[SMZKSHelper sharedInstance] createRecordWithParameters:paramDict
                                                    delegate:self
                                                 andSelector:@selector(uploadResponseResult:withError:andContext:)];
    
    [self updateAttachmentRequestStatus:model.statusCode
                            forRecordId:model.localId];
}

#pragma mark Process Queue Management

- (void)processQueue
{
    @synchronized(self)
    {
        if ((self.processCurrentStatus  == ActionStatus_Cancelled_By_Sync)
                 && (self.processNextStatus  == ActionStatus_Cancelled_By_Sync))
        {
            return;
        }
        
        [self testMyQueue:@"processQueue"];
        
        
        if ([self.requestQueue count] > 0)
        {
            SMAttachmentModel *firstEnteredModel = [self.requestQueue lastObject];
         
            self.currentActiveModel = [firstEnteredModel retain];
            
            if ([firstEnteredModel isDownload])
            {
                if (firstEnteredModel.statusCode == ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS )
                {
                    NSLog(@" ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS - I m going back ");
                    return;
                }
                else if (firstEnteredModel.statusCode == ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE ) 
                {
                    [self updateAttachmentRequestStatus:ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS
                                            forRecordId:firstEnteredModel.localId];
                     firstEnteredModel.statusCode = ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS;
                    
                    //Fix 009189: App is crashing when network connectivity goes down during downloading of multiple attachments
                    //Move the setting of firstEnteredModel before the web service call
                    [self.requestDictionary setObject:firstEnteredModel forKey:firstEnteredModel.localId];
                    
                    [[SMSalesForceRestAPI sharedInstance] sendRequest:[firstEnteredModel request]
                                                         withDelegate:self];
                    // Start Network Activity
                    [[SVMXSystemUtility sharedInstance] startNetworkActivity];
                    self.processNextStatus = ActionStatus_In_Memory;
                }
            }
            else if ([firstEnteredModel isUpload])
            {
                if (firstEnteredModel.statusCode == ATTACHMENT_STATUS_UPLOAD_IN_PROGRESS )
                {
                    return;
                }
                else if (firstEnteredModel.statusCode == ATTACHMENT_STATUS_UPLOAD_IN_QUEUE)
                {
                    firstEnteredModel.statusCode = ATTACHMENT_STATUS_UPLOAD_IN_PROGRESS;
                    
                    [self startUploadingAttachment:firstEnteredModel];
                
                    [self.requestDictionary setObject:firstEnteredModel forKey:firstEnteredModel.localId];
                    
                    // Start Network Activity
                    [[SVMXSystemUtility sharedInstance] startNetworkActivity];
                     self.processNextStatus = ActionStatus_In_Memory;
                }
            }
            else
            {
                    // Vipin - 9167
                [self removeFromProcessQueue:firstEnteredModel];
                [self processQueue];
            }
        }
        else
        {
            self.processCurrentStatus = ActionStatus_Completed;
            [self manageProcessStatus];
        }
    }
}

- (void)completedActionService:(NSString *)localId
{
    [self testMyQueue:@"completedActionService"];
    @synchronized(self)
    {
        // Stop Network Activity
        [[SVMXSystemUtility sharedInstance] stopNetworkActivity];
     
        if (nil != localId)
        {
            SMAttachmentModel *model = [self.requestDictionary objectForKey:localId];
            if (nil != model)
            {
                [self removeFromProcessQueue:model];
                self.currentActiveModel = nil;
            }
            [self removeAttachmentFromTrailerTable:localId];
        }
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self processQueue];
        });
    }
}


- (void)completedActionServiceForRequest:(SMRestRequest *)request
{
    @synchronized(self)
    {
        [self completedActionService:[self getLocalIdForRequest:request]];
    }
}

#pragma mark Downloading process

- (void)downloadAttachment:(NSString *)sfId  withFileName:(NSString *)fileName withSize:(NSString *)size andLocalId:(NSString *)localId
{
    @synchronized(self)
    {
        SMAttachmentModel *model = [[SMAttachmentModel alloc] initWithSFId:sfId
                                                               andFileName:fileName];
        model.localId = localId;
        model.statusCode = ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE;
        model.fileSize = [size intValue];
        model.actionType  = SMAttachmentActionTypeDownload;
        
        SMSalesForceRestAPI  *sfRestApi =  [SMSalesForceRestAPI sharedInstance];
        
        SMRestRequest *restRequest = [sfRestApi requestForRetrieveBlobWithObjectType:@"Attachment"
                                                                            objectId:sfId
                                                                           fieldName:@"Body"];
        restRequest.parseResponse = NO;
        
        model.request = restRequest;
        
        [self addToProcessQueue:model];
        
        [self processQueue];
        
        [model release];
    }
}



- (void)downloadAttachment:(NSDictionary *)params
{
    if ( ( nil == params) || ([params count] == 0) )
    {
        return;
    }
    
    [self downloadAttachment:[params objectForKey:kSMSfid]
                withFileName:[params objectForKey:kSMFileName]
                    withSize:[params objectForKey:kSMSize]
                  andLocalId:[params objectForKey:kSMLocalId]];
}


- (void)downloadAllAttachmentInQueue:(NSArray *)items
{
    if (( nil == items) || ([items count] == 0))
    {
        return;
    }
    
    for (SMAttachmentModel *model in items)
    {
        
        [self downloadAttachment:model.sfId
                    withFileName:model.fileName
                        withSize:[NSString stringWithFormat:@"%d", model.fileSize]
                      andLocalId:model.localId];
    }
}


- (void)uploadAttachment:(NSArray *)items
{
    if (( nil == items) || ([items count] == 0))
    {
        return;
    }
    
    for (SMAttachmentModel *model in items)
    {
        model.statusCode = ATTACHMENT_STATUS_UPLOAD_IN_QUEUE;
        model.actionType  = SMAttachmentActionTypeUpload;
        [self addToProcessQueue:model];
    }
    
    [self processQueue];
}


- (NSString *)getLocalIdForRequest:(SMRestRequest *)request
{
    if ((self.requestDictionary == nil) || ( [self.requestDictionary count] == 0) )
    {
        return nil;
    }

    NSArray *ids = [self.requestDictionary allKeys];
    
    NSString *localId = nil;
    
    for (NSString *idString in ids)
    {
        SMAttachmentModel * model = [requestDictionary objectForKey:idString];
         if (model != nil)
         {
               if ([request isEqual:model.request])
               {
                   localId = model.localId;
                   break;
               }
         }
    }
    return localId;
}


#pragma Mark Notification Generator

- (void)postNotificationForObject:(NSString *)localId status:(NSString *)status error:(NSError *)error progressMessage:(NSString *) errorMessage
{
    
    NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:localId,kNotificationId,
                                               status, kNotificationStatus, nil];

    if (error != nil)
    {
        [userInfoDictionary setObject:error forKey:kError];
    }

    if (errorMessage != nil)
    {
        [userInfoDictionary setObject:errorMessage forKey:kProgress];
    }

    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSM_REST_REQUEST_NOTIFICATION
                                                        object:self
                                                      userInfo:userInfoDictionary];
}


#pragma Mark -
#pragma mark SMRestRequestDelegate methods

- (void)request:(SMRestRequest *)request didLoadResponse:(id )response
{
    [response retain];
    
    // Call File to save here.
    NSString *localId = [self getLocalIdForRequest:request];
    SMAttachmentModel *model = [self.requestDictionary objectForKey:localId];
    BOOL hasFileSaved = [self saveAttachmentData:request inFileName:model.fileName];
    //check file exists

    if (hasFileSaved)
    {
        model.statusCode  = ATTACHMENT_STATUS_EXISTS;
        [self updateAttachmentRequestStatus:ATTACHMENT_STATUS_EXISTS
                                forRecordId:localId];
        
        [self postNotificationForObject:localId
                                 status:statusCompleted
                                  error:nil
                        progressMessage:nil];
    }
    else
    {
        
      NSError *error =  [NSError errorWithDomain:kSVMXRestAPIErrorDomain
                                            code:SMAttachmentRequestErrorCodeFileNotSaved
                                        userInfo:[NSDictionary
                                                  dictionaryWithObject:kFileNotSavedMsg forKey:@"ErrorMessage"]];
        
      [self handleError:error forAttachmentId:localId andActionType:kAttachmentActionTypeDownload];
        
        [self postNotificationForObject:localId
                                 status:statusFailure
                                  error:error
                        progressMessage:kFileNotSavedMsg];
        
    }
    
    [self completedActionServiceForRequest:request];
    
    [response release];
}


- (void)request:(SMRestRequest *)request didFailLoadWithError:(NSError *)error
{
    @synchronized([self class])
    {
        NSString *localId  = [self getLocalIdForRequest:request];
        NSString * filePath = [self getFilePath:request];
        [self removeFileAtIndexPath:filePath];
        [self removeFileAtIndexPath:request.tempFileName];

        
        
        [self handleError:error forAttachmentId:localId andActionType:kAttachmentActionTypeDownload];
        
        [self postNotificationForObject:localId
                                status:statusFailure
                                  error:error
                           progressMessage:nil];

        [self completedActionServiceForRequest:request];
    }
}


- (void)request:(SMRestRequest*)request
             didReceiveData:(NSInteger)bytesReceived
         totalBytesReceived:(NSInteger)totalBytesReceived
totalBytesExpectedToReceive:(NSInteger)totalBytesExpectedToReceive
{
    //NSLog(@"  didReceiveData --- %d ", totalBytesReceived/1024);
    NSString *localId =  [self getLocalIdForRequest:request];
    SMAttachmentModel *model = [self.requestDictionary objectForKey:localId];
    
    NSString *progressStatus = [NSString stringWithFormat:@"%d/%d",totalBytesReceived, model.fileSize];
    [self postNotificationForObject:localId
                            status:statusInProgress
                              error:nil
                       progressMessage:progressStatus];
}


- (void)requestDidCancelLoad:(SMRestRequest *)request
{
    NSString * filePath = [self getFilePath:request];
    [self removeFileAtIndexPath:filePath];
    [self removeFileAtIndexPath:request.tempFileName];
    
    if (self.processCurrentStatus == ActionStatus_Cancelled_By_User)
    {
        [self processCancelledRequest:request];
    }
    else if (self.processCurrentStatus == ActionStatus_Cancelled_By_Sync)
    {
        [self replaceCancelledRequestObject];
        [[SVMXSystemUtility sharedInstance] stopNetworkActivity];
    }
    else
    {
        [[SVMXSystemUtility sharedInstance] stopNetworkActivity];
        [self processQueue];
    }
}

- (NSString *)getFilePath:(SMRestRequest *)request;
{
    
    NSString *rootPath = [self getRootFolderForSavingAttachments];
    
    NSString *localId  = [self getLocalIdForRequest:request];
    SMAttachmentModel *model = [self.requestDictionary objectForKey:localId];

    NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",model.fileName]];

    return filePath;
}


- (NSString *)getTempFilePath:(SMRestRequest *)request;
{
   NSString * tempId = [AppDelegate GetUUID];
    
    NSString *rootPath = [self getRootFolderForSavingAttachments];
    
    NSString *localId  = [self getLocalIdForRequest:request];
    SMAttachmentModel *model = [self.requestDictionary objectForKey:localId];
    
   NSString * extension =  [AttachmentUtility fileExtension:model.fileName];
    
    NSString *tempFielName = [tempId stringByAppendingPathExtension:extension];
    request.tempFileName = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",tempFielName]];;
    
    return request.tempFileName;
}


-(void)copyFileFromTempPathForRequest:(SMRestRequest *)request
{
    
}


#pragma mark-
#pragma mark Saving downloaded file




- (BOOL)saveAttachmentData:(SMRestRequest *)request inFileName:(NSString *)fileName
{
    BOOL isSuccess = NO;
    NSString *rootPath = [self getRootFolderForSavingAttachments];
   
    if (rootPath == nil)
    {
        return isSuccess;
    }
    
    NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
  
    //copy from
    NSError * err;
    
    [[NSFileManager defaultManager] copyItemAtPath:request.tempFileName toPath:filePath error:&err];
    
    [self removeFileAtIndexPath:request.tempFileName];
    
    return isSuccess;
}




-(void)removeFileAtIndexPath:(NSString *)filePath
{
    

    NSLog(@"File PAth %@",filePath);
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if(error)
    {
        
    }

}

- (NSString *)getRootFolderForSavingAttachments
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isSuccess = YES;
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    rootPath = [rootPath stringByAppendingPathComponent:@"SVMXC"];
    rootPath = [rootPath stringByAppendingPathComponent:@"Attachments"];
    if (![fm fileExistsAtPath:rootPath]) {
        isSuccess = [fm createDirectoryAtPath:rootPath
                  withIntermediateDirectories:YES
                                   attributes:nil error:NULL];
    }
    if (!isSuccess) {
        return nil;
    }
    return rootPath;
}


- (BOOL)updateAttachmentRequestStatus:(ATTACHMENT_STATUS)status forRecordId:(NSString *)localId
{
    AppDelegate *delegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.dataBase updateStatusOfAttachmentId:localId andStatus:status];
    return YES;
}

- (void)removeAttachmentFromTrailerTable:(NSString *)localId
{
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    [appDelegate.attachmentDataBase deleteFromAttachmentTrailerTable:localId];
}


#pragma Mark  Manage sync Notification Observe

- (void)registerForServiceMaxSyncNotification
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelCurrentRequestSinceSyncInProgress)
                                                 name:kNotificationSyncStarted
                                               object:nil];
     /*********** Data Purge*************/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelCurrentRequestSinceSyncInProgress)
                                                 name:kNotificationDataPurgeStarted                                                             object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restartUnfinishedRequest)
                                                 name:kNotificationSyncCompleted
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restartUnfinishedRequest)
                                                 name:kNotificationDataPurgeCompleted
                                               object:nil];

}


- (void)deregisterForServiceMaxSyncNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationSyncStarted
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationSyncCompleted
                                                  object:nil];
     /*********** Data Purge *************/
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationDataPurgeStarted
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationDataPurgeCompleted
                                                  object:nil];
}

#pragma Mark Manage sync process

- (void)managePendingAtachmentByAction:(NSString *)action
{
    NSArray *array = [appDelegate.attachmentDataBase getUnfinishedAttachments:action];
    
    if ((array == nil) || ([array count]) == 0)
    {
        self.processCurrentStatus = ActionStatus_Completed;
        [self manageProcessStatus];
    }
    else if ([action isEqualToString:kAttachmentActionTypeUpload])
    {
         [self uploadAttachment:array];
    }
    else if ([action isEqualToString:kAttachmentActionTypeDownload])
    {
        [self downloadAllAttachmentInQueue:array];
    }
}


- (void)manageProcessByNextStatus:(ManagerProcessActionStatus)nextStatus
{
    /*
     1. Is next status Completed
     2. In memory process
     3. Now memory Next DB
     4. Restart Pending
     5. DB upload
     6. DB download
     */
    
    NSLog(@" manageProcessByNextStatus %d", nextStatus);

    switch (nextStatus)
    {
        case ActionStatus_In_Memory:
        {
            self.processCurrentStatus = ActionStatus_In_Memory;
            self.processNextStatus  = ActionStatus_Completed;
            [self processQueue];
        }
        break;
            
        case ActionStatus_Now_Memory_Next_DB:
        case ActionStatus_Restart_Pending_Items:
        {
            self.processCurrentStatus = ActionStatus_In_Memory;
            self.processNextStatus =  ActionStatus_DB_Upload;
            [self processQueue];
        }
        break;
            
        case ActionStatus_DB_Upload:
        {
            self.processCurrentStatus = ActionStatus_In_Memory;
            self.processNextStatus =  ActionStatus_DB_Download;
            [self managePendingAtachmentByAction:kAttachmentActionTypeUpload];
        }
        break;
            
        case ActionStatus_DB_Download:
        {
            self.processCurrentStatus = ActionStatus_In_Memory;
            self.processNextStatus    = ActionStatus_Completed;
            [self managePendingAtachmentByAction:kAttachmentActionTypeDownload];
        }
        break;
            
        case ActionStatus_Completed:
        {
            self.processCurrentStatus = ActionStatus_Completed;
        }
        break;
            
        default:
        {
            self.processNextStatus    = ActionStatus_Completed;
            [self processQueue];
        }
        break;
    }
    
}


- (void)manageProcessStatus
{
    [self testMyQueue:@"manageProcessStatus"];
    NSLog(@"manageProcessStatus  %d - %d", self.processCurrentStatus,  self.processNextStatus);
    
    if (self.processCurrentStatus  == ActionStatus_Completed)
    {
        if (self.processNextStatus  == ActionStatus_Completed)
        {
            // Woo We Completed
            // Vipin - 9167
        
            if (self.hasScheduledJob)
            {
                // It is good we are checking any pending job on my desk :)
                double delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                    [self restartAllPendingAttachmentRequest];
                });
            }
            
            self.hasScheduledJob = NO;
            
            
            return;
        }
        else
        {
            [self manageProcessByNextStatus:self.processNextStatus];
        }
    }
    else if (self.processCurrentStatus  == ActionStatus_Cancelled_By_User)
    {
        self.processCurrentStatus  = ActionStatus_Completed;
        self.processNextStatus     = ActionStatus_In_Memory;
        [self processQueue];
    }
    else if (self.processCurrentStatus  == ActionStatus_Cancelled_By_Sync)
    {
        if (self.processNextStatus  == ActionStatus_Now_Memory_Next_DB)
        {
            self.processCurrentStatus = ActionStatus_Completed;
            [self processQueue];
        }
    }
}


- (void)cancelCurrentRequestSinceSyncInProgress
{
    self.processCurrentStatus = ActionStatus_Cancelled_By_Sync;
    self.processNextStatus = ActionStatus_Cancelled_By_Sync;
    
    if ( self.currentActiveModel != nil && [self.currentActiveModel isDownload])
    {
        if (self.currentActiveModel.request != nil )
        {
            [self.currentActiveModel.request setShouldCancel:YES];
            
            self.currentActiveModel.statusCode = ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE;
            
            [self.requestDictionary setObject:self.currentActiveModel forKey:self.currentActiveModel.localId];
        }
    }
}


- (void)verifySyncStatusAndRestartUnfinishedRequest
{
    if  ((self.processCurrentStatus  == ActionStatus_Cancelled_By_Sync)
         && (self.processNextStatus  == ActionStatus_Now_Memory_Next_DB))
    {

        [self manageProcessStatus];
    }
    else
    { // Vipin - 9167
        self.hasScheduledJob = YES;
    }
}


- (void)restartUnfinishedRequest
{
    // Will wait for 12 seconds to avoid collision with other sync :D

    // 1. From Queue
    // 2. From Database - Upload
    // 3. From Database - Download

    self.hasScheduledJob = YES;
    
    if (self.processCurrentStatus == ActionStatus_Cancelled_By_Sync)
    {
    
        self.processCurrentStatus = ActionStatus_Cancelled_By_Sync;
        self.processNextStatus = ActionStatus_Now_Memory_Next_DB;

        double delayInSeconds = 12.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);

        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self verifySyncStatusAndRestartUnfinishedRequest];
        });
    }
}


- (void)uploadResponseResult:(NSArray *)result withError:(NSError *)error andContext:(NSString *)context
{
     NSString *parentId = nil;
     NSString *localId = nil;
    
    // In case of failure
    if (error != nil)
    {
       if  ([self.currentActiveModel.localId isEqualToString:context])
       {
           parentId = self.currentActiveModel.parentSfId;
       }
       
        if ([context length] > 3)
        {
            localId = context;
        }
        else
        {
            localId = self.currentActiveModel.localId;
        }
        
       [self handleError:error forAttachmentId:context parentId:parentId andActionType:kAttachmentActionTypeUpload];
    }
    else
    {
        
        // Assuming one attachment file uploading always.... so one result object
        
        ZKSaveResult * savedResult = (ZKSaveResult *) [result objectAtIndex:0];
        
        if ([context length] > 3)
        {
            localId = context;
        }
        else
        {
            localId = self.currentActiveModel.localId;
        }
        
        parentId = self.currentActiveModel.parentSfId;
    
        //NSLog(@" Rsult id - %@   \n code %@ \n message : %@", [savedResult id], [savedResult statusCode], [savedResult message]);
        
        if ([savedResult success])
        {
            // Recieved a Success message
            
           NSString *sfId = [savedResult id];
           if (nil != sfId)
           {
               // All success :)
               
                [appDelegate.attachmentDataBase updateAttachmentSfId:sfId
                                                           byLocalId:context];
           }else
           {
               // We are recieving bad SF ID
                NSDictionary *userInfo =  [NSDictionary dictionaryWithObject:@"Recieved Bad SalesForce Id" forKey:@"ErrorMessage"];
               
               NSError *error =  [NSError errorWithDomain:kSVMXRestAPIErrorDomain
                                                     code:SMAttachmentRequestErrorCodeDataCorruption
                                                 userInfo:userInfo];
               [self handleError:error
                 forAttachmentId:localId
                        parentId:parentId
                   andActionType:kAttachmentActionTypeUpload];
           }
        }
        else
        {
           // Ohhh there is failure on request.
           NSString *errorCode  = [savedResult statusCode];
           NSString *errorMessage  = ([savedResult message] != nil) ? [savedResult message] : @"";
            
           int code = SMAttachmentRequestErrorCodeUnknown;
           
           if ([errorCode isEqualToString:@"INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY"])
           {
               code = SMAttachmentRequestErrorCodeUnauthorizedAccess;
           }
           else if ([errorCode isEqualToString:@"REQUIRED_FIELD_MISSING"])
           {
               code = SMAttachmentRequestErrorCodeDataCorruption;
           }
            
           
            NSDictionary *userInfo =  [NSDictionary dictionaryWithObject:errorMessage forKey:@"ErrorMessage"];
          
            NSError *error =  [NSError errorWithDomain:kSVMXRestAPIErrorDomain
                                                  code:code
                                              userInfo:userInfo];
            
            [self handleError:error
              forAttachmentId:localId
                     parentId:parentId
                andActionType:kAttachmentActionTypeUpload];
            
        }
    }
    
    [self completedActionService:localId];
    
    // Delete record from Trailer table
    [appDelegate.attachmentDataBase deleteFromAttachmentTrailerTable:localId];
}

#pragma Mark Error Management

- (void)handleError:(NSError *)error forAttachmentId:(NSString *)attachmentId andActionType:(NSString *)actionType
{
    @synchronized([self class])
    {
         [self handleError:error
           forAttachmentId:attachmentId
                  parentId:nil
             andActionType:actionType];
    }
}


- (void)handleError:(NSError *)error
    forAttachmentId:(NSString *)attachmentId
           parentId:(NSString *)parentId
      andActionType:(NSString *)actionType
{
    @synchronized([self class])
    {
        NSInteger errorCode = [error code];
        NSDictionary *userInfo = [error userInfo];
        NSString *errorMsg = [userInfo objectForKey:@"ErrorMessage"];
        
        if (errorCode != SMAttachmentRequestErrorCodeCancelled)
        {
            NSMutableDictionary *someDictionary = [[NSMutableDictionary alloc] init];
            NSString *errorCodeStr = [NSString stringWithFormat:@"%d",errorCode];
            [someDictionary setObject:errorCodeStr forKey:kErrorCode];
            
            if (errorMsg != nil)
            {
                [someDictionary setObject:errorCodeStr forKey:kErrorMsg];
            }
            
            [someDictionary setObject:attachmentId forKey:kAttachmentTrailerId];
            [someDictionary setObject:actionType forKey:kActon];
            
            if (nil != parentId)
            {
                [someDictionary setObject:parentId forKey:kParentId];
            }
            
            [appDelegate.attachmentDataBase insertIntoAttachmentErrorTable:someDictionary];
            [someDictionary release];
            someDictionary = nil;
            
        }
    }
}


- (void)restartAllPendingAttachmentRequest
{
    if ((self.processNextStatus == ActionStatus_Completed)
        || (self.processCurrentStatus == ActionStatus_Completed))
    {
        self.processNextStatus = ActionStatus_Restart_Pending_Items;
    }
    else
    {
        self.hasScheduledJob = YES; // Vipin - 9167
    }
    
    [self manageProcessStatus];
}

// Fix For Defect 9219
-(void)cancelRequestForIds:(NSArray *)idList
{
    @synchronized([self class])
    {
        for(NSString * attachmentId in idList)
        {
           SMAttachmentModel * model =[self.requestDictionary objectForKey:attachmentId];
            if(model != nil)
            {
                if ((model.statusCode == ATTACHMENT_STATUS_UPLOAD_IN_QUEUE)
                   || (model.statusCode == ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE))
                {
                    [self.requestQueue removeObject:model];
                    [self.requestDictionary removeObjectForKey:attachmentId];
                }
            }
        }
    }
}
@end
