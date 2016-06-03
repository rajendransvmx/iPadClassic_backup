//
//  ResourceHandler.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ResourceHandler.h"
#import "StaticResourceService.h"
#import "FactoryDAO.h"
#import "FileModel.h"
#import "StaticResourceModel.h"
#import "FileManager.h"
#import "UnzipUtility.h"
#import "RestRequest.h"
#import "FileModel.h"
#import "ResponseConstants.h"
#import "AttachmentsService.h"
#import "AttachmentModel.h"
#import "RequestConstants.h"
#import "FileManager.h"
#import "DocumentService.h"
#import "DocumentModel.h"
#import "RequestParamModel.h"
#import "StringUtil.h"
#import "CacheManager.h"
#import "ProductManualService.h"
#import "ProductManualModel.h"
#import "ProductManualDAO.h"
#import "TroubleshootDataModel.h"
#import "TroubleshootingDAO.h"
#import "NonTagConstant.h"

@implementation ResourceHandler

#pragma mark - get request parameter handling

- (NSArray*)getStaticeResourceRequestParameterForCount:(NSInteger)count
{
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeStaticResource];
    
    NSMutableArray *listOfStaticResourceToBeDownloaded;
    
    if ([daoService conformsToProtocol:@protocol(StaticResourceDAO)]) {
        
    listOfStaticResourceToBeDownloaded    =  [[NSMutableArray alloc]initWithArray:[daoService getDistinctStaticResourceIdsToBeDownloaded]];
    }
    
    NSMutableArray *listOfRemainingFileModel = [[NSMutableArray alloc]init];
    
    NSMutableArray *requestParamArray = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < count; i++) { //TO DO :Need to change the logic like pagelayout
    
    RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];

    for (int i = 0; i < [listOfStaticResourceToBeDownloaded count]; i++) {
       
        StaticResourceModel *staticResourceModel = [listOfStaticResourceToBeDownloaded objectAtIndex:i];
        
        FileModel *model = [[FileModel alloc]init];
        model.sfId = staticResourceModel.Id;
        model.fileName =  [NSString stringWithFormat:@"%@.zip",staticResourceModel.Name];
        model.objectName = kStaticResource;
        
        if (model.sfId != nil)
        {
            if (i != 0)
            {
                [listOfRemainingFileModel addObject:model];
                
            } else
            {
                requestParamModel.values = @[model];
            }
        }
        
    }
    
    NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc]init];
    
    [infoDictionary setObject:listOfRemainingFileModel forKey:@"remainigFiles"];
    
    requestParamModel.requestInformation = infoDictionary;
    
    [requestParamArray addObject:requestParamModel];
        
    }
    
    return requestParamArray;
}

- (NSArray *)getRequestParamsForDocumentInformation {
    
    NSMutableArray *developerNames = [[NSMutableArray alloc] init];
    DocumentService *service = [[DocumentService alloc] init];
    NSArray *documentModels =  [service getListOfDocument];
    for (DocumentModel *docModel in documentModels) {
        if (docModel.DeveloperName != nil) {
            [developerNames addObject:docModel.DeveloperName];
        }
    }
    
    if ([developerNames count] > 0) {
         RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
        NSString *developerNameString = [StringUtil getConcatenatedStringFromArray:developerNames withSingleQuotesAndBraces:YES];
        NSString *soqlQuery = [[NSString alloc ] initWithFormat:@"Select Type, NamespacePrefix, Name, Keywords, IsDeleted, Id, FolderId, DeveloperName, Description, ContentType, BodyLength From Document where DeveloperName IN %@", developerNameString];
        requestParamModel.value = soqlQuery;
        return @[requestParamModel];
    }
    return nil;
}

- (NSArray*)getDocumentResourceRequestParameterForCount:(NSInteger)count
{
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeDocument];
    
    NSMutableArray *listOfResourceToBeDownloaded;
    
    if ([daoService conformsToProtocol:@protocol(DocumentDAO)]) {
        
        listOfResourceToBeDownloaded    =  [[NSMutableArray alloc] initWithArray:[daoService getListOfDocumentToDownload]];
    }
    
    NSMutableArray *listOfRemainingFileModel = [[NSMutableArray alloc]init];
    
    NSString *rootDirectory = [FileManager getCoreLibSubDirectoryPath];
    NSMutableArray *requestParamArray = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < count; i++) { //TO DO :Need to change the logic like pagelayout
        
        RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
        
        for (int i = 0; i < [listOfResourceToBeDownloaded count]; i++) {
            
            DocumentModel *resourceModel = [listOfResourceToBeDownloaded objectAtIndex:i];
            
            FileModel *model = [[FileModel alloc]init];
            model.sfId = resourceModel.Id;
            model.fileName =  [NSString stringWithFormat:@"%@.%@",resourceModel.Name,resourceModel.Type];
            model.objectName = kDocumentObject;
            model.rootDirectory = rootDirectory;
            
            if (model.sfId != nil)
            {
                if (i != 0)
                {
                    [listOfRemainingFileModel addObject:model];
                } else
                {
                    requestParamModel.values = @[model];
                }
            }
        }
        
        NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc]init];
        
        [infoDictionary setObject:listOfRemainingFileModel forKey:@"remainigFiles"];
        
        requestParamModel.requestInformation = infoDictionary;
        
        [requestParamArray addObject:requestParamModel];
        
    }
    
    return requestParamArray;
}


- (NSArray*)getDownloadDocTemplateRequestparameterForCount:(NSInteger)count
{
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeAttachments];
    
    NSMutableArray *attachmentsToBeDownloaded;
    
    if ([daoService conformsToProtocol:@protocol(AttachmentsDAO)]) {
        
        attachmentsToBeDownloaded    =  [[NSMutableArray alloc]initWithArray:[daoService getAttachmentIdsToBeDownloaded]];
    }
    
    NSMutableArray *listOfRemainingFileModel = [[NSMutableArray alloc]init];
    
    NSMutableArray *requestParamArray = [[NSMutableArray alloc]init];
    
    for (int i = 0 ; i < count; i++) { //TO DO :Need to change the logic like pagelayout
        
        RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
        
        for (int i = 0; i < [attachmentsToBeDownloaded count]; i++) {
            
            FileModel *model = [[FileModel alloc]init];
            model.sfId       = [attachmentsToBeDownloaded objectAtIndex:i];
            model.fileName   = [attachmentsToBeDownloaded objectAtIndex:i];
            model.objectName = kAttachementObject;
            
            if (model.sfId != nil)
            {
                if (i != 0)
                {
                    [listOfRemainingFileModel addObject:model];
                }
                else
                {
                    requestParamModel.values = @[model];
                }
            }
        }
        
        NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc]init];
        
        [infoDictionary setObject:listOfRemainingFileModel forKey:@"remainigFiles"];
        
        requestParamModel.requestInformation = infoDictionary;
        
        [requestParamArray addObject:requestParamModel];
        
    }
    
    return requestParamArray;
}

- (NSArray*)getTroubleshootingDocumentRequestParameterForCount:(NSInteger)count
{
    
    NSString *docId = [[CacheManager sharedInstance] getCachedObjectByKey:@"docId"];
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeTroubleshooting];
    
    NSMutableArray *listOfResourceToBeDownloaded;
    
    if ([daoService conformsToProtocol:@protocol(TroubleshootingDAO)]) {
        
        listOfResourceToBeDownloaded    =  [[NSMutableArray alloc] initWithArray:[daoService getDocumentDetails:docId]];
    }
    
    NSMutableArray *listOfRemainingFileModel = [[NSMutableArray alloc]init];
    
    NSString *rootDirectory = [FileManager getTroubleshootingSubDirectoryPath];
    NSMutableArray *requestParamArray = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < count; i++) { //TO DO :Need to change the logic like pagelayout
        
        RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
        
        for (int i = 0; i < [listOfResourceToBeDownloaded count]; i++) {
            
            TroubleshootDataModel *resourceModel = [listOfResourceToBeDownloaded objectAtIndex:i];
            
            [self deleteTroubleshootingDataForTheModel:resourceModel];
            
            FileModel *model = [[FileModel alloc]init];
            model.sfId = resourceModel.Id;
            model.fileName =  [NSString stringWithFormat:@"%@.%@",resourceModel.Id,resourceModel.Type];
            model.objectName = kDocumentObject;
            model.rootDirectory = rootDirectory;
            
            if (model.sfId != nil)
            {
                if (i != 0)
                {
                    [listOfRemainingFileModel addObject:model];
                } else
                {
                    requestParamModel.values = @[model];
                }
            }
        }
        
        NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc]init];
        
        [infoDictionary setObject:listOfRemainingFileModel forKey:@"remainigFiles"];
        
        requestParamModel.requestInformation = infoDictionary;
        
        [requestParamArray addObject:requestParamModel];
        
    }
    
    return requestParamArray;
}

- (NSArray*)getProductManualRequestParameterForCount:(NSInteger)count
{
    NSString *docId = [[CacheManager sharedInstance] getCachedObjectByKey:@"pMId"];
    NSArray *listOfResourceToBeDownloaded;
    id <ProductManualDAO>  settingsService = [FactoryDAO serviceByServiceType:ServiceTypeProductManual];
    listOfResourceToBeDownloaded = [settingsService
                                    getTheProductManualDetails];
    
    NSMutableArray *listOfRemainingFileModel = [[NSMutableArray alloc]init];
        NSString *rootDirectory = [FileManager getProductManualSubDirectoryPath];
    NSMutableArray *requestParamArray = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < count; i++)
    { //TO DO :Need to change the logic like pagelayout
        
        RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
        
        for (int i = 0; i < [listOfResourceToBeDownloaded count]; i++)
        {
            ProductManualModel *resourceModel = [listOfResourceToBeDownloaded objectAtIndex:i];
            FileModel *model = [[FileModel alloc]init];
            model.sfId = resourceModel.prod_manual_Id;
            model.parentSfId = docId;
            model.fileName = [resourceModel.prod_manual_Id stringByAppendingString:@".pdf"];
            model.objectName = kAttachementObject;
            model.rootDirectory = rootDirectory;
            if (i != 0)
            {
                [listOfRemainingFileModel addObject:model];
            }
            else
            {
                requestParamModel.values = @[model];
            }
            NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc]init];
            [infoDictionary setObject:listOfRemainingFileModel forKey:@"remainigFiles"];
            requestParamModel.requestInformation = infoDictionary;
            [requestParamArray addObject:requestParamModel];
        }
    }
    return requestParamArray;
}

#pragma mark - responce callback handling

-(ResponseCallback*)getResponceCallBackForStaticResourceDownloadWithRequestParam:(RequestParamModel*)requestParamModel
{
    
    /* Once file is downloaded unzip the file to SVMX directory and delete the zip file */
    NSString *rootPath = [FileManager getRootPath];
    
    FileModel *fileModel;
    
    if ([requestParamModel.values count] > 0) {
        
        fileModel = [requestParamModel.values objectAtIndex:0];
        if(fileModel.fileName)
        {
            NSString *filepath = [rootPath stringByAppendingPathComponent:fileModel.fileName];
            
            NSString *documentsDir = [FileManager getCoreLibSubDirectoryPath]; // Get CoreLibrary directory
            
            [UnzipUtility unzipFileAtPath:filepath toFolder:documentsDir];
            
            [FileManager deleteFileAtPath:filepath];
        }
    }
    
    return [self getResponceCallBackObjectForRequestParam:requestParamModel];
}


-(ResponseCallback*)getResponceCallbackForAttachmentDownloadResponceWithRequestParam:(RequestParamModel*)requestParamModel
{
    
    /* Once file is downloaded unzip the file to SVMX directory and delete the zip file */
    NSString *rootPath = [FileManager getRootPath];
    
    FileModel *fileModel;
    
    if ([requestParamModel.values count] > 0) {
        
        fileModel = [requestParamModel.values objectAtIndex:0];
    }
    
    NSString *attachmentId = fileModel.sfId;
    if(attachmentId)
    {
        NSString *filepath = [rootPath stringByAppendingPathComponent:attachmentId];
        
        AttachmentModel *attachmentModel = [[AttachmentModel alloc]init];
        attachmentModel.attachmentId = attachmentId;
        attachmentModel.attachmentBody = [NSData dataWithContentsOfFile:filepath];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:filepath])
        {
            id daoService = [FactoryDAO serviceByServiceType:ServiceTypeAttachments];
            
            if ([daoService conformsToProtocol:@protocol(AttachmentsDAO)]) {
                [daoService updateAttachmentTableWithModelArray:@[attachmentModel]];
            }
            
            [FileManager deleteFileAtPath:filepath];
        }
    }
    return  [self getResponceCallBackObjectForRequestParam:requestParamModel];
}


-(ResponseCallback*)getResponceCallBackForDocumentDownloadWithRequestParam:(RequestParamModel*)requestParamModel

{
    return  [self getResponceCallBackObjectForRequestParam:requestParamModel];
}

- (ResponseCallback*)getResponceCallBackObjectForRequestParam:(RequestParamModel*)requestParamModel
{
    NSMutableArray *remainigFiles = [requestParamModel.requestInformation objectForKey:@"remainigFiles"];
    
    ResponseCallback *callback = [[ResponseCallback alloc]init];
    
    if ([remainigFiles count] > 0) {
        
        requestParamModel.values = @[[remainigFiles objectAtIndex:0]];
        
        [remainigFiles removeObjectAtIndex:0];
        
        [requestParamModel.requestInformation setValue:remainigFiles forKey:@"remainigFiles"];
        
        callback.callBackData = requestParamModel;
        
        callback.callBack = YES;
    } else {
        
        callback.callBack = NO;
    }
    return callback;
}

#pragma mark - Chatter
- (NSArray*)getChatterProductImageParameterForCount:(NSInteger)count
{
    
    NSString *attachmentId = [[CacheManager sharedInstance] getCachedObjectByKey:kChatterAttachmentId];
    
    
    NSMutableArray *listOfResourceToBeDownloaded;
    
    if ([attachmentId length] > 0) {
        
        listOfResourceToBeDownloaded    =  [[NSMutableArray alloc] initWithObjects:attachmentId, nil];
    }
    
    NSMutableArray *listOfRemainingFileModel = [[NSMutableArray alloc]init];
    
    NSString *rootDirectory = [FileManager getChatterSubDirectoryPath];
    NSMutableArray *requestParamArray = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < count; i++) { //TO DO :Need to change the logic like pagelayout
        
        RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
        
        for (int i = 0; i < [listOfResourceToBeDownloaded count]; i++) {
        
            FileModel *model = [[FileModel alloc]init];
            model.sfId = attachmentId;
            model.fileName =  [NSString stringWithFormat:@"%@.%@",attachmentId, @"png"];
            model.objectName = kAttachementObject;
            model.rootDirectory = rootDirectory;
            
            if (model.sfId != nil)
            {
                if (i != 0) {
                    [listOfRemainingFileModel addObject:model];
                }
                else {
                    requestParamModel.values = @[model];
                }
            }
        }
        NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc]init];
        
        [infoDictionary setObject:listOfRemainingFileModel forKey:@"remainigFiles"];
        
        requestParamModel.requestInformation = infoDictionary;
        
        [requestParamArray addObject:requestParamModel];
    }
    return requestParamArray;
}

- (void)deleteTroubleshootingDataForTheModel:(TroubleshootDataModel *)model
{
    NSString *rootDirectory = [FileManager getTroubleshootingSubDirectoryPath];
    
    NSString * filePath = [rootDirectory stringByAppendingPathComponent:
                           [NSString stringWithFormat:@"%@%@", model.Id, @".zip"]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSError *error = nil;
    
    if(fileExists)
    {
        [[NSFileManager defaultManager] removeItemAtPath: filePath error: &error];
    }
    
    NSString *documentsDirectory = [rootDirectory stringByAppendingPathComponent:model.Id];
    BOOL isDocExist  = [[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory];
    
    if(isDocExist && !error)
    {
        [[NSFileManager defaultManager] removeItemAtPath: documentsDirectory error: &error];
        
    }
}

- (NSArray*)getChatterUserImageParameterForCount:(NSInteger)count
{
    
    NSDictionary *userDict = [[CacheManager sharedInstance] getCachedObjectByKey:kChatterUserData];
    
    NSArray *allKeys = [userDict allKeys];
    
    NSString *userId = @"";

    if ([allKeys count] > 0) {
        userId = [allKeys objectAtIndex:0];
    }
    
    NSMutableArray *listOfResourceToBeDownloaded;
    
    if ([userId length] > 0) {
        
        listOfResourceToBeDownloaded  =  [[NSMutableArray alloc] initWithObjects:userId, nil];
    }
    
    NSMutableArray *listOfRemainingFileModel = [[NSMutableArray alloc]init];
    
    NSString *rootDirectory = [FileManager getChatterSubDirectoryPath];
    NSMutableArray *requestParamArray = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < count; i++) { //TO DO :Need to change the logic like pagelayout
        
        RequestParamModel *requestParamModel = [[RequestParamModel alloc]init];
        
        for (int i = 0; i < [listOfResourceToBeDownloaded count]; i++) {
            
            FileModel *model = [[FileModel alloc]init];
            model.sfId = userId;
            model.fileName =  [NSString stringWithFormat:@"%@.%@",userId, @"png"];
            model.objectName = @"User";
            model.rootDirectory = rootDirectory;
            model.suffixUrl = [userDict objectForKey:userId];
            
            if (model.sfId != nil)
            {
                if (i != 0) {
                    [listOfRemainingFileModel addObject:model];
                }
                else {
                    requestParamModel.values = @[model];
                }
            }
        }
        NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc]init];
        
        [infoDictionary setObject:listOfRemainingFileModel forKey:@"remainigFiles"];
        
        requestParamModel.requestInformation = infoDictionary;
        
        [requestParamArray addObject:requestParamModel];
    }
    return requestParamArray;
}





#pragma mark - End

@end
