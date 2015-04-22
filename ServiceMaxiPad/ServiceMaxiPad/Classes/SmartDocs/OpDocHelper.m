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
@property (nonatomic, retain) NSMutableArray *cSignatureAndHtmlListArray;
@property (nonatomic, retain) NSDictionary *cSignatureAndHTMLSubmitListDictionary;

@end

@implementation OpDocHelper
@synthesize isSignatureSynced;
@synthesize cSyncIndex;
@synthesize cSignatureAndHtmlListArray;
@synthesize cSignatureAndHTMLSubmitListDictionary;
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
    [self getSignatureFileAndHTMLFileList];

    if (cSignatureAndHtmlListArray.count) {
        
        [[OpDocSyncDataManager sharedManager] setCOpDocObjectForSync:[cSignatureAndHtmlListArray objectAtIndex:0]];
        
        [OPDocFileUploader requestForUploadingOPDocFilewithTheCallerDelegate:self];
    }
    


}

-(void)secondCallOfTheSyncMethod
{
  id OpDocObject =  [[OpDocSyncDataManager sharedManager] cOpDocObjectForSync];
    [cSignatureAndHtmlListArray removeObject:OpDocObject];
    
    
    if (cSignatureAndHtmlListArray.count)
    {
        OpDocObject = [cSignatureAndHtmlListArray objectAtIndex:0];

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
    cSignatureAndHTMLSubmitListDictionary = [self getSignatureAndHTMLSFIDList];
    

    if(cSignatureAndHTMLSubmitListDictionary.count)
    {
        [[OpDocSyncDataManager sharedManager] setCHtmlSignatureDocSubmissionDictionary:cSignatureAndHTMLSubmitListDictionary];
    
        [OPDocFileUploader requestForSubmittingHTMLAndSignatureDocumentwithTheCallerDelegate:self];
    }
    else{
        //TODO: What to do?
    }
}


-(void)initiateGeneratePDFProcess
{
    NSDictionary *lSubmitDocDict = [[OpDocSyncDataManager sharedManager] cHtmlSignatureDocSubmissionDictionary];
    
    NSMutableArray *lSubmittedHTMLList = (NSMutableArray *)[lSubmitDocDict objectForKey:kOPDocHTMLString];
    NSMutableArray *lSubmittedSignatureList = (NSMutableArray *)[lSubmitDocDict objectForKey:kOPDocSignatureString];

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
        //TODO: What to do?
    }
  
    //TODO: When should we delete the entry from db for Delete_id.
    //[self deleteTheSignatureFiles:lResponseDeleteList];   // Delete the Files Which are present in the Delete_ID value Map.
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
                    
                    [self secondCallOfTheSyncMethod];
                        
                    
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
                    
                    
                     
                    NSDictionary *lResponseDictionary = [[OpDocSyncDataManager sharedManager] cResponseForGeneratingPDFDictionary];
                    
                    [self deleteTheSignatureFiles:[lResponseDictionary objectForKey:kOPDocSignatureString]];
                    [self deleteTheHTMLFiles:[lResponseDictionary objectForKey:kOPDocHTMLString]];
                    
                    
                    
                    if([self.customDelegate conformsToProtocol:@protocol(OPDocCustomDelegate)])
                    {
                        [self.customDelegate OpdocStatus:YES forCategory:CategoryTypeGeneratePDF];
                    }
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

-(void)getSignatureFileAndHTMLFileList
{
    OPDocSignatureService *lOPDocSignatureService = [[OPDocSignatureService alloc] init];
    NSArray *lSignatureListArray = [lOPDocSignatureService getSignatureModelListForFileUpload];
    
    OPDocServices *lOPDocHTMLService = [[OPDocServices alloc] init];
    NSArray *lHTMLListArray = [lOPDocHTMLService getHTMLModelListForFileUpload];
    
    cSignatureAndHtmlListArray = [[NSMutableArray alloc]initWithArray:[lSignatureListArray arrayByAddingObjectsFromArray:lHTMLListArray]];
}

#pragma mark - For Doc Submission Uploading

-(NSDictionary *)getSignatureAndHTMLSFIDList
{
    
    OPDocSignatureService *lOPDocSignatureService = [[OPDocSignatureService alloc] init];
    NSArray *lSignatureListArray = [lOPDocSignatureService getSignatureListToSubmit];
    
    OPDocServices *lOPDocHTMLService = [[OPDocServices alloc] init];
    NSArray *lHTMLListArray = [lOPDocHTMLService getHTMLListToSubmit];
    
    return @{kOPDocHTMLString:lHTMLListArray, kOPDocSignatureString:lSignatureListArray};
}


-(void)deleteTheSignatureFiles:(NSArray *)lDeletionIDList{
    
    //First Delete the Files from the Directory.
    
    OPDocSignatureService *lOPDocSignatureService = [[OPDocSignatureService alloc] init];
    
    
    NSArray *lDataArray = [lOPDocSignatureService getAllFilesPresentInTableForWhichNeedsToBeDeleted];
    
    [self deleteTheFilesFromFolder:lDataArray];
    
    BOOL result = [lOPDocSignatureService deleteRecordsSignatureTableForList:lDeletionIDList];
    
}

-(void)deleteTheHTMLFiles:(NSArray *)lDeletionIDList{
    
    OPDocServices *lOPDocHTMLService = [[OPDocServices alloc] init];
    
    NSArray *lDataArray = [lOPDocHTMLService getAllFilesPresentInTableForWhichNeedsToBeDeleted];
    
    [self deleteTheFilesFromFolder:lDataArray];
    
    
    BOOL result = [lOPDocHTMLService deleteRecordsHTMLTableForList:lDeletionIDList];
    if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:OPDocSavedNotification object:nil];
        });
    }
}

-(void)deleteTheFilesFromFolder:(NSArray *)lDataArray
{
    NSString *lFilePath;
    
    for (int i = 0; i<lDataArray.count; i++) {
        
    
        id OPDocObject = [lDataArray objectAtIndex:i];
        
        if ([OPDocObject isKindOfClass:[OPDocHTML class]]) {
            OPDocHTML *lOPDocHTMLFile = (OPDocHTML *)OPDocObject;
            lFilePath =  [[FileManager getCoreLibSubDirectoryPath] stringByAppendingPathComponent:lOPDocHTMLFile.Name];
            
        }
        else
        {
            OPDocSignature *lOPDocSignatureFile = (OPDocSignature *)OPDocObject;
            lFilePath =  [[FileManager getCoreLibSubDirectoryPath] stringByAppendingPathComponent:lOPDocSignatureFile.Name];

        }
        
        BOOL success = [FileManager deleteFileAtPath:lFilePath];

    }
}

- (void)clearResetSharedInstanceData
{
    isSignatureSynced = NO;
    cSyncIndex = -1;
    cSignatureAndHtmlListArray = nil;
    cSignatureAndHTMLSubmitListDictionary = nil;
}

@end
