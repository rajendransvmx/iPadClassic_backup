//
//  OpDocHelper.h
//  ServiceMaxiPad
//
//  Created by Admin on 05/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"

@protocol OPDocCustomDelegate <NSObject>

- (void)OpdocStatus:(BOOL)status forCategory:(CategoryType)category;

@end


@interface OpDocHelper : NSObject

@property(nonatomic, assign) id <OPDocCustomDelegate> customDelegate;

+ (id)sharedManager;

-(BOOL)isTheOpDocSyncInProgress;
-(void)initiateFileSync;
-(void)initiateDocumentSubmissionProcess;
-(void)initiateGeneratePDFProcess;
-(NSString *)getQueryForCheckingOPDOCFileUploadStatus;

@end
