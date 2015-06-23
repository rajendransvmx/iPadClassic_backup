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
            if (cSingleHtmlAndAssociatedSignatureListArray) {
                cSingleHtmlAndAssociatedSignatureListArray = nil;
            }
            cSingleHtmlAndAssociatedSignatureListArray = [[NSMutableArray alloc] initWithArray:lSignatureList];
            [cSingleHtmlAndAssociatedSignatureListArray addObject:[cHtmlListArray objectAtIndex:0]]; //Always the HTML should be last in array so that it is uploaded last. Cause uploading a HTMl causes a trigger at the server.
        }
        else
        {
            cSingleHtmlAndAssociatedSignatureListArray =  [[NSMutableArray alloc] initWithObjects:[cHtmlListArray objectAtIndex:0], nil];
        }
        
        [self checkIfTheFileIsAlreadyUploaded];
        
    }
    else
    {
        [self initiateDocumentSubmissionProcess]; // IF during the previous cycle, some files were not submitted for "DOC SUBMISSSION"
    }
}

-(void)checkIfTheFileIsAlreadyUploaded
{
    [[OpDocSyncDataManager sharedManager] setCOpDocObjectForSync:[cSingleHtmlAndAssociatedSignatureListArray objectAtIndex:0]];
    [OPDocFileUploader requestTocheckIfOPDocFileIsUploadedBeforewithTheCallerDelegate:self];
}


-(void)uploadTheOPDOCFile
{
    [OPDocFileUploader requestForUploadingOPDocFilewithTheCallerDelegate:self];

}

-(void)secondCallOfTheSyncMethod
{
  id OpDocObject =  [[OpDocSyncDataManager sharedManager] cOpDocObjectForSync];
    [cSingleHtmlAndAssociatedSignatureListArray removeObject:OpDocObject];
    
    
    if (cSingleHtmlAndAssociatedSignatureListArray.count)
    {
        [self checkIfTheFileIsAlreadyUploaded];
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
        SXLogDebug(@"Document Submission for cSignatureAndHTMLSubmitListDictionary:%@", cSignatureAndHTMLSubmitListDictionary);

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
//    NSMutableArray *lSubmittedSignatureList  = [[NSMutableArray alloc]initWithArray:[lSubmitDocDict objectForKey:kOPDocSignatureString]];
    
    NSDictionary *responseForSubmitDoc = [[OpDocSyncDataManager sharedManager] cResponseForDocSubmitDictionary];
    
    NSArray *lResponseHTMLList = [responseForSubmitDoc objectForKey:kOPDocHTMLString];
    NSArray *lResponseSignatureList = [responseForSubmitDoc objectForKey:kOPDocSignatureString];
    NSArray *lResponseDeleteList = [responseForSubmitDoc objectForKey:kOPDocDeleteString];
    
    if (![self checkIftheDeletionIdIsPresentInDictForGeneratingPDFForSubmittedDict:lSubmitDocDict andResponseDict:responseForSubmitDoc])
    {
        if (lResponseHTMLList.count) {
            
            for (int i = 0; i<lResponseHTMLList.count; i++) {
                if ([lSubmittedHTMLList containsObject:[lResponseHTMLList objectAtIndex:i]]) {
                    [lSubmittedHTMLList removeObject:[lResponseHTMLList objectAtIndex:i]];
                }
            }
        }
        
        NSDictionary *lGeneratePDF = @{kOPDocHTMLString: (lSubmittedHTMLList?lSubmittedHTMLList:@[]), kOPDocSignatureString: (lResponseSignatureList?lResponseSignatureList:@[])};
        
        if (lGeneratePDF.count) {
            [[OpDocSyncDataManager sharedManager] setCListForGeneratingPDFDictionary:lGeneratePDF];
            
            [OPDocFileUploader requestForGeneratingPDFwithTheCallerDelegate:self];
            
        }
        else
        {
            
            [self gettingReadyToSyncTheNextSetOfData];
            
        }
    }
    else {
        
        [self gettingReadyToSyncTheNextSetOfData];
        
    }
    
    
    if(lResponseDeleteList.count)
    {
        //TODO: When should we delete the entry from db for Delete_id.
        [self deleteTheSignatureFiles:lResponseDeleteList];   // Delete the Files Which are present in the Delete_ID value Map.
        [self deleteTheHTMLFiles:lResponseDeleteList];   // Delete the Files Which are present in the Delete_ID value Map.
    }
}


//If the deletion ID's from the response of the DOc SUBMission Response is present in the ID's being present in the PDF generation id's then: Do not proceed with generating PDF. and remove the ID's from the DB and delete the corresponding Files from client.
// The Deletion ID's sent back cause the PDF's have already been generated for those ID's.
-(BOOL)checkIftheDeletionIdIsPresentInDictForGeneratingPDFForSubmittedDict:( NSDictionary *)lSubmitDocDict andResponseDict:(NSDictionary *)responseForSubmitDoc
{
    
    NSMutableArray *lSubmittedHTMLList = [[NSMutableArray alloc]initWithArray:[lSubmitDocDict objectForKey:kOPDocHTMLString]];
    NSMutableArray *lSubmittedSignatureList  = [[NSMutableArray alloc]initWithArray:[lSubmitDocDict objectForKey:kOPDocSignatureString]];
    NSArray *lResponseDeleteList = [responseForSubmitDoc objectForKey:kOPDocDeleteString];

    for(NSString *sfid in lSubmittedHTMLList) {
        if ([lResponseDeleteList containsObject:sfid]) {
            return YES;
        }
    }
    
    for(NSString *sfid in lSubmittedSignatureList) {
        if ([lResponseDeleteList containsObject:sfid]) {
            return YES;
        }
    }
    
    return NO;
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
                    
                case CategoryTypeOpDocUploadStatus:
                {

                        if (![[OpDocSyncDataManager sharedManager] fileAlreadyUploaded])
                        {
                            [self uploadTheOPDOCFile];
                        }
                        else
                        {
                            SXLogDebug(@"SyncStatusSuccess/SyncStatusInProgress, OPDOC already Uploaded before");
                            [self secondCallOfTheSyncMethod]; // The current file is already uploaded. SO remove this from the list and upload the next file.
                        }

                    
                    
                }
                    break;
                    
                case CategoryTypeOpDoc:
                {
                    // Check if the sign/html successfully updated to server if not skip this module and upload next module.
                    int stat = [[OpDocSyncDataManager sharedManager] isSuccessfullyUploaded];
                    SXLogDebug(@"flowStatus: OPDOC upload status: %@",(stat?@"YES":@"NO"));
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
                    if ([[OpDocSyncDataManager sharedManager] isSuccessfullyUploaded]) {
                        [self initiateGeneratePDFProcess];

                    }
                    else
                    {

                        [self gettingReadyToSyncTheNextSetOfData];
   

                    }
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
                case CategoryTypeOpDocUploadStatus:
                {
                    if([self.customDelegate conformsToProtocol:@protocol(OPDocCustomDelegate)])
                    {
                        [self.customDelegate OpdocStatus:NO forCategory:CategoryTypeOpDocUploadStatus];
                    }
                }
                    break;
                    
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
        else if (st.syncStatus == SyncStatusNetworkError
                 || st.syncStatus == SyncStatusRefreshTokenFailedWithError) {
            SXLogError(@"SyncStatusNetworkError/SyncStatusRefreshTokenFailedWithError");
            
        }
        
        else if (st.syncStatus == SyncStatusInCancelled) {
            SXLogWarning(@"SyncStatusInCancelled");
            
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
/*
-(NSDictionary *)getSignatureAndHTMLSFIDList
{
    
    OPDocSignatureService *lOPDocSignatureService = [[OPDocSignatureService alloc] init];
    NSArray *lSignatureListArray = [lOPDocSignatureService getSignatureListToSubmit];
    
    OPDocServices *lOPDocHTMLService = [[OPDocServices alloc] init];
    NSArray *lHTMLListArray = [lOPDocHTMLService getHTMLListToSubmit];
    
    return @{kOPDocHTMLString:lHTMLListArray, kOPDocSignatureString:lSignatureListArray};
}
 */
//Old Finish

-(void)deleteTheSignatureFiles:(NSArray *)lDeletionIDList{
    
    //First Delete the Files from the Directory.
    
    OPDocSignatureService *lOPDocSignatureService = [[OPDocSignatureService alloc] init];
    
    for (NSString *signatureSFID in lDeletionIDList) {
        NSArray *lDataArray = [lOPDocSignatureService getAllFilesPresentInTableForWhichNeedsToBeDeleted:signatureSFID];
        
        if (lDataArray.count) {

        [self deleteTheHTMLFileCorrespondingToSignatureFile:lDataArray];
        [self deleteTheFilesFromFolder:lDataArray];
        }
    }

    
    BOOL result;
    result = [lOPDocSignatureService deleteRecordsSignatureTableForList:lDeletionIDList];
    
}

-(void)deleteTheHTMLFiles:(NSArray *)lDeletionIDList{
    
    OPDocServices *lOPDocHTMLService = [[OPDocServices alloc] init];
    
//    NSArray *lDataArray = [lOPDocHTMLService getAllFilesPresentInTableForWhichNeedsToBeDeleted];
    for (NSString *htmlSFID in lDeletionIDList) {
        NSArray *lDataArray = [lOPDocHTMLService getAllFilesPresentInTableForWhichNeedsToBeDeleted:htmlSFID];
        
        if (lDataArray.count) {
            
        [self deleteTheSignatureFilesCorrespondingToHTMLFile:lDataArray];
        [self deleteTheFilesFromFolder:lDataArray];
        }
    }

    
    
    BOOL result;
    result = [lOPDocHTMLService deleteRecordsHTMLTableForList:lDeletionIDList];
//    if (result) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:OPDocSavedNotification object:nil];
//        });
//    }
}

-(void)deleteTheHTMLFileCorrespondingToSignatureFile:(NSArray *)theSignatureModelList
{
    OPDocServices *lOPDocHTMLService = [OPDocServices new];

    for (OPDocSignature *model in theSignatureModelList) {
        NSArray *lDataArray = [lOPDocHTMLService getAllFilesPresentInTableForWhichNeedsToBeDeleted:model.HTMLFileName];
        
        if (lDataArray.count) {
            [self updateTheHTMLTableToDeleteTheRecord:lDataArray];
            [self deleteTheFilesFromFolder:lDataArray];
        }
        

    }
}

-(void)updateTheHTMLTableToDeleteTheRecord:(NSArray *)lHTMLModelList
{
    NSMutableArray *lDeletionIDList = [NSMutableArray new];
    for (OPDocHTML *model in lHTMLModelList) {
        if (model.sfid) {
            [lDeletionIDList addObject:model.sfid];
        }
    }
    OPDocServices *lOPDocHTMLService = [OPDocServices new];

    BOOL result;
    result = [lOPDocHTMLService deleteRecordsHTMLTableForList:lDeletionIDList];

}

-(void)deleteTheSignatureFilesCorrespondingToHTMLFile:(NSArray *)theHTMLModelList
{
    OPDocSignatureService *lOPDocSignatureService = [[OPDocSignatureService alloc] init];
    
    for (OPDocHTML *model in theHTMLModelList) {
        NSArray *lDataArray = [lOPDocSignatureService getAllFilesPresentInTableForWhichNeedsToBeDeleted:model.Name];
        if (lDataArray.count) {
            [self updateTheSignatureTableToDeleteTheRecord:lDataArray];
            [self deleteTheFilesFromFolder:lDataArray];
        }

        
    }
}

-(void)updateTheSignatureTableToDeleteTheRecord:(NSArray *)lSignatureModelList
{
    NSMutableArray *lDeletionIDList = [NSMutableArray new];
    for (OPDocSignature *model in lSignatureModelList) {
        if (model.sfid) {
            [lDeletionIDList addObject:model.sfid];
        }
    }
    
    OPDocSignatureService *lOPDocSignatureService = [OPDocSignatureService new];
    
    BOOL result;
    result = [lOPDocSignatureService deleteRecordsSignatureTableForList:lDeletionIDList];
    
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
            SXLogDebug(@" FILE: %@ DELETED: %d", lFilePath, success);
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


-(NSString *)getQueryForCheckingOPDOCFileUploadStatus
{
    if(cSingleHtmlAndAssociatedSignatureListArray.count)
    {
        id OPDocObject = [cSingleHtmlAndAssociatedSignatureListArray objectAtIndex:0];
        NSString *fileName;
        if([OPDocObject isKindOfClass:[OPDocHTML class]])
        {
            OPDocHTML *lOPDocHTML = (OPDocHTML *)OPDocObject;
            fileName = lOPDocHTML.Name;
        }
        else
        {
            OPDocSignature *lOPDocSignature= (OPDocSignature *)OPDocObject;
            fileName = lOPDocSignature.Name;

            
        }
        
        NSString *query = [NSString stringWithFormat:@"select id from Attachment where Name = '%@'", fileName];
        SXLogDebug(@"query to check opdoc file uploaded before: %@", query);
        return query;
    }
    return nil;
}




@end
