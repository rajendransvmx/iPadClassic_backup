//
//  SyncStatusDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 02/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SyncStatusDetailViewController.h"
#import "SyncManager.h"
#import "DateUtil.h"
#import "PlistManager.h"
#import "SNetworkReachabilityManager.h"
#import "AlertMessageHandler.h"
#import "PlistManager.h"
#import "DBRequestSelect.h"
#import "MobileDeviceSettingDAO.h"
#import "FactoryDAO.h"
#import "SyncProgressDetailModel.h"
#import "StringUtil.h"
#import "TagManager.h"
#import "DatabaseConfigurationManager.h"
#import "NonTagConstant.h"
#import "NSNotificationCenter+UniqueNotif.h"
#import "PlistManager.h"


#define kConfigSyncAlertTag     10
const NSInteger alertViewTagForConfigSync   = 888889;

@interface SyncStatusDetailViewController ()
{
    NSDictionary *settingsDict;
}

@property(nonatomic, strong) SMCheckBoxBindedAlertView *alertViewWithCheckBox;
@property(nonatomic, strong) SMRegularAlertView *regularAlertView;
@property(nonatomic, strong) SMProgressAlertView *configSyncProgressAlertView;

@end

@implementation SyncStatusDetailViewController

#pragma mark - ViewController Life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.smPopover dismissPopoverAnimated:YES];
    
    [self registerForNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view from its nib.
    configSyncTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_ConfigSyncStatus];
    
    dataSyncTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_DataSyncStatus];
    lastSyncStatusTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_lastsync];
    nextSyncStatusTitleLabel.text =[[TagManager sharedInstance]tagByName:kTag_nextsync];
    
    statusTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_status];
    
    lastSyncStatusTitleLabel_Config.text = [[TagManager sharedInstance]tagByName:kTag_lastsync];
    nextSyncStatusTitleLabel_Config.text = [[TagManager sharedInstance]tagByName:kTag_nextsync];
    statusTitleLabel_Config.text = [[TagManager sharedInstance]tagByName:kTag_status];
    [syncConfigBtn setTitle:[[TagManager sharedInstance]tagByName:kTag_SyncConfigNow] forState:UIControlStateNormal];
    
    [syncDataBtn setTitle:[[TagManager sharedInstance]tagByName:kTag_SyncDataNow] forState:UIControlStateNormal];
    
    syncDataBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    syncDataBtn.layer.borderWidth = 0.8;

    syncDataBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
    syncConfigBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    syncConfigBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    syncConfigBtn.layer.borderWidth = 0.8;
    
    [self updateDataSyncRelatedUI];
    [self updateConfigSyncRelatedUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForNotifications {
    
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                                   selector:@selector(receivedDataSyncStatusNotification:)
                                                       name:kDataSyncStatusNotification
                                                     object:[SyncManager sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                                   selector:@selector(updateSyncStatusAndTime)
                                                       name:kSyncTimeUpdateNotification
                                                     object:nil];
    
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                                   selector:@selector(startScheduledConfigSync)
                                                       name:kScheduledConfigSyncNotification
                                                     object:[SyncManager sharedInstance]];
}
#pragma mark - Button Actions

- (IBAction)syncConfigClicked:(id)sender
{
    if ([[SyncManager sharedInstance] isConfigSyncInProgress])
    {
        return;
    }
    
    [sender setTitleColor:[UIColor colorWithHexString:@"#FF6633"] forState:UIControlStateNormal];
    
    if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        if ([[AppManager sharedInstance] hasTokenRevoked])
        {
            [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired
                                                                   message:nil
                                                               andDelegate:self];
        }
        else
        {
            [self showConfigSyncConfirmMessage];
            
        }
    }
    else
    {
        [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInternetNotReachable];
    }
}

- (IBAction)syncDataClicked:(id)sender
{
    if ([[SyncManager sharedInstance] isDataSyncInProgress])
    {
        return;
    }
    else
    {
        [sender setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        
        if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            NSUInteger status;
            status = [PlistManager getStoredApplicationStatus];
            
            if ([[AppManager sharedInstance] hasTokenRevoked])
            {
                
                [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired message:nil andDelegate:nil];
            }
            else
            {
                if ([PlistManager storedCheckBoxValueForDataSyncConfirmMessage] == 0)
                {
                    [self showDataSyncConfirmMessage];
                }
                else
                {
                    [self startDataSync];
                }
            }
        }
        else
        {
            [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInternetNotReachable];
        }
    }
}

#pragma mark - Data Sync Status/Last Sync Time Update
- (void)receivedDataSyncStatusNotification:(NSNotification *)notification
{
    [self updateDataSyncRelatedUI];
}


#pragma mark - Config Sync Status/Last Sync Time Update
- (void)receivedConfigSyncStatusNotification:(NSNotification *)notification
{
    [self updateConfigSyncRelatedUI];
}


#pragma mark - Sync Confoirmation message

- (void)showDataSyncConfirmMessage
{
    NSString *tittle   = [[TagManager sharedInstance]tagByName:kTag_DataSync];
    NSString *message1 = [[TagManager sharedInstance]tagByName:kTag_DataSyncRetrieveApptmnt];
    NSString *message2 = [[TagManager sharedInstance]tagByName:kTag_YouCanContinueUseAppDuringDataSync];
   
    NSString *titleCancel = [[TagManager sharedInstance]tagByName:kTagCancelButton];
    NSString *otherButtonTittle = [[TagManager sharedInstance]tagByName:kTagStartSync];
    
    NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];
    NSDictionary *checkBoxDictionary = nil;
    
    BOOL val = YES;
    if ([PlistManager storedCheckBoxValueForDataSyncConfirmMessage] == 0)
    {
        val = NO;
    }
    
    NSString *checkBoxMessage = [[TagManager sharedInstance]tagByName:kTag_GotItDontShowAgain];
    checkBoxDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:val] ,checkBoxMessage, nil];
    
    SMCheckBoxBindedAlertView *alertView = [[SMCheckBoxBindedAlertView alloc] initWithTitle:tittle
                                                                                   delegate:self
                                                                                   messages:messages
                                                                           checkBoxMessages:checkBoxDictionary
                                                                               cancelButton:titleCancel
                                                                                otherButton:otherButtonTittle];
 
    self.alertViewWithCheckBox = alertView;
    alertView = nil;
}


- (void)showConfigSyncConfirmMessage
{
    NSString *title = [[TagManager sharedInstance]tagByName:kTag_ConfigSync];
    NSString *message1 = [[TagManager sharedInstance]tagByName:kTag_ConfigSyncUpdateBusinessRule];
    
    NSString *titleCancel = [[TagManager sharedInstance]tagByName:kTagCancelButton];
    NSString *otherButtonTittle = [[TagManager sharedInstance]tagByName:kTagStartSync];
    
    NSArray *messages = [NSArray arrayWithObjects:message1, nil];
    
    SMRegularAlertView *alertView = [[SMRegularAlertView alloc]initWithTitle:title
                                                                    delegate:self
                                                                    messages:messages
                                                                cancelButton:titleCancel
                                                                 otherButton:otherButtonTittle];
    alertView.tag = kConfigSyncAlertTag;
    self.regularAlertView = alertView;
    alertView = nil;
}


- (void)showValidatingProfileStatusMessage
{
    NSString *tittle   = [[TagManager sharedInstance]tagByName:kTag_ProfileValidationInProgress];
    
    NSString *message1 = [[TagManager sharedInstance]tagByName:kTag_PleaseDoNotSwitchApp];
   // NSString *message2 = [[TagManager sharedInstance]tagByName:kTag_DoingWillCancelProfileValidation];
    NSString *message2 = [[TagManager sharedInstance]tagByName:kTag_DoingWillCancelProfileValidation];

    
    NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];
    
    
    SMProgressAlertView *alertView  = [[SMProgressAlertView alloc] initWithTitle:tittle
                                                                        delegate:self
                                                                        messages:messages
                                                                    cancelButton:nil
                                                                     otherButton:nil];
    self.configSyncProgressAlertView = alertView;
    
    /* HS 6 DEc
    [self.configSyncProgressAlertView updateProgressBarWithValue:0.4
                                                      andMessage:[[TagManager sharedInstance]tagByName:kTag_ValidatingProfile]];
    HS 6 Dec */
    
    [self.configSyncProgressAlertView updateProgressBarWithValue:0.4
                                                      andMessage:[[TagManager sharedInstance]tagByName:kTag_ValidatingProfile]];
    alertView = nil;
}

- (void)showConfigSyncProgressStatusMessage
{
    NSString *title = [[TagManager sharedInstance]tagByName:kTag_ConfigSyncInProgress];
    
    NSString *message1 = [[TagManager sharedInstance]tagByName:kTag_PleaseDontSwitchAnotherApp];
    NSString *message2 = [[TagManager sharedInstance]tagByName:kTag_DoingSoCancelSync];
    NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];
    
    SMProgressAlertView *alertView = [[SMProgressAlertView alloc]initWithTitle:title
                                                                      delegate:self
                                                                      messages:messages
                                                                  cancelButton:nil
                                                                   otherButton:nil];
    self.configSyncProgressAlertView = alertView;
    [self.configSyncProgressAlertView updateProgressBarWithValue:0.001 andMessage:nil];
}


#pragma mark - Start Sync

- (void)startDataSync
{
    if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        [[SyncManager sharedInstance] performSyncWithType:SyncTypeData];
        [self updateDataSyncRelatedUI];
    }
    else
    {
        [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInternetNotReachable];
    }
}

- (void)startConfigSync
{
    if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        SyncManager *syncManager = [SyncManager sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(syncStatusUpdated:)
                                                     name:kProfileValidationStatusNotification
                                                   object:syncManager];
        [self showValidatingProfileStatusMessage];
        [syncManager performSyncWithType:SyncTypeValidateProfile];
    }
    else
    {
        [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInternetNotReachable];
    }
}


#pragma mark - Screen update

- (void)updateValidateProfileUI:(NSNotification*)aNotif
{
    id statusObject = [aNotif.userInfo objectForKey:@"syncstatus"];
    SyncProgressDetailModel *progressObject;
    if ([statusObject isKindOfClass:[SyncProgressDetailModel class]]) {
        progressObject = [aNotif.userInfo objectForKey:@"syncstatus"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProfileValidationStatusNotification object:nil];
    
     [self.configSyncProgressAlertView removeFromSuperview];
    
    if (progressObject.syncStatus == SyncStatusSuccess)
    {
        SXLogDebug(@"Validation profile Succeded");
        
        [self showConfigSyncProgressStatusMessage];
        
        SyncManager *manager = [SyncManager sharedInstance];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(syncStatusUpdated:)
                                                     name:kConfigSyncStatusNotification
                                                   object:manager];
        [manager performSyncWithType:SyncTypeConfig];
    }
    else
    {
        SXLogWarning(@"Validation profile Failed");
       
        [self updateConfigSyncRelatedUI];
    }
 }


- (void)syncStatusUpdated:(NSNotification*)aNotif
{
    if(aNotif.name == kConfigSyncStatusNotification)
    {
        SyncProgressDetailModel *object = [aNotif.userInfo objectForKey:@"syncstatus"];
        [self updateUserInterface:object];
    }
    
    if(aNotif.name == kProfileValidationStatusNotification)
    {
        [self updateValidateProfileUI:aNotif];
    }
}


- (void)updateUserInterface:(SyncProgressDetailModel*)progressObject
{
    NSString *message = nil;
    switch (progressObject.syncStatus)
    {
        case SyncStatusInProgress:
        {
            if (![StringUtil isStringEmpty:progressObject.message])
            {
                message = [NSString stringWithFormat:@"%@ %@ %@ %@ - %@",
                           [[TagManager sharedInstance]tagByName:kTagSyncProgressStep],
                           progressObject.currentStep,
                           [[TagManager sharedInstance]tagByName:kTagSyncProgressOf],
                           progressObject.numberOfSteps,
                           progressObject.message];
            }
            
            float progress = 1.0;
            
            if (![StringUtil isStringEmpty:progressObject.progress])
            {
                progress = [progressObject.progress floatValue];
            }
            
            if (message != nil)
            {
                [self.configSyncProgressAlertView updateProgressBarWithValue:progress/100.0f andMessage:message];
            }
        }
        break;
            
        case SyncStatusSuccess:
        {
            [self updatedOnConfigSyncFinished];
            [[AppManager sharedInstance] loadHomeScreen];// reload custom tab bar after config sync.
        }
        break;
        case SyncStatusFailed:
        {
            NSString *erroMsg = [progressObject.syncError errorEndUserMessage];
            [self handleConfigSyncFailure:erroMsg];
        }
        break;
            
        default:
            break;
    }
}


- (void)smAlertView:(SMAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView removeFromSuperview];
    self.alertViewWithCheckBox = nil;
    
    // Selected 'Data Sync' Option. Lets proceed it.
    if (buttonIndex != 0)
    {
        if(alertView.tag == kConfigSyncAlertTag)
        {
            [self startConfigSync];
        }
        else
        {
            [self startDataSync];
        }
    }
    //else meant; Cancelled the Sync option. Nothing to worry here.
}


- (void)checkBoxValueChanged:(BOOL)value forKey:(NSString*)key
{
    if (value)
    {
        [PlistManager storeDataSyncConfirmMessageCheckBoxValue:1];
    }
    else
    {
        [PlistManager storeDataSyncConfirmMessageCheckBoxValue:0];
    }
}

- (void)startScheduledConfigSync
{
    [self startConfigSync];
}


#pragma mark - Data sync and Config sync related methods
- (void)updateDataSyncRelatedUI
{
    /*
     * Updating Status
     */
    NSString *status = [PlistManager getLastDataSyncStatus];
    if (([status isEqualToString:kInProgress] | [status isEqualToString:kConflict]))
    {
        dataSyncStatusLabel.text = status;
        [dataSyncStatusLabel setTextColor:[UIColor colorWithHexString:@"#FF6633"]];
    }
    else
    {
        dataSyncStatusLabel.text = status;
        [dataSyncStatusLabel setTextColor:[UIColor colorWithRed:67.0f/255
                                                          green:67.0f/255
                                                           blue:67.0f/255
                                                          alpha:1.0]];
    }
    
    /*
     * Updating Last/Next Sync Time
     */
    dataSyncNextSyncLabel.text = [[SyncManager sharedInstance] nextScheduledDataSyncTime];;;
    
    NSString *dateString = [PlistManager getLastDataSyncGMTTime];
    if (dateString != nil)
    {
        dataSyncLastSyncLabel.text = [DateUtil getLiteralSupportedDateStringForDate:[DateUtil getDateFromDatabaseString:dateString]];
    }
}

- (void)updateConfigSyncRelatedUI
{
    
    /*
     * Updating Status
     */
    NSString *status     = [PlistManager getLastConfigSyncStatus];
    NSString *dateString = [PlistManager getLastConfigSyncGMTTime];
    
    if (![StringUtil isStringEmpty:status])
    {
        configSyncStatusLabel.text = status;
    }
    
    /*
     * Updating Last/Next Sync Time
     */
    if (![StringUtil isStringEmpty:dateString])
    {
        configSyncLastSyncLabel.text = [DateUtil getLiteralSupportedDateStringForDate:[DateUtil getDateFromDatabaseString:dateString]];
    }
    
    configSyncNextSyncLabel.text = [[SyncManager sharedInstance] nextScheduledConfigSyncTime];
    
}
#pragma mark - End



- (void)showConfigSyncAlertViewForMessage:(NSString *)message {
    NSString *retry =[ [TagManager sharedInstance]tagByName:kTagSyncProgressRetry] ;
    
    [[AlertMessageHandler sharedInstance] showCustomMessage:message
                                               withDelegate:self
                                                        tag:alertViewTagForConfigSync
                                                      title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                          cancelButtonTitle:retry
                                       andOtherButtonTitles:@[[[TagManager sharedInstance]tagByName:kTagSyncProgressIWillTry]]];
}



- (void)handleConfigSyncAlertViewCallBack:(UIAlertView *)alertView
                     clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            if (![[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
                
                [self showConfigSyncAlertViewForMessage:[[TagManager sharedInstance] tagByName:KTagAlertInrnetNotAvailableError]];
                return;
            }
            
            [self.configSyncProgressAlertView updateProgressBarWithValue:0 andMessage:[[TagManager sharedInstance]tagByName:kTag_Retrying]];
            
            SyncManager *manager = [SyncManager sharedInstance];
            [manager performSyncWithType:SyncTypeConfig];
        }
            break;
            
        case 1: {
            [self updatedOnConfigSyncFinished];
            [[SyncManager sharedInstance] enableAllParallelSync:YES];
            [[SyncManager sharedInstance] setSyncCompletionFlag];
        }
        default:
            break;
    }
}


-(void)handleConfigSyncFailure:(NSString *)errorMsg {
    [self updateConfigSyncRelatedUI];
    [self showConfigSyncAlertViewForMessage:errorMsg];
}


- (void)updateSyncStatusAndTime
{
    [self updateConfigSyncRelatedUI];
    [self updateDataSyncRelatedUI];
}

-(void)updatedOnConfigSyncFinished {
    [self.configSyncProgressAlertView removeFromSuperview];
    self.configSyncProgressAlertView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfigSyncStatusNotification object:nil];
    [self updateSyncStatusAndTime];
}

#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
            
        case alertViewTagForConfigSync:
        {
            [self handleConfigSyncAlertViewCallBack:alertView clickedButtonAtIndex:buttonIndex];
        }
            break;
           
        default:
            break;
    }
}


@end