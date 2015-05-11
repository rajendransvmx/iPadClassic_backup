//
//  AttachmentServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "AttachmentServiceLayer.h"
#import "ZKSObject.h"
#import "AttachmentsUploadManager.h"
#import "AttachmentTXModel.h"
#import "Base64.h"
#import "AttachmentUtility.h"
#import "AttachmentHelper.h"
#import "ZKSaveResult.h"
#import "SMLogger.h"
#import "StringUtil.h"

@implementation AttachmentServiceLayer


- (instancetype) initWithCategoryType:(CategoryType)categoryType
                requestType:(RequestType)requestType {
    
    self = [super initWithCategoryType:categoryType requestType:requestType];
    
    if (self != nil) {
        //Intialize if required
        
    }
    
    return self;
    
}

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                        responseData:(id)responseData
{
    
    SXLogInfo(@"Process the response. in OPdocService Layer");
    SXLogWarning(@"responseData: %@", responseData);
    
    NSDictionary *responseDict = (NSDictionary *)responseData;
    
    if (self.requestType == RequestAttachmentUpload) {
        
        /*
         Expected Result
         responseData: {
         context =     {
         Name = "samplehtmlpage.html";
         ProcessID = "sdfsdfsdf-2323";
         "SF_ID" = a1LK0000001XaoBMAS;
         };
         result =     (
         00PK0000001sobwMAA
         );
         }
         
         */
        
        NSArray *lResultantSFIDs = [responseDict objectForKey:@"result"];
        ZKSaveResult * savedResult = (ZKSaveResult *) [lResultantSFIDs lastObject];
        NSString *lResultantSFIDString = [savedResult id];
        
        //lResultantSFIDs will return array of zksresultObject
        if(![StringUtil isStringEmpty:lResultantSFIDString])
        {
            AttachmentTXModel *model = [[AttachmentsUploadManager sharedManager] modelUnderUploadProcess];
            
            model.idOfAttachment = lResultantSFIDString;
            
            [self updateTheDBForTheUploadedAttachment:model];
        }
        
        
    }


    return nil;
    
}


- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    RequestParamModel * param = nil;
    
    if (self.requestType == RequestAttachmentUpload) {
        
        AttachmentTXModel *model = [[AttachmentsUploadManager sharedManager] modelUnderUploadProcess];
        model.extensionName = [NSString stringWithFormat:@".%@",[model.name pathExtension]];
        ZKSObject * obj = [[ZKSObject alloc] initWithType:@"Attachment"];
        NSString *fileDataString = [AttachmentUtility getEncodedBlobDataForAttachment:model];
        [obj setFieldValue:fileDataString field:@"Body"];
        [obj setFieldValue:model.name field:@"Name"];
        [obj setFieldValue:model.parentId field:@"ParentId"];
        [obj setFieldValue:kFalse field:@"isPrivate"];

        NSArray * array = [[NSArray alloc] initWithObjects:obj, nil];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:model.parentId forKey:@"SF_ID"];
        [dict setObject:model.name forKey:@"Name"];
        
        param = [[RequestParamModel alloc] init];
        param.values = array;
        param.context = dict;
        
    }
    
    return (param != nil) ? @[param]:nil;
    //return @[param];
}


-(void)updateTheDBForTheUploadedAttachment:(AttachmentTXModel *)model
{
    [AttachmentHelper  updateSFIdForUploadedAttachmentModel:model];
}

@end
