//
//  SyncConstants.h
//  ServiceMaxMobile
//
//  Created by Shravya shridhar on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CategoryType) {
    
    CategoryTypeInitialSync,
    CategoryTypeOneCallRestIntialSync,
    CategoryTypeDataSync,
    CategoryTypeOneCallDataSync,
    CategoryTypeIncrementalOneCallMetaSync,
    CategoryTypeEventSync,
    CategoryTypeConfigSync,
    CategoryTypeOneCallConfigSync,
    CategoryTypeDOD,
    CategoryTypeCustomWS,
    CategoryTypeSFMSearch,
    CategoryTypeLocationPing,
    CategoryTypeDataPurge,
    CategoryTypeAttachment,
    CategoryTypeTroubleShooting,
    CategoryTypeTroubleShootingDataDownload,
    CategoryTypeJobLog,
    CategoryTypeResetApp,
    CategoryTypeValidateProfile

};

typedef NS_ENUM(NSUInteger, SyncType) {
    SyncTypeInitial,
    SyncTypeConfig,
    SyncTypeData,
    SyncTypeEvent,
    SyncTypeReset,
    SyncTypeValidateProfile
};

typedef NS_ENUM(NSUInteger, SyncStatus) {
    SyncStatusInQueue,
    SyncStatusSuccess,
    SyncStatusInProgress,
    SyncStatusPaused,
    SyncStatusFailed,
    SyncStatusConflict,
    SyncStatusNetworkError
};


typedef  NS_ENUM(NSUInteger, SyncProgressStatus) {
    SyncStatusvalidateProfile = 1,
    SyncStatusDeviceTagsDownloading,
    SyncStatusOneCallSync,
    SyncStatusObjectDefinitionsDownloading,
    SyncStatusDependentPicklistDownloading,
    SyncStatusPageLayoutDownlaoding,
    SyncStatusRTPicklistDownlaoding ,
    SyncStatusDownloadingEvents ,
    SyncStatusDownloadingRecords ,
    SyncStatusDownloadingTXFETCH,
    SyncStatusCompleted,
    SyncStatusFailedWithError
} ;
