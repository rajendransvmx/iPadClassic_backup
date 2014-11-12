//
//  FileDownloadRequest.m
//  ServiceMaxMobile
//
//  Created by shravya on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "FileDownloadRequest.h"
#import "CustomerOrgInfo.h"
#import "AppMetaData.h"
#import "AFHTTPRequestOperation.h"
#import "RequestFactory.h"
//#import "SFMetaDataModel.h"
#import "FileModel.h"
#import "FileManager.h"

@implementation FileDownloadRequest

- (void)main {
    @synchronized([self class]) {
        @autoreleasepool {
            
            /**  Get the Url string Base url + API URL */
            FileModel *fileToBeDownloaded = nil;
            if ([self.requestParameter.values count] > 0) {
                fileToBeDownloaded = [self.requestParameter.values objectAtIndex:0];
            }
            
            //NSString *urlString = @"http://upload.wikimedia.org/wikipedia/commons/5/5d/Crateva_religiosa.jpg";
            NSString *urlString = [self getBaseUrlDependingOnTheRequest:fileToBeDownloaded];
            NSURL *apiURL = [NSURL URLWithString:urlString];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:apiURL];
            
            /** Set the http method */
            [urlRequest setHTTPMethod:@"GET"];
            
            /** Set the request timeout */
            //TODO : hardcoded to 3 minutes.
            [urlRequest setTimeoutInterval:[self timeOutForRequest]];
            
            /** Content type */
            [urlRequest setValue:kContentType forHTTPHeaderField:@"content-type"];
            
            /** Set Header properties  */
            NSDictionary *otherHttpHeaders = [self httpHeaderParameters];
            NSArray *allKeys = [otherHttpHeaders allKeys];
            for (NSString *eachKey in allKeys) {
                NSString *eachValue = [otherHttpHeaders objectForKey:eachKey];
                [urlRequest setValue:eachValue forHTTPHeaderField:eachKey];
            }
            
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
            
            NSString *rootPath = fileToBeDownloaded.rootDirectory;
            if (fileToBeDownloaded.rootDirectory == nil) {
                rootPath = [FileManager  getRootPath];
            }
           
            NSString *filePathLocal = [[NSString alloc] initWithFormat:@"%@/%@",rootPath,fileToBeDownloaded.fileName];
            //operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePathLocal append:NO];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Successfully downloaded file to %@", filePathLocal);
                if (responseObject != nil) {
                    NSData *data = (NSData *)responseObject;
                    [self writeData:data toFilePath:filePathLocal];
                }
                [self didReceiveResponseSuccessfully:responseObject];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                NSInteger code = error.code;
                NSHTTPURLResponse *response =  [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
                if (response != nil)
                {
                    code = response.statusCode;
                }
                
                [self didRequestFailedWithError:[NSError errorWithDomain:error.domain code:code userInfo:error.userInfo] andResponse:operation.responseObject];
            }];
            
            [operation start];
         }
    }
}


- (NSDictionary *)httpHeaderParameters
{
    
    @synchronized([self class]){
        
        NSString *oAuthToken = self.oAuthId;
        oAuthToken = [NSString stringWithFormat:@"OAuth %@",oAuthToken];
        
        if (oAuthToken != nil) {
            return [NSDictionary dictionaryWithObjectsAndKeys:oAuthToken, kOAuthSessionTokenKey,nil];
        }
        
    }
    return nil;
}

- (NSString *)getBaseUrlDependingOnTheRequest:(FileModel *)fileModel {
    
    return [self urlByType:self.requestType andFileModel:fileModel];
}

- (NSString*)urlByType:(RequestType)type andFileModel:(FileModel *)fileModel
{
    NSString *url = nil;
    NSString *subUrl = nil;
    
    switch (type) {
        case RequestStaticResourceDownload:
        case RequestAttachmentDownload:
        case RequestDocumentDownload:
        case RequestTroubleShootDocInfoFetch:
        case RequestProductManualDownload:
             subUrl = [[NSString alloc] initWithFormat:@"%@%@/%@/%@",kFileDownloadUrlFromObject, fileModel.objectName, fileModel.sfId,kFileDownloadUrlBody];
            break;
        default:

            break;
    }
    url = [self getUrlWithStringApppended:subUrl];
    return url;
}
#pragma mark - delegate

- (void)didReceiveResponseSuccessfully:(id)responseObject
{
    [self.serverRequestdelegate didReceiveResponseSuccessfully:responseObject andRequestObject:self];
}

- (void)didRequestFailedWithError:(id)error andResponse:(id)someResponseObj
{
    [self.serverRequestdelegate didRequestFailedWithError:error Response:someResponseObj andRequestObject:self];
}

#pragma mark - File writing
- (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath {
     return   [data writeToFile:filePath atomically:YES];
}

#pragma mark -Urls based on the request type
- (NSString*)getUrlWithStringApppended:(NSString*)stringToAppend
{
    CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
    return  [[NSString alloc] initWithFormat:@"%@%@",[customerOrgInfoInstance instanceURL],stringToAppend];
}


@end
