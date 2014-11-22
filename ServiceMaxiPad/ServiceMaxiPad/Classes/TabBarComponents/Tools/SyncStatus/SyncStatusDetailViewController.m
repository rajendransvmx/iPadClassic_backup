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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view from its nib.
    syncDataBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    syncDataBtn.layer.borderWidth = 0.8;

    syncDataBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
    syncConfigBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

    syncConfigBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    syncConfigBtn.layer.borderWidth = 0.8;
    
    [self registerForNotifications];
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
                                                   selector:@selector(syncStatusUpdated:)
                                                       name:kProfileValidationStatusNotification
                                                     object:[SyncManager sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                                   selector:@selector(receivedDataSyncStatusNotification:)
                                                       name:kDataSyncStatusNotification
                                                     object:[SyncManager sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                                   selector:@selector(receivedConfigSyncStatusNotification:)
                                                       name:kConfigSyncStatusNotification
                                                     object:[SyncManager sharedInstance]];
    
    //    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
    //                                             selector:@selector(updateSyncStatusAndTime)
    //                                                 name:kSyncTimeUpdateNotification
    //                                               object:[SyncManager sharedInstance]];
    
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
        [self showConfigSyncConfirmMessage];
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
            if ([PlistManager storedCheckBoxValueForDataSyncConfirmMessage] == 0)
            {
                [self showDataSyncConfirmMessage];
            }
            else
            {
                [self startDataSync];
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
    NSString *tittle   = @"Data Sync";
    NSString *message1 = @"Data Sync will retrieve the latest appointments, work orders and other information.";
    NSString *message2 = @"You can continue to use the ServiceMax app during data sync.";
   
    NSString *titleCancel = [[TagManager sharedInstance]tagByName:kTagCancelButton];
    NSString *otherButtonTittle = [[TagManager sharedInstance]tagByName:kTagStartSync];
    
    NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];
    NSDictionary *checkBoxDictionary = nil;
    
    BOOL val = YES;
    if ([PlistManager storedCheckBoxValueForDataSyncConfirmMessage] == 0)
    {
        val = NO;
    }
    
    NSString *checkBoxMessage = @"Got it. Don't show me this again.";
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
    NSString *title = @"Config Sync";
    NSString *message1 = @"Config Sync will update all business rules and configuration items. You will not be able to use the app during this process.";
    
    NSString *titleCancel = [[TagManager sharedInstance]tagByName:kTagCancelButton];
    NSString *otherButtonTittle = [[TagManager sharedInstance]tagByName:kTagStartSync];
    
    NSArray *messages = [NSArray arrayWithObjects:message1, nil];
    
    SMRegularAlertView *alertView = [[SMRegularAlertView alloc]initWithTitle:title
                                                                    delegate:self
                                                                    messages:messages
                                                                cancelButton:titleCancel
                                                                 otherButton:otherButtonTittle];
    self.regularAlertView = alertView;
    alertView = nil;
}


- (void)showValidatingProfileStatusMessage
{
    NSString *tittle   = @"Profile Validation in Progress";
    NSString *message1 = @"Please do not switch to another application or press the home button during this progress.";
    NSString *message2 = @"Doing so will cancel or interrupt profile validation.";
    
    NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];
    
    
    SMProgressAlertView *alertView  = [[SMProgressAlertView alloc] initWithTitle:tittle
                                                                        delegate:self
                                                                        messages:messages
                                                                    cancelButton:nil
                                                                     otherButton:nil];
    self.configSyncProgressAlertView = alertView;
    
    [self.configSyncProgressAlertView updateProgressBarWithValue:0.4
                                                      andMessage:@"Validating Profile"];
    alertView = nil;
}

- (void)showConfigSyncProgressStatusMessage
{
    NSString *title = @"Config Sync in Progress";
    
    NSString *message1 = @"Please do not switch to another application or press the home button while sync is in progress";
    NSString *message2 = @"Doing so will cancel or interrupt the synchronization.";
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
        [self showValidatingProfileStatusMessage];
        
        SyncManager *syncManager = [SyncManager sharedInstance];
        [syncManager performSyncWithType:SyncTypeValidateProfile];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateValidateProfileUI:)
                                                     name:kProfileValidationStatusNotification
                                                   object:syncManager];
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
    if (progressObject.syncStatus == SyncStatusSuccess)
    {
        NSLog(@"Validation profile Succeded");
        [self.configSyncProgressAlertView removeFromSuperview];
        
        [self showConfigSyncProgressStatusMessage];
        
        // Lets populate current db data for migration
        
        DatabaseConfigurationManager *configurationManager = [DatabaseConfigurationManager sharedInstance];
        [configurationManager resetDataMigration];
        [configurationManager populateDataForMigration];
        [configurationManager doPriorDatabaseConfigurationForMetaSync];
        
        SyncManager *manager = [SyncManager sharedInstance];
        [manager performSyncWithType:SyncTypeConfig];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(syncStatusUpdated:)
                                                     name:kConfigSyncStatusNotification
                                                   object:manager];
    }
    else
    {
        NSLog(@"Validation profile Failed");
        [self.configSyncProgressAlertView removeFromSuperview];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProfileValidationStatusNotification object:nil];
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
            [[SyncManager sharedInstance] scheduleSync];
        }
            
        case SyncStatusFailed:
        {
            [self.configSyncProgressAlertView removeFromSuperview];
            self.configSyncProgressAlertView = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfigSyncStatusNotification object:nil];
            [self updateConfigSyncRelatedUI];
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
        if([alertView.titleLabel.text isEqual:@"Config Sync"])
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
    
    configSyncNextSyncLabel.text = [[SyncManager sharedInstance] nextScheduledConfigSyncTime];;
    
}
#pragma mark - End
@end
