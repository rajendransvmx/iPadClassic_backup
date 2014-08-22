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
#define WORKORDERPRIORITY                       @"SVMXDEV__Priority__c"
#define WORKORDERTYPE                           @"SVMXDEV__Order_Type__c"
#define WORKORDERCLOSEDON                       @"SVMXDEV__Closed_On__c"
#define WORKORDERSTATUS                         @"SVMXDEV__Order_Status__c"
#define WORKORDERDESCRIPTION                    @"SVMXDEV__Problem_Description__c"
// #define WORKORDERSUMMARY                        @"Problem_Summery__c"
#define WORKORDERPRODUCTNAME                    @"ProductName"
#define WORKORDERPRODUCTCODE                    @"ProductCode"

#define RELATEDPRODUCTOBJ                       @"SVMXDEV__Product__r"

#define SVMXDEVLONGITUDE                          @"SVMXDEV__Longitude__c"
#define SVMXDEVLATITUDE                           @"SVMXDEV__Latitude__c"
#define SVMXDEVRESTORATION                        @"SVMXDEV__Restoration_Customer_By__c"
#define SVMXDEVRESOLUTION                         @"SVMXDEV__Resolution_Customer_By__c"
#define SVMXDEVCONTACTEMAIL                       @"SVMXDEV__Contact__r.Email"
#define SVMXDEVCONTACTPHONE                       @"SVMXDEV__Contact__r.Phone"
#define SVMXDEVCONTACTNAME                        @"SVMXDEV__Contact__r.Name"
#define SVMXDEVCONTACT                            @"SVMXDEV__Contact__c"
#define SVMXDEVBILLINGCOUNTRY                     @"SVMXDEV__Company__r.BillingCountry"
#define SVMXDEVBILLINGPOSTALCODE                  @"SVMXDEV__Company__r.BillingPostalCode"
#define SVMXDEVBILLINGSTATE                       @"SVMXDEV__Company__r.BillingState"
#define SVMXDEVBILLINGCITY                        @"SVMXDEV__Company__r.BillingCity"
#define SVMXDEVBILLINGSTREET                      @"SVMXDEV__Company__r.BillingStreet"
#define SVMXDEVCOMPANY                            @"SVMXDEV__Company__c"
#define SVMXDEVCOMPANYNAME                        @"SVMXDEV__Company__r.Name"
#define SVMXDEVACCOUNTNAME                        @"AccountName"
#define SVMXDEVCOMPONENT                          @"SVMXDEV__Component__c"
#define SVMXDEVWORKPERFORMED                      @"SVMXDEV__Work_Performed__c"

#define CONTACTPHONE                            @"Phone"
#define CONTACTEMAIL                            @"Email"
#define CONTACTNAME                             @"ContactName"
#define ACCOUNTBILLINGSTREET                    @"BillingStreet"
#define ACCOUNTBILLINGSTATE                     @"BillingState"
#define ACCOUNTBILLINGPOSTALCODE                @"BillingPostalCode"
#define ACCOUNTBILLINGCOUNTRY                   @"BillingCountry"
#define ACCOUNTBILLINGCITY                      @"BillingCity"

#define WORKORDERSTREET                         @"SVMXDEV__Street__c"
#define WORKORDERCITY                           @"SVMXDEV__City__c"
#define WORKORDERSTATE                          @"SVMXDEV__State__c"
#define WORKORDERZIP                            @"SVMXDEV__Zip__c"
#define WORKORDERCOUNTRY                        @"SVMXDEV__Country__c"

//pavaman 25th Jan 2011
#define WORKORDERCURRENCY						@"CurrencyIsoCode"

//pavaman 1st Feb 2011
#define RELATED_COMPONENT						@"SVMXDEV__Component__r"
#define RELATED_COMPONENT_NAME					@"ComponentName"

#define WORKORDERNAME                           @"Name"
#define PROBLEMSUMMARY                          @"SVMXDEV__Problem_Description__c"
#define TOPLEVELID                              @"SVMXDEV__Top_Level__c"
#define ACCOUNTID                               @"SVMXDEV__Company__c"
#define CASEID                                  @"SVMXDEV__Case__c"
#define PRODUCTID                               @"SVMXDEV__Product__c"
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
#define ROOTCAUSE                               @"SVMXDEV__Root_Cause__c"
#define SYMPTOM                                 @"SVMXDEV__Symptom__c"
#define FAILEDASSEMBLY                          @"SVMXDEV__Failed_Assembly__c"
#define HOWFIXED                                @"SVMXDEV__How_Fixed__c"

// ##############################################################################
// TROUBLESHOOTING
#define FILEID                                  @"FILEID"
#define FILENAME                                @"FILENAME"
#define FOLDERNAMETOCREATE                      @"FOLDERNAMETOCREATE"
#define CELLINDEX                               @"CELLINDEX"

#define ACCOUNT                                 @"SVMXDEV__Company__r"
#define CONTACT                                 @"SVMXDEV__Contact__r"

