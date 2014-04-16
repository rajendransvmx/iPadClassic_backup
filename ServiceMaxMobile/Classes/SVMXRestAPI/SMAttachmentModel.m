//
//  SMAttachmentModel.m
//  iService
//
//  Created by Vipindas on 11/17/13.
//
//

#import "SMAttachmentModel.h"

@implementation SMAttachmentModel


@synthesize fileSize;
@synthesize errorCode;
@synthesize downloadCompleted;
@synthesize statusCode;
@synthesize actionType;

@synthesize localId;
@synthesize sfId;
@synthesize status;
@synthesize fileName; 
@synthesize sol;
@synthesize errorMessage;
@synthesize request;
@synthesize dataForUploading;
@synthesize isPrivate;
@synthesize parentSfId;
@synthesize encodeDataForUploading;


- (id)initWithSFId:(NSString *)sfid andFileName:(NSString *)fileNameWithExtension
{
    self = [super init];
    
    if (self)
    {
        self.sfId = sfid;
        self.fileName = fileNameWithExtension;
    }
    
    return self;
}

- (id)initWithSFId:(NSString *)sfid andFileName:(NSString *)fileNameWithExtension andLocalId:(NSString *)locId
{
    self = [super init];
    
    if (self)
    {
        self.sfId = sfid;
        self.fileName = fileNameWithExtension;
        self.localId = locId;
    }
    return self;
}


- (void)dealloc
{
    [sfId release]; sfId = nil;
    [fileName release]; fileName = nil;
    [status release]; status = nil;
    [sol  release]; sol = nil;
    [errorMessage release]; errorMessage = nil;
    [request release]; request = nil;
    [localId release]; localId = nil;
    [isPrivate release]; isPrivate = nil;
    [dataForUploading release]; dataForUploading = nil;
    [parentSfId release]; parentSfId = nil;
    [encodeDataForUploading release]; encodeDataForUploading = nil;
    
    [super dealloc];
}


- (NSString *)actionTypeString
{
    if (self.actionType == SMAttachmentActionTypeUpload)
    {
        return kAttachmentActionTypeUpload;
    }
    else if (self.actionType == SMAttachmentActionTypeDownload)
    {
        return kAttachmentActionTypeDownload;
    }
    else
    {
        return @"Unknown Action";
    }
}

- (BOOL)isDownload
{
    if (self.actionType == SMAttachmentActionTypeDownload)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isUpload
{
    if (self.actionType == SMAttachmentActionTypeUpload)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

   
@end
