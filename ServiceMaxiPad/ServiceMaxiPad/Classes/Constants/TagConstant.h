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
extern NSString *const kTagRescheduleYes;
extern NSString *const kTagRescheduleNo;

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
extern NSString *const kTagSfmLeftPaneAccountHistory ;
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
extern NSString *const kTagSyncMetasyncStart;
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
extern NSString *const kTagEditList              ;
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





//@end
