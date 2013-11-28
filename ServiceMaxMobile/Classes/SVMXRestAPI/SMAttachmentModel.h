//
//  SMAttachmentModel.h
//  iService
//
//  Created by Vipindas on 11/17/13.
//
//

#import <Foundation/Foundation.h>
#import "SMRestRequest.h"
#import "SVMXSystemConstant.h"

@interface SMAttachmentModel : NSObject
{
    NSInteger fileSize;           // in Bytes
    NSInteger statusCode;         // in Bytes
    NSInteger errorCode;
    NSInteger downloadCompleted; // In bytes
    NSInteger actionType;        // SMAttachmentActionType - Values Ex:- 1 - Upload, 2 - Download.

    NSString *sfId;
    NSString *localId;           // Local_id of the attachment  
    NSString *status;
    NSString *fileName;          // File Name with Extension
    NSString *sol;
    NSString *errorMessage;
    NSString *isPrivate;
    NSString *parentSfId;
    NSString *encodeDataForUploading;  // Encoded Data 
    
    NSData   *dataForUploading;

    SMRestRequest *request;
}

@property(nonatomic, copy) NSString *sfId;
@property(nonatomic, copy) NSString *localId;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, copy) NSString *fileName;
@property(nonatomic, copy) NSString *sol;
@property(nonatomic, copy) NSString *errorMessage;
@property(nonatomic, copy) NSString *isPrivate;
@property(nonatomic, copy) NSString *parentSfId;
@property(nonatomic, copy) NSString *encodeDataForUploading;

@property(nonatomic, retain) NSData *dataForUploading;
@property(nonatomic, retain) SMRestRequest *request;

@property(nonatomic, assign) NSInteger fileSize;
@property(nonatomic, assign) NSInteger statusCode;
@property(nonatomic, assign) NSInteger errorCode;
@property(nonatomic, assign) NSInteger downloadCompleted;
@property(nonatomic, assign) NSInteger actionType;


- (id)initWithSFId:(NSString *)sfid andFileName:(NSString *)fileNameWithExtension;
- (NSString *)actionTypeString;

- (BOOL)isDownload;
- (BOOL)isUpload;

@end
