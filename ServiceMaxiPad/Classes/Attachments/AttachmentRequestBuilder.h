//
//  AttachmentRequest.h
//  ServiceMaxiPad
//
//  Created by Anoop on 11/5/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "RestRequest.h"

@class AttachmentTXModel;

@interface AttachmentRequestBuilder : RestRequest

- (NSURLRequest*)getRequestForAttachmentDownload:(AttachmentTXModel*)attachmentTXModel;

@end
