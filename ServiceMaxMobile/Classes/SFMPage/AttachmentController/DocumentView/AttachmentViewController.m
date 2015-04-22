//
//  AttachmentViewController.m
//  ServiceMaxMobile
//
//  Created by Shravya shridhar on 11/17/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "AttachmentViewController.h"
#import "AppDelegate.h"
#import "SMAttachmentRequestManager.h"
#import "AttachmentUtility.h"
#import "AttachmentDatabase.h"

#define kSM_REST_REQUEST_NOTIFICATION @"SMRestRequestAttachmentNotififcation"
#define kNotificationStatus @"status"
#define kNotificationId     @"id"
#define kErrorObject        @"error"
#define kErrorMessage       @"errorMessage"
#define kProgress           @"progress"





@interface AttachmentViewController ()

@end

@implementation AttachmentViewController
@synthesize attachmentProgressBarsDictionary;
@synthesize selectAttachmentForCancel;

- (void)dealloc {
     [self removeAttachmentDownloadObserver];
    [attachmentProgressBarsDictionary release];
    [selectAttachmentForCancel release];
    [super dealloc];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Adding entity to progressbar dictionary

- (void)addProgressBar:(UIProgressView *)progressBar ForId:(NSString *)attachmentId {
    
    @synchronized([self class]){
        
        if ([attachmentId length] > 0) {
            if (attachmentProgressBarsDictionary == Nil) {
                NSMutableDictionary *someDictionary = [[NSMutableDictionary alloc] init];
                self.attachmentProgressBarsDictionary = someDictionary;
                [someDictionary release];
                someDictionary = nil;
            }
            if (progressBar != nil) {
                [attachmentProgressBarsDictionary setObject:progressBar forKey:attachmentId];
            }
        }
    }
}

- (void)updateProgressBarWithValue:(CGFloat)value forId:(NSString *)attachmentId {
    
    @synchronized([self class]){
        if (attachmentId != nil) {
            UIProgressView *progressView = [attachmentProgressBarsDictionary objectForKey:attachmentId];
            if (progressView !=  nil) {
                 progressView.progress = value;
            }
        }
    }
}

- (void)removeProgressbarForId:(NSString *)attachmentId {
     @synchronized([self class]){
         UIProgressView *progressView = [attachmentProgressBarsDictionary objectForKey:attachmentId];
         if (progressView !=  nil) {
             [progressView removeFromSuperview];
             [attachmentProgressBarsDictionary removeObjectForKey:attachmentId];
         }
     }
}

#pragma mark -
#pragma mark Adding observer to notification
- (void)addAttachmentDownloadObserver {
     @synchronized([self class]){
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAttachmentDownloadNotification:) name:kSM_REST_REQUEST_NOTIFICATION object:nil];

     }
}
- (void)removeAttachmentDownloadObserver {
     @synchronized([self class]){
         [[NSNotificationCenter defaultCenter] removeObserver:self name:kSM_REST_REQUEST_NOTIFICATION object:nil];

     }
}

- (void)addDataSyncObserver {
    @synchronized([self class]){
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleIncrementalDataSyncNotification:) name:kIncrementalDataSyncDone object:nil];
        
    }
}
- (void)removeDataSyncObserver {
    @synchronized([self class]){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kIncrementalDataSyncDone object:nil];
        
    }
}


#pragma - Handling notification
- (void)handleAttachmentDownloadNotification:(NSNotification *)notification{
     @synchronized([self class]){
         
         if ([[notification name] isEqualToString:kSM_REST_REQUEST_NOTIFICATION]) {
        
             NSDictionary *userInfo = [notification userInfo];
             NSString *attachmentId = [userInfo objectForKey:kNotificationId];
             if (attachmentId == nil) {
                 return;
             }
             
             NSString *status = [userInfo objectForKey:kNotificationStatus];
             if ([status isEqualToString:statusCompleted]) {
                 [self downloadCompleteForId:attachmentId];
             }
             else  if ([status isEqualToString:statusFailure]) {
                 NSError *error = [userInfo objectForKey:kErrorObject];
                 [self downloadFailedForId:attachmentId withError:error];
             }
             else  if ([status isEqualToString:statusInProgress]) {
                 NSString *progressString = [userInfo objectForKey:kProgress];
                
                 CGFloat progress = [self getProgress:progressString];
                  NSLog(@"__________________%@_______%@ -- %f _________",attachmentId,progressString,progress);
                [self updateStatusProgress:progress forId:attachmentId];
                
             }

         }
     }
}

- (void)handleIncrementalDataSyncNotification:(NSNotification *)notification{
    
    NSLog(@"handleIncrementalDataSyncNotification");
};


#pragma mark - Downlaod status hanlders

- (void)updateStatusProgress:(CGFloat)progress forId:(NSString *)attachmentId {
 
    /*Need to write a function */
    [self updateProgressBarWithValue:progress forId:attachmentId];
}

- (void)downloadCompleteForId:(NSString *)attachmentId {
     [self updateProgressBarWithValue:1.0 forId:attachmentId];
}

- (void)downloadFailedForId:(NSString *)attachmentId withError:(NSError *)error {
  // [self handleError:error forAttachmentId:attachmentId];
}

#pragma mark-Alerts
- (void)showInternetnotAvailableAlert:(NSString *)title {
    
    UIAlertView *syncAlert = [[UIAlertView alloc] initWithTitle:title message:[appDelegate.wsInterface.tagsDictionary valueForKey:ALERT_INTERNET_NOT_AVAILABLE] delegate:nil cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary valueForKey:ALERT_ERROR_OK]  otherButtonTitles:nil, nil];
    
    [syncAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    [syncAlert release];
}

#pragma mark -
#pragma mark - Adding the clearing function
- (void)cleanUpBeforeUnload {
    [self removeAttachmentDownloadObserver];
}


#pragma mark - Download document
- (void)downloadAttachment:(NSDictionary *)attachment {
    @synchronized([self class]){
        NSString *attachmentId = [attachment  objectForKey:K_ATTACHMENT_ID];
        NSString *name = [attachment  objectForKey:K_NAME];
        if (attachmentId != nil) {
            
          
            if (![appDelegate isInternetConnectionAvailable]) {
                [self showInternetnotAvailableAlert:name];
                return;
            }
           
            UIProgressView *progressView = [self createProgressBar];
            [self addProgressBar:progressView ForId:attachmentId];
            
            /*Send ids for downloading */
            NSString *sfid = [attachment objectForKey:@"Id"];
            if (sfid == nil) {
                /*Check in db*/
                sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:@"Attachment" local_id:attachmentId];
                
            }
            if (sfid.length > 0) {
                NSString *pathExtension =  [name pathExtension];
                if (pathExtension == nil) {
                    pathExtension=@"";
                }
                NSString *fileName = [NSString stringWithFormat:@"%@.%@",attachmentId,pathExtension];
                NSString *size = [appDelegate.attachmentDataBase getSizeForAttachmentId:attachmentId];
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:attachment];
                if (size != nil) {
                    [dictionary setObject:size forKey:K_SIZE];
                }
                
                [AttachmentUtility insertIntoAttachmentTrailerForDownload:dictionary forFileName:fileName];
                [dictionary release];
                dictionary = nil;
                
                [[SMAttachmentRequestManager sharedInstance] downloadAttachment:sfid withFileName:fileName withSize:size andLocalId:attachmentId];
            }
        }
    }
    
}

- (float)getProgress:(NSString *)progressString {
    NSArray *components = [progressString componentsSeparatedByString:@"/"];
    float progress = 0.0;
    float numberOfBytes = 0.0,totalNumberOfBytes = 0.0;
    if ([components count] > 0) {
        numberOfBytes = [[components objectAtIndex:0] floatValue];
    }
    
    if ([components count] > 1) {
        totalNumberOfBytes = [[components objectAtIndex:1] floatValue];
    }
    if (totalNumberOfBytes > 1 && numberOfBytes > 1) {
        progress = numberOfBytes/totalNumberOfBytes;
    }
    return progress;
}

- (UIProgressView *)createProgressBar{
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(50, 20+7, 80, 20);
    progressView.progress= 0.0;
    progressView.trackTintColor = [UIColor colorWithRed:36.0/255 green:36.0/255 blue:36.0/255 alpha:1.0];
    return [progressView autorelease];
}

#pragma mark - Download Cancelling methods
- (void)cancelDownloadForAttachment:(NSDictionary *)attachmentDict {
    @synchronized([self class]){
        [attachmentDict retain];
        NSString *attachmentId = [attachmentDict objectForKey:K_ATTACHMENT_ID];
        if (attachmentId.length > 0) {
            
            /*Cross check with Vipin what happens if I send the request to cancel on finished  record. Do i need to check the status again */
            /*send request to cancel the download to request manager*/
            
            BOOL isCancelled = [[SMAttachmentRequestManager sharedInstance] cancelAttachmentRequestByLocalId:attachmentId];

            if (!isCancelled) {
                [attachmentDict release];
                return;
            }
            [self removeProgressbarForId:attachmentId];
            
            /*remove the entry from attachment trailer table and reload the view*/
            [AttachmentUtility deleteFromAttachmentTrailerForDownload:attachmentId];
            if ([NSThread isMainThread]) {
                [self reloadViewData];
            }
            else{
                [self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
            }
        }
        [attachmentDict release];
    }
}

/*This function needs to be overridden*/
- (void)reloadViewData {
    
}


#pragma mark - Cancellation alert
- (void)showAlertForCancelConfirmationAlert:(NSString *)title andMessage:(NSString *)message {
    
    AppDelegate *appDelegate=(AppDelegate*) [[UIApplication sharedApplication] delegate];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_YES] otherButtonTitles:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_NO] , nil];
    alertView.tag = DOWNLOAD_CANCEL_ALERT;
    [alertView show];
    [alertView release];
}


#pragma mark - Handling error and error code
/*
- (void)handleError:(NSError *)error forAttachmentId:(NSString *)attachmentId {
    
    @synchronized([self class]){
        NSInteger errorCode = [error code];
        NSDictionary *userInfo = [error userInfo];
        NSString *errorMsg = [userInfo objectForKey:@"ErrorMessage"];
        if (errorCode != SMAttachmentRequestErrorCodeCancelled) {
        
            NSMutableDictionary *someDictionary = [[NSMutableDictionary alloc] init];
            NSString *errorCodeStr = [NSString stringWithFormat:@"%d",errorCode];
            [someDictionary setObject:errorCodeStr forKey:kErrorCode];
        
            if (errorMsg != nil) {
                [someDictionary setObject:errorCodeStr forKey:kErrorMsg];
            }
            [someDictionary setObject:attachmentId forKey:kAttachmentTrailerId];
            [someDictionary setObject:@"DOWNLOAD" forKey:kActon];
        
            [appDelegate.attachmentDataBase insertIntoAttachmentErrorTable:someDictionary];
            [someDictionary release];
            someDictionary = nil;
        
        }
    }
}
 */

#pragma mark - Attachment Sharing
//Attachment Sharing //Defect 11338
- (void) deleteDuplicateAttachmentsCreated:(NSArray *)fielnames
{
    @autoreleasepool
    {
        for (NSString * name in fielnames)
        {
            BOOL success =[AttachmentUtility deleteDuplicateFileCreated:name];
            SMLog(kLogLevelVerbose, @"Duplicate file deleted %@ , success = %d",name, success);
        }
    }
    
}

- (void)createDuplicateAttachmentFile:(NSMutableDictionary *)attachmentDict;
{
    if (attachmentDict != nil && [attachmentDict count] > 0)
    {
        NSArray * allKeys = [attachmentDict allKeys];
        
        @autoreleasepool
        {
            for (NSString * localId in allKeys)
            {
                @autoreleasepool {
                    NSString * attachmentName = [attachmentDict objectForKey:localId];
                    
                    NSData * data =  [AttachmentUtility getEncodedDataForExistingFile:localId attachmentName:attachmentName];
                    if (data != nil)
                    {
                        BOOL success = [AttachmentUtility saveDuplicateAttachmentData:data inFileName:attachmentName];
                        SMLog(kLogLevelVerbose, @"Duplicate file created = %@ Success = %d", attachmentName, success);
                    }

                }
            }
        }
    }
}

- (NSMutableArray *)getAttachemntUrlsForSharing:(NSArray *)attachmentFiles;
{
    NSMutableArray * urlArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool
    {
        for (NSString * fileName in attachmentFiles)
        {
            NSURL * url = [AttachmentUtility getUrlForFilename:fileName];
            
            if (url != nil)
            {
                [urlArray addObject:url];
            }
        }
    }
    return [urlArray autorelease];
}
#pragma mark - END
@end
