//
//  OPDocViewController.m
//  iService
//
//  Created by Damodar on 4/29/13.
//
//

#import "OPDocViewController.h"
#import "HTMLJSWrapper.h"
#import "NSObject+SBJson.h"
#import "NSData-AES.h"
#import "SBJsonParser.h"
#import "Utility.h"
#import "FileManager.h"

//#import "SVMXDatabaseMaster.h"

//#import "AppDelegate.h"

@interface OPDocViewController ()
//krishna opdoc syncOPDocHtmlData
- (void)syncOPDocHtmlData:(NSData *)fileData andFileName:(NSString *)fileName;

//Aparna: Source Update
- (void)updateAndSyncSourceObjects;
@end

@implementation OPDocViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Memory management methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private methods
- (NSMutableDictionary *) signatureDictionary {
    
    if(self.signatureInfoDict == nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        self.signatureInfoDict = dict;
        dict = nil;
    }
    return self.signatureInfoDict;
}
- (void)popNavigationController:(id)sender
{
    //To a deprecated method warning, we are adding the 'completion' block
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark -
#pragma mark Source Update Methods
//Aparna: Source Update
- (void)updateAndSyncSourceObjects
{
//    NSArray *sourceObjToBeUpdated = [appDelegate.dataBase sourceUpdatesForProcessId:[appDelegate.dataBase sfIdForProcessId:self.processIdentifier]];
//    [appDelegate.dataBase updateSourceObjects:sourceObjToBeUpdated forSFId:recordIdentifier andLocalId:self.localIdentifier];
}

#pragma mark - Init Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRecordId:(NSString *)recordId andProcessId:(NSString *)processId andLocalId:(NSString *)localid
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.recordIdentifier = recordId;
        self.processIdentifier = processId;
        
        //krishna OPDOC offline generation
        self.localIdentifier = localid;
    }
    return self;
}
#pragma mark - Navigation Button Actions

//krishna OPDOC
- (void)backView
{
    
//    clear all signatures and dictionaries
    
    
    
    
/*
    //clear all signatures in directory. as this is not finalized
    
    NSString *documentDirectoryPath = [FileManager getCoreLibSubDirectoryPath];
    
    NSString *nonFinalizedPath = [documentDirectoryPath stringByAppendingPathComponent:@"nonfinalized.plist"];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    NSDictionary *nonFinalizedDict = [NSDictionary dictionaryWithContentsOfFile:nonFinalizedPath];
    NSArray *nonFinalizedSignatures = [nonFinalizedDict allValues];
    for (NSString *nonFinalizedFile in nonFinalizedSignatures) {
        
        NSString *signaturePath = [[documentDirectoryPath stringByAppendingPathComponent:nonFinalizedFile] stringByAppendingPathExtension:@"png"];
        if([filemanager fileExistsAtPath:signaturePath]) {
            if(![appDelegate.dataBase isSignatureFinalized:[signaturePath lastPathComponent]])// Dam - signature sum'13
            {
                [filemanager removeItemAtPath:signaturePath error:nil];
            
                [appDelegate.calDataBase deleteOPDocSignatureForName:nonFinalizedFile];
            }
        }
    }
    [self destroyNonFinalizedPlist];
    appDelegate.calDataBase.opDocController = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    //9751 & 9753
    [SVMXDatabaseMaster  releaseTheDb];

    //Aparna: Source Update
    //Refresh SFM Page View
    [appDelegate.sfmPageController.detailView performSelectorOnMainThread:@selector(refreshDetails) withObject:nil waitUntilDone:YES];
*/
}

#pragma mark - Set title for OPDocs
- (void) setTitleForOutputDocs
{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSString *processName = [appDelegate.dataBase getProcessNameForProcesId:self.processIdentifier];
//    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@",processName, self.opdocTitleString];
}

#pragma mark - Populate navigation bar
/** Populating navigation bar **/
- (void)populateNavigationBar
{
    // Left bar button
    // Title
    // Right button if any
}

#pragma mark - View life cycle
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![Utility notIOS7]) {
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    //Modified shravya - OPDOC-CR
//    NSString * alert_ok = @"OK"; // [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
//    if (![Utility isStringEmpty:alert_ok]) {
//         [[SVMXDatabaseMaster sharedDataBaseMaterObject] setOkayMessageForErrorAlerts:alert_ok];
//    }
   
    [self populateNavigationBar];
    
    [self setTitleForOutputDocs];
    
    [self addJsExecuterToView];
}

#pragma mark - Adding the js executer to the view
- (void)addJsExecuterToView {

    NSString *codeSnippet =  [HTMLJSWrapper getWrapperForOPDocs:nil forRecord:self.localIdentifier andProcessId:self.processIdentifier];
    
    NSString *corelibDir = [FileManager getCoreLibSubDirectoryPath];
    NSString *htmlfilepath = [corelibDir stringByAppendingPathComponent:@"OPDoc.html"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:htmlfilepath])
        [[NSFileManager defaultManager] removeItemAtPath:htmlfilepath error:NULL];
    
    [codeSnippet writeToFile:htmlfilepath
                  atomically:NO
                    encoding:NSUTF8StringEncoding
                       error:NULL];
    
    CGRect rect = CGRectMake(0, 0, 1024, 708);
    if(self.jsExecuter == nil)
    {
        JSExecuter *tempVar = [[JSExecuter alloc] initWithParentView:self.view andCodeSnippet:nil andDelegate:self andFrame:rect];
        self.jsExecuter = tempVar;
        tempVar = nil;
    }
    
    [self.jsExecuter loadHTMLFileFromPath:htmlfilepath];
    
}
#pragma mark - Related UserInfo

//Get current user info
- (NSString *) getCurrentUserName {

    NSString *userFullName=@"";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userFullName = [userDefaults objectForKey:@"USERFULLNAME"];  //To get user display name not email id
    return userFullName;
    
}
//Get user related info
- (NSString *)dictionaryResponseForRelatedUserInfo {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //7594 defect - krishna
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MM/dd/YYYY" options:0 locale:[NSLocale currentLocale]];
    NSString *dateformat = formatString;//[dateFormatter dateFormat];
    NSString *amtext = [dateFormatter AMSymbol];
    NSString *pmtext = [dateFormatter PMSymbol];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *timeformat = [dateFormatter dateFormat];
    
    NSArray *valuesArray = [NSArray arrayWithObjects:[self getCurrentUserName],dateformat,timeformat,amtext,pmtext,nil];
    NSArray *keysArray = [NSArray arrayWithObjects:@"username",@"dateformat",@"timeformat",@"amtext",@"pmtext", nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:valuesArray forKeys:keysArray];
    NSString * response =  [dict JSONRepresentation];
    
    
    dateFormatter = nil;
    return response;

}

#pragma mark - iOSJS Bridge Delegates
- (void)eventOccured:(NSString *)eventName andParameter:(NSString *)jsonParameterString{
       
    if([eventName isEqualToString:@"relateduserinput"]) {
        
        NSString *response = [self dictionaryResponseForRelatedUserInfo];
        [self.jsExecuter response:response forEventName:eventName];
        
    }
    else if([eventName isEqualToString:@"capturesignature"])
    {
        self.signEventName = eventName;
        self.signEventParameterString = jsonParameterString;
        [self captureSignature];
    }
    else if([eventName isEqualToString:@"issignatureavailable"])
    {
        NSString *coreLibDir = [FileManager getCoreLibSubDirectoryPath];
        NSString *filePath = [coreLibDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",jsonParameterString]];

        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
            filePath = @"";
        
        NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
        [responseDict setObject:jsonParameterString forKey:@"Id"];
        [responseDict setObject:filePath forKey:@"Path"];
        [self.jsExecuter response:[responseDict JSONRepresentation] forEventName:eventName];
    }
    else if([eventName isEqualToString:@"finalize"])
    {
        //Aparna: Source Update
        [self updateAndSyncSourceObjects];
        
        SBJsonParser *jsonpr = [[SBJsonParser alloc] init];
        NSDictionary *finalizeDict = [jsonpr objectWithString:jsonParameterString];
        jsonpr = nil;
        
        [self finalizeAndStoreHTML:finalizeDict];
    }
    else if ([eventName isEqualToString:@"console"]){
        NSLog(@"Console: %@",jsonParameterString);
    }
}

#pragma mark - Popover delegate.
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{    
    return YES;
}

#pragma mark - Finalize and store rreceived HTML content
//krishna opdoc syncOPDocHtmlData

- (void)finalizeAndStoreHTML:(NSDictionary *)finalizeDict
{
    NSString *str =  [self.jsExecuter.jsWebView stringByEvaluatingJavaScriptFromString:@"captureData();"];

    NSData *fileData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *coreLibDir = [FileManager getCoreLibSubDirectoryPath]; // [docArrayPath objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@.html",[finalizeDict objectForKey:@"ProcessId"],[finalizeDict objectForKey:@"RecordId"],[Utility currentDateInGMTForOPDoc]];
    NSString *filePath = [coreLibDir stringByAppendingPathComponent:fileName];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    [filemanager createFileAtPath:filePath contents:[str dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    [self syncOPDocHtmlData:fileData andFileName:fileName];
}

- (void)syncOPDocHtmlData:(NSData *)fileData andFileName:(NSString *)fileName {

    
    /* Call Request class for starting the sync and uploading the documents : Follow iPhone's ZKS call structure */
    
//    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    NSDictionary * dict = [appDelegate.SFMPage objectForKey:gHEADER];
//    NSString * HeaberObjectName = [dict objectForKey:@"hdr_Object_Name"];
//    //save to document directory
//    
//    [appDelegate.calDataBase insertOPDocHtmlData:fileData WithId:self.recordIdentifier localId:self.localIdentifier apiName:HeaberObjectName WONumber:self.opdocTitleString docNsme:fileName forProcessId:self.processIdentifier];
//    appDelegate.calDataBase.opDocController = self;
    
}

#pragma mark - Signature Capture modules

- (void)captureSignature
{
    if (isShowingSignatureCapture)
        return;
    
    if(sign != nil)
    {
        sign = nil;
    }

    sign = [[OPDocSignatureViewController alloc] initWithNibName:[OPDocSignatureViewController description] bundle:nil];
    
    sign.signatureName = self.signEventParameterString;
    
    sign.view.frame = CGRectMake(0, self.view.frame.size.height-sign.view.frame.size.height, sign.view.frame.size.width, sign.view.frame.size.height);
    CGPoint centerPt = sign.view.center;
    centerPt.x = self.view.center.x;
    sign.view.center = centerPt;
    [sign.view setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];

	sign.parent = nil;
    sign.delegate = self;
	if( signimagedata != nil )
	{
		sign.imageData = signimagedata;
		[sign setImage];
	}
	[self.view addSubview:sign.view];
    
    isShowingSignatureCapture = YES;
}
#pragma mark - OPDocSignatureViewController delegate
//krishna opdoc syncOPDocHtmlData

- (void) setSignImageData:(NSData *)imageData withSignId:(NSString *)signId andSignName:(NSString *)signName
{
    isShowingSignatureCapture = NO;

    if (imageData == nil)
    {
        isShowingSignatureCapture = NO;
        return;
    }
    
    // Call appDelegate Method to save signature to SFDC
/*    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary * dict = [appDelegate.SFMPage objectForKey:gHEADER];
    NSString * HeaberObjectName = [dict objectForKey:@"hdr_Object_Name"];
    
    NSString * WoNumber = self.opdocTitleString;
    if ([WoNumber isEqualToString:nil] || [WoNumber isEqualToString:@""])
        WoNumber = @"";

    [appDelegate.calDataBase insertSignatureData:imageData WithId:signId RecordId:appDelegate.sfmPageController.recordId apiName:HeaberObjectName WONumber:WoNumber flag:@"OPDOC" andSignName:signName];
*/
    
    NSString *documentDirectory = [FileManager getCoreLibSubDirectoryPath];
    //krishna opdoc syncOPDocHtmlData

    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    self.signatureInfoDict = [self signatureDictionary];
    NSLog(@"signInfoDict %@",[self.signatureInfoDict description]);
    NSString *oldfilePath = @"";
    for(NSString *file in [self.signatureInfoDict allKeys]) {
        if ([file isEqualToString:signId]) {
            
            oldfilePath = [documentDirectory stringByAppendingPathComponent:[self.signatureInfoDict objectForKey:signId]];
            oldfilePath = [oldfilePath stringByAppendingPathExtension:@"png"];
            [filemanager removeItemAtPath:oldfilePath error:nil];
        }
    }
    [self.signatureInfoDict setObject:signName forKey:signId];

    
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",signName]];

    [filemanager createFileAtPath:filePath contents:[imageData AESDecryptWithPassphrase:@"hello123_!@#$%^&*()"] attributes:nil];
    
    isShowingSignatureCapture = NO;
    
    NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
    [responseDict setObject:signName forKey:@"Id"];
    [responseDict setObject:filePath forKey:@"Path"];
    [self.jsExecuter response:[responseDict JSONRepresentation] forEventName:self.signEventName];
    
}


@end
