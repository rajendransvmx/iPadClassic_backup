//
//  AttachmentHelper.m
//  ServiceMaxiPad
//
//  Created by Anoop on 10/29/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "AttachmentHelper.h"
#import "FactoryDAO.h"
#import "AttachmentService.h"
#import "AttachmentDAO.h"
#import "AttachmentErrorDAO.h"
#import "AttachmentUtility.h"
#import "AttachmentsDownloadManager.h"
#import "DateUtil.h"
#import "ModifiedRecordsService.h"
#import "ModifiedRecordsDAO.h"
#import "UIImage+SMXCustomMethods.h"
#import "DBRequestInsert.h"
#import "TransactionObjectModel.h"
#import "TransactionObjectDAO.h"
#import "TransactionObjectService.h"
#import "AttachmentsUploadManager.h"
#import "OPDocHTML.h"
#import "OPDocDAO.h"
#import "OPDocServices.h"
#import "StringUtil.h"
#import "AttachmentLocalService.h"
#import "AttachmentLocalDAO.h"
#import "AttachmentLocalModel.h"
#import "DatabaseConstant.h"

static NSString *const kThirdPartyApps                  = @"Third Party Apps";

@implementation AttachmentHelper

+(NSMutableArray*)getDocAttachmentsLinkedToParentId:(NSString*)parentsfId andOPDocsForRecordId:(NSString*)recordId {
    
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    id <AttachmentErrorDAO> attachmentErrorService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentError];

    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kAttachmentTXParentId operatorType:SQLOperatorEqual andFieldValue:parentsfId];
    DBCriteria * errorCriteria = [[DBCriteria alloc] initWithFieldName:kAttachmentERParentSFId operatorType:SQLOperatorEqual andFieldValue:parentsfId];
    NSArray *errorAttachmentArray = [attachmentErrorService fetchAttachmentsErrorRecordsByFields:nil andCriteria:errorCriteria withDistinctFlag:NO];
    NSArray *attachmentArray = [attachmentService fetchRecordsByFields:nil andCriteria:criteria withDistinctFlag:NO];
    NSDictionary *videosDict = [AttachmentUtility videoTypesDict];
    NSDictionary *imagesDict = [AttachmentUtility imageTypesDict];
    NSArray *downloadedAttachments = [AttachmentUtility downloadedAttachments];
    NSMutableArray *documentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (AttachmentTXModel *attachModel in attachmentArray)
    {
        NSRange range = [attachModel.name rangeOfString:@"." options:NSBackwardsSearch];
        if (range.location != NSNotFound)
        {
            attachModel.extensionName = [attachModel.name substringFromIndex:range.location];
            attachModel.extensionName = [attachModel.extensionName lowercaseString];
            attachModel.nameWithoutExtension = [attachModel.name substringToIndex:range.location];
            NSString *downloadedFileName = [AttachmentUtility fileNameForAttachment:attachModel];
            attachModel.isDownloaded = [downloadedAttachments containsObject:downloadedFileName];
            if ([StringUtil isStringEmpty:attachModel.lastModifiedDate]) {
                attachModel.lastModifiedDate = attachModel.createdDate;
            }
            attachModel.displayDateString = [DateUtil getUserReadableDateForAttachment:attachModel.lastModifiedDate withFormat:kDateAttachment];
            
            NSString *videoExtension, *imageExtension;
            if (![StringUtil isStringEmpty:attachModel.extensionName]) {
                videoExtension = [videosDict objectForKey:attachModel.extensionName];
                imageExtension = [imagesDict objectForKey:attachModel.extensionName];
            }
            
        if ([StringUtil isStringEmpty:videoExtension] && [StringUtil isStringEmpty:imageExtension]) {
                [documentsArray addObject:attachModel];
            }
        }
        
    }
    
    id <OPDocDAO> opdocService = [FactoryDAO serviceByServiceType:ServiceTypeOPDocHTML];
    NSArray *outputDocsArray = [opdocService getLocallySavedHTMLListForId:recordId];
    for (OPDocHTML *opDocHtmlModel in outputDocsArray)
    {
        AttachmentTXModel *attachmentModel = [[AttachmentTXModel alloc] init];
        attachmentModel.extensionName = @".html";
        attachmentModel.localId = opDocHtmlModel.local_id;
        attachmentModel.ownerId = opDocHtmlModel.record_id;
        attachmentModel.name = opDocHtmlModel.Name;
        attachmentModel.nameWithoutExtension = [opDocHtmlModel.Name stringByDeletingPathExtension];
        attachmentModel.isDownloaded = YES;
        attachmentModel.isOutputdoc = YES;
        attachmentModel.lastModifiedDate = opDocHtmlModel.lastModifiedDate;
        attachmentModel.bodyLength = opDocHtmlModel.bodyLength;
        attachmentModel.displayDateString = [DateUtil getUserReadableDateForAttachment:attachmentModel.lastModifiedDate withFormat:kDateAttachment];
        if ([AttachmentUtility getUrlForAttachment:attachmentModel]) {
            [documentsArray addObject:attachmentModel];
        }
    }
    
    for (int index=0; index<documentsArray.count; index++) {
        AttachmentTXModel *attachmentModel=[documentsArray objectAtIndex:index];
        for (AttachmentTXModel *errorModel in errorAttachmentArray) {
            if ([errorModel.localId isEqualToString:attachmentModel.localId]) {
                attachmentModel.errorCode=errorModel.errorCode;
                attachmentModel.errorMessage=errorModel.errorMessage;
                [documentsArray replaceObjectAtIndex:index withObject:attachmentModel];
            }
        }
    }
    
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:NO];
    [documentsArray sortUsingDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
    return documentsArray;

}

+(NSMutableArray*)getImagesAndVideosAttachmentsLinkedToParentId:(NSString*)parentsfId {
    
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kAttachmentTXParentId operatorType:SQLOperatorEqual andFieldValue:parentsfId];
    NSArray *attachmentArray = [attachmentService fetchRecordsByFields:nil andCriteria:criteria withDistinctFlag:NO];
    NSDictionary *videosDict = [AttachmentUtility videoTypesDict];
    NSDictionary *imagesDict = [AttachmentUtility imageTypesDict];
    NSArray *downloadedAttachments = [AttachmentUtility downloadedAttachments];
    NSMutableArray *imagesVideosArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (AttachmentTXModel *attachModel in attachmentArray)
    {
        NSRange range = [attachModel.name rangeOfString:@"." options:NSBackwardsSearch];
        if (range.location != NSNotFound)
        {
            attachModel.extensionName = [attachModel.name substringFromIndex:range.location];
            attachModel.extensionName = [attachModel.extensionName lowercaseString];
            attachModel.nameWithoutExtension = [attachModel.name substringToIndex:range.location];
            NSString *downloadedFileName = [NSString stringWithFormat:@"%@%@",attachModel.localId,attachModel.extensionName];
            attachModel.isDownloaded = [downloadedAttachments containsObject:downloadedFileName];
            if ([StringUtil isStringEmpty:attachModel.lastModifiedDate]) {
                attachModel.lastModifiedDate = attachModel.createdDate;
            }
            attachModel.displayDateString = [DateUtil getUserReadableDateForAttachment:attachModel.lastModifiedDate withFormat:kDateImagesAndVideosAttachment];
            
            NSString *videoExtension, *imageExtension;
            if (![StringUtil isStringEmpty:attachModel.extensionName]) {
                videoExtension = [videosDict objectForKey:attachModel.extensionName];
                imageExtension = [imagesDict objectForKey:attachModel.extensionName];
                
                if (![StringUtil isStringEmpty:imageExtension])
                {
                    attachModel.thumbnailImage = [AttachmentUtility scaleImage:[AttachmentUtility filePathForAttachment:attachModel] toSize:CGSizeMake(170.0f, 170.0f)];
                }
                
                if (![StringUtil isStringEmpty:videoExtension])
                {
                    attachModel.isVideo = YES;
                    UIImage *videoImage = [AttachmentUtility getThumbnailImageForFilePath:[AttachmentUtility filePathForAttachment:attachModel]];
                    attachModel.thumbnailImage = [UIImage scaleImage:videoImage toSize:CGSizeMake(170.0f, 170.0f)];
                }
            }
            
            if (![StringUtil isStringEmpty:videoExtension] || ![StringUtil isStringEmpty:imageExtension]) {
                [imagesVideosArray addObject:attachModel];
            }
        }
        
    }
    
    id <AttachmentErrorDAO> attachmentErrorService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentError];
    DBCriteria * errorCriteria = [[DBCriteria alloc] initWithFieldName:kAttachmentERParentSFId operatorType:SQLOperatorEqual andFieldValue:parentsfId];
    NSArray *errorAttachmentArray = [attachmentErrorService fetchAttachmentsErrorRecordsByFields:nil andCriteria:errorCriteria withDistinctFlag:NO];
    for (int index=0; index<imagesVideosArray.count; index++) {
        AttachmentTXModel *attachmentModel=[imagesVideosArray objectAtIndex:index];
        for (AttachmentTXModel *errorModel in errorAttachmentArray) {
            if ([errorModel.localId isEqualToString:attachmentModel.localId]) {
                attachmentModel.errorCode=errorModel.errorCode;
                attachmentModel.errorMessage=errorModel.errorMessage;
                [imagesVideosArray replaceObjectAtIndex:index withObject:attachmentModel];
            }
        }
    }
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:NO];
    [imagesVideosArray sortUsingDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
    return imagesVideosArray;
    
}

+(BOOL)deleteAttachmentsWithLocalIds:(NSArray*)localIds {
    
    if (!localIds.count) {
        return NO;
    }
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    return [attachmentService deleteRecordsForRecordLocalIds:localIds];
    
}

+(BOOL)saveDeleteAttachmentsToModifiedRecords:(NSMutableArray*)modifiedRecordsArray {
    
    if (!modifiedRecordsArray.count) {
        return NO;
    }
    id <ModifiedRecordsDAO> modifiedRecordsService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
   return [modifiedRecordsService saveRecordModels:modifiedRecordsArray];
    
}

+(BOOL)revertDeleteAttachmentsFromModifiedRecordsForParentId:(NSString*)parentId
                                                 andLocalIds:(NSArray*)localIdsArray
{
    id <ModifiedRecordsDAO> modifiedRecordsService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:kobjectName
                                                      operatorType:SQLOperatorEqual
                                                     andFieldValue:kAttachmentTableName];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"parentLocalId"
                                                      operatorType:SQLOperatorEqual
                                                     andFieldValue:parentId];
    DBCriteria *criteriaThree = [[DBCriteria alloc]initWithFieldName:kSyncRecordLocalId
                                                      operatorType:SQLOperatorIn
                                                     andFieldValues:localIdsArray];
    BOOL status = [modifiedRecordsService deleteRecordsFromObject:kModifiedRecords
                                  whereCriteria:@[criteriaOne, criteriaTwo, criteriaThree]
                           andAdvanceExpression:nil];
    return status;
}

+(NSArray*)modifiedRecordLocalIds
{
    return [[AttachmentsUploadManager sharedManager] localIdsModifiedArray];
}

+(void)addModifiedRecordLocalId:(NSString*)localId
{
    if (![StringUtil isStringEmpty:localId])
    {
        [[[AttachmentsUploadManager sharedManager] localIdsModifiedArray] addObject:localId];
    }
}

+(void)removeModifiedRecordLocalIds
{
    [[[AttachmentsUploadManager sharedManager] localIdsModifiedArray] removeAllObjects];
}

+(NSArray*)getLocalIdsOfDeleteAttachmentsFromModifiedRecordsForParentId:(NSString*)parentId {
    
    id <ModifiedRecordsDAO> modifiedRecordsService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:kobjectName
                                                      operatorType:SQLOperatorEqual
                                                     andFieldValue:kAttachmentTableName];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"parentLocalId"
                                                      operatorType:SQLOperatorEqual
                                                     andFieldValue:parentId];
    NSArray *tempArray = [modifiedRecordsService fetchDataForFields:@[kSyncRecordLocalId] criterias:@[criteriaOne, criteriaTwo] objectName:kModifiedRecords andModelClass:[ModifiedRecordModel class]];
    NSMutableArray *localIdsArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (ModifiedRecordModel *model in tempArray)
    {
        if (![StringUtil isStringEmpty:model.recordLocalId]) {
            [localIdsArray addObject:model.recordLocalId];
        }
    }
    return localIdsArray;
}

+(NSArray*)getImagesAndVideosForUpload {
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIsNull andFieldValue:nil];
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kAttachmentTXLastModifiedDate operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    NSArray *attachmentArray = [attachmentService fetchRecordsByFields:nil andCriterias:@[criteriaOne, criteriaTwo] withDistinctFlag:NO];
    return attachmentArray;
}

+(NSArray*)getImagesAndVideosForUploadForParentId:(NSString*)parentId {
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIsNull andFieldValue:nil];
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kAttachmentTXParentId operatorType:SQLOperatorEqual andFieldValue:parentId];
    DBCriteria *criteriaThree = [[DBCriteria alloc] initWithFieldName:kAttachmentTXLastModifiedDate operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    NSArray *attachmentArray = [attachmentService fetchRecordsByFields:nil andCriterias:@[criteriaOne, criteriaTwo, criteriaThree] withDistinctFlag:NO];
    return attachmentArray;
}

+(NSArray*)getRecentlyAddedImagesAndVideosForParentId:(NSString*)parentId {
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIsNull andFieldValue:nil];
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kAttachmentTXParentId operatorType:SQLOperatorEqual andFieldValue:parentId];
    DBCriteria *criteriaThree = [[DBCriteria alloc] initWithFieldName:kAttachmentTXLastModifiedDate operatorType:SQLOperatorIsNull andFieldValue:nil];
    
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    NSArray *attachmentArray = [attachmentService fetchRecordsByFields:nil andCriterias:@[criteriaOne, criteriaTwo, criteriaThree] withDistinctFlag:NO];
    return attachmentArray;
}

+(BOOL)revertImagesAndVideosForUploadForParentId:(NSString*)parentId {
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIsNull andFieldValue:nil];
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kAttachmentTXParentId operatorType:SQLOperatorEqual andFieldValue:parentId];
    DBCriteria *criteriaThree = [[DBCriteria alloc] initWithFieldName:kAttachmentTXLastModifiedDate operatorType:SQLOperatorIsNull andFieldValue:nil];
    
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    NSArray *imageAndVideosForUpload = [attachmentService fetchRecordsByFields:nil andCriterias:@[criteriaOne, criteriaTwo, criteriaThree] withDistinctFlag:NO];

    if (![imageAndVideosForUpload count]) {
        return NO;
    }
    NSMutableArray *localIdArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (AttachmentTXModel *deleteModel in imageAndVideosForUpload)
    {
        if (![[AttachmentsUploadManager sharedManager] hasAttachmentInQueue:deleteModel.localId])
        {
            deleteModel.extensionName = [NSString stringWithFormat:@".%@",[deleteModel.name pathExtension]];
            BOOL isSuccess = [AttachmentUtility deleteAttachment:deleteModel];
            if (isSuccess) {
                [localIdArray addObject:deleteModel.localId];
            }
        }
    }
    return [self deleteAttachmentsWithLocalIds:localIdArray];
}

+(BOOL)updateSFIdForUploadedAttachmentModel:(AttachmentTXModel*)attachmentModel {
    
    if (attachmentModel == nil || [StringUtil isStringEmpty:attachmentModel.localId])
        return NO;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:attachmentModel.localId];
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    BOOL status = [transactionService updateEachRecord:[self getDataDict:attachmentModel]
                                            withFields:[self getAttachmentFields:attachmentModel]
                                          withCriteria:[NSArray arrayWithObject:criteria]
                                         withTableName:kAttachmentTableName];
    return status;
    
}

+(BOOL)saveLocallyAddedAttachment:(AttachmentTXModel*)attachmentTXModel {
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSDictionary *dataDict = [self getDataDict:attachmentTXModel];
    NSArray *models = @[[self getTransactiomModel:dataDict]];
    
    BOOL status = [transactionService insertTransactionObjects:models andDbRequest:[self getInsertQuery:attachmentTXModel]];
    return status;
}

+ (NSString *)getInsertQuery:(AttachmentTXModel *)model
{
    DBRequestInsert *insert = [[DBRequestInsert alloc] initWithTableName:kAttachmentTableName andFieldNames:[self getAttachmentFields:model]];
    
    return [insert query];
}

+ (TransactionObjectModel *)getTransactiomModel:(NSDictionary *)dataDict
{
    TransactionObjectModel *transactionModel = [[TransactionObjectModel alloc] initWithObjectApiName:kAttachmentTableName];
    [transactionModel mergeFieldValueDictionaryForFields:dataDict];
    return transactionModel;
}

+ (NSDictionary *)getDataDict:(AttachmentTXModel *)attachmentModel
{
    if (attachmentModel != nil){
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.isPrivate] ? attachmentModel.isPrivate : @"" forKey:kAttachmentTXIsPrivate];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.parentId] ? attachmentModel.parentId : @"" forKey:kAttachmentTXParentId];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.idOfAttachment] ? attachmentModel.idOfAttachment : @"" forKey:kId];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.lastModifiedDate] ?  attachmentModel.lastModifiedDate : @"" forKey:kAttachmentTXLastModifiedDate];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.systemModStamp] ?  attachmentModel.systemModStamp : @"" forKey:kAttachmentTXSystemModStamp];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.createdDate] ?  attachmentModel.createdDate : @"" forKey:kAttachmentTXCreatedDate];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.localId] ? attachmentModel.localId : @"" forKey:kLocalId];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.name] ? attachmentModel.name : @"" forKey:kAttachmentTXName];
        return dict;
    }
    return nil;
}

+ (NSMutableArray*)getAttachmentFields:(AttachmentTXModel*)model
{
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[[self getDataDict:model] allKeys]];
    return fields;
}

+ (BOOL)saveAttachmentLocalModelToDB:(AttachmentLocalModel*)localModel
{
    id <AttachmentLocalDAO> attachmentLocalService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentLocal];
    return [attachmentLocalService saveAttachmentLocalModel:localModel];
}

+ (BOOL)deleteAttachmentLocalModelFromDB:(NSString*)parentLocalId
{
    id <AttachmentLocalDAO> attachmentLocalService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentLocal];
    return [attachmentLocalService deleteRecordWithParentLocalId:parentLocalId];
}

+(NSArray*)getAllLocalAttachments
{
    id <AttachmentLocalDAO> attachmentLocalService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentLocal];
    return [attachmentLocalService fetchAllRecordsFromLocalAttachment];
}

+(BOOL)updateSFIdInAttachmentForCurrentParentLocalId:(NSString*)parentLocalId toParentId:(NSString*)parentId {
    
    if ([StringUtil isStringEmpty:parentLocalId] || [StringUtil isStringEmpty:parentId])
        return NO;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kAttachmentTXParentId operatorType:SQLOperatorEqual andFieldValue:parentLocalId];
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    AttachmentTXModel *attachmentModel = [[AttachmentTXModel alloc] init];
    attachmentModel.parentId = parentId;
    
    BOOL status = [transactionService updateEachRecord:[self getDataDict:attachmentModel]
                                            withFields:@[kAttachmentTXParentId]
                                          withCriteria:[NSArray arrayWithObject:criteria]
                                         withTableName:kAttachmentTableName];
    return status;
    
}

+(BOOL)updateLastModifiedDateOfAttachmentForParentId:(NSString*)parentId {
    
    if ([StringUtil isStringEmpty:parentId])
        return NO;
    
    DBCriteria *criteriaOne = [[DBCriteria alloc] initWithFieldName:kAttachmentTXParentId operatorType:SQLOperatorEqual andFieldValue:parentId];
    DBCriteria *criteriaTwo = [[DBCriteria alloc] initWithFieldName:kAttachmentTXLastModifiedDate operatorType:SQLOperatorIsNull andFieldValue:nil];
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    AttachmentTXModel *attachmentModel = [[AttachmentTXModel alloc] init];
    attachmentModel.lastModifiedDate = [DateUtil getDatabaseStringForDate:[NSDate date]];
    
    BOOL status = [transactionService updateEachRecord:[self getDataDict:attachmentModel]
                                            withFields:@[kAttachmentTXLastModifiedDate]
                                          withCriteria:@[criteriaOne, criteriaTwo]
                                         withTableName:kAttachmentTableName];
    return status;
    
}

+ (void)deleteAttachmentsFromDBDirectoryForParentId:(NSString*)parentId
{
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kAttachmentTXParentId operatorType:SQLOperatorEqual andFieldValue:parentId];
    NSArray *attachmentArray = [attachmentService fetchRecordsByFields:nil andCriteria:criteria withDistinctFlag:NO];
    NSArray *downloadedAttachments = [AttachmentUtility downloadedAttachments];
    
    for (AttachmentTXModel *attachModel in attachmentArray)
    {
        NSRange range = [attachModel.name rangeOfString:@"." options:NSBackwardsSearch];
        if (range.location != NSNotFound)
        {
            attachModel.extensionName = [attachModel.name substringFromIndex:range.location];
            attachModel.extensionName = [attachModel.extensionName lowercaseString];
            attachModel.nameWithoutExtension = [attachModel.name substringToIndex:range.location];
            NSString *downloadedFileName = [AttachmentUtility fileNameForAttachment:attachModel];
            attachModel.isDownloaded = [downloadedAttachments containsObject:downloadedFileName];
            if (attachModel.isDownloaded)
            {
                [AttachmentUtility deleteAttachment:attachModel];
            }
        }
    }

    [attachmentService deleteRecordsForParentId:parentId];
    [AttachmentHelper deleteAttachmentLocalModelFromDB:parentId];
}


#pragma mark -
#pragma mark Numerial Third Party App connect.

+ (NSString *)getJSONStringForThirdPartyAppConnect {
    
    NSString *tableName = kTableCodeSnippet;
    NSArray *fields = [NSArray arrayWithObjects:kId,kCodeSnippetData,nil];
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kCodeSnippetName operatorType:SQLOperatorEqual andFieldValue:kThirdPartyApps];
    
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kCodeSnippetID operatorType:SQLOperatorEqual andFieldValue:@"Code008"];
    NSString *advExpression = @"(1 or 2)";
    
    
    id <TransactionObjectDAO>transObjectService  = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray *allRecords = [transObjectService fetchDataWithhAllFieldsAsStringObjects:tableName fields:fields expression:advExpression criteria:@[criteria1,criteria2]];
    
    for (TransactionObjectModel *model in allRecords) {
        return [[model getFieldValueDictionary] objectForKey:kCodeSnippetData];
    }
    return nil;
    
}

@end
