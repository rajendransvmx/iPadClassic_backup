//
//  FileModel.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "FileModel.h"

@implementation FileModel

@synthesize sfId;
@synthesize localId;
@synthesize status;
@synthesize fileName;
@synthesize sol;
@synthesize errorMessage;
@synthesize isPrivate;
@synthesize parentSfId;
@synthesize suffixUrl;
@synthesize fileSize;
@synthesize statusCode;
@synthesize errorCode;
@synthesize actionType;

- (void)dealloc
{
    sfId     = nil;
    localId  = nil;
    status   = nil;
    fileName = nil;
    sol      = nil;
    errorMessage = nil;
    isPrivate    = nil;
    parentSfId   = nil;
    suffixUrl    = nil;
}

@end
