//
//  SyncProgressStatusHandler.m
//  ServiceMaxiPhone
//
//  Created by Radha Sathyamurthy on 28/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SyncProgressStatusHandler.h"
#import "TagManager.h"


@implementation SyncProgressStatusHandler


- (SyncProgressDetailModel *)getProgressDetailsForStatus:(WebserviceResponseStatus *)responseStatus{
    SyncProgressDetailModel * progressModel = nil;
    
    switch (responseStatus.category) {
    case  CategoryTypeInitialSync:
        break;
        case  CategoryTypeOneCallRestInitialSync:
             progressModel = [self getDetailsForOneCallRestIntialSync:responseStatus];
            break;
        case  CategoryTypeResetApp:
            progressModel = [self getDetailsForOneCallRestIntialSync:responseStatus];
            break;
            
        case  CategoryTypeValidateProfile:
            progressModel = [self getDetailsForValidationProfile:responseStatus];
            break;
            
    case   CategoryTypeDataSync:
        break;
            
    case CategoryTypeOneCallDataSync:
        break;
            
    case   CategoryTypeEventSync:
        break;
            
    case  CategoryTypeConfigSync:
        {
            progressModel = [self getDetailsForOneCallRestIntialSync:responseStatus];
        }
        break;
            
    case  CategoryTypeDOD:
        break;
            
    case  CategoryTypeCustomWS:
        break;
            
    case CategoryTypeSFMSearch:
        break;
            
    case CategoryTypeIncrementalOneCallMetaSync:
        {
            progressModel = [self getDetailsForIncrementalOneCallMetaSync:responseStatus];
        }
        break;
        
    default:
            break;
    }
    
    return progressModel;
}

- (SyncProgressDetailModel *)getDetailsForOneCallRestIntialSync:(WebserviceResponseStatus *)responseStatus
{
    @synchronized([self class])
    {
        NSString *message = @"";
        NSString *currentStep = @"";
        NSString *progress = @"";
        NSString *numOfSteps = @"6";
        
        /*
        Downloading translations. -IPAD018_TAG084
        Downloading SFM process definition, wizard configuration and user profile settings . - IPAD018_TAG085
        Downloading SFM page layout definition. - IPAD018_TAG086
        Downloading object and picklist definition. - IPAD018_TAG087
        Downloading events and its related record id's. - IPAD018_TAG088
        Downloading dataset record id's. - IPAD018_TAG120
        Download data. - IPAD018_TAG121
         */
        
        @autoreleasepool
        {
            switch (responseStatus.syncProgressState)
            {
                case SyncStatusDeviceTagsDownloading:
                    message =  [[TagManager sharedInstance]tagByName:kTag_Downloading_translations];
                    currentStep = @"1";
                    progress = @"5";
                    break;
                    
                case SyncStatusOneCallSync:
                    message =   [[TagManager sharedInstance]tagByName:kTag_Downloading_ProcessDefinition_ProfileSettings];               currentStep = @"1";
                    progress = @"10";
                    break;
                    
                case SyncStatusObjectDefinitionsDownloading: //first one
                    message =     [[TagManager sharedInstance]tagByName:kTag_Downloading_Object_Picklist];
                    currentStep = @"3";
                    progress = @"30";
                    break;
                    
                case SyncStatusPageLayoutDownlaoding:
                    message =    [[TagManager sharedInstance]tagByName:kTag_Downloading_PageLayout];
                    currentStep = @"2";
                    progress = @"20";
                    break;
                    
                case SyncStatusDependentPicklistDownloading: //second one
                    message =    [[TagManager sharedInstance]tagByName:kTag_Downloading_Object_Picklist];                    currentStep = @"3";
                    progress = @"40";
                    break;
                    
                case SyncStatusRTPicklistDownlaoding: //third one
                    message =  [[TagManager sharedInstance]tagByName:kTag_Downloading_Object_Picklist];                    currentStep = @"3";
                    progress = @"40";
                    break;
                    
                case SyncStatusDownloadingEvents:
                    message =   [[TagManager sharedInstance]tagByName:kTag_Downloading_Event_RelatedRecord];                    currentStep = @"4";
                    progress = @"60";
                    break;
                    
                case SyncStatusDownloadingRecords:
                    message = [[TagManager sharedInstance]tagByName:kTag_Downloading_Event_RelatedRecord];                     currentStep = @"5";
                    progress = @"70";
                    break;
                    
                case SyncStatusDownloadingTXFETCH:
                    message =   [[TagManager sharedInstance]tagByName:kTag_Download_Data];
                    currentStep = @"6";
                    progress = @"80";
                    break;
                case SyncStatusCompleted:
                    message =   @"Download complete.";
                    currentStep = @"6";
                    progress = @"100";
                    break;
                    
                case SyncStatusvalidateProfile:
                    message =  [[TagManager sharedInstance]tagByName:kTag_ValidatingProfile];
                    currentStep = @"1";
                    progress = @"5";
                    break;
                    
                default:
                    break;
            }
        }
        SyncProgressDetailModel * progressModel = [[SyncProgressDetailModel alloc] initWithProgress:progress
                                                                                        currentStep:currentStep
                                                                                            message:message
                                                                                         totalSteps:numOfSteps
                                                                                         syncStatus:responseStatus.syncStatus];
        return progressModel;
    }
}

- (SyncProgressDetailModel *)getDetailsForIncrementalOneCallMetaSync:(WebserviceResponseStatus *)responseStatus
{
    @synchronized([self class])
    {
        NSString *message = @"";
        NSString *currentStep = @"";
        NSString *progress = @"";
        NSString *numOfSteps = @"4";
        
        @autoreleasepool
        {
            switch (responseStatus.syncProgressState)
            {
                case SyncStatusDeviceTagsDownloading:
                    message = [[TagManager sharedInstance]tagByName:kTag_Downloading_translations];//[[SMXTagsManager sharedTagManager]getTagForId:Tag_Downloading_translations];
                    currentStep = @"1";
                    progress = @"5";
                    break;
                    
                case SyncStatusOneCallSync:
                    message =   [[TagManager sharedInstance]tagByName:kTag_Downloading_ProcessDefinition_ProfileSettings];                   currentStep = @"1";
                    progress = @"10";
                    break;
                    
                    
                case SyncStatusPageLayoutDownlaoding:
                    message =     [[TagManager sharedInstance]tagByName:kTag_Downloading_PageLayout];
                    currentStep = @"2";
                    progress = @"30";
                    break;
                    
                case SyncStatusRTPicklistDownlaoding: //third one
                    message =   [[TagManager sharedInstance]tagByName:kTag_Downloading_Object_Picklist];                    currentStep = @"3";
                    progress = @"60";
                    break;
                    
                case SyncStatusObjectDefinitionsDownloading: //first one
                    message =     [[TagManager sharedInstance]tagByName:kTag_Downloading_Object_Picklist];                    currentStep = @"3";
                    progress = @"50";
                    break;
                    
                    
                case SyncStatusDependentPicklistDownloading: //second one
                    message =    [[TagManager sharedInstance]tagByName:kTag_Downloading_Object_Picklist];                    currentStep = @"3";
                    progress = @"80";
                    break;
                    
                    
                case SyncStatusCompleted:
                    message =   @"Download completed";//[[SMXTagsManager sharedTagManager]getTagForId:Tag_Downloading_Data];
                    currentStep = @"4";
                    progress = @"100";
                    break;
                    
                default:
                    break;
            }
        }
        
        SyncProgressDetailModel * progressModel = [[SyncProgressDetailModel alloc] initWithProgress:progress
                                                                                        currentStep:currentStep
                                                                                            message:message
                                                                                         totalSteps:numOfSteps
                                                                                         syncStatus:responseStatus.syncStatus];
        return progressModel;
    }
}

- (SyncProgressDetailModel *)getDetailsForValidationProfile:(WebserviceResponseStatus *)responseStatus
{
    @synchronized([self class])
    {
    SyncProgressDetailModel * progressModel = [[SyncProgressDetailModel alloc] initWithProgress:nil currentStep:nil message:[[TagManager sharedInstance]tagByName:kTag_ProfileValidationInProgress] totalSteps:nil syncStatus:responseStatus.syncStatus];
    return progressModel;
    }
}
@end
