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

#import "FactoryDAO.h"
#import "OPDocDAO.h"
#import "OPDocSignatureDAO.h"
#import "CustomerOrgInfo.h"

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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    sign.view.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    sign.view.hidden = NO;
    sign.view.center = self.view.center;
//    sign.view.frame = CGRectMake( ( self.view.center.x - (sign.view.frame.size.width/2) ), self.view.frame.size.height-sign.view.frame.size.height, sign.view.frame.size.width, sign.view.frame.size.height);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    sign.view.center = CGPointMake(( (size.width/2) - (sign.view.frame.size.width/2) ), ( (size.height/2) - (sign.view.frame.size.height/2) ));
//    sign.view.frame = CGRectMake( ( (size.width/2) - (sign.view.frame.size.width/2) ), size.height-sign.view.frame.size.height, sign.view.frame.size.width, sign.view.frame.size.height);
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
    [self dismissViewControllerAnimated:YES completion:^{}];
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
    NSString *documentDirectoryPath = [FileManager getCoreLibSubDirectoryPath];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    NSArray *nonFinalizedSignatures = [self.signatureInfoDict allValues];
    for (NSString *nonFinalizedFile in nonFinalizedSignatures) {
        
        NSString *signaturePath = [[documentDirectoryPath stringByAppendingPathComponent:nonFinalizedFile] stringByAppendingPathExtension:@"png"];
        if([filemanager fileExistsAtPath:signaturePath])
        {
                [filemanager removeItemAtPath:signaturePath error:nil];
        }
    }

    [self.signatureInfoDict removeAllObjects];
    self.signatureInfoDict = nil;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
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
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Left bar button
//    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:self.opdocTitleString style:UIBarButtonItemStylePlain target:self action:@selector(popNavigationController:)];
//    self.navigationItem.leftBarButtonItem = customBarItem;
    
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OPDocBackArrow.png"]];
    
    UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, arrow.frame.size.height)];
    backLabel.text = self.opdocTitleString;
    backLabel.font = [UIFont systemFontOfSize:17];
    backLabel.textColor = [UIColor whiteColor];
    backLabel.backgroundColor = [UIColor clearColor];
    backLabel.textAlignment = NSTextAlignmentLeft;
    backLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (arrow.frame.size.width + backLabel.frame.size.width), arrow.frame.size.height)];
    backView.backgroundColor = [UIColor clearColor];
    [backView addSubview:arrow];
    [backView addSubview:backLabel];
    backView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popNavigationController:)];
    [backView addGestureRecognizer:tap];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:backView];
    self.navigationItem.leftBarButtonItem = barBtn;
  
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    titleLabel.text = @"Customer Sign Off";
    titleLabel.font = [UIFont boldSystemFontOfSize:21];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
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
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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

    NSString *userFullName=[[CustomerOrgInfo sharedInstance] userDisplayName];
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
    
    // Insert signatures and html file records into tables
    id<OPDocDAO> opdocService =  [FactoryDAO serviceByServiceType:ServiceTypeOPDocHTML];
    
    OPDocHTML *model = [[OPDocHTML alloc] init];
    model.process_id = self.processIdentifier;
    model.record_id = self.recordIdentifier;
    model.objectName = self.opdocTitleString;
    model.Name = fileName;
    
    [opdocService addHTMLfile:model];
    
    id<OPDocSignatureDAO> opdocSignService =  [FactoryDAO serviceByServiceType:ServiceTypeOPDocSignature];
    NSArray *signIds = [self.signatureInfoDict allKeys];
    for (NSString *signId in signIds)
    {
        OPDocSignature *signatureModel = [[OPDocSignature alloc] init];
        signatureModel.process_id = self.processIdentifier;
        signatureModel.record_id = self.recordIdentifier;
        signatureModel.objectName = self.opdocTitleString;
        signatureModel.HTMLFileName = fileName;
        signatureModel.signId = signId;
        signatureModel.Name = [[self.signatureInfoDict objectForKey:signId] stringByAppendingPathExtension:@"png"];
        
        [opdocSignService addSignature:signatureModel];
    }
    
    
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

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.33f];
    view.tag = 9999;
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:view];
    
    sign = [[OPDocSignatureViewController alloc] initWithNibName:[OPDocSignatureViewController description] bundle:nil];
//    sign.view.backgroundColor = [UIColor clearColor];
    
    sign.signatureName = self.signEventParameterString;
    
    sign.view.frame = CGRectMake(0, 0, sign.view.frame.size.width, sign.view.frame.size.height);
    
    sign.view.center = self.view.center;
    
	sign.parent = nil;
    sign.delegate = self;
	if( signimagedata != nil )
	{
		sign.imageData = signimagedata;
		[sign setImage];
	}
    
    
    // border radius
    [sign.view.layer setCornerRadius:2.0f];
    
    // border
    [sign.view.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [sign.view.layer setBorderWidth:1.0f];
    
    // drop shadow
    [sign.view.layer setShadowColor:[UIColor blackColor].CGColor];
    [sign.view.layer setShadowOpacity:0.6];
    [sign.view.layer setShadowRadius:2.0];
    [sign.view.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
	[self.view addSubview:sign.view];
    
    isShowingSignatureCapture = YES;
}
#pragma mark - OPDocSignatureViewController delegate
//krishna opdoc syncOPDocHtmlData

- (void) setSignImageData:(NSData *)imageData withSignId:(NSString *)signId andSignName:(NSString *)signName
{
    [[self.view viewWithTag:9999] removeFromSuperview];
    
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
