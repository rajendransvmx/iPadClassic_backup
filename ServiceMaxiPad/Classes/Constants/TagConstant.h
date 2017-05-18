//
// TagConstant.h
// ServiceMaxMobile
//
// Created by Shubha S on 14/05/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//


/**
 *  @file   TagConstant.h
 *  @class  TagConstant
 *
 *  @brief
 *
 *   This is a class which holds all the tag constants
 *
 *  @author Shubha S
 *  @bug    No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>

//@interface TagConstant : NSObject

//Tags List

extern NSString *const kTagResetApplication;
extern NSString *const kSfmDataBaseName;

extern NSString *const kTagEditEvent;
extern NSString *const kTagEventOverlap;
extern NSString *const kTagOpportunityAcount;

//Home page
extern NSString *const kTagMap;
extern NSString *const kTagHomeMapText;
extern NSString *const kTagHomeTask;
extern NSString *const kTagExplore;
extern NSString *const kTagNewItem;
extern NSString *const kTagRecentlyCreated;
extern NSString *const kTagHomeHelp;
extern NSString *const kTagRecents;
extern NSString *const kTagRecentsText;
extern NSString *const kTagHomeHelpText;
extern NSString *const kTagHomeNoEvents;
extern NSString *const kTagHomeCalendar;
extern NSString *const kTagHomeTaskText;
extern NSString *const kTagHomeCreateNew;
extern NSString *const kTagHomeCreateNewText;
extern NSString *const kTagHomeCalendarText;
extern NSString *const kTagTools;
extern NSString *const kTagPurgeDataStatus;
extern NSString *const kTagPurgeDataNow;
extern NSString *const kTagPushLogsNow;
extern NSString *const kTagPushLogsStatus;
extern NSString *const kPurgeDataProgress;

extern NSString *const kTagWeek;
extern NSString *const kTagDay;
extern NSString *const kTagMonth;

//progressbar
extern NSString *const kTagSyncProgressMetadata;
extern NSString *const kTagSyncProgressPagedata ;
extern NSString *const kTagSyncProgressObjDefinition ;
extern NSString *const kTagSyncProgressBatchDefinition;
extern NSString *const kTagSyncProgressPicklistDefinition;
extern NSString *const kTagSyncProgressRTPicklist;
extern NSString *const kTagSyncProgressSFWMetadata;
extern NSString *const kTagSfmCreatedDate;
extern NSString *const kTagSyncProgressMobSettings;
extern NSString *const kTagSyncProgressDpPicklist;
extern NSString *const kTagSyncProgressEventSync;
extern NSString *const kTagSyncProgressDcSync;
extern NSString *const kTagSyncProgressCleanup;
extern NSString *const kTagSyncProgressTxFetch;
extern NSString *const kTagSyncProgressLocaldb;
extern NSString *const kTagSyncProgressSyncComplete ;
extern NSString *const kTagSyncProgressRetry ;
extern NSString *const kTagSyncProgressIWillTry ;
extern NSString *const kTagSyncProgressStep ;
extern NSString *const kTagSyncProgressOf ;
extern NSString *const kTagSyncProgressTitle ;

extern NSString *const kTagSyncProgressMetadataDesc ;
extern NSString *const kTagSyncProgressPagedataDesc ;
extern NSString *const kTagSyncProgressObjDefinitionDesc;
extern NSString *const kTagSyncProgressBatchDefinitionDesc;
extern NSString *const kTagSyncProgressPicklistDefinitionDesc;
extern NSString *const kTagSyncProgressRTPicklistDesc;
extern NSString *const kTagSyncProgressSFWMetadataDesc;
extern NSString *const kTagSfmSeeMore ;
extern NSString *const kTagSyncProgressMobSettingsDesc;
extern NSString *const kTagSyncProgressSfmSearchDesc ;
extern NSString *const kTagSyncProgressDpPicklistDesc ;
extern NSString *const kTagSyncProgressEventSyncDesc ;
extern NSString *const kTagSyncProgressDcSyncDesc ;
extern NSString *const kTagSyncProgressCleanupDesc;
extern NSString *const kTagSyncProgressTxFetchDesc;
extern NSString *const kTagSyncProgressLocaldbDesc;
extern NSString *const kTagSyncProgressSyncCompleteDesc;

//Calendar

extern NSString *const kTagLeftTaskLabel;
extern NSString *const kTagRightScheduleLabel;
extern NSString *const kTagYearLabel;
extern NSString *const kTagSliderCurrentWeekLabel;
extern NSString *const kTagDayOneLabel;
extern NSString *const kTagDayTwoLabel;
extern NSString *const kTagDayOneLabel;
extern NSString *const kTagDayTwoLabel;
extern NSString *const kTagDayThreeLabel;
extern NSString *const kTagDayFourLabel;
extern NSString *const kTagDayFiveLabel;
extern NSString *const kTagDaySixLabel;
extern NSString *const kTagDaySevenLabel;
extern NSString *const kTagMonthOneLabel;
extern NSString *const kTagMonthTwoLabel;
extern NSString *const kTagMonthThreeLabel;
extern NSString *const kTagMonthFourLabel;
extern NSString *const kTagMonthFiveLabel;
extern NSString *const kTagMonthSixLabel;
extern NSString *const kTagMonthSevenLabel;
extern NSString *const kTagMonthEightLabel;
extern NSString *const kTagMonthNineLabel;
extern NSString *const kTagMonthTenLabel;
extern NSString *const kTagMonthElevenLabel;
extern NSString *const kTagMonthTwelveLabel;
extern NSString *const KTagSettingsTitle;

#define Tag_CAL_MON                            @"IPAD006_TAG029"
#define Tag_CAL_TUE                            @"IPAD006_TAG030"
#define Tag_CAL_WED                            @"IPAD006_TAG031"
#define Tag_CAL_THU                            @"IPAD006_TAG032"
#define Tag_CAL_FRI                            @"IPAD006_TAG033"
#define Tag_CAL_SAT                            @"IPAD006_TAG034"
#define Tag_CAL_SUN                            @"IPAD006_TAG035"


#define Tag_CAL_Jan                            @"IPAD006_TAG043" //Jan - first 3 letter of month
#define Tag_CAL_Feb                            @"IPAD006_TAG044"
#define Tag_CAL_Mar                            @"IPAD006_TAG045"
#define Tag_CAL_Apr                            @"IPAD006_TAG046"
#define Tag_CAL_May                            @"IPAD006_TAG020"
#define Tag_CAL_Jun                            @"IPAD006_TAG047"
#define Tag_CAL_Jul                            @"IPAD006_TAG048"
#define Tag_CAL_Aug                            @"IPAD006_TAG049"
#define Tag_CAL_Sep                            @"IPAD006_TAG050"
#define Tag_CAL_Oct                            @"IPAD006_TAG051"
#define Tag_CAL_Nov                            @"IPAD006_TAG052"
#define Tag_CAL_Dec                            @"IPAD006_TAG053"


#define kTag_Today                             @"IPAD006_TAG005"
#define kTag_Tomorrow                          @"IPAD006_TAG090"
#define kTag_Yesterday                         @"IPAD008_TAG005"
#define kTag_NewTask                           @"IPAD014_TAG091"
#define kTag_TextGoes                          @"IPAD007_TAG011"
#define kTag_AttachementDownloadComplete       @"IPAD024_TAG030"
#define kTag_Confirm       @"IPAD014_TAG081"
#define kTag_AddEvent       @"IPAD006_TAG091"
#define kTag_PleaseSelectAppointment       @"IPAD006_TAG099"

#define kTag_Limitto       @"IPAD014_TAG076"
#define kTag_PleaseConfigureValidAccount       @"IPAD024_TAG029"
#define kTag_TheSelectedAttachementWillBeRemoved       @"IPAD024_TAG032" //The selected attachment will be removed and will be deleted from the server at the next sync. This action cannot be undone.
#define kTag_FileNotSupportedByWebView       @"IPAD024_TAG033" //File cannot be loaded on the webview, File not supported by web view
#define kTag_CannotBeLoadedInWebView       @"IPAD024_TAG034" //Can not be loaded in web view
#define kTag_AttachementDownloads       @"IPAD024_TAG035" //Attachment Downloads
#define kTag_ConfirmAppReset       @"IPAD018_TAG144" //Confirm App Reset

#define kTag_ThisWillRemoveData       @"IPAD018_TAG145" //This will remove all data stored on this iPad and re-synchronize with the server.
#define kTag_ProcessTakeSeveralMinutes       @"IPAD018_TAG146" //This process can take several minutes. You will be unable to use your iPad during app reset.
#define kTag_AppResetInProgress       @"IPAD018_TAG147" //App Reset in Progress
#define kTag_PleaseDoNotSwitchApp       @"IPAD018_TAG148" //Please do not switch to another application or press the home button during this progress.
#define kTag_DoingCancelReset               @"IPAD018_TAG149" //Doing so will cancel or interrupt the reset.
#define kTag_ResetingApplicationContents       @"IPAD018_TAG150" //Reseting Application Contents
#define kTag_SyncFailed                     @"IPAD018_TAG151" //Sync Failed
#define kTag_WouldRetryResetApplicationNow       @"IPAD018_TAG152" //Would you like to retry Reset Application now?
#define kTag_ProfileValidationInProgress       @"IPAD015_TAG016" //Profile Validation in Progress
#define kTag_DoingWillCancelProfileValidation       @"IPAD015_TAG017" //Doing so will cancel or interrupt profile validation.


#define kTag_ValidatingProfile       @"IPAD015_TAG018" //Validating Profile...
#define kTag_ProfileValidationfailed       @"IPAD015_TAG019" //Profile Validation failed
#define kTag_AM       @"SFM002_TAG094" //AM
#define kTag_PM       @"SFM002_TAG095" //PM
#define kTag_Reschedule       @"IPAD006_TAG100" //Reschedule
#define kTag_priority       @"IPAD014_TAG092" //priority
#define kTag_orderstatus       @"IPAD014_TAG048" //order status
#define kTag_purposeofvisit       @"IPAD014_TAG043" //purpose of visit
#define kTag_problemdescription       @"IPAD014_TAG053" //problem description

//#define kTag_Details                @"IPAD014_TAG095"


//#define kTag_ProductHistory_Records      @"IPAD019_TAG016"

/*
#define kTag_AccountHistory_Records      @"Account History and Records"

#define kTag_ImagesAndVideo      @"Images and Video"
#define kTag_ProductManual @"Product Manual"
#define kTag_Troubleshooting @"Troubleshooting"
 */

#define kTag_search @"SFM002_TAG010"

#define kTag_SessionExpireMsg @"IPAD015_TAG020" //Your session with ServiceMax Mobile has expired. Please relogin.
#define kTag_RemoteAccessRevokedMsg @"IPAD015_TAG021" //Your remote access has been revoked. Please navigate back to the Tools screen to logout and re-authenticate

#define kTag_RemoveDataAlertMsg @"IPAD018_TAG194" //This will remove all ServiceMax data stored on this iPad and re-synchronize with the server. This process can take several minutes. You will be unable to use your iPad during app reset.





#define kTag_s @"IPAD006_TAG093" //s- Sunday
#define kTag_sat @"IPAD006_TAG126" //s - saturday
#define kTag_thur @"IPAD006_TAG127" //t- thursday
#define kTag_m @"IPAD006_TAG094"
#define kTag_t @"IPAD006_TAG095" //t- tuesday
#define kTag_w @"IPAD006_TAG096"
#define kTag_f @"IPAD006_TAG097"


//#define kTag_Sun @"IPAD006_TAG093"
//#define kTag_Mon @"IPAD006_TAG094"
//#define kTag_t @"IPAD006_TAG095"
//#define kTag_w @"IPAD006_TAG096"
//#define kTag_f @"IPAD006_TAG097"

#define kTag_History @"IPAD006_TAG098"
#define kTag_Add     @"IPAD014_TAG086"
#define kTag_Lists    @"IPAD006_TAG081"

#define kTag_ItemSelected @"IPAD024_TAG027"
#define kTag_ConfigSync @"IPAD018_TAG135"
#define kTag_Resolve @"IPAD018_TAG095"
#define kTag_Resolution @"IPAD014_TAG041"
#define kTag_details @"IPAD018_TAG096"
#define kTag_acInfo @"IPAD014_TAG050"

#define kTag_Update @"IPAD014_TAG075"
#define kTag_Edit @"IPAD006_TAG124"

#define kTag_NoTaskFound_TryLater @"IPAD006_TAG125"
#define kTag_description @"IPAD006_TAG109"//description
#define kTag_DescriptonCantMore @"IPAD014_TAG104"

#define kTag_Event @"IPAD006_TAG108"
#define kTag_duedate @"IPAD006_TAG107"
#define kTag_EditTask @"IPAD006_TAG106"
#define kTag_ThisTimeOverlapsAppointment @"IPAD006_TAG105"
#define kTag_SelectDateTime @"IPAD006_TAG104"
#define kTag_DeleteEvent @"IPAD006_TAG103"
#define kTag_PleaseSelectGuest @"IPAD006_TAG102"
#define kTag_StartTimeMustEarlierEndTime @"IPAD006_TAG101"
#define kTag_ViewProcess @"IPAD014_TAG102"
#define kTag_products_at_thislocation @"IPAD014_TAG101"
#define kTag_Open @"IPAD014_TAG068"
#define kTag_service_location @"IPAD014_TAG067"
#define kTag_phone @"IPAD014_TAG100"
#define kTag_contact @"IPAD014_TAG099"
#define kTag_PleaseSelectCustomer @"IPAD014_TAG098"
#define kTag_billing_type @"IPAD014_TAG097"
#define kTag_PleaseFillDesc @"IPAD014_TAG096"
#define kTag_Change_Resolution @"IPAD018_TAG158"
#define kTag_ResolutionAtNextSync @"IPAD018_TAG157"
#define kTag_Sync_Conflict_Resolution @"IPAD018_TAG156"
#define kTag_Initial_Sync @"IPAD018_TAG155"
#define kTag_Initiating_Sync @"IPAD018_TAG154"

#define kTag_NoItemsEntered @"IPAD014_TAG139"


#define kTag_Downloading_translations @"IPAD018_TAG084"
#define kTag_Downloading_ProcessDefinition_ProfileSettings @"IPAD018_TAG085"
#define kTag_Downloading_PageLayout @"IPAD018_TAG086"
#define kTag_Downloading_Object_Picklist @"IPAD018_TAG087"
#define kTag_Downloading_Event_RelatedRecord @"IPAD018_TAG088"
#define kTag_Downloading_DatasetReocord @"IPAD018_TAG120"
#define kTag_Download_Data @"IPAD018_TAG121"

//HS 6 Jan
#define kTag_Edittask @"IPAD014_TAG103"
#define kTag_Tap_ItemToSelect @"IPAD014_TAG105" //Tap any item to add to Selected List
#define kTag_Apply @"IPAD014_TAG106"
#define kTag_number @"IPAD014_TAG107"
#define kTag_remain @"IPAD014_TAG108"
#define kTag_AddSelected @"IPAD014_TAG109"
#define kTag_Filters @"IPAD014_TAG110"
#define kTag_CustomerDebrief @"IPAD014_TAG111"
#define kTag_LineItemActions @"IPAD014_TAG135"
#define kTag_GetPrice @"WORD005_TAG017"
#define kTag_DownloadComplete @"IPAD018_TAG159"
#define kTag_DataSyncRetrieveApptmnt @"IPAD018_TAG160" //Data Sync will retrieve the latest appointments, work orders and other information.
#define kTag_YouCanContinueUseAppDuringDataSync @"IPAD018_TAG161" //You can continue to use the ServiceMax app during data sync.
#define kTag_DataSync @"IPAD018_TAG162"
#define kTag_GotItDontShowAgain @"IPAD018_TAG163" //Got it. Don't show me this again.
#define kTag_ConfigSyncUpdateBusinessRule @"IPAD018_TAG164"  //Config Sync will update all business rules and configuration items. You will not be able to use the app during this process.
#define kTag_ConfigSyncInProgress @"IPAD018_TAG165" //Config Sync in Progress
#define kTag_PlsDontSwitchAnotherApp @"IPAD018_TAG166" //Please do not switch to another application or press the home button while sync is in progress
#define kTag_DoingWillCancelSync @"IPAD018_TAG167" //Doing so will cancel or interrupt the synchronization.

#define kTag_DecideLater @"IPAD018_TAG098"

#define kTag_Retrying @"IPAD018_TAG168"
#define kTag_SyncConflicts @"IPAD018_TAG093"
#define kTag_DataSyncStatus @"IPAD018_TAG100"
#define kTag_lastsync @"IPAD018_TAG119"
#define kTag_status @"IPAD018_TAG169"
#define kTag_ConfigSyncStatus @"IPAD018_TAG170"
#define kTag_Conflicts @"IPAD018_TAG171"
#define kTag_Notifications @"IPAD018_TAG172"
#define kTag_UseServerVersion @"IPAD018_TAG173"
#define kTag_nextsync @"IPAD018_TAG104"
#define kTag_StatusAndManualSync @"IPAD018_TAG138"
#define kTag_ResolveConflicts @"IPAD018_TAG139"
#define kTag_NotificationHistory @"IPAD007_TAG010"
#define kTag_TextSize @"IPAD007_TAG009"
#define kTag_SyncDataNow @"IPAD018_TAG140"
#define kTag_SyncConfigNow @"IPAD018_TAG141"
#define kTag_SyncConflicts @"IPAD018_TAG093"
#define kTag_KeepMyChanges @"IPAD018_TAG097"
#define kTag_IncludeOnlineItems @"IPAD019_TAG013"
#define kTag_SFMSearchLimit   @"IPAD019_SET001"
#define kTag_Documents @"IPAD024_TAG004"
#define kTag_ImagesAndVideo @"IPAD024_TAG037"
#define kTag_AcHistoryAndRecords @"IPAD019_TAG015"

#define kTag_ItemsFound @"IPAD019_TAG014"

#define kTag_ProductHistoryAndRecords @"IPAD019_TAG016" //Tag not available

#define kTag_Troubleshooting @"IPAD014_TAG005"
#define kTag_Product Manual @"IPAD016_TAG001"
#define kTag_UnableFetchTechnicianAddress @"IPAD013_TAG012"
#define kTag_ServiceMaxMobileForiPad @"IPAD009_TAG007"
#define kTag_ResettingAppRemoveLocalData @"IPAD018_TAG174" //Resetting the app will remove all local data and settings and re-sync to the server.
#define kTag_InternetRequiredToResetApp @"IPAD018_TAG175" //An Internet connection is required to reset the app.
#define kTag_PurgingDataRemovesOldAppmt @"IPAD018_TAG176" //Purging data removes old appointments and work orders from your device. They are not deleted from the server. You will be unable to use the application while purging.
#define kTag_InternetRequiredToPurgeData @"IPAD018_TAG177" //An Internet connection is required to purge data.
#define kTag_PurgeNow @"IPAD018_TAG179"

#define kTag_ServiceMAxNeedPurgeOldAppmt @"IPAD018_TAG178" //ServiceMax needs to purge old appointments and work orders.
#define kTag_ServiceMAxNeedPurgeOldAppmtActionFoundInTools @"IPAD018_TAG180" //ServiceMax needs to purge old appointments and work orders. If you choose to purge later, this action can be found in Tools.
#define kTag_WelcomeToServiceMaxMobile @"IPAD018_TAG181" //Welcome to ServiceMax Mobile
#define kTag_WeAreDownloadingLatestWorkOrder @"IPAD018_TAG182" //We're downloading the latest work orders, appointments, and other information you need to deliver flawless field service. This process can take a few minutes. Please do not press the home button or switch to another application because this will stop the download process.
#define kTag_WhileYouWaitTakeLook @"IPAD018_TAG183" //While you wait, take a look through the illustrations below for tips on using the application.
//#define kTag_ConfigSyncInProgress @"IPAD018_TAG184"
#define kTag_PleaseDontSwitchAnotherApp @"IPAD018_TAG185" //Please do not switch to another application or press the home button while sync is in progress
#define kTag_DoingSoCancelSync @"IPAD018_TAG186" //Doing so will cancel or interrupt the synchronization.
#define kTag_ConfigSyncNeeded @"IPAD018_TAG187"
#define kTag_ServiceMaxNeedSyncForms @"IPAD018_TAG188" //ServiceMax needs to sync forms, rules and other configuration items.
#define kTag_ServiceMaxNeedSyncFormsActionsFoundInTools @"IPAD018_TAG189" //ServiceMax needs to sync forms, rules and other configuration items. If you choose to sync later, this action can be found in Tools.
#define kTag_CustomerDebrief @"IPAD014_TAG111"

#define kTag_WorkOrder @"IPAD014_TAG112"
#define kTag_Details @"IPAD014_TAG036"
#define kTag_LineItems @"IPAD014_TAG009"
#define kTag_descriptionofservice @"IPAD014_TAG113"
#define kTag_usePricefromPricebook @"IPAD014_TAG114"
//#define kTag_status @"IPAD018_TAG169"
#define kTag_useDiscountPricing @"IPAD014_TAG115"

#define kTag_accountname @"IPAD014_TAG116"
#define kTag_workOrderNumber @"IPAD014_TAG117"
#define kTag_CannotSave @"IPAD014_TAG118"
#define kTag_IssuesNeedResolution @"IPAD014_TAG119"
#define kTag_edit @"IPAD014_TAG066"
#define kTag_textArea @"IPAD014_TAG120"
#define kTag_ResolutionAt @"IPAD014_TAG121"
#define kTag_RestorationAt @"IPAD014_TAG122"
#define kTag_CleanUpAt @"IPAD014_TAG123"
#define kTag_AbandonChanges @"IPAD014_TAG124"
#define kTag_SaveChanges @"IPAD014_TAG125"
#define kTag_WorkOrderDebrief @"IPAD014_TAG126"
#define kTag_Finalize @"SFM004_TAG006"
#define kTag_ItemsSelected @"IPAD024_TAG028"
#define kTag_Select @"IPAD024_TAG005"
#define kTag_On  @"IPAD014_TAG127"
#define kTag_Off @"IPAD014_TAG128"
#define kTag_remain @"IPAD014_TAG108"
#define kTag_NewPost @"IPAD008_TAG011"
#define kTag_Reply @"IPAD008_TAG012"
#define kTag_PreviousItem @"IPAD014_TAG129"
#define kTag_Download @"IPAD014_TAG130"
#define kTag_CancelDownload @"IPAD014_TAG131"
#define kTag_ThereAreNoActionPermission @"IPAD014_TAG132" //There are no actions assigned to this item or you do not have permission to see them.
#define kTag_NoActionsAvailable @"IPAD014_TAG133"
#define kTag_Failure @"IPAD014_TAG134"
#define kTag_Finalize @"SFM004_TAG006"
#define kTag_description @"IPAD006_TAG109"
#define kTag_For @"IPAD006_TAG110" //For
#define kTag_Technician @"IPAD006_TAG111"
#define kTag_TermsAndConditions @"IPAD006_TAG112"
#define kTag_InternetConnectionOffline @"IPAD006_TAG113" //Internet connection appears to be offline
#define kTag_YourRemoteAccessRoevoked @"IPAD006_TAG114" //Your remote access has been revoked. Please navigate back to the Tools screen to logout and re-authenticate
#define kTag_ServiceMax @"IPAD011_TAG001"

#define kTag_ApplicationLevelSettingOff @"IPAD018_TAG190" //Application Level Log Setting is OFF.
#define kTag_NoLogsToPush @"IPAD018_TAG191" //No logs to push.
#define kTag_Uploading @"IPAD018_TAG192"
#define kTag_to @"IPAD006_TAG115"
#define kTag_CreateEvent @"IPAD006_TAG116"
#define kTag_start @"IPAD006_TAG117"
#define kTag_end @"IPAD006_TAG118"
#define kTag_and @"IPAD006_TAG119"
#define kTag_more @"IPAD014_TAG052"
#define kTag_eventName @"IPAD006_TAG120"
#define kTag_PreviousMonth @"IPAD006_TAG121"
#define kTag_NextMonth @"IPAD006_TAG122"
#define kTag_appointment @"IPAD006_TAG123"
#define kTag_Edit @"IPAD006_TAG124"
#define kTag_Today @"IPAD006_TAG005"
#define kTag_Tomorrow @"IPAD006_TAG090"
#define kTag_Yesterday @"IPAD008_TAG005"
#define kTag_DownloadingRecordsIDsNotRelatedEvents @"IPAD018_TAG193" //Downloading records IDs not related to events
#define kTag_LoggingOut @"IPAD015_TAG022"
#define kTag_SignedOut @"IPAD015_TAG023"
#define kTag_YouHaveSignedOut @"IPAD015_TAG024" //You have been signed out.
#define kTag_ThanksForUsingServiceMax @"IPAD015_TAG025" //Thanks for using ServiceMax Mobile!


//HS 6 Jan



//Tags for Pulse App
#define kTag_PleaseLoginWithSameUserId @"IPAD025_TAG001"
#define kTag_PleaseLoginWithSameOrgId @"IPAD025_TAG002"
#define kTag_InvalidNotification @"IPAD025_TAG003"
#define kTag_NetworkUnavailable @"IPAD025_TAG004"  //Network unavailable to complete action
#define kTag_WouldLikeViewCancel @"IPAD025_TAG005" //Would you like to View/Cancel the selected Record?
#define kTag_SaveAndView @"IPAD025_TAG006"
#define kTag_View @"IPAD025_TAG012"
#define kTag_AbandonAndView @"IPAD025_TAG007"
#define kTag_NoViewLayoutForObject @"IPAD025_TAG008"

#define kTag_ThisRecordDeletedFromServer @"IPAD025_TAG009"
#define kTag_Downloads @"IPAD025_TAG010" //Downloads
#define kTag_Completed @"IPAD022_TAG004"
#define kTag_Started @"IPAD025_TAG013"
#define kTag_InProgress @"IPAD018_TAG059"

#define kTag_AddEditFilters @"IPAD014_TAG142"  //lookup
#define kTag_IncludeOnline @"IPAD014_TAG143"
#define kTag_LookUpTitle @"IPAD014_TAG136"
#define kTag_AddSingleLine @"IPAD014_TAG137"

#define kTag_GregorianCalendarOnlyAlert @"IPAD006_TAG132"

extern NSString *const kTagJanuary;
extern NSString *const kTagFebruary;
extern NSString *const kTagMarch;
extern NSString *const kTagApril;
extern NSString *const kTagMay;
extern NSString *const kTagJune;
extern NSString *const kTagJuly;
extern NSString *const kTagAugust;
extern NSString *const kTagSeptember;
extern NSString *const kTagOctober;
extern NSString *const kTagNovember;
extern NSString *const kTagDecember;

extern NSString *const kTagSegmentDayButton;
extern NSString *const kTagSegmentWeekButton;
extern NSString *const kTagSliderTodayButton;

extern NSString *const kTagNoViewLayOut;
extern NSString *const kTagNoViewProcess;
extern NSString *const kTagCalendarMonday;
extern NSString *const kTagCalendarTuesday;
extern NSString *const kTagCalendarWednsday;
extern NSString *const kTagCalendarThursday;
extern NSString *const kTagCalendarFriday;
extern NSString *const kTagCalendarSaturday;
extern NSString *const kTagCalendarSunday;

extern NSString *const kTagEventReschedulePrompt;
extern NSString *const kTagYes;
extern NSString *const kTagNo;

// LOGIN SCREEN

extern NSString *const kTagLoginUserNamePlaceHolder;
extern NSString *const kTagPasswordPlaceHolder;
extern NSString *const kTagLoginSignUp;
extern NSString *const kTagLoginCreateSampleData;

// ALERT BOX
extern NSString *const kTagAlertTitleError;
extern NSString *const kTagAlertErrorOk;
extern NSString *const KTagAlertResponceError;
extern NSString *const kTagAlertResponce;
extern NSString *const kTagAlertRequiredFields;
extern NSString *const kTagAlertWarningError;
extern NSString *const KTagAlertInrnetNotAvailableError;

// MAP
extern NSString *const kTagOnClickMapError;
extern NSString *const kTagMapPopOverTitle;
extern NSString *const kTagMapHomeLocationTitle;
extern NSString *const kTagMapDirectionFailed;
extern NSString *const kTagMapTo;
extern NSString *const kTagMapWoMinutes;

extern NSString *const kTagMapPopOverDrivingDirectionButton;
extern NSString *const kTagMapPopOverJobDetailButton;

// MAP VIEW
extern NSString *const kTagMapViewErrorTitlle;

// General
extern NSString *const kTagtBackButtonTitle;
extern NSString *const kTagChatterNoProductInfoError;
extern NSString *const kCancelButtonTitle;
extern NSString *const kDoneButtonTitle;

// SFM PAGE
extern NSString *const kTagSfmActionPopOVerListOne ;
extern NSString *const kTagSfmActionPopOVerListThree;
extern NSString *const kTagSfmChatterShreButton;
extern NSString *const kTagSfmPostButton ;
extern NSString *const kTagSfmTroubleShooting ;
extern NSString *const kTagSfmSummayTotalAmount;
extern NSString *const kTagSfmSummaryBackHeader;
extern NSString *const kTagSfmLeftPaneHeader;
extern NSString *const kTagSfmLeftPaneLine;
extern NSString *const kTagSfmLeftPaneAddInfo;
extern NSString *const kTagSfmLeftPaneAttachments ;
extern NSString *const kTagSfmLeftPaneSwitchProcess;
extern NSString *const kTagSfmActionButtonSave;
extern NSString *const kTagSfmActionQuickSave;
extern NSString *const kTagSfmSectionPostFix;
extern NSString *const kTagSfmLeftPaneProductHistory ;
extern NSString *const kTag_AccountHistory ;
extern NSString *const kTagInformation;
extern NSString *const kTagSLAClocks;

//NEW
extern NSString *const kTagSfmDetailFieldNotAccessible ;
extern NSString *const kTagSfmInvalidEmail ;
extern NSString *const kTagSfmInvalidUrl ;
extern NSString *const kTagSfmLookUpSearch ;
extern NSString *const kTagSfmLookUpSearchFor;

//Krishna CONTEXTFILTER
extern NSString *const kTagSfmLookUpContextLimitTo ;


extern NSString *const kTagCancelButton ;
extern NSString *const kTagDelete;
extern NSString *const kTagSlaRestoration;
extern NSString *const kTagSlaResolution ;

extern NSString *const kTagSfmSignatureCancelButton;
extern NSString *const kTagSfmSignatureDoneButton ;

// CHATTER VIEW
extern NSString *const kTagChatterDisabledError;
extern NSString *const kTagChatterTitle ;
extern NSString *const kTagChatterPost ;
extern NSString *const kTagChatterToday;
extern NSString *const kTagChatterYesterday ;
extern NSString *const kTagChatterDayBeforeYesterday ;
extern NSString *const kTagchatterShare;

// Troubleshooting
extern NSString *const kTagTroubleShootingError ;
extern NSString *const kTagTroubleShootingNoProductInfoError;

// Product Manual
extern NSString *const kTagProductManualTitle ;
extern NSString *const kTagProductManualNotPresent;

// Service Report
extern NSString *const kTagSummaryReportTitle;
extern NSString *const kTagSummaryReportTotalAmountTitle ;
extern NSString *const kTagServiceReportStatusAttaching;
extern NSString *const kTagServiceReportTitle ;
extern NSString *const kTagSummaryReportWorkPerformedTitle;
extern NSString *const kTagSummaryReportSno;
extern NSString *const kTagSummaryReportpartsTitle;
extern NSString *const kTagSummaryReportLabourTitle;
extern NSString *const kTagSummaryReportExpenceTitle;
extern NSString *const kTagSummaryReportQuanityTitle;
extern NSString *const kTagSummaryReportRateTitle;
extern NSString *const kTagSummaryReportUnitPriceTitle;
extern NSString *const kTagSummaryReportHoursTitle;
extern NSString *const kTagSummaryReportLinePrice;
extern NSString *const kTagServiceReportCustomerSignature;
extern NSString *const kTagServiceReportTotalCost;
extern NSString *const kTagServiceReportWorkOrderNumber ;
extern NSString *const kTagServiceReportDate;
extern NSString *const kTagServiceReportAddress;
extern NSString *const kTagServiceReportContact;
extern NSString *const kTagServiceReportPhone;
extern NSString *const kTagServiceReportPartsPartTitle;
extern NSString *const kTagServiceReportPartOtyTitle;
extern NSString *const kTagServiceReportPartsDiscountTitle;
extern NSString *const kTagServiceReportProblemDescription;
extern NSString *const kTagServiceReportLabourRateTitle;
extern NSString *const kTagServiceReportExpenceTypeTitle;
extern NSString *const kTagServiceReportRetrievingServiceReport;
extern NSString *const kTagServiceReportDetailsOfWorkPerformed;
extern NSString *const kTagServiceReportEmailError;
extern NSString *const kTagServiceReportPleaseSetUpEmailFirstError ;

//PDF
extern NSString *const kTagPdfAttaching;
extern NSString *const kTagPdfEmail ;
extern NSString *const kTagPdfServiceReport;


// About


extern NSString *const kTagAboutVersionTitle ;
extern NSString *const kTagAboutLoggedInfoTitle;
extern NSString *const kTagAboutLoggedInfoAsTitle;


extern NSString *const kTagSignOut;
extern NSString *const kTagPurgeData;
extern NSString *const kTagAbout;
extern NSString *const kTagResetApp;
extern NSString *const kTagSignedinto;
extern NSString *const kTagStartSync;
extern NSString *const kTagLoading;
extern NSString *const kTagmore;
extern NSString *const kTagHostNotFound_CheckURL;
extern NSString *const kTagHostNotFound;

// Add Tasks


extern NSString *const kTagAddTasksPrompt ;
extern NSString *const kTagAddTasksPriorityTitle ;
extern NSString *const kTagAddTaskPriorityLow ;
extern NSString *const kTagAddTaskPriorityNormal;
extern NSString *const kTagAddTaskPriorityHigh ;

extern NSString *const kTagAddTaskCancelButton ;
extern NSString *const kTagAddTaskDoneButton ;

//New Tags

extern NSString *const kTagTroubleShootOflineError ;
extern NSString *const kTagNotAssociatedRecord;
extern NSString *const kTagChatterNewPost;
extern NSString *const kTagChatterFaceTime ;
extern NSString *const kTagChatterFaceTimeConfig ;
extern NSString *const kTagChatterAlertAuthenticatiojnError;

extern NSString *const kTagAlertConnectionError ;
extern NSString *const kTagAlertSwitchUser;
extern NSString *const kTagAlertIpadError;
extern NSString *const kTagAlertApplicationError;
extern NSString *const kTagAlertSynchroniseError;
extern NSString *const kTagAlertinvalideError;
extern NSString *const kTagAlertCopyToFlipBoard ;
extern NSString *const kTagAlertConfigureMail;
extern NSString *const kTagSystemError;
extern NSString *const kTagFunctionalError;
extern NSString *const kTagTypeOfError;

extern NSString *const kTagIpadSyncLabel;
extern NSString *const kTagiPadSyncText;
extern NSString *const kTagiPadLogoutLabel ;
extern NSString *const kTagiPadLogOutText;
extern NSString *const kTagMapOfflineText;
extern NSString *const kTagSfmNoPageLayout;
extern NSString *const kTagSfmSwitchProcess;
extern NSString *const kTagSfmSyncError;
extern NSString *const kTagSfmSfwError;
extern NSString *const kTagSyncMetaSyncFailed;
extern NSString *const kTagGetPriceObjectsNotFound;
extern NSString *const kTagBizzRuleTitle;
extern NSString *const kTagBizzRuleErrorTitle;
extern NSString *const kTagGetPriceNOtEntitled;
extern NSString *const kTagLimitToForContextFilter;

extern NSString *const kTagLoginSwitchUser;
extern NSString *const kTagLoginConnectionError;
extern NSString *const kTagLoginIncorrectVersion;
extern NSString *const kTagLoginIpadAppVersion;
extern NSString *const kTagLoginSerivcemaxVersion;

extern NSString *const kTagProfileError;

//OAuth : shirni.
extern NSString *const kTagRemoteAccesError;
extern NSString *const kTagSyncLoginError ;
extern NSString *const kTagInactiveUser;

extern NSString *const kTagSyncSynchronizeButton;
extern NSString *const kTagSyncStatusButton ;

extern NSString *const kTagSyncMobileSelect;

extern NSString *const kTagSyncRecordIdLabel;

extern NSString *const kTagSyncErrorMessage ;
extern NSString *const kTagSyncApplyChanges ;
extern NSString *const kTagSyncConflicts;
extern NSString *const kTagSyncDataSynchronization;
extern NSString *const kTagSyncMetaDataConfiguration ;
extern NSString *const kTagSyncEvents;
extern NSString *const kTagSyncDataSync ;
extern NSString *const kTagSyncConfiguration ;
extern NSString *const kTagSyncEventSynchronization ;
extern NSString *const kTagSyncLastTime;
extern NSString *const kTagSyncNextTime;
extern NSString *const kTagSyncLastStatus;
extern NSString *const kTagSyncReferredRecordError;
extern NSString *const kTagSyncFailed ;
extern NSString *const kTagSyncSucceeded ;
extern NSString *const kTagSyncProgress;
extern NSString *const kTagSyncCompleted ;
extern NSString *const kTagSyncChooseObject;
extern NSString *const kTagSyncFailedTryAgain;
extern NSString *const kTagSyncStatusButton1;
extern NSString *const kTagSyncHold;
extern NSString *const kTagSyncUndo ;
extern NSString *const kTagSyncFullDataSynchronize ;
extern NSString *const kTagSyncNoInternet;
extern NSString *const kTagSyncMetasyncDue ;
extern NSString *const kTag_SyncNow;
extern NSString *const kTagConncetingToSalesForce;
extern NSString *const kTagRetrievingData;
extern NSString *const kTagSavingDataOffline;
extern NSString *const kTagDataONDemand;
extern NSString *const kTagDownloading;
extern NSString *const kTagLastUpadatedOn;
extern NSString *const kTagRefreshFromSalesForce;
extern NSString *const kTagPushLogs;
extern NSString *const kTagPushLogStatus;
extern NSString *const kTagPushLogStatusInProgress ;
extern NSString *const kTagPushLogStatusSuccess ;
extern NSString *const kTagPushLogStatusFailed ;
extern NSString *const kTagLoginContinue;


extern NSString *const kTagDataPurgeMessage;
extern NSString *const kTagDataPurgeDue;
extern NSString *const kTagLastDataPurge;
extern NSString *const kTagNextDataPurge;
extern NSString *const kTagDataPurgeStatus;
extern NSString *const kTagDataPurgeStatusInProgress;
extern NSString *const kTagDataPurgeStatusSuccess;
extern NSString *const kTagDataPurgeStatusFailed ;
extern NSString *const kTagNotScheduled;
extern NSString *const kTagDataPurgeStatusCancelled;


extern NSString *const kTagDataPurge;
extern NSString *const kTagDpProgressConfigWs;
extern NSString *const kTagDpProgressConfigData;
extern NSString *const kTagDpProgressConfigOutOfData;
extern NSString *const kTagDpProgressDataBasevalidate;
extern NSString *const kTagDpProgressDc;
extern NSString *const kTagDpProgressAdc;
extern NSString *const kTagDpProgressPriceData;
extern NSString *const kTagDpProgressDataBaseCleanUp;
extern NSString *const kTagDpProgressGetData ;
extern NSString *const kTagDpProgressRemoveData;


extern NSString *const kTafSyncResetApplication	;

//SFM Search
extern NSString *const kTagSfmSearch;
extern NSString *const kTagSfmSearchDescription;
extern NSString *const kTagSfmSearchCriteria;
extern NSString *const kTagIncludeOnlineResults;
extern NSString *const kTagSfmSerachEnterText;
extern NSString *const kTagSfmSearchGo;
extern NSString *const kTagSfmSearchResults;
extern NSString *const kTagSfmCriteriaContains;
extern NSString *const kTagSfmCriteriaExactMatch;
extern NSString *const kTagSfmCriteriaEndsWith;
extern NSString *const kTagSfmCriteriaStartsWith;
extern NSString *const kTagSfmSearchClose;
extern NSString *const kTagSfmShow;
extern NSString *const kTagSfmRecords;

// Tags for SFM Screen
extern NSString *const kTagActions           ;
extern NSString *const kTagInformation       ;

//8915
extern NSString *const kTagShowAllButtonText;
extern NSString *const kTagViewButtontext ;
extern NSString *const kTagMoreButtonText ;

//Macros Which Is Only Used For Localization Of Days in Calender Views....

//Keys For Dictionary
extern NSString *const kTagCalendarDayOneLabel   ;
extern NSString *const kTagCalendarDayTwoLabel   ;
extern NSString *const kTagCalendarDayThreeLabel ;
extern NSString *const kTagCalendarDayFourLabel  ;
extern NSString *const kTagCalendarDayFiveLabel  ;
extern NSString *const kTagCalendarDaySixLabel   ;
extern NSString *const kTagCalendarDaySevenLabel ;

//Conflict
extern NSString *const kTagConflictRetry        ;
extern NSString *const kTagConflictRemove       ;
extern NSString *const kTagConflictHold         ;
extern NSString *const kTagConflictApplyMy      ;
extern NSString *const kTagConflictGetFrom      ;
extern NSString *const kTagSyncSelectOnline     ;
extern NSString *const kTagConflictChanges      ;
extern NSString *const kTagSyncConfigConfirm    ;


// Attachment
extern NSString *const kTagUpLoadError           ;
extern NSString *const kTagDownLoadError         ;
extern NSString *const kTagTapToDownload         ;
extern NSString *const kTagDocuments             ;
extern NSString *const kTagSelect              ;
extern NSString *const kTagDocumentList          ;
extern NSString *const kTagDeleteAction          ;
extern NSString *const kTagAddPhotoVideo         ;
extern NSString *const kTagPhotosVideos          ;
extern NSString *const kTagAddFromCamera         ;
extern NSString *const kTagTakeNewPic            ;
extern NSString *const kTagTakeNewVideo          ;
extern NSString *const kTagLargeImageWarnig      ;
extern NSString *const kTagLargeVideoWarning     ;
extern NSString *const kTagFileLocallyNotFound   ;

extern NSString *const kTagDownLoading           ;
extern NSString *const kTagDocDeleteConfirmation ;
extern NSString *const kTagDataCorruptionError   ;
extern NSString *const kTagFileNotFoundError     ;
extern NSString *const kTagFileSaveError         ;
extern NSString *const kTagUnauthorisedAccess    ;
extern NSString *const kTagNetworkConnectionTimeOut;
extern NSString *const kTagUnknownError          ;
extern NSString *const kTagDeleteLocallyAction   ;
extern NSString *const kTagDeleteButtonTitle     ;

// Smart docs
extern NSString *const kTag_Customer_Sign_Off    ;
extern NSString *const kTag_FINALIZE;
extern NSString *const kTagsessionExpiredMsg     ;


//calendar
extern NSString *const kTagFourteenDaysEventError;
extern NSString *const kTagEventTimeError;
extern NSString *const kTagNoTechnicianAssociatedError;
extern NSString *const kTagDragAndDropNotAllowedMessage;

//service report sync status
extern NSString *const KTagReportSyncStatusTitle;
extern NSString *const KTagReportViewButtonTitle;
extern NSString *const KTagReportSyncFailed;
extern NSString *const KTagOpDocReportTitle;
extern NSString *const KTagInProgess;
extern NSString *const KTagSuccess;
extern NSString *const KTagFailed;
extern NSString *const KTagConflicts;

//adding missing tag
extern NSString *const kValidAddressMsg ;
extern NSString *const kValidAddressMsgRecords ;
extern NSString *const kStatus ;
extern NSString *const kLastPurge ;
extern NSString *const kNextPurge ;
extern NSString *const kPurgeProgressMessage ;
extern NSString *const kPurgeWarningMessage ;
extern NSString *const kSignIn ;
extern NSString *const kPurgeDataLogs;

//ProductIQ tags
extern NSString *const KWizardNameForProductIQ;
extern NSString *const KStepNameForProductIQ;

// SECSCAN-260
extern NSString *const kValidateProfileSSLPinning;
extern NSString *const kSSLPinningEnabled;

//@end
