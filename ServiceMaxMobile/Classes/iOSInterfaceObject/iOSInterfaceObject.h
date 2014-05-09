//
//  iOSInterfaceObject.h
//  iService
//
//  Created by Samman Banerjee on 14/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZipArchive.h"
#import "ImageCacheClass.h"
#import "ZKQueryResult.h"
#import "ZKSObject.h"
#import "Base64.h"

@class AppDelegate;

@protocol iOSInterfaceObjectDelegate

@optional
- (void) setEventDetails:(NSArray *)_eventDetails;
- (void) stopActivity;
// For week view only
- (void) didQueryWorkOrder:(NSDictionary *)dictionary;
@end


@interface iOSInterfaceObject : NSObject
{
    id<iOSInterfaceObjectDelegate> delegate;

    AppDelegate * appDelegate;
    
    ZipArchive * zip;

    id caller;

    NSString * workOrderId;
    NSString * accountId;
    
    NSMutableString * workOrderIdArrayString;
    
    NSMutableArray * workOrderIdArray;
    NSUInteger workOrderIdArrayCounter;
    
    NSString * productId;
    
    NSString * currentDate, * previousDate;
    
    NSMutableArray * eventArray;
    NSMutableArray * taskArray;
    
    NSArray * eventDetails;
    
    NSUInteger counter;
    
    NSMutableArray * workOrderDetailsArray;
	
	//pavaman 11th Jan 2011
	NSMutableArray * dateRange;
    
    // Signature Capture
    BOOL didRemovePreviousSignature, attachNewSignature;
}

@property (nonatomic, assign) id<iOSInterfaceObjectDelegate> delegate;

@property (nonatomic, assign) id caller;

@property (nonatomic, retain) NSString * topLevelId;
@property (nonatomic, retain) NSString * workOrderId;
@property (nonatomic, retain) NSString * accountId;
@property (nonatomic, retain) NSString * caseId;

@property (nonatomic, retain) NSArray * eventDetails;

- (id) initWithCaller:(id)_caller;

+ (NSString *) getLocalTimeFromGMT:(NSString *)gmtDate;
+ (NSString *) getGMTFromLocalTime:(NSString *)localTime;

//8945 day light savings 
+ (NSString *) localTimeFromGMT:(NSString *)gmtDate;
//pavaman 1st Jan 2011
//+ (NSString *) adjustDateWrapAround:(NSString *)startTime:(NSString *)endTime;//  Unused Methods

- (void) queryTasksForDate:(NSString *)date;

- (void) create:(NSArray *)objects;
- (void) update:(NSArray *)objects;
- (void) delete:(NSArray *)objects;

- (void) queryTroubleshootingForProductName:(NSString *)productName;
- (NSURLConnection *) queryTroubleshootingBodyForDocument:(NSDictionary *)documentName;

// Chatter related
- (void) getProductPictureForId:(NSString *)_productId;
- (void) queryChatterForProductId:(NSString *)_productId;
- (void) getUserNameFromId:(NSArray *)userId;
- (NSString *) dayByComparingTodayWithDate:(NSString *)date;
//- (void) getImagesForIds:(NSArray *)Ids;//  Unused Methods
//- (void) didGetUserNamesForIds:(ZKQueryResult *)result error:(NSError *)error context:(id)context;//  Unused Methods

// Product Manual
- (void) queryManualForProductName:(NSString *)productName;
- (NSURLConnection *) queryManualBodyForDocument:(NSString *)productName ManId:(NSString*)ManId;
- (void) queryServiceReportForWorkOrderId:(NSString *)woId serviceReport:(NSString *)serviceReport;

// Signature Capture
//- (void) setSignImageData:(NSData *)imageData;

//krishnasign added extra param and changed the imagename to recordId
- (void) setSignImageData:(NSData *)imageData WithId:(NSString *)SFId WithRecordId:(NSString *)recordId andSignId:(NSString *)sign;
- (void) removePreviousSignature:(NSString *)signatureName;
- (void) didGetSignatureList:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didRemoveSignature:(ZKQueryResult *)result error:(NSError *)error context:(id)context;

@end

// PLIST RELATED - Samman - 3rd Aug, 2011
#define OBJECT_HISTORY_PLIST                    @"Object_history.plist"
#define SWITCH_VIEW_LAYOUTS_PLIST               @"Switch_View_Layouts.plist"

#define POSTTYPE                                @"POSTTYPE"
#define CHATTERPOST                             @"CHATTERPOST"
#define CHATTERCOMMENTARRAY                     @"CHATTERCOMMENTARRAY"
#define FEEDPOSTID                              @"FeedPostId"
#define POSTCREATEDBYID                         @"CreatedById"
#define POSTDATESTAMP                           @"CreatedDate"
#define FEEDPOST                                @"FeedPost"
#define FEEDPOSTBODY                            @"Body"
#define USERNAME                                @"UserName"
#define USERNAME_CHATTER                        @"Username"
#define PRODUCT2FEEDID                          @"Id"

#define FEEDCOMMENTFIELD                        @"FeedComments"

#define COMMENTCREATEDBYID                      @"CreatedById"
#define COMMENTDATESTAMP                        @"CreatedDate"
#define COMMENTBODY                             @"CommentBody"

#define TYPEFEED                                @"Feed"
#define TYPECOMMENT                             @"Comment"
#define TYPECOMMENTPOST                         @"CommentPost"
#define TYPECHATSEPERATOR                       @"ChatSeperator"

#define ISERVICEFOLDER                          @"iServiceFolder"
#define FILEFOLDER                              @"FILEFOLDER"

#define IMAGE                                   @"IMAGE"
#define PARENTID                                @"ParentId"

#define EVENTARRAY                              @"EventArray"
#define WORKORDERARRAY                          @"WorkOrderArray"
#define WORKORDERDETAILSARRAY                   @"WorkOrderDetailsArray"

#define ACTIVITYDATE                            @"ActivityDate"
#define ACTIVITYDATETIME                        @"ActivityDateTime"
#define CREATEDDATE                             @"CreatedDate"
#define DURATION                                @"DurationInMinutes"
#define ENDDATETIME                             @"EndDateTime"
#define EVENTID                                 @"Id"
#define OWNERID                                 @"OwnerId"
#define STARTDATETIME                           @"StartDateTime"
#define SUBJECT                                 @"Subject"
#define WHATID                                  @"WhatId"

#define WORKORDERID                             @"Id"
#define WORKORDERPRIORITY                       @"SPR14__Priority__c"
#define WORKORDERTYPE                           @"SPR14__Order_Type__c"
#define WORKORDERCLOSEDON                       @"SPR14__Closed_On__c"
#define WORKORDERSTATUS                         @"SPR14__Order_Status__c"
#define WORKORDERDESCRIPTION                    @"SPR14__Problem_Description__c"
// #define WORKORDERSUMMARY                        @"Problem_Summery__c"
#define WORKORDERPRODUCTNAME                    @"ProductName"
#define WORKORDERPRODUCTCODE                    @"ProductCode"

#define RELATEDPRODUCTOBJ                       @"SPR14__Product__r"

#define SPR14LONGITUDE                          @"SPR14__Longitude__c"
#define SPR14LATITUDE                           @"SPR14__Latitude__c"
#define SPR14RESTORATION                        @"SPR14__Restoration_Customer_By__c"
#define SPR14RESOLUTION                         @"SPR14__Resolution_Customer_By__c"
#define SPR14CONTACTEMAIL                       @"SPR14__Contact__r.Email"
#define SPR14CONTACTPHONE                       @"SPR14__Contact__r.Phone"
#define SPR14CONTACTNAME                        @"SPR14__Contact__r.Name"
#define SPR14CONTACT                            @"SPR14__Contact__c"
#define SPR14BILLINGCOUNTRY                     @"SPR14__Company__r.BillingCountry"
#define SPR14BILLINGPOSTALCODE                  @"SPR14__Company__r.BillingPostalCode"
#define SPR14BILLINGSTATE                       @"SPR14__Company__r.BillingState"
#define SPR14BILLINGCITY                        @"SPR14__Company__r.BillingCity"
#define SPR14BILLINGSTREET                      @"SPR14__Company__r.BillingStreet"
#define SPR14COMPANY                            @"SPR14__Company__c"
#define SPR14COMPANYNAME                        @"SPR14__Company__r.Name"
#define SPR14ACCOUNTNAME                        @"AccountName"
#define SPR14COMPONENT                          @"SPR14__Component__c"
#define SPR14WORKPERFORMED                      @"SPR14__Work_Performed__c"

#define CONTACTPHONE                            @"Phone"
#define CONTACTEMAIL                            @"Email"
#define CONTACTNAME                             @"ContactName"
#define ACCOUNTBILLINGSTREET                    @"BillingStreet"
#define ACCOUNTBILLINGSTATE                     @"BillingState"
#define ACCOUNTBILLINGPOSTALCODE                @"BillingPostalCode"
#define ACCOUNTBILLINGCOUNTRY                   @"BillingCountry"
#define ACCOUNTBILLINGCITY                      @"BillingCity"

#define WORKORDERSTREET                         @"SPR14__Street__c"
#define WORKORDERCITY                           @"SPR14__City__c"
#define WORKORDERSTATE                          @"SPR14__State__c"
#define WORKORDERZIP                            @"SPR14__Zip__c"
#define WORKORDERCOUNTRY                        @"SPR14__Country__c"

//pavaman 25th Jan 2011
#define WORKORDERCURRENCY						@"CurrencyIsoCode"

//pavaman 1st Feb 2011
#define RELATED_COMPONENT						@"SPR14__Component__r"
#define RELATED_COMPONENT_NAME					@"ComponentName"

#define WORKORDERNAME                           @"Name"
#define PROBLEMSUMMARY                          @"SPR14__Problem_Description__c"
#define TOPLEVELID                              @"SPR14__Top_Level__c"
#define ACCOUNTID                               @"SPR14__Company__c"
#define CASEID                                  @"SPR14__Case__c"
#define PRODUCTID                               @"SPR14__Product__c"
#define BILLINGCITY                             @"BillingCity"
#define BILLINGCOUNTRY                          @"BillingCountry"
#define BILLINGPOSTALCODE                       @"BillingPostalCode"
#define BILLINGSTATE                            @"BillingState"
#define BILLINGSTREET                           @"BillingStreet"
#define CUSTOMERNAME                            @"CustomerName"
#define CUSTOMEREMAIL                           @"CustomerEmail"
#define CUSTOMERPHONE                           @"CustomerPhone"

//sahana 17th Aug
#define FULLPHOTOURL                            @"FullPhotoUrl"
#define URLCONNECTION                           @"URLCONNECTION"


// Task
#define TASKID                                  @"Id"
#define TASKPRIORITY                            @"Priority"
#define TASKDESCRIPTION                         @"Description"
#define TASKSUBJECT                             @"Subject"
#define TASKACTIVITYDATE                        @"ActivityDate"
#define TASKOWNERID                             @"OwnerId"
#define TASKISRECURRENCE                        @"IsRecurrence"
#define TASKSTATUS                              @"Status"

// Work Order Describe
#define ROOTCAUSE                               @"SPR14__Root_Cause__c"
#define SYMPTOM                                 @"SPR14__Symptom__c"
#define FAILEDASSEMBLY                          @"SPR14__Failed_Assembly__c"
#define HOWFIXED                                @"SPR14__How_Fixed__c"

// ##############################################################################
// TROUBLESHOOTING
#define FILEID                                  @"FILEID"
#define FILENAME                                @"FILENAME"
#define FOLDERNAMETOCREATE                      @"FOLDERNAMETOCREATE"
#define CELLINDEX                               @"CELLINDEX"

#define ACCOUNT                                 @"SPR14__Company__r"
#define CONTACT                                 @"SPR14__Contact__r"

