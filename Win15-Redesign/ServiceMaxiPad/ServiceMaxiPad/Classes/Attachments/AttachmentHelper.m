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

@implementation AttachmentHelper

+(NSMutableArray*)getDocAttachmentsLinkedToParentId:(NSString*)parentsfId {
    
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kAttachmentTXParentId operatorType:SQLOperatorEqual andFieldValue:parentsfId];
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
            attachModel.isDownloading = [[[AttachmentsDownloadManager sharedManager] downloadingDictionary] valueForKey:attachModel.localId] ? YES : NO;
            attachModel.displayDateString = [DateUtil getDateStringForDBDateTime:attachModel.lastModifiedDate inFormat:kDateAttachment];
            
            NSString *videoExtension, *imageExtension;
            if ([attachModel.extensionName length]) {
                videoExtension = [videosDict objectForKey:attachModel.extensionName];
                imageExtension = [imagesDict objectForKey:attachModel.extensionName];
            }
            
        if (![videoExtension length] && ![imageExtension length]) {
                [documentsArray addObject:attachModel];
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
            attachModel.isDownloading = [[[AttachmentsDownloadManager sharedManager] downloadingDictionary] valueForKey:attachModel.localId] ? YES : NO;
            attachModel.displayDateString = [DateUtil getDateStringForDBDateTime:attachModel.lastModifiedDate inFormat:kDateImagesAndVideosAttachment];
            
            NSString *videoExtension, *imageExtension;
            if ([attachModel.extensionName length]) {
                videoExtension = [videosDict objectForKey:attachModel.extensionName];
                imageExtension = [imagesDict objectForKey:attachModel.extensionName];
                
                if ([imageExtension length])
                {
                    attachModel.thumbnailImage = [AttachmentUtility scaleImage:[AttachmentUtility filePathForAttachment:attachModel] toSize:CGSizeMake(170.0f, 170.0f)];
                }
                
                if ([videoExtension length])
                {
                    attachModel.isVideo = YES;
                    UIImage *videoImage = [AttachmentUtility getThumbnailImageForFilePath:[AttachmentUtility filePathForAttachment:attachModel]];
                    attachModel.thumbnailImage = [UIImage scaleImage:videoImage toSize:CGSizeMake(170.0f, 170.0f)];
                }
            }
            
            if ([videoExtension length] || [imageExtension length]) {
                [imagesVideosArray addObject:attachModel];
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

+(NSArray*)getImagesAndVideosForUpload {
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIsNull andFieldValue:nil];
    
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    NSArray *attachmentArray = [attachmentService fetchRecordsByFields:nil andCriteria:criteria withDistinctFlag:NO];
    return attachmentArray;
}

+(BOOL)updateSFIdForUploadedAttachmentModel:(AttachmentTXModel*)attachmentModel {
    
    if (attachmentModel == nil || ![attachmentModel.localId length])
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
        [dict setObject:[attachmentModel.isPrivate length] ? attachmentModel.isPrivate : @"" forKey:@"IsPrivate"];
        [dict setObject:[attachmentModel.parentId length] ? attachmentModel.parentId : @"" forKey:@"ParentId"];
        [dict setObject:[attachmentModel.idOfAttachment length] ? attachmentModel.idOfAttachment : @"" forKey:kId];
        [dict setObject:[attachmentModel.lastModifiedDate length] ?  attachmentModel.lastModifiedDate : @"" forKey:@"LastModifiedDate"];
        [dict setObject:[attachmentModel.systemModStamp length] ?  attachmentModel.systemModStamp : @"" forKey:@"SystemModstamp"];
        [dict setObject:[attachmentModel.createdDate length] ?  attachmentModel.createdDate : @"" forKey:@"CreatedDate"];
        [dict setObject:[attachmentModel.localId length] ? attachmentModel.localId : @"" forKey:kLocalId];
        [dict setObject:[attachmentModel.name length] ? attachmentModel.name : @"" forKey:@"Name"];
        return dict;
    }
    return nil;
}

+ (NSMutableArray*)getAttachmentFields:(AttachmentTXModel*)model
{
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[[self getDataDict:model] allKeys]];
    return fields;
}

@end
