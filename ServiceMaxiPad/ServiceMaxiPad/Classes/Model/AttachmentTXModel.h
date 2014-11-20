//
//  AttachmentTXModel.h
//  ServiceMaxiPad
//
//  Created by Anoop on 10/29/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachmentTXModel : NSObject

@property(nonatomic, copy) NSString *localId;
@property(nonatomic, copy) NSString *body;
@property(nonatomic, copy) NSString *parentId;
@property(nonatomic, copy) NSString *createdDate;
@property(nonatomic, copy) NSString *contentType;
@property(nonatomic, readwrite) NSUInteger bodyLength;
@property(nonatomic, copy) NSString *ownerId;
@property(nonatomic, copy) NSString *createdById;
@property(nonatomic, copy) NSString *lastModifiedDate;
@property(nonatomic, copy) NSString *idOfAttachment;
@property(nonatomic, copy) NSString *isPrivate;
@property(nonatomic, copy) NSString *isDeleted;
@property(nonatomic, copy) NSString *descriptionString;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *systemModStamp;
@property(nonatomic, copy) NSString *lastModifiedById;

//Custom
@property(nonatomic, copy) NSString *nameWithoutExtension;
@property(nonatomic, copy) NSString *errorMessage;
@property(nonatomic, assign) NSInteger errorCode;
@property(nonatomic, copy) NSString *extensionName;
@property(nonatomic, copy) NSString *displayDateString;
@property(nonatomic, assign) BOOL isDownloaded;
@property(nonatomic, assign) BOOL isDownloading;
@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, assign) BOOL isVideo;
@property(nonatomic, strong) UIImage *thumbnailImage;

- (void)explainMe;

+ (NSDictionary*)getMappingDictionary;

@end
