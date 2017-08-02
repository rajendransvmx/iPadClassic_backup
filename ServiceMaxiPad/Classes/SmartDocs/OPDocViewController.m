//
//  OPDocViewController.m
//  iService
//
//  Created by Damodar on 4/29/13.
//
//

#import "OPDocViewController.h"
#import "HTMLJSWrapper.h"
#import "NSData-AES.h"
#import "Utility.h"
#import "FileManager.h"
#import "FactoryDAO.h"
#import "SourceUpdateDAO.h"
#import "OPDocDAO.h"
#import "OPDocSignatureDAO.h"
#import "CustomerOrgInfo.h"
#import "SyncManager.h"
#import "SNetworkReachabilityManager.h"
#import "AlertMessageHandler.h"
#import "AttachmentUtility.h"
#import "DateUtil.h"
#import "TagManager.h"

@interface OPDocViewController ()

- (void)syncOPDocHtmlData:(NSData *)fileData andFileName:(NSString *)fileName;
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

    CGPoint  pt = self.view.center;
    pt.y = pt.y - 32.0f;
    sign.view.center = pt;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    sign.view.center = CGPointMake(( (size.width/2) - (sign.view.frame.size.width/2) ), ( (size.height/2) - (sign.view.frame.size.height/2) - 32.0f));
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
    [self backView];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark -
#pragma mark Source Update Methods

- (void)updateAndSyncSourceObjects
{
    id<SourceUpdateDAO> service = [FactoryDAO serviceByServiceType:ServiceTypeSourceUpdate];
    [service updateTargetObjectsForSmartDocProcess:self.processSFID forObject:self.objectName andLocalId:self.localIdentifier];
}

#pragma mark - Init Methods

/**
 * @name initWithNibName: bundle: forObject: forRecordId: andLocalId: andProcessId: andProcessSFId:
 *
 * @author Damodar Shenoy
 *
 * @brief Initializes OPDocViewController with given input parameters. Unexpecte behavior if any of the input params are nil.
 *
 * \par
 *
 * @param  nibNameOrNil : Nib from which the view has to be loaded
 * @param  nibBundleOrNil : bundle from which the nib has to be taken from
 * @param  objectName : Name of the parent object
 * @param  recordId : Id of the parent record
 * @param  localId : local id of parent record
 * @param  processId : local Id of the OPDoc process
 * @param  pSFId : SFId of the OPDoc process
 * @return An object of OPDocViewController
 *
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forObject:(NSString*)objectName forRecordId:(NSString *)recordId andLocalId:(NSString *)localid andProcessId:(NSString *)processId andProcessSFId:(NSString *)pSFId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.recordIdentifier = recordId;
        self.processIdentifier = processId;
        self.processSFID = pSFId;
        self.objectName = objectName;
        
        self.localIdentifier = localid;
    }
    return self;
}
#pragma mark - Navigation Button Actions


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

/**
 * @name setTitleForOutputDocs
 *
 * @author Damodar Shenoy
 *
 * @brief Sets the back button with the title name field value of parent record
 *
 * \par
 *
 * @param  nil
 * @return void
 *
 */
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backView)];
    [backView addGestureRecognizer:tap];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:backView];
    self.navigationItem.leftBarButtonItem = barBtn;
  
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    titleLabel.text = [[TagManager sharedInstance] tagByName:kTag_Customer_Sign_Off];
    titleLabel.font = [UIFont boldSystemFontOfSize:21];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    // Right button for printing
    self.printButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(printWebPage:)];
    self.navigationItem.rightBarButtonItem = self.printButton;

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
   
    [self populateNavigationBar];
    
    [self setTitleForOutputDocs];
    
    [self addJsExecuterToView];
    
    self.printButton.enabled = NO;
}

#pragma mark - Adding the js executer to the view

/**
 * @name addJsExecuterToView
 *
 * @author Damodar Shenoy
 *
 * @brief Adds the webview to the controllers view using JSExecuter class and loads the core library
 *
 * \par
 *
 * @param  nil
 * @return void
 *
 */
- (void)addJsExecuterToView {

    NSString *codeSnippet =  [HTMLJSWrapper getWrapperForOPDocs:nil forRecord:self.localIdentifier andProcessId:self.processIdentifier];
    
    NSString *corelibDir = [FileManager getCoreLibSubDirectoryPath];
    NSString *htmlfilepath = [corelibDir stringByAppendingPathComponent:@"OPDoc.html"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:htmlfilepath])
        [[NSFileManager defaultManager] removeItemAtPath:htmlfilepath error:NULL];
    
    [codeSnippet writeToFile:[corelibDir stringByAppendingPathComponent:@"OPDoc.html"]
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
    
    // IPAD-4599
    NSString *orgAddress = [[NSUserDefaults standardUserDefaults] objectForKey:kOrgAddressKey];
    if (orgAddress == nil) orgAddress = @"";
    
        NSArray *valuesArray = [NSArray arrayWithObjects:[self getCurrentUserName],dateformat,timeformat,amtext,pmtext, orgAddress, nil];
    NSArray *keysArray = [NSArray arrayWithObjects:@"username",@"dateformat",@"timeformat",@"amtext",@"pmtext", @"orgAddress", nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:valuesArray forKeys:keysArray];
    NSString * response =  [Utility jsonStringFromObject:dict];
    
    dateFormatter = nil;
    return response;

}

#pragma mark - iOSJS Bridge Delegates
- (void)eventOccured:(NSString *)eventName andParameter:(NSString *)jsonParameterString{
       
    if([eventName isEqualToString:@"relateduserinput"]) {
        
        NSString *response = [self dictionaryResponseForRelatedUserInfo];
        [self.jsExecuter response:response forEventName:eventName];
        
    }
    else if([eventName isEqualToString:@"fetchdisplaytags"]) {
        
        /*
         Display tags for to be put up while OPDoc is generated
         Only Finalize button title in OPDoc is required as of now
         For future add key value pairs in responseDict variable
         */
        
        NSString *finalizeKey = kTag_FINALIZE;
        NSString *finalizeLocalStr = [[TagManager sharedInstance] tagByName:kTag_FINALIZE];
        
        NSDictionary *responseDict = @{ finalizeKey : finalizeLocalStr };
        NSString *response = [Utility jsonStringFromObject:responseDict];
        
        [self.jsExecuter response:response forEventName:eventName];
        
    }
    else if([eventName isEqualToString:@"capturesignature"])
    {
        self.signEventName = eventName;
        self.signEventParameterString = jsonParameterString;
        //      ProcessUniqueName + "_" + RecordId + "_" + DOM_Id
        //      UniqueName is the value of the attribute "signature-name" of the signature button dom
        NSString *combinedString = [NSString stringWithFormat:@"%@_%@_",self.processIdentifier,self.localIdentifier];
        NSString *domElementId = [jsonParameterString stringByReplacingOccurrencesOfString:combinedString withString:@""];
        NSString *jsQuery = [NSString stringWithFormat:@"document.querySelectorAll('[signature-name=\"%@\"]')[0].innerText.toString();",domElementId];
        NSString *buttonTitle = [self.jsExecuter.jsWebView stringByEvaluatingJavaScriptFromString:jsQuery];
        [self captureSignatureWithTitle:buttonTitle];
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
        [self.jsExecuter response:[Utility jsonStringFromObject:responseDict] forEventName:eventName];
    }
    else if([eventName isEqualToString:@"finalize"])
    {
        //Aparna: Source Update
        [self updateAndSyncSourceObjects];
        NSDictionary *finalizeDict = [Utility objectFromJsonString:jsonParameterString];
        
        [self finalizeAndStoreHTML:finalizeDict];
    }
    else if ([eventName isEqualToString:@"console"]){
       // NSLog(@"Console: %@",jsonParameterString);
    }
}

#pragma mark - Finalize and store rreceived HTML content


/**
 * @name finalizeAndStoreHTML:
 *
 * @author Damodar Shenoy
 *
 * @brief Stores the HTML file doc to local directory along with its corresponding signatures and starts the data sync
 *
 * \par
 *
 * @param  Dictionary containing the details : process id, record id and current date for naming the html file
 * @return void
 *
 */
- (void)finalizeAndStoreHTML:(NSDictionary *)finalizeDict
{
    if([UIPrintInteractionController isPrintingAvailable])
        self.printButton.enabled = YES;
    
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
    model.record_id = self.localIdentifier;
    model.objectName = self.objectName;
    model.Name = fileName;
    model.lastModifiedDate = [DateUtil getDatabaseStringForDate:[NSDate date]];
    model.bodyLength = [AttachmentUtility getSizeforFileAtPath:filePath];
    [opdocService addHTMLfile:model];
    
    id<OPDocSignatureDAO> opdocSignService =  [FactoryDAO serviceByServiceType:ServiceTypeOPDocSignature];
    NSArray *signIds = [self.signatureInfoDict allKeys];
    for (NSString *signId in signIds)
    {
        OPDocSignature *signatureModel = [[OPDocSignature alloc] init];
        signatureModel.process_id = self.processIdentifier;
        signatureModel.record_id = self.localIdentifier;
        signatureModel.objectName = self.objectName;
        signatureModel.HTMLFileName = fileName;
        signatureModel.signId = signId;
        signatureModel.Name = [[self.signatureInfoDict objectForKey:signId] stringByAppendingPathExtension:@"png"];
        
        [opdocSignService addSignature:signatureModel];
    }
    
    [self.signatureInfoDict removeAllObjects];
    [self syncOPDocHtmlData:fileData andFileName:fileName];
}

- (void)syncOPDocHtmlData:(NSData *)fileData andFileName:(NSString *)fileName
{
    /* Call Request class for starting the sync and uploading the documents */
   [[SyncManager sharedInstance] performDataSyncIfNetworkReachable];
}

#pragma mark - Signature Capture modules

/**
 * @name captureSignature
 *
 * @author Damodar Shenoy
 *
 * @brief Loads the signature capture view using OPDocSignatureViewController class
 *
 * \par
 *
 * @param  nil
 * @return void
 *
 */
- (void)captureSignatureWithTitle:(NSString*)title{
    if (isShowingSignatureCapture)
        return;
    
    if(sign != nil)
    {
        sign = nil;
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
    view.tag = 9999;
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:view];
    
    sign = [[OPDocSignatureViewController alloc] initWithNibName:[OPDocSignatureViewController description] bundle:nil];
    
    sign.signatureName = self.signEventParameterString;
    
    sign.view.frame = CGRectMake(0, 0, sign.view.frame.size.width, sign.view.frame.size.height);
    
    CGPoint  pt = self.view.center;
    pt.y = pt.y - 32.0f;
    sign.view.center = pt;
    
	sign.parent = nil;
    sign.delegate = self;
    sign.dataSource = self;
    
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
    sign.titleLabel.text = title;

    
    isShowingSignatureCapture = YES;
}

#pragma mark - OPDocSignatureViewController delegate

/**
 * @name setSignImageData: withSignId: andSignName:
 *
 * @author Damodar Shenoy
 *
 * @brief Send the watermarked signature along with the sign Id against which the sign has to be saved using the given name
 *
 * \par
 *
 * @param  imageData : Raw signature data
 * @param  signId : Unique signature identifier
 * @param  signName : Unique signature name
 * @return void
 *
 */
- (void) setSignImageData:(NSData *)imageData withSignId:(NSString *)signId andSignName:(NSString *)signName
{
    [[self.view viewWithTag:9999] removeFromSuperview];
    
    isShowingSignatureCapture = NO;

    if (imageData == nil)
    {
        isShowingSignatureCapture = NO;
        return;
    }
    
    
    NSString *documentDirectory = [FileManager getCoreLibSubDirectoryPath];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    self.signatureInfoDict = [self signatureDictionary];
   
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
    [self.jsExecuter response:[Utility jsonStringFromObject:responseDict] forEventName:self.signEventName];
    
}


- (NSString *) getRandomString
{
    NSString *date = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSArray *randomArray = [date componentsSeparatedByString:@"."];
    NSString *randomString = nil;
    randomString = [NSString stringWithFormat:@"%@%@",[[randomArray objectAtIndex:0] substringWithRange:
                                                       NSMakeRange(2, 6)],[[randomArray objectAtIndex:1] substringWithRange:NSMakeRange(0, 5)]];
    
    return randomString;
}

/**
 * @name getWaterMarktext
 *
 * @author Damodar Shenoy
 *
 * @brief Get the watermark string for signature. A required method
 *
 * \par
 *
 * @param  nil
 * @return NSString object containing the text
 *
 */
- (NSString*)getWaterMarktext
{
    
    NSString * objName = self.opdocTitleString;
    
    if ([Utility isStringEmpty: objName])
        objName = [self getRandomString];
    
    NSDate * today = [NSDate date];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TIMEFORMAT];
    
    // Optionally for time zone converstions
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [dateFormatter stringFromDate:today];
    
    NSString * string = [NSString stringWithFormat:@"%@ %@ ", objName, stringFromDate];
    
    NSMutableString * markerString = [[NSMutableString alloc] initWithCapacity:0];
    for (int i = 0; i < 10; i++)
    {
        [markerString appendString:string];
    }
    
    return markerString;
}

- (NSString *)getWrappedStringFromString:(NSString *)data
{
    if([data length] == 0) return nil;
    
    UIFont *font = [UIFont boldSystemFontOfSize:21];
    
    CGSize constraint = CGSizeMake(MAX_WIDTH, MAX_HEIGHT);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    //    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect oldRect = [data boundingRectWithSize:constraint
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:attributes
                                        context:nil];
    
    CGSize oldSize = CGSizeMake(oldRect.size.width, oldRect.size.height);
    
    
    NSString *newData = [data substringToIndex:0];
    
    //Modified Kri - OPDOC-CR
    CGSize newSize = CGSizeZero;
    int position = 0;
    
    while ((MAX_WIDTH-10)> newSize.width)
    {
        
        NSRange range;
        
        range.length = 1;
        
        range.location = position;
        
        oldRect = [newData boundingRectWithSize:constraint
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:attributes
                                        context:nil];
        oldSize = CGSizeMake(oldRect.size.width, oldRect.size.height);
        
       // SXLogInfo(@"Range Position = %lu Data Length = %lu",(unsigned long)range.location,(unsigned long)[data length]);
        if(range.location >= [data length])
        {
            range.location = 0;
            position = 0;
        }
        newData = [newData stringByAppendingFormat:@"%@",[data substringWithRange:range]];
        
        
        
        oldRect = [newData boundingRectWithSize:constraint
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:attributes
                                        context:nil];
        newSize = CGSizeMake(oldRect.size.width, oldRect.size.height);
        
        position++;
        if(oldSize.width >= newSize.width)
        {
            break;
        }
        
    }
    
    return newData;
}

#pragma mark - Printing


- (IBAction)printWebPage:(id)sender
{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    if(!controller){
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    UIPrintInteractionCompletionHandler completionHandler =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
        }
    };
    
    controller.delegate = self;
    
    // Obtain a printInfo so that we can set our printing defaults.
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    // This application produces General content that contains color.
    printInfo.outputType = UIPrintInfoOutputGeneral;
    // We'll use the URL as the job name.
    printInfo.jobName = @"Customer Sign Off";
    // Set duplex so that it is available if the printer supports it. We are
    // performing portrait printing so we want to duplex along the long edge.
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    
    printInfo.orientation = UIPrintInfoOrientationPortrait;
    
    // Use this printInfo for this print job.
    controller.printInfo = printInfo;
    
    // Be sure the page range controls are present for documents of > 1 page.
    controller.showsPageRange = YES;
    
    // This code uses a custom UIPrintPageRenderer so that it can draw a header and footer.
    UIPrintPageRenderer *myRenderer = [[UIPrintPageRenderer alloc] init];
    // The APLPrintPageRenderer class provides a jobtitle that it will label each page with.
    //    myRenderer.jobTitle = printInfo.jobName;
    // To draw the content of each page, a UIViewPrintFormatter is used.
    UIViewPrintFormatter *viewFormatter = [self.jsExecuter.jsWebView viewPrintFormatter];
    
    
    [myRenderer addPrintFormatter:viewFormatter startingAtPageAtIndex:0];
    // Set our custom renderer as the printPageRenderer for the print job.
    controller.printPageRenderer = myRenderer;
        
    /*
     The method we use to present the printing UI depends on the type of UI idiom that is currently executing. Once we invoke one of these methods to present the printing UI, our application's direct involvement in printing is complete. Our custom printPageRenderer will have its methods invoked at the appropriate time by UIKit.
     */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [controller presentFromBarButtonItem:self.printButton animated:YES completionHandler:completionHandler];  // iPad
    }
    else {
        [controller presentAnimated:YES completionHandler:completionHandler];  // iPhone
    }
}


//- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController
//{
//    return self;
//}

@end
