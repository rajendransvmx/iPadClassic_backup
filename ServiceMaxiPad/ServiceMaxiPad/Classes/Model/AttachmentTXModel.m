//
//  AttachmentTXModel.m
//  ServiceMaxiPad
//
//  Created by Anoop on 10/29/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "AttachmentTXModel.h"

@implementation AttachmentTXModel

- (void)explainMe {
    
    NSLog(@"localId %@ \n body %@ \n parentId %@ \n createdDate %@ \n contentType %@ \n bodyLength %@ \n ownerId %@ \n createdById %@ \n lastModifiedDate %@ \n idOfAttachment %@ \n isPrivate %d \n isDeleted %d \n descriptionString %@ \n name %@ \n systemModStamp %@ \n lastModifiedById %@ \n", _localId, _body, _parentId, _createdDate, _contentType,
          _bodyLength, _ownerId, _createdById, _lastModifiedDate, _idOfAttachment, _isPrivate, _isDeleted, _descriptionString,
          _name, _systemModStamp, _lastModifiedById);
}

+ (NSDictionary*)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: kAttachmentTXlocalId, @"localId", kAttachmentTXBody, @"body", kAttachmentTXParentId, @"parentId", kAttachmentTXCreatedDate, @"createdDate", kAttachmentTXContentType, @"contentType", kAttachmentTXBodyLength, @"bodyLength", kAttachmentTXOwnerId, @"ownerId", kAttachmentTXCreatedById, @"createdById", kAttachmentTXLastModifiedDate, @"lastModifiedDate", kAttachmentTXId, @"idOfAttachment", kAttachmentTXIsPrivate, @"isPrivate", kAttachmentTXIsDeleted, @"isDeleted", kAttachmentTXDescription, @"descriptionString", kAttachmentTXName, @"name", kAttachmentTXSystemModStamp, @"systemModStamp", kAttachmentTXLastModifiedById, @"lastModifiedById", nil];
    
    return mapDictionary;
    
}

@end
