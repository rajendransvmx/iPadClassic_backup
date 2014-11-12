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

@property (nonatomic, retain) id cOpDocObjectForSync;
@property (nonatomic, retain) NSDictionary *cHtmlSignatureDocSubmissionDictionary;
@property (nonatomic, retain) NSDictionary *cListForGeneratingPDFDictionary;
@property (nonatomic, retain) NSDictionary *cResponseForDocSubmitDictionary;
@property (nonatomic, retain) NSDictionary *cResponseForGeneratingPDFDictionary;

@end
