//
//  NonTagConstant.h
//  ServiceMaxMobile
//
//  Created by Shubha S. on 16/05/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//


/**
 *  @file   NonTagConstant.h
 *  @class  NonTagConstant
 *
 *  @brief
 *
 *   This class which holds all the non tag related constant.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>

//Location Ping
extern NSString *const kTextLocationSettingDisable;
extern NSString *const kTextAppLocationSettingDisable;
extern NSString *const kTextFailure;
extern NSString *const kTextLocationSuccess;
extern NSString *const kTextFailedToGetLocation;


/** String Constants */
extern NSString *const kSuccess;
extern NSString *const kInProgress;
extern NSString *const kFailed;



// FOR OBJECTS VALUES IN DICTIONARY FOR
//Tags List Values in case if webservice fails

extern NSString *const kTextCalendarValue;
extern NSString *const kTextMapValue;
extern NSString *const kTextCreateNewValue;
extern NSString *const kTextHomeRecentsValue;
extern NSString *const kTextHomeTaskValue    ;
extern NSString *const kTextHomeHelpValue   ;

extern NSString *const kTextCalendarTextValue ;
extern NSString *const kTextMapPlanWork        ;
extern NSString *const kTextCreateNewService    ;
extern NSString *const kTextViewRecent  ;
extern NSString *const kTextTrackTask    ;
extern NSString *const kTextShowHelp;
extern NSString *const kTextNoEvent;

extern NSString *const kTextSchedule   ;
extern NSString *const kTextDay ;
extern NSString *const kTextWeek ;
extern NSString *const kTextToday      ;
extern NSString *const kTextJanuary    ;
extern NSString *const kTextFebruary   ;
extern NSString *const kTextMarch      ;
extern NSString *const kTextApril      ;
extern NSString *const kTextMay;
extern NSString *const kTextJune;
extern NSString *const kTextJuly ;
extern NSString *const kTextAugust     ;
extern NSString *const kTextSeptember  ;
extern NSString *const kTextOctober    ;
extern NSString *const kTextNovember   ;
extern NSString *const kTextDecember   ;
extern NSString *const kTextYear;
extern NSString *const kTextCurentWeek;
extern NSString *const kTextModay;
extern NSString *const kTextTuesday;
extern NSString *const kTextWednsday;
extern NSString *const kTextThursday;
extern NSString *const kTextFriday;
extern NSString *const kTextSaturday;
extern NSString *const kTextSunday;


//Values For Dictionary
extern NSString *const kTextMon  ;
extern NSString *const kTextTue  ;
extern NSString *const kTextWed  ;
extern NSString *const kTextThu  ;
extern NSString *const kTextFri ;
extern NSString *const kTextSat  ;
extern NSString *const kTextSun  ;

//Values
extern NSString *const kTextLogin                 ;

extern NSString *const kTroubleShootPlaceHolder   ;

//Chatter
extern NSString *const kChatterPlaceHolder        ;

extern NSString *const kTextChatter              ;

//Macros defintion for getEvents

extern NSString *const kTextObjectApiName     ;
extern NSString *const kTextObjectLabel       ;
extern NSString *const kTextAdditionalInfo    ;
extern NSString *const kTextColorCode         ;
extern NSString *const kTextActivityDate       ;
extern NSString *const kTextActivityDateTime   ;
extern NSString *const kTextAttachments        ;
extern NSString *const kTextCreateDate      ;
extern NSString *const kTextDescription       ;
extern NSString *const kTextDurationInMinutes  ;
extern NSString *const kTextEndDateTime        ;
extern NSString *const kTextIsAllEvent         ;
extern NSString *const kTextIsArchived        ;
extern NSString *const kTextIsChild            ;
extern NSString *const kTextISGrouped         ;
extern NSString *const kTextIsPrivate         ;
extern NSString *const kTextIsReminderSet ;
extern NSString *const kTextLocation    ;
extern NSString *const kTextStartDateTime ;
extern NSString *const kTextSubject  ;
extern NSString *const kCancel;
extern NSString *const kTextType    ;
extern NSString *const kTextWhatId  ;
extern NSString *const kTextEventId ;

//Addtional Information


extern NSString *const kTextStreet       ;
extern NSString *const kTextCity         ;
extern NSString *const kTextState        ;
extern NSString *const kTextCountry     ;
extern NSString *const kTextZip          ;
extern NSString *const kTextLattitude   ;
extern NSString *const kTextLongitude   ;
extern NSString *const kTextEventLocalId;

//SaveTargets keys
extern NSString *const kTextSuccess;


//Create Object History
extern NSString *const kTextResultId             ;
extern NSString *const kTextObjectSpaceLabel   ;
extern NSString *const kTextObjectName       ;
extern NSString *const kTextNameField  ;

// Macros for Settings of Location Ping
extern NSString *const kTextLocationTrackFequency ;
extern NSString *const kTextEnableLocationUpdate  ;
extern NSString *const kTextLocationRecord       ;


//ORG prefix
extern NSString *const kTextSvmxOrgPrefix ;



//MapView
//TODO: Add these keys to mapview tag constants
extern NSString *const KMapNoValidAddress;
extern NSString *const KMapNoValidAddresses;

extern NSString *const kCalDetailPhone;
extern NSString *const kCalDetailPriority;
extern NSString *const kCalDetailBillingType;
extern NSString *const kCalDetailOrderStatus;
extern NSString *const kCalDetailProductsAtLocation;
extern NSString *const kCalDetailEvent;
extern NSString *const kCalDetailEventName;
extern NSString *const kCalDayViewEventOverlap;

//Attachments
extern NSString *const kAttachmentCancelDownload;
extern NSString *const kAttachmentUnableDelete;
extern NSString *const kAttachmentImagesAndVideos;

extern NSString *const kOPDocHTMLString;
extern NSString *const kOPDocSignatureString;
extern NSString *const kOPDocDeleteString;

extern NSString *const kAccHistory;
extern NSString *const kProHistory;


/*Chatter*/
extern NSString *const kChatterAttachmentId;
extern NSString *const kChatterUserData;

// IPAD-4541 - Verifaya
extern NSString *const kVToggleTabBar;
extern NSString *const kVEventStartDateTime;
extern NSString *const kVEventEndDateTime;
extern NSString *const kVDataSyncLastTimeLbl;
extern NSString *const kVDataSyncLastTimeVal;
extern NSString *const kVDataSyncNextTimeLbl;
extern NSString *const kVDataSyncNextTimeVal;
extern NSString *const kVConfigSyncLastTimeLbl;
extern NSString *const kVConfigSyncLastTimeVal;
extern NSString *const kVConfigSyncNextTimeLbl;
extern NSString *const kVConfigSyncNextTimeVal;
extern NSString *const kVSignInBtn;

@interface NonTagConstant : NSObject
@end
