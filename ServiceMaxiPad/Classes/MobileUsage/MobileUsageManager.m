//
//  MobileUsageManager.m
//  ServiceMaxiPad
//
//  Created by Madhusudhan.HK on 6/27/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "MobileUsageManager.h"
#import "MobileUsageHelper.h"
#import "MobileUsageDataLoader.h"
#import "SNetworkReachabilityManager.h"
#import "AlertMessageHandler.h"
#import "FileManager.h"
#import "WebserviceResponseStatus.h"
#import "SyncManager.h"
#import "SNetworkReachabilityManager.h"
#import "MobileUsageDataModel.h"


@interface MobileUsageManager()
@end


@implementation MobileUsageManager

#pragma mark Singleton Methods

+ (instancetype) sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance
{
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    return self;
}


#pragma mark - End
#pragma mark - mobile usage process methods

- (void) startMobileUsageDataSyncProcess
{
    SXLogDebug(@"\n ======== :Mobile usgae: ======== \n At %@ check for JS file exists at local and procced ",self.class);
    
    
    BOOL isFileExists = [MobileUsageHelper isFileExistsAtPath:[FileManager getMobileUsageSubDirectoryPath]];
    
    if(isFileExists)
    {
        SXLogDebug(@"\n ======== :Mobile usgae: ======== \n At %@ initiate JS file execution",self.class);
        [self initiateJsFileExcecution];
        
    }else
    {
        SXLogDebug(@"\n ======== :Mobile usgae: ======== \n At %@ If file not exists then Downlad from server",self.class);
        [self  initiateJSFileDownloadFromServer];
    }
}

-(void) stopMobileUsageDataSyncProcess
{
    
    SXLogDebug(@"Mobile Usage process is stoped");
    
}


- (void) initiateJsFileExcecution
{
    SXLogDebug(@"\n ======== :Mobile usgae: ======== \n At %@ As of now we do not have JS file executer engin at client side, So ardcoded MobileUsageDataModel with sample values and sending ",self.class);
    [MobileUsageDataModel getMobileUageDetails];
    [self triggerMobileUsageWebservicesForCategoryType:CategoryTypeLocationPing];
    
}

- (void) initiateJSFileDownloadFromServer
{

    [self triggerMobileUsageWebservicesForCategoryType:CategoryTypeMobileUsageFileDownload];
    
}
- (void) triggerMobileUsageWebservicesForCategoryType:(CategoryType)type
{
    if (![[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        SXLogDebug(@"Location ping webservice not triggered as no connectivity.");
        return;
    }
    
    if ([[SyncManager sharedInstance] isConfigSyncInProgress] || [[SyncManager sharedInstance] isInitalSyncOrResetApplicationInProgress]) {
        SXLogDebug(@"Location ping webservice not triggered as meta/initial sync is in progress.");
        return;
    }
    
    if ([[AppManager sharedInstance] hasTokenRevoked]) {
        SXLogDebug(@"Location ping webservice not triggered as oauth token is revoked.");
        return;
    }
    
    if (self.isMobileUsageDataUploadRequestRunning) {
        SXLogDebug(@"Location ping webservice not triggered as already old location web service is in progress.");
        return;
    }
    
    switch (type) {
        case CategoryTypeMobileUsageFileDownload:
            /*
             * Initiating webserviceInBackground for JS file download.
             */
           [self performSelectorInBackground:@selector(makeRequestForJSFileDownload) withObject:self];
            break;
            
        case CategoryTypeLocationPing:
            /*
             * Initiating webserviceInBackground Mobile usage data upload.
             */
            [self performSelectorInBackground:@selector(initiateMobileUsageDataUploadInBackground:) withObject:self];
            break;
            
        default:
            break;
    }
    
}

- (void) makeRequestForJSFileDownload
{
    SXLogDebug(@"\n ======== :Mobile usgae: ======== \n At %@ Initiate Mobile Usage JS file download from server ",self.class);
    [MobileUsageDataLoader makingRequestForJSFileDownloadWithId:@"fileId" andCallerDelegate:self];
}

- (void)initiateMobileUsageDataUploadInBackground:(id)sender
{
    SXLogDebug(@"\n ======== :Mobile usgae: ======== \n At %@ Sending Mobile Usage data to server ",self.class);
    
    _isMobileUsageDataUploadRequestRunning = YES;
   
    [MobileUsageDataLoader makingRequestForMobileUsageDataUploadToServer:nil andCallerDelegate:self];
    
}
#pragma mark - End
#pragma mark -Flow node delegate method

- (void)flowStatus:(id)status
{
    
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *responseStatus = (WebserviceResponseStatus*)status;
        switch (responseStatus.category)
        {
            case CategoryTypeLocationPing:
                
                
                if  (responseStatus.syncStatus == SyncStatusSuccess)
                {
                    _isMobileUsageDataUploadRequestRunning = NO;
                    SXLogDebug(@"Mobile Usage data sent to server successfull");
                   
                }
                
                else if (responseStatus.syncStatus == SyncStatusFailed)
                {
                    _isMobileUsageDataUploadRequestRunning = NO;
                    SXLogDebug(@"Mobile usage web service failed.");
                    [self stopMobileUsageDataSyncProcess];
                    
                }
                break;
            case CategoryTypeMobileUsageFileDownload:
                
            {
                if  (responseStatus.syncStatus == SyncStatusSuccess)
                {
                    SXLogDebug(@"Mobile Usage JS file Downloaded successfull  ");
                    [self initiateJsFileExcecution];
                }
                
                else if (responseStatus.syncStatus == SyncStatusFailed)
                {
                    SXLogDebug(@"Failed to Download Mobile Usage JS file  ");
                    [self stopMobileUsageDataSyncProcess];
                }
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - End

@end
