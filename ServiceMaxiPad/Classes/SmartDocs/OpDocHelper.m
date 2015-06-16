//
//  OpDocHelper.m
//  ServiceMaxiPad
//
//  Created by Admin on 05/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "OpDocHelper.h"
#import "OPDocFileUploader.h"
#import "OPDocSignatureService.h"
#import "OPDocServices.h"
#import "OpDocSyncDataManager.h"
#import "NonTagConstant.h"
#import "WebserviceResponseStatus.h"
#import "OPDocHTML.h"
#import "OPDocSignature.h"
#import "FileManager.h"
#import "FlowDelegate.h"

@interface OpDocHelper() <FlowDelegate>

@property (nonatomic, assign) BOOL isSignatureSynced;
@property (nonatomic, assign) int cSyncIndex;
@property (nonatomic, strong) NSMutableArray *cHtmlListArray;
@property (nonatomic, strong) NSMutableArray *cSingleHtmlAndAssociatedSignatureListArray;
@property (nonatomic, strong) NSDictionary *cSignatureAndHTMLSubmitListDictionary;
@property (nonatomic, strong) NSMutableArray *cFailedInPreviousProcessHTMLListArray;


@end

@implementation OpDocHelper
@synthesize isSignatureSynced;
@synthesize cSyncIndex;
@synthesize cHtmlListArray;
@synthesize cSingleHtmlAndAssociatedSignatureListArray;
@synthesize cSignatureAndHTMLSubmitListDictionary;
@synthesize cFailedInPreviousProcessHTMLListArray;

@synthesize customDelegate;


+ (id)sharedManager {
    static OpDocHelper *sharedOpDocHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOpDocHelper = [[self alloc] init];
    });
    return sharedOpDocHelper;
}


/* Upload Files */
-(void)initiateFileSync
{
    if (cHtmlListArray) {
        cHtmlListArray = nil;
    }
    cHtmlListArray = [[NSMutableArray alloc] initWithArray:[self getHTMLFileList]];

    [self getSignaturesAndMakeADictOfHTMLSignToUpload];
    
    /*
    if (cHtmlListArray.count) {
        
        [[OpDocSyncDataManager sharedManager] setCOpDocObjectForSync:[cSignatureAndHtmlListArray objectAtIndex:0]];
        
        [OPDocFileUploader requestForUploadingOPDocFilewithTheCallerDelegate:self];
    }
     */
}

-(void)getSignaturesAndMakeADictOfHTMLSignToUpload
{
    if (cHtmlListArray.count) {
        NSArray *lSignatureList = [self getSignatureListForHtmlModel: [cHtmlListArray objectAtIndex:0]];
        
        if(lSignatureList.count)
        {
            cSingleHtmlAndAssociatedSignatureListArray = [[NSMutableArray alloc] initWithArray:lSignatureList];
            [cSingleHtmlAndAssociatedSignatureListArray addObject:[cHtmlListArray objectAtIndex:0]]; //Always the HTML should be last in array so that it is uploaded last. Cause uploading a HTMl causes a trigger at the server.
        }
        else
        {
            cSingleHtmlAndAssociatedSignatureListArray =  [[NSMutableArray alloc] initWithObjects:[cHtmlListArray objectAtIndex:0], nil];
        }
        
        //Initiate the sync Call
        [[OpDocSyncDataManager sharedManager] setCOpDocObjectForSync:[cSingleHtmlAndAssociatedSignatureListArray objectAtIndex:0]];
        [OPDocFileUploader requestForUploadingOPDocFilewithTheCallerDelegate:self];

    }
    else
    {
        [self initiateDocumentSubmissionProcess]; // IF during the previous cycle, some files were not submitted for "DOC SUBMISSSION"
    }
}

-(void)secondCallOfTheSyncMethod
{
  id OpDocObject =  [[OpDocSyncDataManager sharedManager] cOpDocObjectForSync];
    [cSingleHtmlAndAssociatedSignatureListArray removeObject:OpDocObject];
    
    
    if (cSingleHtmlAndAssociatedSignatureListArray.count)
    {
        OpDocObject = [cSingleHtmlAndAssociatedSignatureListArray objectAtIndex:0];

        [[OpDocSyncDataManager sharedManager] setCOpDocObjectForSync:OpDocObject];

        [OPDocFileUploader requestForUploadingOPDocFilewithTheCallerDelegate:self];
    }
    else
    {
        //TODO: What to do????????
        //Initiating DocSubmission. Check it while integrating.
        
        [self initiateDocumentSubmissionProcess];
        
    }
   
}

-(void)initiateDocumentSubmissionProcess
{

    if (cHtmlListArray.count) {
        cSignatureAndHTMLSubmitListDictionary = [self getSignatureAndHTMLSFIDListForHtmlFile:[cHtmlListArray objectAtIndex:0]];
    }

    else{
        // For failed Cases in the previous cycles.
        
        if (!cFailedInPreviousProcessHTMLListArray) {
            cFailedInPreviousProcessHTMLListArray = [[NSMutableArray alloc] initWithArray:[self getHTMLListForDocSubmission]];
        }
        else
        {
            if (cFailedInPreviousProcessHTMLListArray.count) {
                [cFailedInPreviousProcessHTMLListArray removeObjectAtIndex:0];

            }
        }
        
        if (cFailedInPreviousProcessHTMLListArray.count) {
            cSignatureAndHTMLSubmitListDictionary = [self getSignatureAndHTMLSFIDListForHtmlFile:[cFailedInPreviousProcessHTMLListArray objectAtIndex:0]];
        }
        else
        {
            cFailedInPreviousProcessHTMLListArray = nil;
            cSignatureAndHTMLSubmitListDictionary = nil;
        }
    }
    
    if(cSignatureAndHTMLSubmitListDictionary.count)
    {
        [[OpDocSyncDataManager sharedManager] setCHtmlSignatureDocSubmissionDictionary:cSignatureAndHTMLSubmitListDictionary];
        
        [OPDocFileUploader requestForSubmittingHTMLAndSignatureDocumentwithTheCallerDelegate:self];
    }
    else
    {
        // if nothing to do here then cal the delegate
        if([self.customDelegate conformsToProtocol:@protocol(OPDocCustomDelegate)])
        {
            [self.customDelegate OpdocStatus:YES forCategory:CategoryTypeGeneratePDF];
        }
    }
}


-(void)initiateGeneratePDFProcess
{
    NSDictionary *lSubmitDocDict = [[OpDocSyncDataManager sharedManager] cHtmlSignatureDocSubmissionDictionary];
    
    NSMutableArray *lSubmittedHTMLList = [[NSMutableArray alloc]initWithArray:[lSubmitDocDict objectForKey:kOPDocHTMLString]];
    NSMutableArray *lSubmittedSignatureList  = [[NSMutableArray alloc]initWithArray:[lSubmitDocDict objectForKey:kOPDocSignatureString]];

    NSDictionary *responseForSubmitDoc = [[OpDocSyncDataManager sharedManager] cResponseForDocSubmitDictionary];
    
    NSArray *lResponseHTMLList = [responseForSubmitDoc objectForKey:kOPDocHTMLString];
    NSArray *lResponseSignatureList = [responseForSubmitDoc objectForKey:kOPDocSignatureString];
    NSArray *lResponseDeleteList = [responseForSubmitDoc objectForKey:kOPDocDeleteString];

    if (lResponseHTMLList.count) {
        
        for (int i = 0; i<lResponseHTMLList.count; i++) {
            if ([lSubmittedHTMLList containsObject:[lResponseHTMLList objectAtIndex:i]]) {
                [lSubmittedHTMLList removeObject:[lResponseHTMLList objectAtIndex:i]];
            }

        }
    }

    
    NSDictionary *lGeneratePDF = @{kOPDocHTMLString: lSubmittedHTMLList, kOPDocSignatureString: lResponseSignatureList};
    
    if (lGeneratePDF.count) {
        [[OpDocSyncDataManager sharedManager] setCListForGeneratingPDFDictionary:lGeneratePDF];
        
        [OPDocFileUploader requestForGeneratingPDFwithTheCallerDelegate:self];

    }
    else
    {
        
        [self gettingReadyToSyncTheNextSetOfData];

    }
  
    //TODO: When should we delete the entry from db for Delete_id.
    [self deleteTheSignatureFiles:lResponseDeleteList];   // Delete the Files Which are present in the Delete_ID value Map.
    [self deleteTheHTMLFiles:lResponseDeleteList];   // Delete the Files Which are present in the Delete_ID value Map.

}

-(void)gettingReadyToSyncTheNextSetOfData
{
    //Initiate SYncing for the next HTML file and its associated signatures.
    
    if (cHtmlListArray.count) {
        [cHtmlListArray removeObjectAtIndex:0];

    }
    
    if (cHtmlListArray.count) {
        [self getSignaturesAndMakeADictOfHTMLSignToUpload];

    }
    else
    {
        
        
        /*
        if([self.customDelegate conformsToProtocol:@protocol(OPDocCustomDelegate)])
        {
            [self.customDelegate OpdocStatus:YES forCategory:CategoryTypeGeneratePDF];
        }
         */
        
        
        [self initiateDocumentSubmissionProcess];
    }
}

#pragma mark FLOW DELEGATE

- (void)flowStatus:(id)status;
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        if (st.syncStatus == SyncStatusSuccess) {
            switch (st.category) {
                case CategoryTypeOpDoc:
                {
                    // Check if the sign/html successfully updated to server if not skip this module and upload next module.
                    if ([[OpDocSyncDataManager sharedManager] isSuccessfullyUploaded]) {
                        [self secondCallOfTheSyncMethod];
                    }
                    else
                    {
                        [self gettingReadyToSyncTheNextSetOfData];

                    }
                    
                    
                }
                    break;
                case CategoryTypeSubmitDocument:
                {
                    
                    [self initiateGeneratePDFProcess];
                }

                    break;
                    
                case CategoryTypeGeneratePDF:
                {
                    //TODO: Check when the entry have to be deleted from the DB
                  
                    
                    if ([[OpDocSyncDataManager sharedManager] isSuccessfullyUploaded]) {

                    
                    NSDictionary *lResponseDictionary = [[OpDocSyncDataManager sharedManager] cResponseForGeneratingPDFDictionary];
                    
                    [self deleteTheSignatureFiles:[lResponseDictionary objectForKey:kOPDocSignatureString]];
                    [self deleteTheHTMLFiles:[lResponseDictionary objectForKey:kOPDocHTMLString]];
                  
                    }
                    //======================================================================
                    //Re-initiate the SYncing process for next html and signatures
                    [self gettingReadyToSyncTheNextSetOfData];
                    //======================================================================


                }
                    
                    break;
                default:
                    break;
            }
        }
        else if (st.syncStatus == SyncStatusFailed)
        {
            switch (st.category) {
                case CategoryTypeOpDoc:
                {
                    if([self.customDelegate conformsToProtocol:@protocol(OPDocCustomDelegate)])
                    {
                        [self.customDelegate OpdocStatus:NO forCategory:CategoryTypeOpDoc];
                    }
                }
                    
                    break;
                case CategoryTypeSubmitDocument:
                {
                    if([self.customDelegate conformsToProtocol:@protocol(OPDocCustomDelegate)])
                    {
                        [self.customDelegate OpdocStatus:NO forCategory:CategoryTypeSubmitDocument];
                    }
                }
                    break;
                    
                case CategoryTypeGeneratePDF:
                {
                    if([self.customDelegate conformsToProtocol:@protocol(OPDocCustomDelegate)])
                    {
                        [self.customDelegate OpdocStatus:NO forCategory:CategoryTypeGeneratePDF];
                    }
                }
                    
                    break;
                default:
                    break;

            }
        }
    }
}


#pragma mark -
#pragma mark UTILITY METHODS

#pragma mark - For File Uploading

-(NSArray *)getHTMLFileList
{

    OPDocServices *lOPDocHTMLService = [[OPDocServices alloc] init];
    NSArray *htmlListArray = [lOPDocHTMLService getHTMLModelListForFileUpload];
    
    return htmlListArray;
}


-(NSArray *)getSignatureListForHtmlModel:(OPDocHTML *)htmlModel

{
    OPDocSignatureService *lOPDocSignatureService = [[OPDocSignatureService alloc] init];
    NSArray *lSignatureListArray = [lOPDocSignatureService getSignatureModelListForFileUploadforRecordID:htmlModel.record_id andHTMLFileName:htmlModel.Name];

    return lSignatureListArray;
}

#pragma mark - For Doc Submission Uploading

-(NSDictionary *)getSignatureAndHTMLSFIDListForHtmlFile:(OPDocHTML *)htmlModel
{
    
    OPDocSignatureService *lOPDocSignatureService = [[OPDocSignatureService alloc] init];
    NSArray *lSignatureListArray = [lOPDocSignatureService getSignatureListToSubmitForHtmlFile:htmlModel.Name];
    
//    OPDocServices *lOPDocHTMLService = [[OPDocServices alloc] init];
//    NSArray *lHTMLListArray = [lOPDocHTMLService getHTMLListToSubmitForHtmlFile:htmlModel.Name];
    
    
    return @{kOPDocHTMLString:@[htmlModel.sfid], kOPDocSignatureString:lSignatureListArray};
}

-(NSArray *) getHTMLListForDocSubmission
{
    OPDocServices *lOPDocHTMLService = [[OPDocServices alloc] init];
    NSArray *lHTMLListArray = [lOPDocHTMLService getHTMLListToSubmit];
    
    return lHTMLListArray;
}
//Old Start
-(NSDictionary *)getSignatureAndHTMLSFIDList
{
    
    OPDocSignatureService *lOPDocSignatureService = [[OPDocSignatureService alloc] init];
    NSArray *lSignatureListArray = [lOPDocSignatureService getSignatureListToSubmit];
    
    OPDocServices *lOPDocHTMLService = [[OPDocServices alloc] init];
    NSArray *lHTMLListArray = [lOPDocHTMLService getHTMLListToSubmit];
    
    return @{kOPDocHTMLString:lHTMLListArray, kOPDocSignatureString:lSignatureListArray};
}
//Old Finish

-(void)deleteTheSignatureFiles:(NSArray *)lDeletionIDList{
    
    //First Delete the Files from the Directory.
    
    OPDocSignatureService *lOPDocSignatureService = [[OPDocSignatureService alloc] init];
    
    for (NSString *signatureSFID in lDeletionIDList) {
        NSArray *lDataArray = [lOPDocSignatureService getAllFilesPresentInTableForWhichNeedsToBeDeleted:signatureSFID];
        
        [self deleteTheFilesFromFolder:lDataArray];
    }

    
    BOOL result;
    result = [lOPDocSignatureService deleteRecordsSignatureTableForList:lDeletionIDList];
    
}

-(void)deleteTheHTMLFiles:(NSArray *)lDeletionIDList{
    
    OPDocServices *lOPDocHTMLService = [[OPDocServices alloc] init];
    
//    NSArray *lDataArray = [lOPDocHTMLService getAllFilesPresentInTableForWhichNeedsToBeDeleted];
    for (NSString *htmlSFID in lDeletionIDList) {
        NSArray *lDataArray = [lOPDocHTMLService getAllFilesPresentInTableForWhichNeedsToBeDeleted:htmlSFID];
        
        [self deleteTheFilesFromFolder:lDataArray];
    }

    
    
    BOOL result = [lOPDocHTMLService deleteRecordsHTMLTableForList:lDeletionIDList];
    if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:OPDocSavedNotification object:nil];
        });
    }
}

-(void)deleteTheFilesFromFolder:(NSArray *)lDataArray
{
    NSString *lFilePath = nil;
    
    for (int i = 0; i<lDataArray.count; i++) {
        
        
        id OPDocObject = [lDataArray objectAtIndex:i];
        
        if ([OPDocObject isKindOfClass:[OPDocHTML class]]) {
            OPDocHTML *lOPDocHTMLFile = (OPDocHTML *)OPDocObject;
            if (lOPDocHTMLFile.Name) {
                lFilePath =  [[FileManager getCoreLibSubDirectoryPath] stringByAppendingPathComponent:lOPDocHTMLFile.Name];
            }
        }
        else
        {
            OPDocSignature *lOPDocSignatureFile = (OPDocSignature *)OPDocObject;
            if (lOPDocSignatureFile.Name) {
                lFilePath =  [[FileManager getCoreLibSubDirectoryPath] stringByAppendingPathComponent:lOPDocSignatureFile.Name];
            }
        }
        
        BOOL success = NO;
        if (lFilePath) {
            success = [FileManager deleteFileAtPath:lFilePath];
            SXLogInfo(@" FILE: %@ DELETED: %d", lFilePath, success);
        }
    }
}

- (void)clearResetSharedInstanceData
{
    isSignatureSynced = NO;
    cSyncIndex = -1;
    cHtmlListArray = nil;
    cSingleHtmlAndAssociatedSignatureListArray = nil;
    cSignatureAndHTMLSubmitListDictionary = nil;
}
/*
 Description: This method will clear local OpDoc html files from coreLib when users performs reset app or switch user.
 */
- (void)clearOpDocHTMLAndSignatureFilesOnReset {
    NSArray *lOpDocFiles = [self getHTMLFileList];
    if (lOpDocFiles.count  > 0) {
        [self deleteTheFilesFromFolder:lOpDocFiles];
        for (OPDocHTML *lOpDocHTML in lOpDocFiles) {
            NSArray *lOpDocSignatureList = [self getSignatureListForHtmlModel:lOpDocHTML];
            if (lOpDocSignatureList.count > 0) {
                [self deleteTheFilesFromFolder:lOpDocSignatureList];
            }
        }
    }
}
@end
