//
//  AttachmentErrorUtility.m
//  ServiceMaxMobile
//
//  Created by Sahana on 05/05/15.
//  Copyright (c) 2015 SivaManne. All rights reserved.
//

#import "AttachmentErrorUtility.h"

@implementation AttachmentErrorUtility


+(SMAttachmentRequestErrorCode)getErrorCodeForNetworkError:(NSInteger)errorCode
{
    
    switch (errorCode) {
        case NSURLErrorTimedOut:
            return SMAttachmentRequestErrorCodeRequestTimeOut;
            break;
        case NSURLErrorFileDoesNotExist :
            return SMAttachmentRequestErrorCodeFileNotFound;
            break;
        case  NSURLErrorBadServerResponse:
            return SMAttachmentRequestErrorCodeFileNotFound;
            break;
        case NSURLErrorCancelled:
            return SMAttachmentRequestErrorCodeCancelled;
            break;
        default:
            return SMAttachmentRequestErrorCodeUnknown;
            break;
    }
    
    return SMAttachmentRequestErrorCodeUnknown;
}

@end



