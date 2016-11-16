 //
//  ServiceFactory.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/12/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "ServiceFactory.h"
#import "BaseServiceLayer.h"
#import "InitialSyncServiceLayer.h"
#import "OneCallRestIntialSyncServiceLayer.h"
#import "DataSyncServiceLayer.h"
#import "OneCallDataSyncServiceLayer.h"
#import "EventSyncServiceLayer.h"
#import "ConfigSyncServiceLayer.h"
#import "OneCallConfigSyncServiceLayer.h"
#import "SFMSearchServiceLayer.h"
#import "CustomWSServiceLayer.h"
#import "SFMSearchServiceLayer.h"
#import "LocationPingServiceLayer.h"
#import "DataPurgeServiceLayer.h"
#import "AttachmentServiceLayer.h"
#import "TroubleShootingServiceLayer.h"
#import "JobLogServiceLayer.h"
#import "OpDocServiceLayer.h"
#import "TechnicianServiceLayer.h"
#import "ProductManualServiveLayer.h"
#import "SFMPageHistoryServiceLayer.h"
#import "ChatterServiceLayer.h"
#import "APNSServiceLayer.h"
#import "GetPriceDataServiceLayer.h"
#import "CustomActionWebServiceLayer.h"
#import "SFMOnlineLookUpServiceLayer.h"
#import "ProdIQDataServiceLayer.h"
#import "SyncProfileServiceLayer.h"

@implementation ServiceFactory

+(instancetype)serviceLayerWithCategoryType:(CategoryType)categoryType
                                requestType:(RequestType)requestType {
    
    @synchronized([self class]) {
        
        __autoreleasing id baseServiceLayer = nil;
        
        switch (categoryType) {
                
            case CategoryTypeInitialSync: {
                
                baseServiceLayer = [[InitialSyncServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
            break;
            case CategoryTypeResetApp: {
                
                baseServiceLayer = [[OneCallRestIntialSyncServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
                break;
                
            case CategoryTypeValidateProfile: {
                
                baseServiceLayer = [[OneCallRestIntialSyncServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
                break;

            case CategoryTypeOneCallRestInitialSync: {
                
                baseServiceLayer = [[OneCallRestIntialSyncServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
            break;
                
            case CategoryTypeDataSync: {
                
                baseServiceLayer = [[DataSyncServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
                
            case CategoryTypeOneCallDataSync: {
                
                baseServiceLayer = [[OneCallDataSyncServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
                
            case CategoryTypeEventSync: {
                
                baseServiceLayer = [[EventSyncServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;

            case CategoryTypeConfigSync: {
                
                baseServiceLayer = [[ConfigSyncServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
                
            case CategoryTypeOneCallConfigSync: {
    
                baseServiceLayer = [[OneCallConfigSyncServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
                
            case CategoryTypeDOD: {
                
                baseServiceLayer = [[SFMSearchServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
            case CategoryTypeAPNSDOD: {
                
                baseServiceLayer = [[APNSServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
                break;
                
            case CategoryTypeCustomWS: {
                
                baseServiceLayer = [[CustomWSServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
                
            case CategoryTypeSFMSearch: {
                
                baseServiceLayer = [[SFMSearchServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
                
            case CategoryTypeLocationPing: {
                
                baseServiceLayer = [[LocationPingServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
                
                
            case CategoryTypeAttachment: {
                
                baseServiceLayer = [[AttachmentServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
            case CategoryTypeAttachmentUpload: {
                
                baseServiceLayer = [[AttachmentServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
                break;
                
            case CategoryTypeTroubleShooting: {
                
                baseServiceLayer = [[TroubleShootingServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
                
            break;
                
            case CategoryTypeTroubleShootingDataDownload: {
                
                baseServiceLayer = [[TroubleShootingServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
                
            case CategoryTypeTechnicianDetails: {
                
                baseServiceLayer = [[TechnicianServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
                
            case CategoryTypeTechnicianAddress: {
                
                baseServiceLayer = [[TechnicianServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
            break;
                
            case CategoryTypeIncrementalOneCallMetaSync: {
                baseServiceLayer = [[OneCallRestIntialSyncServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
                break;
                
            case CategoryTypeJobLog: {
                baseServiceLayer = [[JobLogServiceLayer alloc]initWithCategoryType:categoryType requestType:requestType];
            }
                break;
                
            case CategoryTypeOpDoc:
            case CategoryTypeOpDocUploadStatus:
            {
                baseServiceLayer = [[OpDocServiceLayer alloc]initWithCategoryType:categoryType requestType:requestType];
            }
                break;
                /****************************dataPurge ****************************//////// */
            case CategoryTypeDataPurge:
            {
                baseServiceLayer = [[DataPurgeServiceLayer alloc]initWithCategoryType:categoryType
                                                            requestType:requestType];
            }
                break;
            case CategoryTypeDataPurgeFrequency:
            {
                baseServiceLayer = [[DataPurgeServiceLayer alloc]initWithCategoryType:categoryType requestType:requestType];
            }
                break;
                
            case CategoryTypeSubmitDocument:
            case CategoryTypeGeneratePDF:{
                baseServiceLayer = [[OpDocServiceLayer alloc]initWithCategoryType:categoryType requestType:requestType];
            }
                break;
                /******************************************************* */
                
            case CategoryTypeProductManual:
            {
                baseServiceLayer = [[ProductManualServiveLayer alloc]initWithCategoryType:categoryType requestType:requestType];
            }
            break;
            
            case CategoryTypeProductManualDownlaod:
            {
                baseServiceLayer = [[ProductManualServiveLayer alloc]initWithCategoryType:categoryType requestType:requestType];
            }
            break;
                
            case CategoryTypeProductHistory:
            case CategoryTypeAccountHistory:
            {
                baseServiceLayer = [[SFMPageHistoryServiceLayer alloc] initWithCategoryType:categoryType
                                                                                requestType:requestType];
            }
            break;
            case CategoryTypeGetPriceData: {
                baseServiceLayer = [[GetPriceDataServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
            break;
            case CategoryTypeChatter:
            case CategoryTypeChatterPosts:
            case CategoryTypeChatterUserImage:
            case CategoryTypeChatterFeedInsert:
            case CategoryTypeChatterFeedUpdate:
            {
                baseServiceLayer = [[ChatterServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
            break;
                
            case CategoryTypeCustomWebServiceCall:
            {
                baseServiceLayer =[[CustomActionWebServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
            break;
                
            case CategoryTypeCustomWebServiceAfterBeforeCall:
            {
                baseServiceLayer =[[CustomActionWebServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
                break;
                
            case CategoryTypeLookupSearch: {
                
                baseServiceLayer = [[SFMOnlineLookUpServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
                
            }
                break;
            case CategoryTypeProductIQData: {
                baseServiceLayer = [[ProdIQDataServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
                break;
            case CategoryTypeSyncProfiling: {
                baseServiceLayer = [[SyncProfileServiceLayer alloc] initWithCategoryType:categoryType requestType:requestType];
            }
                break;
            default:
                return baseServiceLayer;
                break;
        }
        return baseServiceLayer;
    }
}


@end
