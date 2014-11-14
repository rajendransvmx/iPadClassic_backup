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
    
    NSLog(@"Process the response. in OPdocService Layer");
    NSLog(@"responseData: %@", responseData);
    
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
        
        //NSDictionary *lContextDictionary = (NSDictionary *)[responseDict objectForKey:@"context"];
        
        NSArray *lResultantSFIDs = [responseDict objectForKey:@"result"];
        
        //lResultantSFIDs will return array of zksresultObject
        NSString *lResultantSFID = @"";
        if([lResultantSFIDs count] > 0)
        {
            lResultantSFID = (NSString*)[lResultantSFIDs objectAtIndex:0];
        }
        
        AttachmentTXModel *model = [[AttachmentsUploadManager sharedManager] modelUnderUploadProcess];
        
        model.idOfAttachment = lResultantSFID;
        
        [self updateTheDBForTheUploadedAttachment:model];
    }


    return nil;
    
}


- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    RequestParamModel * param = nil;
    
    if (self.requestType == RequestAttachmentUpload) { // Uploading HTMl and Signature Files Uploading
        
        AttachmentTXModel *model = [[AttachmentsUploadManager sharedManager] modelUnderUploadProcess];
        model.extensionName = [NSString stringWithFormat:@".%@",[model.name pathExtension]];
        ZKSObject * obj = [[ZKSObject alloc] initWithType:@"Attachment"];
        NSString *fileDataString = [AttachmentUtility getEncodedBlobDataForAttachment:model];
        
        [obj setFieldValue:fileDataString field:@"Body"];
        [obj setFieldValue:model.name field:@"Name"];
        [obj setFieldValue:model.parentId field:@"ParentId"];
        [obj setFieldValue:model.localId field:@"localId"];
        [obj setFieldValue:(model.isPrivate? @"True":@"False") field:@"isPrivate"];
        [obj setFieldValue:@"Attachment" field:@"ObjectName"];

        NSArray * array = [[NSArray alloc] initWithObjects:obj, nil];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:model.parentId forKey:@"SF_ID"];
//        [dict setObject:self.cProcess_ID forKey:@"ProcessID"];
        //9007
        [dict setObject:model.name forKey:@"Name"];
        
        param = [[RequestParamModel alloc] init];
        param.values = array;
        param.context = dict;
        
    }
    
    return @[param];
}

- (RequestParamModel*)getRequestParameters {
    
    switch (self.requestType) {
        case RequestGetAttachment:
            
            break;
            
        default:
            break;
    }
   // NSLog(@"Invalid request type");
    return nil;
    
}


-(void)updateTheDBForTheUploadedAttachment:(AttachmentTXModel *)model
{
    //TODO: Write Query to update the DB for the succesful upload of the Attachment.
    
    [AttachmentHelper  updateSFIdForUploadedAttachmentModel:model];
}

@end
