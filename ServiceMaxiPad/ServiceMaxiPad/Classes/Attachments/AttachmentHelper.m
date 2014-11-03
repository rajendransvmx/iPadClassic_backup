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

@implementation AttachmentHelper

+ (NSArray*) getAllDocAttachmentsBasedOnLastModifiedDate {
    
    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachment];
    
    NSArray *attachmentArray = [attachmentService fetchRecordsByFields:nil andCriteria:nil withDistinctFlag:NO];
    NSDictionary *videosDict = [AttachmentUtility videoTypesDict];
    NSDictionary *imagesDict = [AttachmentUtility imageTypesDict];
    NSMutableArray *documentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (AttachmentTXModel *attachModel in attachmentArray)
    {
        NSRange range = [attachModel.name rangeOfString:@"." options:NSBackwardsSearch];
        if (range.location != NSNotFound)
        {
            attachModel.extensionName = [[attachModel.name substringFromIndex:range.location] lowercaseString];
            attachModel.nameWithoutExtension = [attachModel.name substringToIndex:range.location];
            
            if (![videosDict valueForKey:attachModel.extensionName] && ![imagesDict valueForKey:attachModel.extensionName]) {
                [documentsArray addObject:attachModel];
            }
        }
        
    }
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:NO];
    [documentsArray sortUsingDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
    return documentsArray;

}

@end
