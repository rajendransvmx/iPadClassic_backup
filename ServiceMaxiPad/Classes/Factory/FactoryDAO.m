//
//  FactoryDAO.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/27/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "FactoryDAO.h"
#import "SFProcessDAO.h"
#import "SFProcessService.h"
#import "AttachmentService.h"
#import "AttachmentErrorService.h"
#import "MobileDeviceTagDAO.h"
#import "MobileDeviceTagService.h"
#import "SFExpressionService.h"
#import "SFExpressionComponentService.h"
#import "ExpressionParserService.h"
#import "SFProcessService.h"
#import "SFProcessComponentService.h"
#import "MobileDeviceSettingService.h"
#import "SFWizardService.h"
#import "SFMWizardComponentService.h"
#import "SFObjectMappingService.h"
#import "SFObjectFieldService.h"
#import "SearchProcessService.h"
#import "SearchProcessObjectsService.h"
#import "SFObjectMappingComponentService.h"
#import "DocTemplateService.h"
#import "DocTemplateDetailService.h"
#import "AttachmentsService.h"
#import "SFObjectMappingComponentService.h"
#import "BusinessRuleService.h"
#import "ProcessBusinessRuleService.h"
#import "SFMSearchFieldService.h"
#import "SFMSearchFilterCriteriaService.h"
#import "SyncHeapService.h"
#import "TransactionObjectService.h"
#import "SourceUpdateService.h"
#import "SFPicklistService.h"
#import "SFRecordTypeService.h"
#import "SFNamedSearchService.h"
#import "SFNamedSearchComponentService.h"
#import "ObjectNameFieldValueService.h"
#import "SFRTPicklistService.h"
#import "StaticResourceService.h"
#import "DocumentService.h"
#import "SFObjectService.h"
#import "UniversalService.h"
#import "ModifiedRecordsService.h"
#import "SFChildRelationshipService.h"
#import "SyncErrorConflictService.h"
#import "CalenderEventObjectService.h"
#import "JobLogService.h"
#import "UserGPSLogService.h"
#import "OPDocServices.h"
#import "OPDocSignatureService.h"
#import "SFNamedSearchFilterService.h"
#import "LinkedSfmProcessService.h"
#import "ProductManualService.h"
#import "DODRecordsService.h"
#import "TroubleshootingService.h"
#import "DataPurgeService.h"
#import "ChatterPostDetailService.h"
#import "ProductImageDataService.h"
#import "UserImageService.h"
#import "AttachmentLocalService.h"
#import "CustomActionURLModel.h"
#import "SFCustomActionURLService.h"
#import "CustomActionRequestService.h"
@implementation FactoryDAO


/**
 * @name  + (id)serviceByServiceType:(ServiceType)type;
 *
 * @author Vipindas Palli
 *
 * @brief Factory method to generate DAO service object by service Name
 *
 *
 * @param  type Context of the view controller
 *
 * @return object Object of Service class and type of DAO protocol
 *
 */

+ (id)serviceByServiceType:(ServiceType)type
{
    id serviceObject = nil;
    
    switch (type) {
        case ServiceTypeUniversal:
            serviceObject = [[UniversalService alloc] init];
            break;
        case ServiceTypeUserImage:
            serviceObject = [UserImageService new];
            break;
        case ServiceTypeMobileDeviceTag:
            serviceObject = [[MobileDeviceTagService alloc]init];
            break;
        case ServiceTypeExpression:
            serviceObject = [[SFExpressionService alloc] init];
            break;
        case ServiceTypeExpressionComponent:
            serviceObject = [[SFExpressionComponentService alloc]init];
            break;
        case ServiceTypeExpressionParser:
            serviceObject = [[ExpressionParserService alloc] init];
            break;
        case ServiceTypeProcess:
            serviceObject = [[SFProcessService alloc]init];
            break;
        case ServiceTypeProcessComponent:
            serviceObject = [[SFProcessComponentService alloc] init];
            break;
        case ServiceTypeMobileDeviceSettings:
            serviceObject = [[MobileDeviceSettingService alloc] init];
            break;
        case ServiceTypeSFWizard:
            serviceObject = [[SFWizardService alloc]init];
            break;
        case ServiceTypeSFObjectMapping:
            serviceObject = [[SFObjectMappingService alloc] init];
            break;
        case ServiceTypeSFWizardComponent:
            serviceObject = [[SFMWizardComponentService alloc]init];
            break;
        case ServiceTypeSFObjectMappingComponent:
            serviceObject = [[SFObjectMappingComponentService alloc] init];
            break;
        case ServiceTypeSFObjectField:
            serviceObject = [[SFObjectFieldService alloc] init];
            break;
        case ServiceTypeSFMSearchProcess:
            serviceObject = [[SearchProcessService alloc] init];
            break;
        case ServiceTypeDocTemplate:
            serviceObject = [[DocTemplateService alloc] init];
            break;
        case ServiceTypeSFMSearchProcessObject:
            serviceObject = [[SearchProcessObjectsService alloc] init];
            break;
        case ServiceTypeDocTemplateDetail:
            serviceObject = [[DocTemplateDetailService alloc] init];
            break;
        case ServiceTypeAttachments:
            serviceObject = [[AttachmentsService alloc] init];
            break;
        case ServiceTypeAttachmentLocal:
            serviceObject = [[AttachmentLocalService alloc] init];
            break;
        case ServiceTypeAttachmentError:
            serviceObject = [[AttachmentErrorService alloc] init];
            break;
        case ServiceTypeNamedSearch:
            serviceObject = [[SFNamedSearchService alloc] init];
            break;
        case ServiceTypeSearchObjectDetail:
            serviceObject = [[SFNamedSearchComponentService alloc] init];
            break;
        case ServiceTypeBusinessRule:
            serviceObject = [[BusinessRuleService alloc] init];
            break;
        case ServiceTypeProcessBusinessRule:
            serviceObject = [[ProcessBusinessRuleService alloc] init];
            break;
        case ServiceTypeSyncHeap:
            serviceObject = [[SyncHeapService alloc] init];
            break;
        case ServiceTypeSFMSearchField:
            serviceObject = [[SFMSearchFieldService alloc]init];
            break;
        case ServiceTypeSFMSearchFilterCriteria:
            serviceObject = [[SFMSearchFilterCriteriaService alloc]init];
            break;
        case ServiceTypeTransactionObject:
            serviceObject = [[TransactionObjectService alloc] init];
            break;
        case ServiceTypeSourceUpdate:
            serviceObject = [[SourceUpdateService alloc]init];
            break;
        case ServiceTypeSFPickList:
            serviceObject = [[SFPicklistService alloc]init];
            break;
        case ServiceTypeSFRecordType:
            serviceObject = [[SFRecordTypeService alloc]init];
            break;
        case ServiceTypeObjectNameFieldValue:
            serviceObject = [[ObjectNameFieldValueService alloc] init];
            break;
        case ServiceTypeSFRTPicklist:
            serviceObject = [[SFRTPicklistService alloc]init];
            break;
        case ServiceTypeSFObject:
            serviceObject = [[SFObjectService alloc] init];
            break;
        case ServiceTypeDocument:
            serviceObject = [[DocumentService alloc]init];
            break;
        case ServiceTypeStaticResource:
            serviceObject = [[StaticResourceService alloc]init];
            break;
        case ServiceTypeModifiedRecords:
            serviceObject = [[ModifiedRecordsService alloc] init];
            break;
        case ServiceTypeCustomActionRequestParams:
            serviceObject = [[CustomActionRequestService alloc] init];
            break;
        case ServiceTypeSFChildRelationShip:
            serviceObject = [[SFChildRelationshipService  alloc] init];
            break;
        case ServiceTypeSyncErrorConflict:
            serviceObject = [[SyncErrorConflictService alloc]init];
            break;
            
        case ServiceCalenderEventList:
            serviceObject = [[CalenderEventObjectService alloc] init];
            break;
        case ServiceTypeJobLog:
            serviceObject = [[JobLogService alloc]init];
            break;
        case ServiceTypeUserGPSLog:
            serviceObject = [[UserGPSLogService alloc]init];
            break;
        case ServiceTypeAttachment:
            serviceObject = [[AttachmentService alloc] init];
            break;
        case ServiceTypeOPDocHTML :                   /** HTML Table */
            serviceObject = [[OPDocServices alloc] init];
            break;
        case ServiceTypeOPDocSignature:                  /** Signature Table */
            serviceObject = [[OPDocSignatureService alloc] init];
            break;
        case ServiceTypeNamedSerachFilter:
            serviceObject = [[SFNamedSearchFilterService alloc] init];
            break;
        case ServiceTypeLinkedSFMProcess:
            serviceObject = [[LinkedSfmProcessService alloc] init];
            break;
        case ServiceTypeProductManual:
            serviceObject = [[ProductManualService alloc] init];
            break;
        case ServiceTypeDOD:
            serviceObject = [[DODRecordsService alloc] init];
            break;
        case ServiceTypeTroubleshooting:
            serviceObject = [[TroubleshootingService alloc] init];
            break;
        case ServiceTypeCustomUrlAction:
            serviceObject = [[SFCustomActionURLService alloc] init];
            break;
        case ServiceTypeDataPurge:
            serviceObject = [DataPurgeService new];
            break;
        case ServiceTypeChatterPostDetail:
            serviceObject = [ChatterPostDetailService new];
            break;
        case ServiceTypeProductImageData:
            serviceObject = [ProductImageDataService new];
            break;
        default:
            break;
            
    }
    return serviceObject;

}

+(id)createServiceForSFProcessService
{
    id <SFProcessDAO> daoService =  [[SFProcessService alloc] init];
    return daoService;
}

@end
