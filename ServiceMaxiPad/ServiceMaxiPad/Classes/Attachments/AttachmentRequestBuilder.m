//
//  AttachmentRequest.m
//  ServiceMaxiPad
//
//  Created by Anoop on 11/5/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "AttachmentRequestBuilder.h"
#import "CustomerOrgInfo.h"
#import "AppMetaData.h"
#import "RequestFactory.h"
#import "AttachmentTXModel.h"

@implementation AttachmentRequestBuilder

- (NSURLRequest*)getRequestForAttachmentDownload:(AttachmentTXModel*)attachmentTXModel {
    
    NSString *urlString = [self getBaseUrlDependingOnTheRequest:attachmentTXModel];
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
    
    return urlRequest;
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

- (NSString *)getBaseUrlDependingOnTheRequest:(AttachmentTXModel *)attachmentTXModel {
    
    return [self urlByType:self.requestType andFileModel:attachmentTXModel];
}

- (NSString*)urlByType:(RequestType)type andFileModel:(AttachmentTXModel *)attachmentTXModel
{
    NSString *url = nil;
    NSString *subUrl = nil;
    
    switch (type) {
            
        case RequestTypeSFMAttachmentsDownload:
            subUrl = [[NSString alloc] initWithFormat:@"%@%@/%@/%@",kFileDownloadUrlFromObject, @"Attachment", attachmentTXModel.idOfAttachment, kFileDownloadUrlBody];
            break;
        default:
            
            break;
    }
    url = [self getUrlWithStringApppended:subUrl];
    return url;
}

#pragma mark -Urls based on the request type
- (NSString*)getUrlWithStringApppended:(NSString*)stringToAppend
{
    CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
    return  [[NSString alloc] initWithFormat:@"%@%@",[customerOrgInfoInstance instanceURL],stringToAppend];
}

@end
