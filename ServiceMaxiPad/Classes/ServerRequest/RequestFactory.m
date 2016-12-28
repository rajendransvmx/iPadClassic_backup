//
//  RequestFactory.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 31/05/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "RequestFactory.h"
#import "RestRequest.h"
#import "QueryZksRequest.h"
#import "ZksDescribeLayoutRequest.h"
#import "ZKSDescribeObjectRequest.h"
#import "FileDownloadRequest.h"
#import "ZKSCreateObjectRequest.h"
#import "ZKSQueryRequest.h"

@implementation RequestFactory

+ (id)requestForRequestType:(RequestType)requestType
{
    //TODO Krishhna : based on request type create the request object and return
    @synchronized([self class])
    {
        id requestClass = nil;
        switch (requestType)
        {
                
            case RequestValidateProfile :
            case RequestServicemaxVersion:
            case RequestGroupProfile:
            case RequestSFMMetaDataSync:  //metadata
            case RequestSFMMetaDataInitialSync:
            case RequestSFMPageData:
            case RequestSFMObjectDefinition:
            case RequestSFMBatchObjectDefinition:
            case RequestSFMPicklistDefinition:
            case RequestSFWMetaData:
            case RequestMobileDeviceTags:
            case RequestMobileDeviceSettings:
            case RequestSFMSearch:
            case RequestGetPriceObjects:
            case RequestGetPriceCodeSnippet:
            case RequestGetAttachment:
            case RequestProductManual:
            case RequestEvents: //Data
            case RequestDownloadCriteria:
            case RequestGetPriceDataTypeZero:
            case RequestGetPriceDataTypeOne:
            case RequestGetPriceDataTypeTwo:
            case RequestGetPriceDataTypeThree:
            case RequestTXFetch:
            case RequestProductIQTxFetch:
            case RequestAdvancedDownLoadCriteria:
            case RequestGetDelete:                     //Initial Data Sync
            case RequestgetDeleteDownloadCriteria:
            case RequestCleanUpSelect:
            case RequestCleanUp:
            case RequestPutDelete:
            case RequestPutInsert:
            case requestGetInsert:
            case RequestGetInsertDownloadCriteria:
            case RequestPutUpdate:
            case RequestGetUpdate:
            case RequestGetUpdateDownloadCriteria:
            case RequestTechnicianLocationUpdate:
            case RequestLocationHistory:
            case RequestSignatureAfterSync:
            case RequestDataPurge:
            case RequestContactImage:
            case RequestLogs:
            case RequestCustomWebServiceCall:
            case RequestTXFetchOptimized:
            case RequestSubmitDocument:
            case RequestDataOnDemandGetData:
            case RequestDataPushNotification:
            case RequestDataOnDemandGetPriceInfo:
            case RequestTypeUserTrunk:
            case RequestOneCallDataSync:
            case RequestDependantPickListRest:
            case RequestOneCallMetaSync:
            case RequestObjectDefinition:
            case RequestStaticResourceLibrary:
            case RequestDocumentInfoFetch:
            case RequestRecordType:
            case RequestTroubleshooting:
            case RequestSyncTimeLogs:
            case RequestTypeOPDocHTMLAndSignatureSubmit:
            case RequestTypeOPDocGeneratePDF:
            case RequestTypeAccountHistory:
            case RequestTypeProductHistory:
            case RequestTypeChatterrProductData:
            case RequestTypeChatterPostDetails:
            case RequestTypeChatterFeedInsert:
            case RequestTypeChatterFeedCommnetInsert:
            case RequestTypeCustomActionWebService:
            case RequestTypeCustomActionWebServiceAfterBefore:
            case RequestTypePurgeRecords:
                requestClass = [self getRestRequestByType:requestType];
                break;
            case RequestMasterSyncTimeLog:
                requestClass = [self getRestRequestByType:requestType];
                break;
            case RequestDependentPicklist:
            case RequestChatter:
            case RequestTechnicianDetails:
                requestClass = [self getRestRequestByType:requestType];
                break;
            case RequestTechnicianAddress:
                requestClass = [self getRestRequestByType:requestType];
                break;
            case RequestDownloadPdf:
            case RequestServiceReportLogo:
            case RequestRecordTypePicklist:
            case RequestCodeSnippet:
            case RequestSignatureBeforeUpdate:
            case RequestSignatureAfterUpdate:
            case RequestGeneratePDF:
                //case RequestRecordType:
            case RequestRTDependentPicklist:
                
                
            case RequestTypeCheckOPDOCUploadStatus:
            case RequestTypeOpDocUploading:
            case RequestAttachmentUpload:
            case RequestTypeChatterPost:
                requestClass = [self getZKSRequestByType:requestType];
                
                break;
            case RequestStaticResourceDownload:
            case RequestAttachmentDownload:
            case RequestDocumentDownload:
            case RequestTroubleShootDocInfoFetch:
            case RequestProductManualDownload:
            case RequestTypeChatterProductImageDownload:
            case RequestTypeChatterUserImage:
                requestClass = [self getFileDownloadRequestByType:requestType];
                break;
                
                
                /********************* dataPurge *******************//////////////
            case RequestDataPurgeFrequency:
            case RequestDatPurgeDownloadCriteria:
            case RequestDataPurgeAdvancedDownLoadCriteria:
            case RequestDataPurgeGetPriceDataTypeZero:
            case RequestDataPurgeGetPriceDataTypeOne:
            case RequestDataPurgeGetPriceDataTypeTwo:
            case RequestDataPurgeGetPriceDataTypeThree:
            case RequestDataPurgeProductIQData:
                
                requestClass = [self getRestRequestByType:requestType];
                break;
            case RequestTypeOnlineLookUp:
                
                requestClass = [self getRestRequestByType:requestType];
                break;
                
                
                /** Product IQ **/
            case RequestProductIQUserConfiguration:
            case RequestProductIQTranslations:
            case RequestProductIQObjectDescribe:
            case RequestProductIQData:
            case RequestProductIQDeleteData:
                requestClass = [self getRestRequestByType:requestType];
                break;
                
            default:
                break;
        }
        return requestClass;
    }
    return nil;
}

+ (id)getRestRequestByType:(RequestType)requestType
{
    id restRequestClass = [[RestRequest alloc]initWithType:requestType];
    
    return restRequestClass;
}

+ (id)getFileDownloadRequestByType:(RequestType)requestType
{
    id fileRequest = [[FileDownloadRequest alloc] initWithType:requestType];
    return fileRequest;
}

+ (id)getZKSRequestByType:(RequestType)requestType
{
    id zksRequestClass = nil;
    
    switch (requestType) {
        case RequestContactImage:
        case RequestDownloadPdf:
        case RequestGetAttachment:
        case RequestStaticResourceLibrary:
        case RequestGeneratePDF:
        case RequestServiceReportLogo:
        case RequestCodeSnippet:
        case RequestRecordType:
            zksRequestClass = [[QueryZksRequest alloc]initWithType:requestType];
            break;
            
        case RequestRecordTypePicklist:
        case RequestRTDependentPicklist:
            zksRequestClass = [[ZksDescribeLayoutRequest alloc]initWithType:requestType];
            break;
            
        case RequestDependentPicklist:
            zksRequestClass = [[ZKSDescribeObjectRequest alloc]initWithType:requestType];
            break;
            
        case RequestTypeOpDocUploading:
        case RequestAttachmentUpload:
            zksRequestClass = [[ZKSCreateObjectRequest alloc]initWithType:requestType];
            break;
            
        case RequestTypeChatterPost:
        case RequestTypeCheckOPDOCUploadStatus:

            zksRequestClass = [[ZKSQueryRequest alloc] initWithType:requestType];
            break;
            
            //TO DO: Check the zks type
        case RequestTroubleshooting:
        case RequestProductManual:
        case RequestChatter:
        case RequestSignatureBeforeUpdate:
        case RequestSignatureAfterUpdate:
        default:
            break;
    }
    return zksRequestClass;
}

+ (id)getSoapRequest:(RequestType)requestType
{
    return nil;
}

@end
