//
//  DocumentsDownloadManager.m
//  ServiceMaxiPad
//
//  Created by Anoop on 11/3/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "AttachmentsDownloadManager.h"
#import "AttachmentUtility.h"
#import "SMAppDelegate.h"
#import "AttachmentTXModel.h"
#import "AttachmentRequestBuilder.h"
#import "RequestConstants.h"
#import "TagManager.h"
#import "SNetworkReachabilityManager.h"

NSString * const kDocumentsDownloadKeyDocuments = @"Documents";
NSString * const kDocumentsDownloadKeyImagesVideos = @"ImagesVideos";
NSString * const kDocumentsDownloadKeyContentLength = @"ContentLength";
NSString * const kDocumentsDownloadKeyFileType = @"fileType";
NSString * const kDocumentsDownloadKeyFileId = @"fileId";
NSString * const kDocumentsDownloadKeyFileName = @"fileName";
NSString * const kDocumentsDownloadKeyFileExtension = @"fileExtension";
NSString * const kDocumentsDownloadKeyURL = @"URL";
NSString * const kDocumentsDownloadKeyStartTime = @"startTimeAttachmentsDownloadManager.h";
NSString * const kDocumentsDownloadKeyProgress = @"progress";
NSString * const kDocumentsDownloadKeyTask = @"downloadTask";
NSString * const kDocumentsDownloadKeyStatus = @"requestStatus";
NSString * const kDocumentsDownloadKeyDetails = @"downloadDetails";
NSString * const kDocumentsDownloadKeyResumeData = @"resumedata";
NSString * const kDocumentsDownloadKeyErrorCode  = @"ErrorCode";

NSString * const RequestStatusDownloading = @"RequestStatusDownloading";
NSString * const RequestStatusPaused = @"RequestStatusPaused";
NSString * const RequestStatusFailed = @"RequestStatusFailed";

static AttachmentsDownloadManager *attachmentDownloadManager = nil;

@interface AttachmentsDownloadManager () <NSURLSessionDelegate>

@end

@implementation AttachmentsDownloadManager
@synthesize downloadingDictionary,sessionManager;

#pragma mark -
#pragma mark - Initialization Methods

- (id)init {
    
    self = [super init];
    
    if (self != nil)
    {
        _imgDict = [AttachmentUtility imageTypesDict];
        _videoDict = [AttachmentUtility videoTypesDict];
        downloadingDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        sessionManager = [self backgroundSession];
        [self populateOtherDownloadTasks];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange) name:kNetworkConnectionChanged object:nil];
    }
    return self;
}

//TODO: Check for datasync
- (void)didInternetConnectionChange
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        [self resumeAllDownloads];
    }
    else
    {
        [self pauseAllDownloads];
    }
}

+ (AttachmentsDownloadManager *)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      if (attachmentDownloadManager == nil) {
                          attachmentDownloadManager = [[AttachmentsDownloadManager alloc] init];
                      }
                  }
                  );
    
    return attachmentDownloadManager;
}

#pragma mark - My Methods -

- (NSURLSession *)backgroundSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.servicemaxinc.DocumentsDownloadManager.SimpleBackgroundTransfer.BackgroundSession"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}

- (NSArray *)tasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)dataTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)uploadTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)downloadTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)tasksForKeyPath:(NSString *)keyPath
{
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [sessionManager getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return tasks;
}

- (void)addDocumentAttachmentForDownload:(AttachmentTXModel *)attachmentModel
{
    
   // NSURL *url = [NSURL URLWithString:@"http://www.mountainguides.com/photos/everest-south/c2_2011b.jpg"];
    AttachmentRequestBuilder *requestObj = [[AttachmentRequestBuilder alloc] initWithType:RequestTypeSFMAttachmentsDownload];
    NSURLRequest *attachmentDownloadRequest = [requestObj getRequestForAttachmentDownload:attachmentModel];
    NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:attachmentDownloadRequest];
    
    NSMutableDictionary *downloadInfo = [NSMutableDictionary dictionary];
    [downloadInfo setValue:attachmentDownloadRequest.URL.absoluteString forKey:kDocumentsDownloadKeyURL];
    [downloadInfo setValue:attachmentModel.localId forKey:kDocumentsDownloadKeyFileId];
    [downloadInfo setValue:attachmentModel.nameWithoutExtension forKey:kDocumentsDownloadKeyFileName];
    [downloadInfo setValue:attachmentModel.extensionName forKey:kDocumentsDownloadKeyFileExtension];
    [downloadInfo setValue:@(attachmentModel.bodyLength) forKey:kDocumentsDownloadKeyContentLength];
    
    NSString *videoExtension, *imageExtension;
    if ([attachmentModel.extensionName length]) {
        videoExtension = [self.videoDict objectForKey:attachmentModel.extensionName];
        imageExtension = [self.imgDict objectForKey:attachmentModel.extensionName];
    }
    
    if (![videoExtension length] && ![imageExtension length]) {
        [downloadInfo setValue:kDocumentsDownloadKeyDocuments forKey:kDocumentsDownloadKeyFileType];
    }
    else
    {
        [downloadInfo setValue:kDocumentsDownloadKeyImagesVideos forKey:kDocumentsDownloadKeyFileType];
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:downloadInfo options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [downloadTask setTaskDescription:jsonString];
    
    [downloadInfo setValue:[NSDate date] forKey:kDocumentsDownloadKeyStartTime];
    [downloadInfo setValue:RequestStatusDownloading forKey:kDocumentsDownloadKeyStatus];
    [downloadInfo setValue:downloadTask forKey:kDocumentsDownloadKeyTask];
    
    NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                 [AttachmentUtility calculateFileSizeInUnit:(unsigned long long)attachmentModel.bodyLength],
                                 [AttachmentUtility calculateUnit:(unsigned long long)attachmentModel.bodyLength]];
    
    NSMutableString *detailLabelText = [NSMutableString stringWithFormat:@"0 %@ of %@",
                                        [AttachmentUtility calculateUnit:(unsigned long long)attachmentModel.bodyLength],
                                        fileSizeInUnits
                                        ];
    [downloadInfo setValue:detailLabelText forKey:kDocumentsDownloadKeyDetails];
    [downloadingDictionary setValue:downloadInfo forKey:attachmentModel.localId];
    
    if (![videoExtension length] && ![imageExtension length]) {
        if([self.documentsDelegate respondsToSelector:@selector(documentDownloadRequestStarted:)])
            [self.documentsDelegate documentDownloadRequestStarted:downloadInfo];
    }
    else
    {
        if([self.imagesVideosDelegate respondsToSelector:@selector(imagesVideosDownloadRequestStarted:)])
            [self.imagesVideosDelegate imagesVideosDownloadRequestStarted:downloadInfo];
    }
    [downloadTask resume];
}

- (void)populateOtherDownloadTasks
{
    NSArray *downloadTasks = [self downloadTasks];
    
    for(int i=0; i < downloadTasks.count; i++)
    {
        NSURLSessionDownloadTask *downloadTask = [downloadTasks objectAtIndex:i];
        
        NSError *error = nil;
        
        NSData *taskDescription = [downloadTask.taskDescription dataUsingEncoding:NSUTF8StringEncoding];
        if (!taskDescription) {
            [downloadTask cancel];
            return;
        }
        NSMutableDictionary *downloadInfo = [[NSJSONSerialization JSONObjectWithData:taskDescription options:NSJSONReadingAllowFragments error:&error] mutableCopy];
        
        if(error)
        {
            SXLogError(@"Error while retreiving json value: %@", error);
        }
        
        [downloadInfo setValue:downloadTask forKey:kDocumentsDownloadKeyTask];
        [downloadInfo setValue:[NSDate date] forKey:kDocumentsDownloadKeyStartTime];
        
        NSURLSessionTaskState taskState = downloadTask.state;
        if(taskState == NSURLSessionTaskStateRunning)
            [downloadInfo setValue:RequestStatusDownloading forKey:kDocumentsDownloadKeyStatus];
        else if(taskState == NSURLSessionTaskStateSuspended)
            [downloadInfo setValue:RequestStatusPaused forKey:kDocumentsDownloadKeyStatus];
        else
            [downloadInfo setValue:RequestStatusFailed forKey:kDocumentsDownloadKeyStatus];
        
        if(!downloadInfo)
        {
            [downloadTask cancel];
        }
        else
        {
            [downloadingDictionary setValue:downloadInfo forKey:[AttachmentsDownloadManager attachmentIdFromDownloadInfo:downloadInfo]];
        }
    }
}

/**Post local notification when all download tasks are finished
 */
- (void)presentNotificationForDownload:(NSString *)fileName
{
    UIApplication *application = [UIApplication sharedApplication];
    UIApplicationState appCurrentState = [application applicationState];
    if(appCurrentState == UIApplicationStateBackground || UIApplicationStateActive)
    {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@: %@",[[TagManager sharedInstance]tagByName:kTag_AttachementDownloadComplete],fileName];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [application presentLocalNotificationNow:localNotification];
    }
}


#pragma mark - NSURLSession Delegates -

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    for(NSMutableDictionary *downloadDict in [downloadingDictionary allValues])
    {
        if([downloadTask isEqual:[downloadDict objectForKey:kDocumentsDownloadKeyTask]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                int64_t totalDownloadBytes = [[downloadDict valueForKey:kDocumentsDownloadKeyContentLength] intValue];
                
                float progress = (double)downloadTask.countOfBytesReceived/(double)totalDownloadBytes;
                
                NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                             [AttachmentUtility calculateFileSizeInUnit:(unsigned long long)totalDownloadBytes],
                                             [AttachmentUtility calculateUnit:(unsigned long long)totalDownloadBytes]];
                
                NSMutableString *detailLabelText = [NSMutableString stringWithFormat:@"%.2f %@ of %@",
                                                    [AttachmentUtility calculateFileSizeInUnit:(unsigned long long)totalBytesWritten],
                                                    [AttachmentUtility calculateUnit:(unsigned long long)totalBytesWritten],
                                                    fileSizeInUnits
                                                    ];
                
                
                [downloadDict setValue:[NSNumber numberWithFloat:progress] forKey:kDocumentsDownloadKeyProgress];
                [downloadDict setValue:detailLabelText forKey:kDocumentsDownloadKeyDetails];
                NSString *attachmentId = [downloadingDictionary valueForKey:kDocumentsDownloadKeyFileId];
                
                if ([attachmentId length]) {
                    [downloadingDictionary removeObjectForKey:attachmentId];
                    [downloadingDictionary setValue:downloadDict forKey:attachmentId];
                }
                
                if ([self isDocumentsFileType:downloadDict])
                {
                    if([self.documentsDelegate respondsToSelector:@selector(documentDownloadRequestProgress:)])
                        [self.documentsDelegate documentDownloadRequestProgress:downloadDict];
                }
                else
                {
                    if([self.imagesVideosDelegate respondsToSelector:@selector(imagesVideosDownloadRequestProgress:)])
                        [self.imagesVideosDelegate imagesVideosDownloadRequestProgress:downloadDict];
                }
                
            });
            break;
        }
    }
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    for(NSMutableDictionary *downloadInfo in [downloadingDictionary allValues])
    {
        if([[downloadInfo objectForKey:kDocumentsDownloadKeyTask] isEqual:downloadTask])
        {
            NSString *fileId = [downloadInfo objectForKey:kDocumentsDownloadKeyFileId];
            NSString *fileExtension = [downloadInfo objectForKey:kDocumentsDownloadKeyFileExtension];
            NSString *destinationPath = [[FileManager getAttachmentsSubDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",fileId,fileExtension]];
            NSURL *fileURL = [NSURL fileURLWithPath:destinationPath];
            SXLogInfo(@"directory Path = %@",destinationPath);
            
            if (location) {
                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&error];
                if (error) {
                    [AttachmentUtility showAlertViewWithTitle:[[TagManager sharedInstance]tagByName:kTag_AttachementDownloads] msg:error.localizedDescription];
                }
                else {
                   // [self presentNotificationForDownload:[downloadInfo objectForKey:kDocumentsDownloadKeyFileName]];
                }
            }
            
            break;
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSInteger errorReasonNum = [[error.userInfo objectForKey:@"NSURLErrorBackgroundTaskCancelledReasonKey"] integerValue];
    
    if([error.userInfo objectForKey:@"NSURLErrorBackgroundTaskCancelledReasonKey"] &&
       (errorReasonNum == NSURLErrorCancelledReasonUserForceQuitApplication ||
        errorReasonNum == NSURLErrorCancelledReasonBackgroundUpdatesDisabled))
    {
        NSString *taskInfo = task.taskDescription;
        
        NSError *error = nil;
        NSData *taskDescription = [taskInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *taskInfoDict = [[NSJSONSerialization JSONObjectWithData:taskDescription options:NSJSONReadingAllowFragments error:&error] mutableCopy];
        
        if(error)
        {
            SXLogError(@"Error while retreiving json value: %@",error);
        }
        
        NSString *fileURL = [taskInfoDict objectForKey:kDocumentsDownloadKeyURL];
        NSMutableDictionary *downloadInfo = [[NSMutableDictionary alloc] initWithDictionary:taskInfoDict ? taskInfoDict : @{}];
        
        NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        if(resumeData)
            task = [sessionManager downloadTaskWithResumeData:resumeData];
        else
            task = [sessionManager downloadTaskWithURL:[NSURL URLWithString:fileURL]];
        [task setTaskDescription:taskInfo];
        [downloadInfo setValue:task forKey:kDocumentsDownloadKeyTask];
        [downloadInfo setValue:[NSNumber numberWithInteger:AttachmentDownloadErrorUserForceQuit] forKey:kDocumentsDownloadKeyErrorCode];
        [task cancel];
        [downloadingDictionary removeObjectForKey:[AttachmentsDownloadManager attachmentIdFromDownloadInfo:downloadInfo]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self isDocumentsFileType:downloadInfo]) {
                if([self.documentsDelegate respondsToSelector:@selector(documentDownloadRequestCanceled:)])
                    [self.documentsDelegate documentDownloadRequestCanceled:downloadInfo];
                SXLogError(@"Documents download failed with info:%@",downloadInfo);
            }
            else
            {
                if([self.imagesVideosDelegate respondsToSelector:@selector(imagesVideosDownloadRequestCanceled:)])
                    [self.imagesVideosDelegate imagesVideosDownloadRequestCanceled:downloadInfo];
                SXLogError(@"images and videos download failed with info:%@",downloadInfo);
            }
        });
        return;
    }
    for(NSMutableDictionary *downloadInfo in [downloadingDictionary allValues])
    {
        if([[downloadInfo objectForKey:kDocumentsDownloadKeyTask] isEqual:task])
        {
            if(error)
            {
                if(error.code != NSURLErrorCancelled)
                {
                    NSString *taskInfo = task.taskDescription;
                    
                    NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
                    if(resumeData)
                        task = [sessionManager downloadTaskWithResumeData:resumeData];
                    else
                        task = [sessionManager downloadTaskWithURL:[NSURL URLWithString:[downloadInfo objectForKey:kDocumentsDownloadKeyURL]]];
                    [task setTaskDescription:taskInfo];
                    
                    [downloadInfo setValue:RequestStatusFailed forKey:kDocumentsDownloadKeyStatus];
                    [downloadInfo setValue:(NSURLSessionDownloadTask *)task forKey:kDocumentsDownloadKeyTask];
                    [downloadInfo setValue:[NSNumber numberWithInteger:error.code] forKey:kDocumentsDownloadKeyErrorCode];
                    [task cancel];
                    [downloadingDictionary removeObjectForKey:[AttachmentsDownloadManager attachmentIdFromDownloadInfo:downloadInfo]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{

                        if ([self isDocumentsFileType:downloadInfo]) {
                            if([self.documentsDelegate respondsToSelector:@selector(documentDownloadRequestCanceled:)])
                                [self.documentsDelegate documentDownloadRequestCanceled:downloadInfo];
                              SXLogError(@"Documents download cancelled with info:%@",downloadInfo);
                        }
                        else
                        {
                            if([self.imagesVideosDelegate respondsToSelector:@selector(imagesVideosDownloadRequestCanceled:)])
                                [self.imagesVideosDelegate imagesVideosDownloadRequestCanceled:downloadInfo];
                            SXLogError(@"Images and videos download failed with info:%@",downloadInfo);
                        }
                    });
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [downloadingDictionary removeObjectForKey:[AttachmentsDownloadManager attachmentIdFromDownloadInfo:downloadInfo]];
                    
                    if ([self isDocumentsFileType:downloadInfo]) {
                        if([self.documentsDelegate respondsToSelector:@selector(documentDownloadRequestFinished:)])
                            [self.documentsDelegate documentDownloadRequestFinished:downloadInfo];
                    }
                    else
                    {
                        if([self.imagesVideosDelegate respondsToSelector:@selector(imagesVideosDownloadRequestFinished:)])
                            [self.imagesVideosDelegate imagesVideosDownloadRequestFinished:downloadInfo];
                    }
                });
            }
            break;
        }
    }
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    SMAppDelegate *appDelegate = (SMAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    
    SXLogInfo(@"All tasks are finished");
}

#pragma mark - DocumentsDownloadingCell Delegate -

- (void)cancelDownloadWithId:(NSString*)attachmentId
{
    if (![attachmentId length]) {
        return;
    }
    NSMutableDictionary *downloadInfo = [downloadingDictionary objectForKey:attachmentId];
    [downloadInfo setValue:[NSNumber numberWithInteger:AttachmentDownloadErrorUserCancelled] forKey:kDocumentsDownloadKeyErrorCode];
    NSURLSessionDownloadTask *downloadTask = [downloadInfo objectForKey:kDocumentsDownloadKeyTask];
    [downloadTask cancel];
    [downloadingDictionary removeObjectForKey:attachmentId];
    
    if ([self isDocumentsFileType:downloadInfo]) {
        if([self.documentsDelegate respondsToSelector:@selector(documentDownloadRequestCanceled:)])
            [self.documentsDelegate documentDownloadRequestCanceled:downloadInfo];
    }
    else
    {
        if([self.imagesVideosDelegate respondsToSelector:@selector(imagesVideosDownloadRequestCanceled:)])
            [self.imagesVideosDelegate imagesVideosDownloadRequestCanceled:downloadInfo];
        
    }
}

- (void)pauseOrRetry:(NSString*)attachmentId
{
    if (![attachmentId length]) {
        return;
    }
    NSMutableDictionary *downloadInfo = [downloadingDictionary objectForKey:attachmentId];
    NSURLSessionDownloadTask *downloadTask = [downloadInfo objectForKey:kDocumentsDownloadKeyTask];
    NSString *downloadingStatus = [downloadInfo objectForKey:kDocumentsDownloadKeyStatus];
    
    if([downloadingStatus isEqualToString:RequestStatusDownloading])
    {
        [downloadTask suspend];
        [downloadInfo setValue:RequestStatusPaused forKey:kDocumentsDownloadKeyStatus];
        [downloadInfo setValue:[NSDate date] forKey:kDocumentsDownloadKeyStartTime];
        [downloadingDictionary removeObjectForKey:attachmentId];
        [downloadingDictionary setValue:downloadInfo forKey:attachmentId];
    }
    else if([downloadingStatus isEqualToString:RequestStatusPaused])
    {
        [downloadTask resume];
        [downloadInfo setValue:RequestStatusDownloading forKey:kDocumentsDownloadKeyStatus];
        [downloadingDictionary removeObjectForKey:attachmentId];
        [downloadingDictionary setValue:downloadInfo forKey:attachmentId];
    }
    else
    {
        [downloadTask resume];
        [downloadInfo setValue:RequestStatusDownloading forKey:kDocumentsDownloadKeyStatus];
        [downloadInfo setValue:[NSDate date] forKey:kDocumentsDownloadKeyStartTime];
        [downloadingDictionary removeObjectForKey:attachmentId];
        [downloadingDictionary setValue:downloadInfo forKey:attachmentId];
    }
}


- (BOOL)isDocumentsFileType:(NSMutableDictionary*)downloadDict {
    
    NSString *videoExtension, *imageExtension;
    NSString *extensionName = [downloadDict objectForKey:kDocumentsDownloadKeyFileExtension];
    if ([extensionName length]) {
        videoExtension = [self.videoDict objectForKey:extensionName];
        imageExtension = [self.imgDict objectForKey:extensionName];
    }
    
    return (![videoExtension length] && ![imageExtension length]);
}


+ (NSString*)attachmentIdFromDownloadInfo:(NSMutableDictionary*)downloadDict {
    
    NSString *fileId = [downloadDict objectForKey:kDocumentsDownloadKeyFileId];
    if ([fileId length]) {
        return fileId;
    }
    return @"Unknown";
}

#pragma DownloadTask control methods

- (void)pauseAllDownloads {
    
    @synchronized([self class]){
        NSArray *downloadTasks = [self downloadTasks];
        
        for(NSURLSessionDownloadTask *downloadTask in downloadTasks)
        {
            [downloadTask suspend];
        }
    }
}

- (void)resumeAllDownloads {
    
    @synchronized([self class]){
        
        NSArray *downloadTasks = [self downloadTasks];
        
        for(NSURLSessionDownloadTask *downloadTask in downloadTasks)
        {
            [downloadTask resume];
        }
    }
}

- (void)cancelAllDownloads {
    
    @synchronized([self class]){
        
        NSArray *downloadTasks = [self downloadTasks];
        
        for(NSURLSessionDownloadTask *downloadTask in downloadTasks)
        {
            [downloadTask cancel];
        }
    }
}

@end

