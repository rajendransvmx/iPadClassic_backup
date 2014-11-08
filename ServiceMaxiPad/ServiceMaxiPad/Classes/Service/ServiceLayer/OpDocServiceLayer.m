//
//  OpDocServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Admin on 31/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "OpDocServiceLayer.h"
#import "OpDocSyncDataManager.h"
#import "ParserFactory.h"
#import "WebServiceParser.h"
#import "ResourceHandler.h"
#import "ZKSObject.h"
#import "Base64.h"
#import "OPDocHTML.h"
#import "OPDocSignature.h"
#import "SFMPageHelper.h"
#import "FileManager.h"

#import "OPDocServices.h"
#import "OPDocSignatureService.h"
#import "NonTagConstant.h"


#define kSmartDocsHTMLID                       @"HTMLID"
#define kSmartDocsSignatureUsed                @"SIGNATURE"
#define kSmartDocsSignaturesToDel              @"DELETE_ID"

@interface OpDocServiceLayer()

@property (nonatomic, copy) NSString *cParent_SFID;
@property (nonatomic, copy) NSString *cFileName;
@property (nonatomic, copy) NSString *cProcess_ID;
@property (nonatomic, copy) NSString *cLocal_ID;
@property (nonatomic, copy) NSString *cRecord_ID;
@property (nonatomic, copy) NSString *cObjectName;
@property (nonatomic, assign) BOOL  isHTMLDoc;
@property (nonatomic, copy) NSString *cWorkOrderOuputString;

@end

@implementation OpDocServiceLayer

@synthesize cParent_SFID;
@synthesize cFileName;
@synthesize cProcess_ID;
@synthesize cLocal_ID;
@synthesize cRecord_ID;
@synthesize cObjectName;
@synthesize isHTMLDoc;
@synthesize cWorkOrderOuputString;

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

    if (self.requestType == RequestTypeOpDocUploading) {
        
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
        
        NSDictionary *lContextDictionary = (NSDictionary *)[responseDict objectForKey:@"context"];
        NSString *lResultantSF_ID = [responseDict objectForKey:@"result"];

        id OPDocObject = [[OpDocSyncDataManager sharedManager] cOpDocObjectForSync];
        
        if([OPDocObject isKindOfClass:[OPDocHTML class]])
        {
            OPDocHTML *lOPDocHTML = (OPDocHTML *)OPDocObject;
            lOPDocHTML.sfid = lResultantSF_ID;
            
            OPDocServices *lOpdocHTMLService = [[OPDocServices alloc] init];
            [lOpdocHTMLService updateHTML:lOPDocHTML];
            
        }
        else{
            OPDocSignature *lOPDocSignature = (OPDocSignature *)OPDocObject;
            lOPDocSignature.sfid = lResultantSF_ID;
            
            OPDocSignatureService *lOpdocSignatureService = [[OPDocSignatureService alloc] init];
            [lOpdocSignatureService updateSignature:lOPDocSignature];
            
        }
    }
    else if(self.requestType == RequestTypeOPDocHTMLAndSignatureSubmit)
    {
        
        /*
         
         Expected Response
         
         
        responseData: {
            aplOrder = "<null>";
            errors =     (
            );
            eventName = "SUBMIT_DOCUMENT";
            eventType = SYNC;
            message = "<null>";
            messageType = "<null>";
            pageUI = "<null>";
            success = 1;
            value = "<null>";
            valueMap =     (
                            {
                                data = "<null>";
                                key = HTMLID;
                                "lstInternal_Request" = "<null>";
                                "lstInternal_Response" = "<null>";
                                record = "<null>";
                                value = "<null>";
                                valueMap =             (
                                );
                                values =             (
                                                      00PK0000001sYozMAE
                                                      );
                            },
                            {
                                data = "<null>";
                                key = SIGNATURE;
                                "lstInternal_Request" = "<null>";
                                "lstInternal_Response" = "<null>";
                                record = "<null>";
                                value = "<null>";
                                valueMap =             (
                                );
                                values =             (
                                );
                            },
                            {
                                data = "<null>";
                                key = "DELETE_ID";
                                "lstInternal_Request" = "<null>";
                                "lstInternal_Response" = "<null>";
                                record = "<null>";
                                value = "<null>";
                                valueMap =             (
                                );
                                values =             (
                                );
                            }
                            );
            values =     (
            );
        }
        */
        
        if([responseDict objectForKey:@"success"])
        {
            
            NSArray *ResponseForSubmitArray = [responseDict objectForKey:@"valueMap"];
            
            NSArray *htmlArray;
            NSArray *signatureArray;
            NSArray *deleteArray;
            
            for (NSDictionary *lDict in ResponseForSubmitArray) {
                if ([[lDict objectForKey:@"key"] isEqualToString:@"HTMLID"]) {
                    htmlArray = [lDict objectForKey:@"values"];
                    
                }
                else  if ([[lDict objectForKey:@"key"] isEqualToString:@"SIGNATURE"]) {
                    signatureArray = [lDict objectForKey:@"values"];
                    
                }
                else  if ([[lDict objectForKey:@"key"] isEqualToString:@"DELETE_ID"]) {
                    deleteArray = [lDict objectForKey:@"values"];
                    
                }
            }
            [[OpDocSyncDataManager sharedManager] setCResponseForDocSubmitDictionary:@{kOPDocHTMLString:htmlArray, kOPDocSignatureString:signatureArray, kOPDocDeleteString:deleteArray}];
            
        }
        else
        {
            //TODO: What if success is 0?

        }
        

        NSLog(@"responseDict :%@", responseDict);
    }
    else
    { // Generate PDF

        /*
         
         Expected Response:
         
        responseData: {
            aplOrder = "<null>";
            errors =     (
            );
            eventName = "GENERATE_PDF";
            eventType = SYNC;
            message = "<null>";
            messageType = "<null>";
            pageUI = "<null>";
            success = 1;
            value = "<null>";
            valueMap =     (
                            {
                                data = "<null>";
                                key = HTMLID;
                                "lstInternal_Request" = "<null>";
                                "lstInternal_Response" = "<null>";
                                record = "<null>";
                                value = "<null>";
                                valueMap =             (
                                );
                                values =             (
                                                      00PK0000001sobwMAA
                                                      );
                            },
                            {
                                data = "<null>";
                                key = SIGNATURE;
                                "lstInternal_Request" = "<null>";
                                "lstInternal_Response" = "<null>";
                                record = "<null>";
                                value = "<null>";
                                valueMap =             (
                                );
                                values =             (
                                );
                            }
                            );
            values =     (
            );
        }
    */
        
        NSLog(@"responseDict :%@", responseDict);

        if([responseDict objectForKey:@"success"])
        {
            
            NSArray *ResponseForSubmitArray = [responseDict objectForKey:@"valueMap"];
            
            NSArray *htmlArray;
            NSArray *signatureArray;
            
            for (NSDictionary *lDict in ResponseForSubmitArray) {
                if ([[lDict objectForKey:@"key"] isEqualToString:@"HTMLID"]) {
                    htmlArray = [lDict objectForKey:@"values"];
                    
                }
                else  if ([[lDict objectForKey:@"key"] isEqualToString:@"SIGNATURE"]) {
                    signatureArray = [lDict objectForKey:@"values"];
                    
                }
                
            }
            
            [[OpDocSyncDataManager sharedManager] setCResponseForGeneratingPDFDictionary:@{kOPDocHTMLString:htmlArray, kOPDocSignatureString:signatureArray}];

        }
        else
        {
            //TODO: What if success is 0?
            
        }
        
    }
    
    return nil;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    RequestParamModel * param = nil;
    
    if (self.requestType == RequestTypeOpDocUploading) { // Uploading HTMl and Signature Files Uploading
        
        
        [self saveFileDetailsLocallyForObject];  // For saving the local reference of the Model details.
        
//        self.cParent_SFID = @"a1LK0000001XaoBMAS"; //TODO:REMVOE it. For Testing only
        
        ZKSObject * obj = [[ZKSObject alloc] initWithType:@"Attachment"];
        
        [obj setFieldValue:self.cFileName field:@"Name"];
        [obj setFieldValue:self.cWorkOrderOuputString field:@"Description"];
        
      
        NSString *lFilePath =  [[FileManager getCoreLibSubDirectoryPath] stringByAppendingPathComponent:self.cFileName];
        
        NSData * fileData = [NSData dataWithContentsOfFile:lFilePath];
        NSString * fileString = [Base64 encode:fileData];
        
        [obj setFieldValue:fileString field:@"Body"];
        [obj setFieldValue:self.cParent_SFID field:@"ParentId"];
        [obj setFieldValue:@"False" field:@"isPrivate"];
        
        NSArray * array = [[NSArray alloc] initWithObjects:obj, nil];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:self.cParent_SFID forKey:@"SF_ID"];
        [dict setObject:self.cProcess_ID forKey:@"ProcessID"];
        //9007
        [dict setObject:self.cFileName forKey:@"Name"];
        
        param = [[RequestParamModel alloc] init];
        param.values = array;
        param.context = dict;
        
        
    }
    else if (self.requestType == RequestTypeOPDocHTMLAndSignatureSubmit){ // For SUBMITTING the list of HTML and Signature files to Server
        
        NSDictionary *lOPDocHTMLAndSignatureObjectDict = [[OpDocSyncDataManager sharedManager] cHtmlSignatureDocSubmissionDictionary];
        NSArray *listOfHTMLIds = [NSMutableArray arrayWithArray:[lOPDocHTMLAndSignatureObjectDict objectForKey:@"html"]];
        NSArray *listOfSignatureIds = [NSMutableArray arrayWithArray:[lOPDocHTMLAndSignatureObjectDict objectForKey:@"signature"]];
        

//        listOfHTMLIds = @[@"00PK0000001sobwMAA"]; // TODO:Remove. For testing only.
        
        if(![listOfHTMLIds count])
        {
            NSLog(@"No Smart Docs files available for PDF Generation!!");
            return nil;
        }
        
        NSMutableDictionary *htmlValueMap = [NSMutableDictionary dictionary];
        [htmlValueMap setObject:kSmartDocsHTMLID forKey:@"key"];
        [htmlValueMap setObject:listOfHTMLIds forKey:@"values"];
        
        NSMutableDictionary *signatureValueMap = [NSMutableDictionary dictionary];
        [signatureValueMap setObject:kSmartDocsSignatureUsed forKey:@"key"];
        [signatureValueMap setObject:listOfSignatureIds forKey:@"values"];
        
        param = [[RequestParamModel alloc] init];
        param.valueMap = @[htmlValueMap, signatureValueMap];
        
    }
    else if (self.requestType == RequestTypeOPDocGeneratePDF){  // For Generating the PDF in the server of the HTML File Submitted already.
        
        NSDictionary *lOPDocHTMLAndSignatureObjectDict = [[OpDocSyncDataManager sharedManager] cListForGeneratingPDFDictionary];
        
        NSArray *listOfHTMLIds = [NSMutableArray arrayWithArray:[lOPDocHTMLAndSignatureObjectDict objectForKey:@"html"]];
        NSArray *listOfSignatureIds = [NSMutableArray arrayWithArray:[lOPDocHTMLAndSignatureObjectDict objectForKey:@"signature"]];
        
//        listOfHTMLIds = @[@"00PK0000001sobwMAA"]; // TODO:Remove. For testing only.

        NSMutableDictionary *htmlValueMap = [NSMutableDictionary dictionary];
        [htmlValueMap setObject:kSmartDocsHTMLID forKey:@"key"];
        [htmlValueMap setObject:listOfHTMLIds forKey:@"values"];
        
        NSMutableDictionary *signatureValueMap = [NSMutableDictionary dictionary];
        [signatureValueMap setObject:kSmartDocsSignatureUsed forKey:@"key"];
        [signatureValueMap setObject:listOfSignatureIds forKey:@"values"];
        
        param = [[RequestParamModel alloc] init];
        param.valueMap = @[htmlValueMap, signatureValueMap];
        
    }
    
    return @[param];
}

-(void)saveFileDetailsLocallyForObject
{
    id OPDocObject = [[OpDocSyncDataManager sharedManager] cOpDocObjectForSync];
    
    if([OPDocObject isKindOfClass:[OPDocHTML class]])
    {
        OPDocHTML *lOPDocHTML = (OPDocHTML *)OPDocObject;
        
        self.cLocal_ID = lOPDocHTML.local_id;
        self.cFileName = lOPDocHTML.Name;
        self.cProcess_ID = lOPDocHTML.process_id;
        self.cRecord_ID = lOPDocHTML.record_id;
        self.cObjectName = lOPDocHTML.objectName;
        self.isHTMLDoc = YES;
        
    }
    else
    {
        OPDocSignature *lOPDocSignature= (OPDocSignature *)OPDocObject;
        
        self.cLocal_ID = lOPDocSignature.local_id;
        self.cFileName = lOPDocSignature.Name;
        self.cProcess_ID = lOPDocSignature.process_id;
        self.cRecord_ID = lOPDocSignature.record_id;
        self.cObjectName = lOPDocSignature.objectName;
        self.isHTMLDoc = NO;

    }
    
    self.cWorkOrderOuputString = @"Work Order Output Doc";

    self.cParent_SFID =  [SFMPageHelper getSfIdForLocalId:self.cRecord_ID objectName:self.cObjectName]; //Retreiving the Parent SF_ID for the corresponding Record_ID.


 
    [self constructNewNameForFile]; // For Renaming the file using the SF_ID instead of the record_id.
    
    [self updateTheTablesWithTheNewFileName:OPDocObject];  // Changing the Filename in the OPDOCHTML Table or OPDOC Signature Table.


    
}

-(void)constructNewNameForFile
{
    self.cFileName = [self.cFileName stringByReplacingOccurrencesOfString:self.cRecord_ID withString:self.cParent_SFID];
}


-(void)updateTheTablesWithTheNewFileName:(id)lOPDocObject
{
    if (isHTMLDoc) {
        OPDocServices *lOpdocHTMLService = [[OPDocServices alloc] init];
        [lOpdocHTMLService updateFileNameInTableForModel:lOPDocObject withNewFileName:self.cFileName];

    }
    else{
    
        OPDocSignatureService *lOpdocSignatureService = [[OPDocSignatureService alloc] init];
        [lOpdocSignatureService updateFileNameInTableForModel:lOPDocObject withNewFileName:self.cFileName];
    }
    
}

@end
