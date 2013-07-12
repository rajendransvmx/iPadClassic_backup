//
//  OPDocViewController.m
//  iService
//
//  Created by Damodar on 4/29/13.
//
//

#import "OPDocViewController.h"
#import "iServiceAppDelegate.h"
#import "HTMLJSWrapper.h"
#import "NSObject+SBJson.h"
#import "About.h"
#import "HelpController.h"
#import "NSData-AES.h"
#import "SBJsonParser.h"
#import "Utility.h"

@interface OPDocViewController ()
//krishna opdoc syncOPDocHtmlData
- (void)syncOPDocHtmlData:(NSData *)fileData andFileName:(NSString *)fileName;
@end

@implementation OPDocViewController
@synthesize signEventName;
@synthesize signEventParameterString;
@synthesize jsExecuter;
@synthesize opdocTitleString;
@synthesize recordIdentifier;
@synthesize processIdentifier;
@synthesize signatureArray;
@synthesize signatureInfoDict;
//@synthesize popOver;

#pragma mark - Memory management methods
- (void)dealloc {
   //[popOver release];
    [opdocTitleString release];
    
    if(existingFilePath)
    {
        [existingFilePath release];
        existingFilePath = nil;
    }

    if(jsExecuter)
    {
        [jsExecuter release];
        jsExecuter = nil;
    }
    
    [recordIdentifier release];
    [processIdentifier release];
    
    [signatureArray release];
    [signatureInfoDict release];
    [super dealloc];
}
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
        [dict release];
    }
    return self.signatureInfoDict;
}
- (void)popNavigationController:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (BOOL)isFilePresentForRecord:(NSString *)recordId forProcess:(NSString *)processId {
    
    NSString *documenDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                                      objectAtIndex:0];
    NSString *htmlFilePath = [[documenDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",processId,recordId]]stringByAppendingPathExtension:@"html"];
    NSString *pdfFilePath = [[documenDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",processId,recordId]]stringByAppendingPathExtension:@"pdf"];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:pdfFilePath]) {
        existingFilePath = [pdfFilePath retain];
        return YES;
    }
    else if ([fileManager fileExistsAtPath:htmlFilePath]) {
        existingFilePath = [htmlFilePath retain];
        return YES;
    }
    existingFilePath = nil;
    return NO;
}
#pragma mark - Init Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRecordId:(NSString *)recordId andProcessId:(NSString *)processId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.recordIdentifier = recordId;
        self.processIdentifier = processId;
        
        ifFileAvailable = [self isFilePresentForRecord:recordId forProcess:processId];
    }
    return self;
}
#pragma mark - Navigation Button Actions

- (IBAction)templateSelector:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    OPDocTemplateSelectorViewController *template = [[[OPDocTemplateSelectorViewController alloc] initWithNibName:@"OPDocTemplateSelectorViewController" bundle:nil] autorelease];
    template.delegate = self;
    popOver = [[UIPopoverController alloc] initWithContentViewController:template];
    [popOver setPopoverContentSize:template.view.frame.size animated:YES];
    popOver.delegate = self;
    [popOver presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

}
-(IBAction)displayUser:(id)sender {
    
    UIButton * button = (UIButton *)sender;
    About * about = [[[About alloc] initWithNibName:@"About" bundle:nil] autorelease];
    UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:about];
    [popover setContentViewController:about animated:YES];
    [popover setPopoverContentSize:about.view.frame.size];
    popover.delegate = self;
    [popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

}

- (IBAction) displayHelp
{
    //Change the text to output docs
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    NSString *lang=[appDelegate.dataBase checkUserLanguage];
    NSString *isfileExists = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"summary_%@",lang] ofType:@"html"];
    if((isfileExists == NULL) || [lang isEqualToString:@"en_US"] ||  !([lang length]>0))
    {
        help.helpString=@"summary.html";
    }
    else
    {
        help.helpString = [NSString stringWithFormat:@"summary_%@.html",lang];
    }
    help.isPortrait = YES;
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:help animated:YES completion:nil];
    [help release];
}
//krishna OPDOC
- (void)backView {
    
    //clear all signatures in document directory. as this is not finalized
    
    //get all opdoc related signature from OPdoc
    NSString *signName = [NSString stringWithFormat:@"%@_%@",self.processIdentifier,self.recordIdentifier];
    
    //check if exists in doc directory if exists delete it.
    NSString *documentDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    NSString *htmlFileName = [[documentDirectoryPath stringByAppendingPathComponent:signName] stringByAppendingPathExtension:@"html"];
    
    if (![filemanager fileExistsAtPath:htmlFileName]) {
        
        NSMutableArray *arr = [appDelegate.calDataBase retrieveAllSignatureOfOutputDocForId:signName];
        
        for(NSString *signature in arr) {
            NSString *signaturePath = [[documentDirectoryPath stringByAppendingPathComponent:signature] stringByAppendingPathExtension:@"png"];
            if([filemanager fileExistsAtPath:signaturePath]) {
                [filemanager removeItemAtPath:signaturePath error:nil];
            }
        }
        //clear opdoc related signatures in Database.
        [appDelegate.calDataBase deleteSignatureForOPDocWhereLikeSignId:signName andSignType:@"OPDOC"];
    }
    appDelegate.calDataBase.opDocController = nil;
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
}

#pragma mark - Set title for OPDocs
- (void) setTitleForOutputDocs {
    
    iServiceAppDelegate *AppDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString * serviceReport = [AppDelegate.wsInterface.tagsDictionary objectForKey:SFM_SUMMARY_BACK_HEADER];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",serviceReport, self.opdocTitleString];
}

#pragma mark - Populate navigation bar
/** Populating navigation bar **/
- (void)populateNavigationBar {
    
    UIImage *multipleTemplateBtnImg = [UIImage imageNamed:@"icon-iService-Debriefing-Summary-portrait-Signature.png"];
    UIImage *logoImage = [UIImage imageNamed:@"wou-servicemax-logo.png"];
    UIView *containingLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, logoImage.size.width + multipleTemplateBtnImg.size.width, logoImage.size.height)];
    
    // Create a custom button with the image for left
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:logoImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(displayUser:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, logoImage.size.width, logoImage.size.height)];
    
    [containingLeftView addSubview:button];
        
    UIBarButtonItem *containingBarButton = [[UIBarButtonItem alloc] initWithCustomView:containingLeftView];    
    [containingLeftView release];
    
    self.navigationItem.leftBarButtonItem = containingBarButton;
    [containingBarButton release];
    
    //UIImage *btn1Image = [UIImage imageNamed:@"service-report-button.png"];
    UIImage *btn2Image = [UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button.png"];
    UIImage *btn3Image = [UIImage imageNamed:@"iService-Screen-Help.png"];

    //create right view for buttons
    UIView *containingRightView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, appDelegate.SyncProgress.frame.size.width+btn2Image.size.width+btn3Image.size.width+20, btn2Image.size.height)];
    // Create a custom button with the image for left

    int padding = 10;
    UIView *syncContainer  = [[UIView alloc] initWithFrame:CGRectMake(-10, -5, appDelegate.SyncProgress.frame.size.width, appDelegate.SyncProgress.frame.size.height)];
    [syncContainer addSubview:appDelegate.SyncProgress];
    
    padding += syncContainer.frame.size.width;
    
    [containingRightView addSubview:syncContainer];

    UIButton *button2 =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setImage:btn2Image forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(backView) forControlEvents:UIControlEventTouchUpInside];
    [button2 setFrame:CGRectMake(padding, 0,  btn2Image.size.width, btn2Image.size.height)];
    
    padding += button2.frame.size.width + 10;
    
    [containingRightView addSubview:button2];
    
    UIButton *button3 =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setImage:btn3Image forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(displayHelp) forControlEvents:UIControlEventTouchUpInside];
    [button3 setFrame:CGRectMake(padding, 0, btn3Image.size.width, btn3Image.size.height)];
    
    [containingRightView addSubview:button3];

    UIBarButtonItem *containingRightBarButton = [[UIBarButtonItem alloc] initWithCustomView:containingRightView];
    [containingRightView release];
    

    self.navigationItem.rightBarButtonItem = containingRightBarButton;
    [containingRightBarButton release];
}

- (void)loadExistingFileInReadonlyMode
{
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 708)];    
    NSURL *url = [NSURL fileURLWithPath:existingFilePath];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webview loadRequest:requestObj];
    [self.view addSubview:webview];
    [webview release];
    
}

#pragma mark - View life cycle
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setTitleForOutputDocs];
    
    if(!ifFileAvailable)
        [self addJsExecuterToView];
    else
        [self loadExistingFileInReadonlyMode];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self populateNavigationBar];
    
}

#pragma mark - Adding the js executer to the view
- (void)addJsExecuterToView {

    NSString *codeSnippet =  [HTMLJSWrapper getWrapperForOPDocs:nil forRecord:self.recordIdentifier andProcessId:self.processIdentifier];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *htmlfilepath = [documentsDirectory stringByAppendingPathComponent:@"OPDoc.html"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:htmlfilepath]);
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
        [tempVar release];
        tempVar = nil;
    }
    
    [self.jsExecuter loadHTMLFileFromPath:htmlfilepath];
    
}
#pragma mark - Related UserInfo

//Get current user info
- (NSString *) getCurrentUserName {

    NSString *userFullName=@"";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userFullName = [userDefaults objectForKey:USERFULLNAME];  //To get user display name not email id
    return userFullName;
    
}
//Get user related info
- (NSString *)dictionaryResponseForRelatedUserInfo {
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSString *dateformat = [dateFormatter dateFormat];
    NSString *amtext = [dateFormatter AMSymbol];
    NSString *pmtext = [dateFormatter PMSymbol];
    
    dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *timeformat = [dateFormatter dateFormat];
    
    NSArray *valuesArray = [NSArray arrayWithObjects:[self getCurrentUserName],dateformat,timeformat,amtext,pmtext,nil];
    NSArray *keysArray = [NSArray arrayWithObjects:@"username",@"dateformat",@"timeformat",@"amtext",@"pmtext", nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:valuesArray forKeys:keysArray];
    NSString * response =  [dict JSONRepresentation];
    return response;

}
#pragma mark - Multiple doc template delegate
- (void)doctemplateId:(NSString *)docId forProcessId:(NSString *)processId {
    
    if(popOver != nil) {
        [popOver dismissPopoverAnimated:YES];
        [popOver release];
        popOver = nil;
    }
    NSLog(@"doc Id %@ process id %@",docId,processId);
    [appDelegate.dataBase UpdateDocumentTemplateId:docId forProcessId:processId];
    [self addJsExecuterToView];
    
    
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
        NSArray *docArrayPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentDirectory = [docArrayPath objectAtIndex:0];
        NSString *filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",jsonParameterString]];

        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
            filePath = @"";
        
        NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
        [responseDict setObject:jsonParameterString forKey:@"Id"];
        [responseDict setObject:filePath forKey:@"Path"];
        [self.jsExecuter response:[responseDict JSONRepresentation] forEventName:eventName];
    }
    else if([eventName isEqualToString:@"finalize"])
    {
        SBJsonParser *jsonpr = [[SBJsonParser alloc] init];
        NSDictionary *finalizeDict = [jsonpr objectWithString:jsonParameterString];
        [jsonpr release];
        
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

    //kri
    NSData *fileData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *docArrayPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = [docArrayPath objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.html",[finalizeDict objectForKey:@"ProcessId"],[finalizeDict objectForKey:@"RecordId"]];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    [filemanager createFileAtPath:filePath contents:[str dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    //sync html data to server kris
    [self syncOPDocHtmlData:fileData andFileName:fileName];

}

- (void)syncOPDocHtmlData:(NSData *)fileData andFileName:(NSString *)fileName {
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary * dict = [appDelegate.SFMPage objectForKey:gHEADER];
    NSString * HeaberObjectName = [dict objectForKey:@"hdr_Object_Name"];
    //save to document directory
    NSString *localId = [appDelegate.databaseInterface getLocalIdFromSFId:self.recordIdentifier tableName:HeaberObjectName];
    
    [appDelegate.calDataBase insertOPDocHtmlData:fileData WithId:self.recordIdentifier localId:localId apiName:HeaberObjectName WONumber:self.opdocTitleString docNsme:fileName forProcessId:self.processIdentifier];
    appDelegate.calDataBase.opDocController = self;
    
}

#pragma mark - Signature Capture modules

- (void)captureSignature
{
    if (isShowingSignatureCapture)
        return;
    
    if(sign != nil)
    {
        [sign release];
        sign = nil;
    }
//    SBJsonParser *someparser = [[SBJsonParser alloc] init];
    
    //signature array consists of signature info data
//    self.signatureArray = [someparser objectWithString:self.signEventParameterString];
    
    sign = [[OPDocSignatureViewController alloc] initWithNibName:[OPDocSignatureViewController description] bundle:nil];
    
    //signatureDataArray consists of signature info data but of OPDocSignatureViewController instance
//    sign.signatureDataArray = [NSMutableArray arrayWithArray:self.signatureArray];
    
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
		sign.imageData = [signimagedata retain];
		[sign SetImage];
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
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary * dict = [appDelegate.SFMPage objectForKey:gHEADER];
    NSString * HeaberObjectName = [dict objectForKey:@"hdr_Object_Name"];
    
    NSString * WoNumber = self.opdocTitleString;
    if ([WoNumber isEqualToString:nil] || [WoNumber isEqualToString:@""])
        WoNumber = @"";
    
    
    //saving the signature to document directory
    //limitation : saving multiple signature with same name, not possible. as it will overwriet
    
    //Krishnsign handling multiple signature.
//    NSString *imageInfoId = [dictionary objectForKey:@"ImageId"];
    
    //krishna opdoc syncOPDocHtmlData

    [appDelegate.calDataBase insertSignatureData:imageData WithId:signId RecordId:appDelegate.sfmPageController.recordId apiName:HeaberObjectName WONumber:WoNumber flag:@"OPDOC" andSignName:signName];

    
    NSArray *docArrayPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = [docArrayPath objectAtIndex:0];
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
    [self.jsExecuter response:[responseDict JSONRepresentation] forEventName:signEventName];
    
}


@end
