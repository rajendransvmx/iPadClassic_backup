//
//  NonTagConstant.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 16/05/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   NonTagConstant.m
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


#import "NonTagConstant.h"

//Location Ping
NSString *const kTextLocationSettingDisable          = @"Location Services Setting is disabled by the User";
NSString *const kTextAppLocationSettingDisable       = @"Application Location Service Setting is disabled by the User";
NSString *const kTextFailure                         = @"Failure";
NSString *const kTextLocationSuccess                 = @"Success";
NSString *const kTextFailedToGetLocation             = @"Failed to get the location";


/** String Constants */
NSString *const kSuccess            = @"Success";
NSString *const kInProgress         = @"In Progress";
NSString *const kFailed             = @"Failed";
NSString *const kCancel             = @"Cancel";


// FOR OBJECTS VALUES IN DICTIONARY FOR
//Tags List Values in case if webservice fails

NSString *const kTextCalendarValue                   = @"Calendar";
NSString *const kTextMapValue                        = @"Map";
NSString *const kTextCreateNewValue                  = @"Create New";
NSString *const kTextHomeRecentsValue                = @"Recents";
NSString *const kTextHomeTaskValue                   = @"Tasks";
NSString *const kTextHomeHelpValue                   = @"Help";

NSString *const kTextCalendarTextValue               = @"View work orders and other activities assigned on your calendar.";
NSString *const kTextMapPlanWork                     = @"See today's work orders on a map and plan your route";
NSString *const kTextCreateNewService                = @"Create new Service Flow transactions such as Parts Orders or Work Orders";
NSString *const kTextViewRecent                      = @"View the list of recently created records";
NSString *const kTextTrackTask                       = @"Track the tasks you plan to perform or have performed, such as making phone calls or sending mail.";
NSString *const kTextShowHelp                        = @"Show ServiceMax help";
NSString *const kTextNoEvent                         = @"No events present for the day.";

NSString *const kTextSchedule   =   @"Schedule";
NSString *const kTextDay        =   @"Day";
NSString *const kTextWeek       =   @"Week";
NSString *const kTextToday      =   @"Today";
NSString *const kTextJanuary    =   @"January";
NSString *const kTextFebruary   =   @"February";
NSString *const kTextMarch      =   @"March";
NSString *const kTextApril      =   @"April";
NSString *const kTextMay        =   @"May";
NSString *const kTextJune       =   @"June";
NSString *const kTextJuly       =   @"July";
NSString *const kTextAugust     =   @"August";
NSString *const kTextSeptember  =   @"September";
NSString *const kTextOctober    =   @"October";
NSString *const kTextNovember   =   @"November";
NSString *const kTextDecember   =   @"December";
NSString *const kTextYear       =   @"2012";
NSString *const kTextCurentWeek =   @"CurrentWeek";
NSString *const kTextModay      =   @"Monday";
NSString *const kTextTuesday    =   @"Tuesday";
NSString *const kTextWednsday   =   @"Wednesday";
NSString *const kTextThursday   =   @"Thursday";
NSString *const kTextFriday     =   @"Friday";
NSString *const kTextSaturday   =   @"Saturday";
NSString *const kTextSunday     =   @"Sunday";


//Values For Dictionary
NSString *const kTextMon  =  @"Mon";
NSString *const kTextTue  =  @"Tue";
NSString *const kTextWed  =  @"Wed";
NSString *const kTextThu  =  @"Thu";
NSString *const kTextFri  =  @"Fri";
NSString *const kTextSat  =  @"Sat";
NSString *const kTextSun  =  @"Sun";

//Values
NSString *const kTextLogin                 = @"Login";
NSString *const kTroubleShootPlaceHolder   = @"trouble_view_placeholder_searchcriteria";

//Chatter
NSString *const kChatterPlaceHolder        = @"chatter_view_place_holder";
NSString *const kTextChatter               = @"Chatter";

//Macros defintion for getEvents

NSString *const kTextObjectApiName             =   @"ObjectAPIName";
NSString *const kTextObjectLabel               =   @"ObjectLabel";
NSString *const kTextAdditionalInfo            =   @"AdditionalInfo";
NSString *const kTextColorCode                 =   @"ColorCode";
NSString *const kTextActivityDate              =   @"ActivityDate";
NSString *const kTextActivityDateTime          =   @"ActivityDateTime";
NSString *const kTextAttachments               =   @"Attachments";
NSString *const kTextCreateDate                =   @"CreatedDate";
NSString *const kTextDescription               =   @"Description";
NSString *const kTextDurationInMinutes         =   @"DurationInMinutes";
NSString *const kTextEndDateTime               =   @"EndDateTime";
NSString *const kTextIsAllEvent                =   @"IsAllDayEvent";
NSString *const kTextIsArchived                =   @"IsArchived";
NSString *const kTextIsChild                   =   @"IsChild";
NSString *const kTextISGrouped                 =   @"IsGroupEvent";
NSString *const kTextIsPrivate                 =   @"IsPrivate";
NSString *const kTextIsReminderSet             =   @"IsReminderSet";
NSString *const kTextLocation                  =   @"Location";
NSString *const kTextStartDateTime             =   @"StartDateTime";
NSString *const kTextSubject                   =   @"Subject";
NSString *const kTextType                      =   @"Type";
NSString *const kTextWhatId                    =   @"WhatId";
NSString *const kTextEventId                   =   @"Id";

//Addtional Information
NSString *const kTextStreet        =  @"Street";
NSString *const kTextCity          =  @"City";
NSString *const kTextState         =  @"State";
NSString *const kTextCountry       =  @"Country";
NSString *const kTextZip           =  @"Zip";
NSString *const kTextLattitude     =  @"Latitude";
NSString *const kTextLongitude     =  @"Longitude";
NSString *const kTextEventLocalId  =  @"EVENT_LOCAL_ID";

//SaveTargets keys
NSString *const kTextSuccess       =  @"success";


//Create Object History
NSString *const kTextResultId              = @"resultIds";
NSString *const kTextObjectSpaceLabel      = @"Object Label";
NSString *const kTextObjectName            = @"OBJECT_NAME";
NSString *const kTextNameField             = @"Name Field";

// Macros for Settings of Location Ping
NSString *const kTextLocationTrackFequency  =  @"Location Tracking Frequency";
NSString *const kTextEnableLocationUpdate   =  @"Enable Location Tracking";
NSString *const kTextLocationRecord         =  @"Location History Records to cache";


//ORG prefix
NSString *const kTextSvmxOrgPrefix         =  ORG_NAME_SPACE;


//MapView
//TODO: Add these keys to mapview tag constants
NSString *const KMapNoValidAddress         = @"Service location is not shown because valid address does not exist for this record:";
NSString *const KMapNoValidAddresses       = @"Service locations are not shown because valid address does not exist for these records:";

NSString *const kCalDetailPhone                 = @"phone";
NSString *const kCalDetailPriority              = @"priority";
NSString *const kCalDetailBillingType           = @"billing type";
NSString *const kCalDetailOrderStatus           = @"order status";
NSString *const kCalDetailProductsAtLocation    = @"products at this location";
NSString *const kCalDetailEvent                 = @"Event";
NSString *const kCalDetailEventName             = @"event name";
NSString *const kCalDayViewEventOverlap         = @"This time overlaps with another appointment";

//Attachments
NSString *const kAttachmentCancelDownload       = @"Are you sure you want to cancel the download?";
NSString *const kAttachmentUnableDelete         = @"Upload in progress! Unable to delete";
NSString *const kAttachmentImagesAndVideos      = @"Images and Videos";

//OPDOC

NSString *const kOPDocHTMLString                = @"html";
NSString *const kOPDocSignatureString           = @"signature";
NSString *const kOPDocDeleteString              = @"delete_id";


NSString *const kAccHistory        = @"SFMPageAccHistory";
NSString *const kProHistory        = @"SFMPageProHistory";

/*Chatter*/
NSString *const kChatterAttachmentId    = @"ChatterAttachmentId";
NSString *const kChatterUserData        = @"ChatterUserData";

// IPAD-4541 - Verifaya
NSString *const kVToggleTabBar = @"ToggleTabBar";
NSString *const kVEventStartDateTime = @"kVAEventStartDateTime";
NSString *const kVEventEndDateTime = @"kVAEventEndDateTime";
NSString *const kVDataSyncLastTimeLbl = @"kVADataSyncLastTimeLabel";
NSString *const kVDataSyncLastTimeVal = @"kVADataSyncLastTimeValue";
NSString *const kVDataSyncNextTimeLbl = @"kVADataSyncNextTimeLabel";
NSString *const kVDataSyncNextTimeVal = @"kVADataSyncNextTimeValue";
NSString *const kVConfigSyncLastTimeLbl = @"kVAConfigSyncLastTimeLabel";
NSString *const kVConfigSyncLastTimeVal = @"kVAConfigSyncLastTimeValue";
NSString *const kVConfigSyncNextTimeLbl = @"kVAConfigSyncNextTimeLabel";
NSString *const kVConfigSyncNextTimeVal = @"kVAConfigSyncNextTimeValue";
NSString *const kVSignInBtn = @"kVSignInBtnLbl";
