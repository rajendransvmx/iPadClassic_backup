//
//  AttachmentHelper.h
//  ServiceMaxiPad
//
//  Created by Anoop on 10/29/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttachmentTXModel.h"

@interface AttachmentHelper : NSObject

+(NSMutableArray*)getDocAttachmentsLinkedToParentId:(NSString*)parentsfId;

+(NSMutableArray*)getImagesAndVideosAttachmentsLinkedToParentId:(NSString*)parentsfId;

@end
