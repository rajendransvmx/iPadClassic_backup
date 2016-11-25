//
//  ParserFactory.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/19/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ParserFactory.h"
#import "MobileDeviceTagParser.h"
#import "OneCallMetaDataParser.h"
#import "SfmPageDataParser.h"
#import "EventResponseParser.h"
#import "ObjectDefinitionParser.h"
#import "RecordTypeParser.h"
#import "TXFetchParser.h"
#import "DependentPickListParser.h"
#import "RTDependentPicklistParser.h"
#import "ADCResponseParser.h"
#import "GetPriceObjectParser.h"
#import "GetPriceDataParser.h"
#import "StaticResourceParser.h"
#import "GetPriceCodeSnippetParser.h"
#import "DCResponseParserV3.h"
#import "DocumentInformationParser.h"
#import "OneCallDataSyncResponseParser.h"
#import "TroubleShootingParser.h"
#import "DataPurgeParser.h"
#import "ProductManualParser.h"
#import "DODParser.h"
#import "SFMSearchParser.h"
#import "SFMPageHistoryParser.h"
#import "ChatterProductDataParser.h"
#import "ChatterPostParser.h"
#import "ChatterPostDetailsParser.h"
#import "ChatterFeedsParser.h"
#import "UserTrunkDataParser.h"
#import "APNSParser.h"
#import "CustomWebServiceParser.h"
#import "SFMOnlineLookUpParser.h"
#import "ProdIQUserConfigParser.h"
#import "ProdIQTranslationsParser.h"
#import "ProdIQObjectDescribeParser.h"
#import "ProdIQDataParser.h"
#import "ProdIQDeleteDataParser.h"
#import "MobileDataUsageParser.h"
#import "PurgeRecordsParser.h"
#import "ValidateProfileParser.h"

@implementation ParserFactory

+(instancetype)parserWithRequestType:(RequestType)requestType {
    
    @synchronized([self class]) {
        
    __autoreleasing id parser;
        
        switch (requestType) {
                
            case RequestValidateProfile:
                parser = [[ValidateProfileParser alloc] init];
                break;
                
            case RequestServicemaxVersion:
                
                break;
                
            case RequestGroupProfile:
                //parser = [[GroupProfileParser alloc] init];
                break;
                
            case RequestSFMMetaDataSync:
                
                break;
                
            case RequestSFMMetaDataInitialSync:
                
                break;
                
            case RequestSFMPageData:
                parser = [[SfmPageDataParser alloc] init];
                break;
                
            case RequestSFMObjectDefinition:
                
                break;
                
            case RequestSFMBatchObjectDefinition:
                
                break;
                
            case RequestSFMPicklistDefinition:
                
                break;
                
            case RequestRecordTypePicklist:
                
                break;
                
            case RequestRecordType:
                parser = [[RecordTypeParser alloc] init];
                break;
                
            case RequestSFWMetaData:
                
                break;
                
            case RequestMobileDeviceTags:
                parser = [[MobileDeviceTagParser alloc] init];
                break;
                
            case RequestMobileDeviceSettings:
                parser = [[OneCallMetaDataParser alloc] init];
                break;
                
            case RequestSFMSearch:
                parser = [[SFMSearchParser alloc] init];
                break;
                
            case RequestGetPriceObjects:
                parser = [[GetPriceObjectParser alloc]init];
                break;
                
            case RequestGetPriceCodeSnippet:
                parser = [[GetPriceCodeSnippetParser alloc]init];
                break;
                
            case RequestDependentPicklist:
                
                break;
                
            case RequestCodeSnippet:
                
                break;
                
            case RequestEvents:
                parser = [[EventResponseParser alloc] init];
                break;
                
            case RequestDownloadCriteria:
                parser = [[DCResponseParserV3 alloc] init];
                break;
                
            case RequestGetPriceDataTypeZero:
                parser = [[GetPriceDataParser alloc] init];
                break;
                
            case RequestGetPriceDataTypeOne:
                parser = [[GetPriceDataParser alloc] init];
                break;
                
            case RequestGetPriceDataTypeTwo:
                parser = [[GetPriceDataParser alloc] init];
                break;
                
            case RequestGetPriceDataTypeThree:
                parser = [[GetPriceDataParser alloc] init];
                break;
                
            case RequestTXFetch:
            case RequestProductIQTxFetch:
                parser = [[TXFetchParser alloc] init];
                break;
                
            case RequestAdvancedDownLoadCriteria:
                parser = [[ADCResponseParser alloc] init];
                break;
                
            case RequestGetDelete:
                
                break;
                
            case RequestgetDeleteDownloadCriteria:
                
                break;
                
            case RequestCleanUpSelect:
            case RequestCleanUp:
                break;
                
            case RequestPutDelete:
                
                break;
                
            case RequestPutInsert:
                
                break;
                
            case requestGetInsert:
                
                break;
                
            case RequestGetInsertDownloadCriteria:
                
                break;
                
            case RequestSignatureBeforeUpdate:
                
                break;
                
            case RequestPutUpdate:
                
                break;
                
            case RequestSignatureAfterUpdate:
                
                break;
                
            case RequestGetUpdate:
                
                break;
                
            case RequestGetUpdateDownloadCriteria:
                
                break;
                
            case RequestTechnicianLocationUpdate:
                
                break;
                
            case RequestLocationHistory:
                
                break;
                
            case RequestSignatureAfterSync:
                
                break;
                
            case RequestDataPurge:
                
                break;
                
            case RequestContactImage:
                
                break;
                
            case RequestLogs:
                
                break;
                
            case RequestCustomWebServiceCall:
                
                break;
                
            case RequestTXFetchOptimized:
                
                break;
                
            case RequestStaticResourceLibrary:
                parser = [[StaticResourceParser alloc]init];
                break;
                
            case RequestSubmitDocument:
                
                break;
                
            case RequestGeneratePDF:
                
                break;
                
            case RequestTroubleshooting:
                parser = [[TroubleshootingParser alloc]init];
                break;
                
            case RequestDataOnDemandGetPriceInfo:
                break;
                
            case RequestDataOnDemandGetData:
                parser = [[DODParser alloc]init];
                break;
                
            case RequestDataPushNotification:
                parser = [[APNSParser alloc]init];
                break;
                
            case RequestTypeUserTrunk:
                parser = [UserTrunkDataParser new];
                break;
                
            case RequestChatter:
                
                break;
                
            case RequestDownloadPdf:
                
                break;
                
            case RequestGetAttachment:
                
                break;
                
            case RequestTechnicianDetails:
                
                break;
                
            case RequestTechnicianAddress:
                
                break;
                
            case RequestServiceReportLogo:
                
                break;
                
            case RequestOneCallDataSync:
                parser = [[OneCallDataSyncResponseParser alloc] init];
                break;
                
            case RequestTypePurgeRecords:
                parser = [[PurgeRecordsParser alloc] init];
                break;
                
            case RequestDependantPickListRest:
                parser = [[DependentPickListParser alloc]init];
                break;
                
            case RequestOneCallMetaSync:
                parser = [[OneCallMetaDataParser alloc] init];
                break;
                
            case RequestObjectDefinition:
                parser = [[ObjectDefinitionParser alloc] init];
                break;
                
            case RequestRTDependentPicklist:
                parser = [[RTDependentPicklistParser alloc]init];
                break;
            case RequestDocumentInfoFetch:
                parser = [[DocumentInformationParser alloc]init];
                break;
                
                /****************datapurgeparser *********************/
            case RequestDataPurgeFrequency:
            case RequestDatPurgeDownloadCriteria:
            case RequestDataPurgeAdvancedDownLoadCriteria:
            case RequestDataPurgeGetPriceDataTypeZero:
            case RequestDataPurgeGetPriceDataTypeOne:
            case RequestDataPurgeGetPriceDataTypeTwo:
            case RequestDataPurgeGetPriceDataTypeThree:
            case RequestDataPurgeProductIQData:
                parser = [[DataPurgeParser alloc] init];
                break;
            case RequestProductManual:
                parser = [[ ProductManualParser alloc] init];
                break;
            case RequestTypeAccountHistory:
            case RequestTypeProductHistory:
                parser = [[SFMPageHistoryParser alloc] init];
                break;
                
            case RequestTypeChatterrProductData:
            case RequestTypeChatterProductImageDownload:
                parser = [[ChatterProductDataParser alloc] init];
                break;
            case RequestTypeChatterPost:
                parser = [[ChatterPostParser alloc] init];
                break;
            case RequestTypeChatterPostDetails:
                parser = [[ChatterPostDetailsParser alloc] init];
                break;
            case RequestTypeChatterFeedInsert:
            case RequestTypeChatterFeedCommnetInsert:
                parser = [[ChatterFeedsParser alloc] init];
                break;
            case RequestTypeCustomActionWebService:
                parser = [[CustomWebServiceParser alloc] init];
                break;
            case RequestTypeCustomActionWebServiceAfterBefore:
                parser = [[CustomWebServiceParser alloc] init];
                break;
            case RequestTypeOnlineLookUp:
                parser = [[SFMOnlineLookUpParser alloc] init];
                break;
            case RequestProductIQUserConfiguration:
                parser = [[ProdIQUserConfigParser alloc] init];
                break;
            case RequestProductIQTranslations:
                parser = [[ProdIQTranslationsParser alloc] init];
                break;
            case RequestProductIQObjectDescribe:
                parser = [[ProdIQObjectDescribeParser alloc] init];
                break;
            case RequestProductIQData:
                parser = [[ProdIQDataParser alloc] init];
                break;
            case RequestProductIQDeleteData:
                parser = [[ProdIQDeleteDataParser alloc] init];
                break;
            case RequestMasterSyncTimeLog:
                parser = [[MobileDataUsageParser alloc] init];
                break;
            default:
                SXLogWarning(@"Invalid parser type requested");
                break;
        }
    return parser;
    }
}

@end
