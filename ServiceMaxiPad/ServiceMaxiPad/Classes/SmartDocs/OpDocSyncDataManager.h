//
//  OpDocSyncDataManager.h
//  ServiceMaxiPad
//
//  Created by Admin on 05/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpDocSyncDataManager : NSObject

+ (id)sharedManager;

@property (nonatomic, strong) id cOpDocObjectForSync;
@property (nonatomic, strong) NSDictionary *cHtmlSignatureDocSubmissionDictionary;
@property (nonatomic, strong) NSDictionary *cListForGeneratingPDFDictionary;
@property (nonatomic, strong) NSDictionary *cResponseForDocSubmitDictionary;
@property (nonatomic, strong) NSDictionary *cResponseForGeneratingPDFDictionary;
@property (nonatomic, assign) BOOL isSuccessfullyUploaded;

@end
