//
//  FactoryDAO.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/27/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   FileName
 *  @class  <Class Name>
 *
 *  @brief  Function prototypes for the console driver.
 *
 *
 *  This contains the prototypes for the console
 *  driver and eventually any macros, constants,
 *  or global variables you will need.
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>

typedef enum ServiceType : NSUInteger
{
    ServiceTypeUniversal = 1,        /**  Universal DAO for universal type operations  */
    ServiceTypeUserImage = 2,        /**  User Image  */
    ServiceTypeMobileDeviceTag = 3,     /**  Mobile Device Tags */
    ServiceTypeExpression = 4,          /** Expression */
    ServiceTypeExpressionComponent = 5, /** Expression component*/
    ServiceTypeExpressionParser = 6,    /** Expression parser*/
    ServiceTypeProcess = 7,             /*SFProcess*/
    ServiceTypeProcessComponent = 8,     /*SFProcessComponent*/
    ServiceTypeMobileDeviceSettings = 9,  /* Mobile device settings */
    ServiceTypeSFObjectMapping = 10,      /* Object Mapping */
    ServiceTypeSFObjectMappingComponent =11, /* object mapping component */
    ServiceTypeSFWizard = 12 ,               /*sfWizard*/
    ServiceTypeSFWizardComponent = 13,        /*sfWizardComponent */
    ServiceTypeSFObjectField = 14,             /*SFObjectField*/
    ServiceTypeSFMSearchProcess = 15,           /*SFMSearchProcess*/
    ServiceTypeSFMSearchProcessObject = 16,      /*SFMSearchProcessObject*/
    ServiceTypeDocTemplate = 17,             /*DocTemplate*/
    ServiceTypeDocTemplateDetail = 18,       /*DocTemplateDetail*/
    ServiceTypeAttachments = 19,            /*Attachments*/
    ServiceTypeNamedSearch = 20,            /*NamedSearch*/
    ServiceTypeSearchObjectDetail = 21,     /*SearchObjectDetail*/
    ServiceTypeBusinessRule = 22,          /*BusinessRule*/
    ServiceTypeProcessBusinessRule = 23,    /*ProcessBusinessRule*/
    ServiceTypeSFMSearchField,              /*SFMSearchField*/
    ServiceTypeSFMSearchFilterCriteria,     /*SFMSearchFilterCriteria*/
    ServiceTypeSyncHeap,                    /* sync heap */
    ServiceTypeTransactionObject,             /*Transaction Object*/
    ServiceTypeSourceUpdate,                /*SourceUpdate*/
    ServiceTypeSFRecordType,                /*SFRecord Type*/
    ServiceTypeSFPickList,                  /*SFPicklist*/
    ServiceTypeObjectNameFieldValue,        /*ObjectNameFielsVale*/
    ServiceTypeSFRTPicklist,                /*SFRTPicklist*/
    ServiceTypeStaticResource,               /*staticresource*/
    ServiceTypeDocument,                      /*static resource document*/
    ServiceTypeSFObject,                     /*SFObject*/
    ServiceTypeModifiedRecords,            /*ModifiedRecords*/
    ServiceTypeSFChildRelationShip,
    ServiceTypeSyncErrorConflict,           /*SyncErrorConflict*/
    ServiceCalenderEventList,           /*Calender Events*/
    ServiceTypeJobLog,                      /** Job Log*/
    ServiceTypeUserGPSLog,                  /** UserGPS Log */
    ServiceTypeAttachment,                  /** Attachment TX images, videos, pdf, doc etc */
    ServiceTypeAttachmentLocal,             /** Locally created attachments **/
    ServiceTypeAttachmentError,             /** Server deleted attachments **/
    ServiceTypeOPDocHTML,                   /** HTML Table */
    ServiceTypeOPDocSignature,              /** Signature Table */
    ServiceTypeNamedSerachFilter,
    ServiceTypeLinkedSFMProcess,
    ServiceTypeProductManual,
    ServiceTypeDOD,
    ServiceTypeTroubleshooting,
    ServiceTypeDataPurge,                   /** DataPurge Table */
    ServiceTypeChatterPostDetail,
    ServiceTypeProductImageData,
    ServiceTypeCustomUrlAction,
    ServiceTypeProductIQ,                   /** Product IQ **/
    ServiceTypeCustomActionRequestParams
}
ServiceType;

@interface FactoryDAO : NSObject

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

+ (id)serviceByServiceType:(ServiceType)type;

+ (id)createServiceForSFProcessService;

@end

