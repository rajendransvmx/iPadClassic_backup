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
            NSString *downloadedFileName = [NSString stringWithFormat:@"%@%@",attachModel.localId,attachModel.extensionName];
            attachModel.isDownloaded = [downloadedAttachments containsObject:downloadedFileName];
            attachModel.isDownloading = [[[[AttachmentsDownloadManager sharedManager] downloadingDictionary] valueForKey:attachModel.localId] boolValue];
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
            attachModel.isDownloading = [[[[AttachmentsDownloadManager sharedManager] downloadingDictionary] valueForKey:attachModel.localId] boolValue];
            attachModel.displayDateString = [DateUtil getDateStringForDBDateTime:attachModel.lastModifiedDate inFormat:kDateAttachment];
            
            NSString *videoExtension, *imageExtension;
            if ([attachModel.extensionName length]) {
                videoExtension = [videosDict objectForKey:attachModel.extensionName];
                imageExtension = [imagesDict objectForKey:attachModel.extensionName];
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

@end
