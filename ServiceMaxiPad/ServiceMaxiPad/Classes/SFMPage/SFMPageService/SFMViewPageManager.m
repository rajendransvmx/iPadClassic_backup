//
//  SFMViewPageManager.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMViewPageManager.h"
#import "SFMPageHelper.h"
#import "PlistManager.h"
#import "StringUtil.h"
#import "SFExpressionParser.h"
#import "SFProcessModel.h"
#import "SFMRecordFieldData.h"

@implementation SFMViewPageManager


- (id)initWithObjectName:(NSString *)objectName
                recordId:(NSString *)recordLocalId
{
    self = [super init];
    if (self) {
        self.objectName = objectName;
        self.recordId = recordLocalId;
        self.processId = [self processIdForViewProcess];
    }
    return self;
}

- (SFMPageViewModel *) sfmPageView
{
    SFMPageViewModel * pageView = [[SFMPageViewModel alloc] init];
    
    pageView.sfmPage = [self sfmPage];
    
    if ([self isSFMPageHasSLAClock:pageView.sfmPage]){
        pageView.slaClock = [self getSlaClockRelatedInfo];
    }
    if ([self isSFMPageHasAccountHistoty:pageView.sfmPage]){
        pageView.accountHistory = [self getAccountHistoryDetails];
    }
    if ([self isSFMPageHasProductHistory:pageView.sfmPage]){
        pageView.productHistory = [self getProductHistoryDetails];
    }
    
    NSDictionary *dict = [self getContactRelatedDetailsForHeader:pageView.sfmPage.headerRecord];
    
    if ([dict count] > 0){
        pageView.contactNUmber = [dict objectForKey:@"MobilePhone"];
        pageView.contactMail = [dict objectForKey:@"Email"];
    }
    
    return pageView;
}


- (NSString *) processIdForViewProcess
{
    NSString *processId = [PlistManager getLastUsedViewProcessForObjectName:self.objectName];
    if ((![StringUtil isStringEmpty:processId]) && ([self isValidProcess:processId error:NULL])) {
        NSLog(@"Valid process in switch layout");
    }
    else
    {
        NSArray *processArray = [SFMPageHelper getAllProcessForType:kProcessTypeView name:self.objectName];
        for (SFMProcess *process in processArray) {
            if ([self isValidProcess:process.processInfo.sfID error:NULL]) {
                processId = process.processInfo.sfID;
                break;
            }
        }
    }
    return processId;
}

- (SLAClock *)getSlaClockRelatedInfo
{
    SLAClock *clockInfo = nil;
    
    NSDictionary *infoDict = [SFMPageHelper getSlAInFo:self.objectName localId:self.recordId
                                            fieldNames:[self getSlaRelatedFields]];
    
    if (infoDict != nil) {
        clockInfo = [[SLAClock alloc] initWithDictionary:infoDict];
    }
    return clockInfo;
}

- (NSArray *)getSlaRelatedFields
{
    NSArray *slaFields = [NSArray arrayWithObjects:kSLARestoratorationCustomer, kSLAResolutionCustomer, kSLAActualRestoration, kSLAActualResolution, kSLAClockPauseTime, kSLAClockPaused, nil];
    return slaFields;
}


- (NSArray *)getAccountHistoryDetails
{
    return [SFMPageHelper getAccountHistoryInfo:self.objectName localId:self.recordId];
}

- (NSArray *)getProductHistoryDetails
{
    return [SFMPageHelper getProductHistoryInfo:self.objectName localId:self.recordId];
}

- (BOOL)isViewProcessExistsForObject:(NSString *)objectName recordId:(NSString *)sfId
{
    BOOL viewRecordExists = NO;
    
    //First check fo record exist for object
    viewRecordExists = [SFMPageHelper isRecordExistsForObject:objectName sfid:sfId];
    
    if (viewRecordExists){
        viewRecordExists = NO;
        NSArray *processArray = [SFMPageHelper getAllProcessForType:kProcessTypeView name:objectName];
        for (SFMProcess *process in processArray) {
            if ([self isValidProcess:process.processInfo.sfID error:NULL]) {
                viewRecordExists = YES;
                break;
            }
        }
    }
    return viewRecordExists;
}

- (NSDictionary *)getContactRelatedDetailsForHeader:(NSDictionary *)headerRecord
{
    SFMRecordFieldData *fieldData = [headerRecord objectForKey:kWorkOrderContactId];
    
    if ([fieldData.internalValue length] > 0 && fieldData.isReferenceRecordExist) {
        NSDictionary *dataDict = [SFMPageHelper getContactDetailsOfContactId:fieldData.internalValue object:@"Contact"];
        return dataDict;
    }
    return nil;
}

- (BOOL)isSFMPageHasAccountHistoty:(SFMPage *)page
{
    SFMHeaderLayout *headerLayout = page.process.pageLayout.headerLayout;
    return [headerLayout isAccountyHistoryExists];
}

- (BOOL)isSFMPageHasProductHistory:(SFMPage *)page
{
    SFMHeaderLayout *headerLayout = page.process.pageLayout.headerLayout;
    return [headerLayout isProductHistoryExists];
}

- (BOOL)isSFMPageHasSLAClock:(SFMPage *)page
{
    BOOL isSLAClock = NO;
    
    NSArray *sections = page.process.pageLayout.headerLayout.sections;
    
    for (SFMHeaderSection *eachSection in sections){
        isSLAClock = [eachSection isSectionSLAClock];
        if (isSLAClock) {
            break;
        }
    }
    return isSLAClock;
}

@end
