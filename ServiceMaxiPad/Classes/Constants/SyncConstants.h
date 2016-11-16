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
    CategoryTypeOneCallRestInitialSync,
    CategoryTypeDataSync,
    CategoryTypeOneCallDataSync,
    CategoryTypeIncrementalOneCallMetaSync,
    CategoryTypeEventSync,
    CategoryTypeConfigSync,
    CategoryTypeOneCallConfigSync,
    CategoryTypeDOD,
    CategoryTypeAPNSDOD,
    CategoryTypeCustomWS,
    CategoryTypeSFMSearch,
    CategoryTypeLocationPing,
    CategoryTypeDataPurgeFrequency,
    CategoryTypeAttachment,
    CategoryTypeAttachmentUpload,
    CategoryTypeTroubleShooting,
    CategoryTypeTroubleShootingDataDownload,
    CategoryTypeTechnicianAddress,
    CategoryTypeTechnicianDetails,
    CategoryTypeJobLog,
    CategoryTypeResetApp,
    CategoryTypeValidateProfile,
    CategoryTypeDataPurge,
    CategoryTypeGetPriceData,
    
    /******* productManual ******************/
    CategoryTypeProductManual,
    CategoryTypeProductManualDownlaod,
    /**************************************/
    
    CategoryTypeOpDocUploadStatus,
    CategoryTypeOpDoc,
    CategoryTypeSubmitDocument,
    CategoryTypeGeneratePDF,
    
    /***SFMPage History*/
    CategoryTypeProductHistory,
    CategoryTypeAccountHistory,
    
    /****Chattter****/
    CategoryTypeChatter,
    CategoryTypeChatterPosts,
    CategoryTypeChatterUserImage,
    CategoryTypeChatterFeedInsert,
    CategoryTypeChatterFeedUpdate,
    
    /***CustomAction--Call webView*****/
    CategoryTypeCustomWebServiceCall,
    CategoryTypeCustomWebServiceAfterBeforeCall,
    
    /*** Lookup Online Search ***/
     CategoryTypeLookupSearch,
    
    /** Product IQ **/
    CategoryTypeProductIQData,
    
    /** Sync Profling **/
    CategoryTypeSyncProfiling
};

typedef NS_ENUM(NSUInteger, SyncType) {
    SyncTypeUnknown = -1,
    SyncTypeInitial = 1,
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
    SyncStatusNetworkError,
    SyncStatusRefreshTokenFailedWithError,
    SyncStatusInCancelled,
    
    //Added for Data Purge
    DataPurgeInProgress,
    DataPurgeCompleted,
    DataPurgeCancelled
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
    SyncStatusFailedWithError,
    SyncStatusFailedWithRevokeTokenFlag,
    ChatterStatusProductImageDownloaded,
    ChattetStautusCompleted,
    ChatterFeedPostStatusCompleted,
    
    
} ;

extern NSString *const kParallelGetPriceSync;
