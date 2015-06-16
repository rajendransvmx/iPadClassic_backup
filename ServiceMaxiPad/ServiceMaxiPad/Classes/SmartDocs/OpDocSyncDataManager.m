//
//  OpDocSyncDataManager.m
//  ServiceMaxiPad
//
//  Created by Admin on 05/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "OpDocSyncDataManager.h"

@implementation OpDocSyncDataManager
@synthesize cOpDocObjectForSync;
@synthesize cHtmlSignatureDocSubmissionDictionary;
@synthesize cListForGeneratingPDFDictionary;
@synthesize cResponseForDocSubmitDictionary;
@synthesize cResponseForGeneratingPDFDictionary;
@synthesize isSuccessfullyUploaded;
@synthesize fileAlreadyUploaded;

+ (id)sharedManager {
    static OpDocSyncDataManager *sharedOpDocSyncManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOpDocSyncManager = [[self alloc] init];
    });
    return sharedOpDocSyncManager;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
