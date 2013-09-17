//
//  PDFCreator.m
//  PDFCreator
//
//  Created by Samman Banerjee on 25/10/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PDFCreator.h"
#import "Base64.h"
#import "ZKServerSwitchboard.h"
#import "AppDelegate.h"
#import "DateTimeFormatter.h"
#import "About.h"
#import "Utility.h"

//extern void NSLog(NSString *format, ...);

@implementation PDFCreator

@synthesize delegate;
@synthesize woId;
@synthesize _wonumber, _date, _recordId;
@synthesize _account;
@synthesize _contact, _phone;
@synthesize _description, _workPerformed;
@synthesize _totalCost;
@synthesize _parts, _labor, _expenses;
@synthesize _signature;
@synthesize createPDF;
@synthesize calledFromSummary;
@synthesize prevInterfaceOrientation;
@synthesize workOrderDetails;
@synthesize reportEssentials;
@synthesize shouldShowBillablePrice;
@synthesize shouldShowBillableQty;

//krishna defect : 5813
@synthesize travelArray;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
       // [appDelegate isInternetConnectionAvailable] = YES;
    }
    
    return self;
}

- (IBAction) displayUser:(id)sender
{
    UIButton * button = (UIButton *)sender;
    About * about = [[[About alloc] initWithNibName:@"About" bundle:nil] autorelease];
    UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:about];
    [popover setContentViewController:about animated:YES];
    [popover setPopoverContentSize:about.view.frame.size];
    popover.delegate = self;

    [popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    if ([[popoverController contentViewController] isKindOfClass:[About class]])
        return YES;
    
    return YES;
}

- (IBAction) Close
{
  /*  if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
    if (calledFromSummary)
        [self dismissViewControllerAnimated:YES completion:nil];
//    else
//        [delegate CloseServiceReport:self];//  Unused methods
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [webView setIsAccessibilityElement:YES];
    [webView setAccessibilityIdentifier:@"PDFWebView"];

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	@try{
    [sendMailButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:PDF_EMAIL] forState:UIControlStateNormal];
	//Defect Fix :- 7454
	[sendMailButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	sendMailButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;

    NSDictionary * dict = [appDelegate.SFMPage objectForKey:gHEADER];
    woId = [dict objectForKey:gHEADER_ID];
    
    // Retrieve report essentials
    if ([reportEssentials count] > 0)
        reportEssentialsDict = [reportEssentials objectAtIndex:0];
    
    // Replace all NSNull objects with @""
    NSArray * _allKeys = [reportEssentialsDict allKeys];
    for (int i = 0; i < [_allKeys count]; i++)
    {
        id obj = [reportEssentialsDict objectForKey:[_allKeys objectAtIndex:i]];
        if ([obj isKindOfClass:[NSNull class]] || (obj == nil))
        {
            [reportEssentialsDict setObject:@"" forKey:[_allKeys objectAtIndex:i]];
        }
    }
    
    srShowContactPhone = srShowProblemDescription = srShowWorkPerformed = srShowParts = srShowLabor = srShowExpenses = srShowLinePrice = srShowDiscount = YES;
    
    if (appDelegate.serviceReport != nil)
    {
        NSLog(@"%@",appDelegate.serviceReport);
        NSLog(@"%@", reportEssentials);
        srShowContactPhone = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET003"] boolValue];
        srShowProblemDescription = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET004"] boolValue];
        srShowWorkPerformed = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET005"] boolValue];
        srShowParts = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET006"] boolValue];
        srShowLabor = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET007"] boolValue];
        srShowExpenses = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET008"] boolValue];
        srShowLinePrice = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET009"] boolValue];
        srShowDiscount = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET010"] boolValue];
    }
    
    NSArray * allKeys = [appDelegate.serviceReport allKeys];
    allKeys = [allKeys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString * key in allKeys)
    {
        NSString * keyNumStr = [key stringByReplacingOccurrencesOfString:@"IPAD004_SET" withString:@""];
        NSUInteger keyNum = [keyNumStr intValue];
        // if ([key Contains:@"Custom Field"])
        if (keyNum >= 11 && keyNum <= 20)
        {
            if (customFields == nil)
                customFields = [[NSMutableArray alloc] initWithCapacity:0];
            NSString * val = [appDelegate.serviceReport objectForKey:key];
            if (val != nil && ![val isKindOfClass:[NSNull class]])
                [customFields addObject:val];
        }
    }
    }@catch (NSException *exp) {
        NSLog(@"Exception Name PDFCreater :viewDidLoad %@",exp.name);
        NSLog(@"Exception Reason PDFCreater :viewDidLoad %@",exp.reason);
    }
    if (iOSObject == nil)
        iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];
    
    [activity startAnimating];
    
    backButton.enabled = NO;
    sendMailButton.enabled = YES;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths objectAtIndex:0];
    NSString * serviceReport = [appDelegate.wsInterface.tagsDictionary objectForKey:PDF_SERVICE_REPORT];
	saveFileName = [[NSString stringWithFormat:@"%@_%@.pdf",serviceReport, _wonumber] retain];
	newFilePath = [[saveDirectory stringByAppendingPathComponent:saveFileName] retain];
    NSLog(@"%@", newFilePath);
#ifdef DEBUG
    // ######################################### //
    // YIKES - REMOVE THIS CODE BEFORE DEPLOYING //
    createPDF = YES;
    // ######################################### //
#endif

    if (createPDF)
        [self CreatePDF];
    else
        [self showServiceReportForId:woId fileName:saveFileName];
    
    if (!calledFromSummary)
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    if(![Utility notIOS7])
    {
        [self moveAllSubviewDown:self.view];
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
}
- (void)moveAllSubviewDown:(UIView *)parentView {
    
    NSArray *allSubViews = [parentView subviews];
    for (int counter = 0; counter < [allSubViews count]; counter++) {
        
        UIView *childView = [allSubViews objectAtIndex:counter];
        CGRect childFrame = childView.frame;
        childFrame.origin.y = childFrame.origin.y+20;
        childView.frame = childFrame;
    }
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        NSLog(@"PDFCreator Internet Reachable");
    }
    else
    {
        NSLog(@"PDFCreator Internet Not Reachable");
        
        if (didRunOperation)
        {
            [activity stopAnimating];
            //[appDelegate displayNoInternetAvailable];  -- Shrinivas
            didRunOperation = NO;
        }
    }
}

- (void) CreatePDF
{
    [self CreatePDFFile:newFilePath];
    didRunOperation = YES;
 //   statusDescription.text = [appDelegate.wsInterface.tagsDictionary objectForKey:PDF_ATTACHING];
    statusDescription.text = [NSString stringWithFormat:@"%@%@", [appDelegate.wsInterface.tagsDictionary objectForKey:PDF_ATTACHING], _wonumber];
    [appDelegate.calDataBase insertPDFintoDB:newFilePath WithrecordId:_recordId apiName:appDelegate.sfmPageController.objectName WOnumber:_wonumber];
    
#ifdef DEBUG
//// YIKES REMOVE BEFORE DEPLOYING - AND UNCOMMENT THE FIRST LINE BELOW
    // [self removeAllPDF:saveFileName];
    backButton.enabled = YES;
    [activity stopAnimating];
    NSURL * _url = [NSURL fileURLWithPath:newFilePath];
    NSURLRequest * requestObj = [NSURLRequest requestWithURL:_url];
    [webView loadRequest:requestObj];
//// YIKES REMOVE BEFORE DEPLOYING
#else
    [self removeAllPDF:saveFileName];
#endif
	
	//Call Agressive data Sync.  -- 10/07/2012 #4740
	//RADHA Defect Fix 5542
	appDelegate.shouldScheduleTimer = YES;
	[appDelegate callDataSync];
}

- (void) removeAllPDF:(NSString *)pdf
{
//    NSString * _query = [NSString stringWithFormat:@"SELECT Id FROM Attachment WHERE Name = '%@' and OwnerId = '%@'", pdf, appDelegate.current_userId];
    
    NSString * _query = [NSString stringWithFormat:@"SELECT Id FROM Attachment WHERE Name = '%@'", pdf];
    
    didremovepdf = FALSE;
    didremoveallPdf = FALSE;
    
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetPDFList:error:context:) context:_query];
   while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES)) 
    {
#ifdef kPrintLogsDuringWebServiceCall
        NSLog(@"PDFCreator.m : removeAllPDF: ZKS call");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (didremovepdf && didremoveallPdf) 
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
    }
}

- (void) didGetPDFList:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    @try{
    for (int i = 0; i < [[result records] count]; i++)
    {
        [array addObject:[[[[result records] objectAtIndex:i] fields] objectForKey:@"Id"]];
    }
    if ([array count] > 0)
    {
        NSLog(@"1");
        didremoveallPdf = FALSE;
        [[ZKServerSwitchboard switchboard] delete:array target:self selector:@selector(didRemoveAllPDF:error:context:) context:nil];
       while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES)) 
        {
#ifdef kPrintLogsDuringWebServiceCall
            NSLog(@"PDFCreator.m : didGetPDFList: ZKS call");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                didremoveallPdf = TRUE;
                break;
            }
            if (didremoveallPdf) 
            {
                break;
            }
            if (appDelegate.connection_error)
            {
                break;
            }
        }

    }
    else
    {
        NSLog(@"2");
        didremoveallPdf = FALSE;
        [self didRemoveAllPDF:nil error:nil context:nil];
       while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES)) 
        {
#ifdef kPrintLogsDuringWebServiceCall
            NSLog(@"PDFCreator.m : didGetPDFList: ZKS call 2");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                didremoveallPdf = TRUE;
                break;
            }
            if (didremoveallPdf) 
            {
                break;
            }
            if (appDelegate.connection_error)
            {
                break;
            }
        }

    }
    
 }@catch (NSException *exp) {
        NSLog(@"Exception Name PDFCreator :didGetPDFList %@",exp.name);
        NSLog(@"Exception Reason PDFCreator :didGetPDFList %@",exp.reason);
    }
    
    // Analyser
 @finally {
    [array release];
    didremovepdf = TRUE;
  }
    
}

- (void) didRemoveAllPDF:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    didremoveallPdf = TRUE;
    return;
    //[self attachPDF:newFilePath];    //Please verify this it might be harmful Please
}
#pragma mark - attach
//Krishna OPDOC attach
- (void) attachOPDOC:(NSString *)opdoc andDocName:(NSString *)docName forSFId:(NSString *)sf_id andProcessId:(NSString *)processId {
    
    //krishna opdoc added signName
    ZKSObject * obj = [[ZKSObject alloc] initWithType:@"Attachment"];

    [obj setFieldValue:docName field:@"Name"];
    [obj setFieldValue:@"Work Order Output Doc" field:@"Description"];
    
    NSData * fileData = [NSData dataWithContentsOfFile:opdoc];
    NSString * fileString = [Base64 encode:fileData];
    
    [obj setFieldValue:fileString field:@"Body"];
    [obj setFieldValue:sf_id field:@"ParentId"];
    [obj setFieldValue:@"False" field:@"isPrivate"];
    
    NSArray * array = [[NSArray alloc] initWithObjects:obj, nil];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:sf_id forKey:@"SF_ID"];
    [dict setObject:processId forKey:@"ProcessID"];
    
    [[ZKServerSwitchboard switchboard] create:array target:self selector:@selector(didAttachDocument:error:context:) context:dict];
    
    // Analyser
    [dict release];
    [array release];
    [obj release];

}
- (void) didAttachDocument:(NSArray *)result error:(NSError *)error context:(id)context
{
    NSLog(@"Attach PDF successful");
    NSLog(@"%@", [error description]);
    NSLog(@"result %@",result);
    
    NSString *attachedResult = @"";
    NSArray *recordsArray = result;
    
    if([recordsArray count] > 0) {
    id someObj =  [recordsArray objectAtIndex:0];
    attachedResult = [someObj id];
    }
    NSDictionary *dictionary = (NSDictionary *)context;
    NSString *processId = [dictionary objectForKey:@"ProcessID"];
    NSString *sfID = [dictionary objectForKey:@"SF_ID"];
    
    //send delegate to the view controller. so that it can disable buttons.
    
    //krishna opdoc
    if(self.delegate && [self.delegate respondsToSelector:@selector(opDocumentAttached:withError:forSFID:andProcessID:)] ) {
        [self.delegate opDocumentAttached:attachedResult withError:error forSFID:sfID andProcessID:processId];
    }
    
    //disable buttons
}
- (void) attachPDF:(NSString *)pdf
{
    NSString * SFId = @"";
    ZKSObject * obj = [[ZKSObject alloc] initWithType:@"Attachment"];
    NSString * fileName = [pdf stringByDeletingLastPathComponent];
    fileName = [pdf substringFromIndex:[fileName length]+1];
    SFId = [appDelegate.calDataBase getSFIdForlocalId:fileName];
    
    [obj setFieldValue:fileName field:@"Name"];
    [obj setFieldValue:@"Work Order Service Report" field:@"Description"];
    
    NSData * fileData = [NSData dataWithContentsOfFile:pdf];
    NSString * fileString = [Base64 encode:fileData];
    
//	[obj setFieldValue:appDelegate.current_userId field:@"OwnerId"];
    [obj setFieldValue:fileString field:@"Body"];
    [obj setFieldValue:SFId field:@"ParentId"];     
    [obj setFieldValue:@"False" field:@"isPrivate"];
    
    NSArray * array = [[NSArray alloc] initWithObjects:obj, nil];
    
    [[ZKServerSwitchboard switchboard] create:array target:self selector:@selector(didAttachPDF:error:context:) context:nil];
    
    // Analyser
    [array release];
    [obj release];
}

- (void) didAttachPDF:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSLog(@"Attach PDF successful");
    NSLog(@"%@", [error description]);
      
    sendMailButton.enabled = YES;
    [self showServiceReportForId:woId fileName:saveFileName];
}

- (void) showServiceReportForId:(NSString *)woId fileName:(NSString *)_saveFileName
{
    statusDescription.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_RETRIEVING_SERVICE_REPORT];
    //Download the service report first
    [self getServiceReport:_saveFileName];
    
    if (sendMailButton.enabled)
    {
        // Display created pdf
        NSURL * _url = [NSURL fileURLWithPath:newFilePath];
        NSURLRequest * requestObj = [NSURLRequest requestWithURL:_url];
        [webView loadRequest:requestObj];
        
        statusDescription.text = _saveFileName;
    }
}

- (void) didQueryAttachmentForServiceReport:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
{
      didRunOperation = NO;
//    NSString * serviceMax = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE];
//    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];

    if ((result == nil) || ([[result records] count] == 0))
    {
        backButton.enabled = YES;
//        statusDescription.text = @"Service Report not found!";
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:@"Enter work details and generate the service report before accessing it here." delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
//        [alert show];
//        [alert release];
        [activity stopAnimating];
        return;
    }

    ZKSObject * obj = [[result records] objectAtIndex:0];
    NSString * dataString = [[obj fields] objectForKey:@"Body"];
    NSData * data = [Base64 decode:dataString];
    
    NSString * filename = [[obj fields] objectForKey:@"Name"];
    
    //Save file
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths objectAtIndex:0];
    
    newFilePath = [[saveDirectory stringByAppendingPathComponent:filename] retain];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:newFilePath contents:data attributes:nil];
    
    //Display created pdf
    NSURL * _url = [NSURL fileURLWithPath:newFilePath];
    NSURLRequest * requestObj = [NSURLRequest requestWithURL:_url];
    [webView loadRequest:requestObj];
    
    statusDescription.text = filename;
    
    backButton.enabled = YES;
    sendMailButton.enabled = YES;
    [activity stopAnimating];
}

- (void) getServiceReport:(NSString *)filename
{
    didRunOperation = YES;
    [iOSObject queryServiceReportForWorkOrderId:woId serviceReport:filename];
}

- (IBAction) sendMail
{
   /* if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    // Bring up interface to send mail
    [self mailServiceReport];
}

// Our method to create a PDF file natively on the iPhone
// This method takes two parameters, a CGRect for size and
// a const char, which will be the name of our pdf file
- (void) CreatePDFFile:(NSString *)filename
{	
    pageRect = CGRectMake(0, 0, 708, 944);
	// This code block sets up our PDF Context so that we can draw to it
	CFStringRef path;
	CFURLRef url;
	CFMutableDictionaryRef myDictionary = NULL;
    
    currentPoint = CGPointMake(newLineBuffer, kBoundaryBuffer + yBuffer);
	// Create a CFString from the filename we provide to this method when we call it
	path = CFStringCreateWithCString (NULL, [filename cStringUsingEncoding:NSUTF8StringEncoding],
									  kCFStringEncodingUTF8);
	// Create a CFURL using the CFString we just defined
	url = CFURLCreateWithFileSystemPath (NULL, path,
										 kCFURLPOSIXPathStyle, 0);
	// This dictionary contains extra options mostly for 'signing' the PDF
	myDictionary = CFDictionaryCreateMutable(NULL, 0,
											 &kCFTypeDictionaryKeyCallBacks,
											 &kCFTypeDictionaryValueCallBacks);
	
    CFDictionarySetValue (myDictionary, kCGPDFContextTitle, CFSTR("Service Report"));
	CFDictionarySetValue (myDictionary, kCGPDFContextCreator, CFSTR("ServiceMax"));
	
    // Create our PDF Context with the CFURL, the CGRect we provide, and the above defined dictionary
	pdfContext = CGPDFContextCreateWithURL (url, &pageRect, myDictionary);
	
    // Cleanup our mess
    CFRelease(myDictionary);
    CFRelease(url);
    CFRelease (path);
    
	// Done creating our PDF Context, now it's time to draw to it
	
	[self createMainPage];
    [self createPage];
	
	// We are done with our context now, so we release it
	CGContextRelease (pdfContext);
}

- (void) mailServiceReport
{
    BOOL canSendMail = [MFMailComposeViewController canSendMail];
    if (canSendMail)
    {
        MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setSubject:[NSString stringWithFormat:@"Service Report - %@", saveFileName]];
        
        // Attach the pdf to the mail
        NSData * data = [NSData dataWithContentsOfFile:newFilePath];
        [mailComposer addAttachmentData:data mimeType:@"application/pdf" fileName:saveFileName];
        [self presentViewController:mailComposer animated:YES completion:nil];
        [mailComposer release];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_EMAIL_ERROR] message:[appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_PLEASE_SET_UP_EMAIL_FIRST] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{ 
    // Notifies users about errors associated with the interface
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void) PDFPageBegin
{
	CGContextBeginPage (pdfContext, &pageRect);
    currentPoint = CGPointMake(xBuffer, kBoundaryBuffer + yBuffer);
}

- (void) PDFPageEnd
{
    CGContextEndPage (pdfContext);
}

- (void) createMainPage
{
    [self PDFPageBegin];
    
    // Set background color
    CGContextSetRGBFillColor(pdfContext, 255 , 255, 255, 1);
    CGContextFillRect(pdfContext, CGRectMake(0, 0, pageRect.size.width, pageRect.size.height));
    
    // Set header image
    [self setHeaderImage];
    [self setReportTitle];
    [self setServiceReportImage];   // This method now only sets the top seperator
    [self setWorkOrder:_wonumber];
    [self setDate:appDelegate.sfmPageController.activityDate];
    @try{
    if (appDelegate.addressType != nil && [appDelegate.addressType length] == 0)
    {
        // [self setAccount:_account];
    }
    else
    {
        if ([appDelegate.addressType isEqualToString:@"Account Bill To"])
        {
            NSDictionary * company = [self getObjectForKey:@"SVMXC__Company__c"];

            if ([company isKindOfClass:[NSDictionary class]])
            {
                _account = [NSArray arrayWithObjects:
                            [company objectForKey:@"BillingStreet"],
                            [company objectForKey:@"BillingCity"],
                            [company objectForKey:@"BillingState"],
                            [company objectForKey:@"BillingCountry"],
                            [company objectForKey:@"BillingPostalCode"], nil];
            }
        }
        else if ([appDelegate.addressType isEqualToString:@"Account Ship To"])
        {
            NSDictionary * company = [self getObjectForKey:@"SVMXC__Company__c"];                
            if ([company isKindOfClass:[NSDictionary class]])
            {
                _account = [NSArray arrayWithObjects:
                        [company objectForKey:@"ShippingStreet"],
                        [company objectForKey:@"ShippingCity"], 
                        [company objectForKey:@"ShippingState"], 
                        [company objectForKey:@"ShippingCountry"], 
                        [company objectForKey:@"ShippingPostalCode"], nil];
            }
        }
        else if ([appDelegate.addressType isEqualToString:@"Service Location"])
        {
            _account = [NSArray arrayWithObjects:
                        [reportEssentialsDict objectForKey:@"SVMXC__Street__c"], 
                        [reportEssentialsDict objectForKey:@"SVMXC__City__c"], 
                        [reportEssentialsDict objectForKey:@"SVMXC__State__c"], 
                        [reportEssentialsDict objectForKey:@"SVMXC__Country__c"], 
                        [reportEssentialsDict objectForKey:@"SVMXC__Zip__c"], nil];
        }
        else if ([appDelegate.addressType isEqualToString:@"Contact Address"])
        {
            NSDictionary * contact = [self getObjectForKey:@"SVMXC__Contact__c"];
            if ([contact isKindOfClass:[NSDictionary class]])
            {

                _account = [NSArray arrayWithObjects:
                        [contact objectForKey:@"MailingStreet"], 
                        [contact objectForKey:@"MailingState"],
                        [contact objectForKey:@"MailingPostalCode"], 
                        [contact objectForKey:@"MailingCountry"], 
                        [contact objectForKey:@"MailingCity"], nil];
            }
        }

        [self setAccount:_account];
    }

    NSString * contactName = [reportEssentialsDict objectForKey:@"Contact.Name"];
    
    if (![contactName isKindOfClass:[NSString class]])
        contactName = @"";
    [self setContact:contactName];
    
    NSString * contactPhone = [reportEssentialsDict objectForKey:@"Contact.Phone"];
    if (![contactPhone isKindOfClass:[NSString class]])
        contactPhone = @"";
    if (srShowContactPhone)
        [self setPhone:contactPhone];

    _description = [reportEssentialsDict objectForKey:@"SVMXC__Problem_Description__c"];
    if (![_description isKindOfClass:[NSString class]])
        _description = @"";
    if (srShowProblemDescription)
        [self setDescription:_description];

    _workPerformed = [reportEssentialsDict objectForKey:@"SVMXC__Work_Performed__c"];
    if (![_workPerformed isKindOfClass:[NSString class]])
        _workPerformed = @"";
    if (srShowWorkPerformed)
        [self setWorkPerformed:_workPerformed];

    if ([customFields count] > 0)
    {
        [self createCustomFields];
    }
    //Radha - Fix for the defect 6337
	[self setDetailsOfWorkPerformed];

    {
        [self setPartsImage];
        
        for (int i = 0; i < [_parts count]; i++)
        {
            NSLog(@"%@", [_parts objectAtIndex:i]);
       //     float linePrice = [[[_parts objectAtIndex:i] objectForKey:@"CostPerPart"] intValue];
       //     Abinash 28th december
            float linePrice = [[[_parts objectAtIndex:i] objectForKey:@"CostPerPart"] floatValue];
            linePrice *= [[[_parts objectAtIndex:i] objectForKey:@"PartsUsed"] floatValue];
            linePrice *= (1 - ([[[_parts objectAtIndex:i] objectForKey:@"Discount"] floatValue]/100));
            {
                NSDictionary * obj = [_parts objectAtIndex:i];
                NSString * discount = [obj valueForKey:@"Discount"];
                
                /* 6773 */
                NSString *quantity = @"";
                float linePriceFinal = 0.0;
                
                if (self.shouldShowBillablePrice) {
                    linePriceFinal =  [[[_parts objectAtIndex:i] objectForKey:SVMXC__Billable_Line_Price__c] floatValue];
                    
                }
                else {
                    linePriceFinal = linePrice;
                }
                
                if (self.shouldShowBillableQty) {
                    quantity = [[_parts objectAtIndex:i] objectForKey:SVMXC__Billable_Quantity__c];
                }
                else {
                    quantity = [[_parts objectAtIndex:i] objectForKey:@"PartsUsed"];
                }
                
                /*  ends 6773 */
                
                if (srShowLinePrice && srShowDiscount)
                {
                    [self writePartsNo:[NSString stringWithFormat:@"%d.", i+1]
                                  part:[[_parts objectAtIndex:i] objectForKey:@"Name"]
                                   qty:quantity
                             unitprice:[[_parts objectAtIndex:i] objectForKey:@"CostPerPart"]
                             lineprice:[NSString stringWithFormat:@"%.2f", linePriceFinal] 
                              discount:discount
                     ];
                }
                else if (srShowLinePrice && !srShowDiscount)
                {
                    [self writePartsNo:[NSString stringWithFormat:@"%d.", i+1]
                                  part:[[_parts objectAtIndex:i] objectForKey:@"Name"]
                                   qty:quantity
                             unitprice:[[_parts objectAtIndex:i] objectForKey:@"CostPerPart"]
                             lineprice:[NSString stringWithFormat:@"%.2f", linePriceFinal]
                     ];
                }
                else if (!srShowLinePrice && srShowDiscount)
                {
                    [self writePartsNo:[NSString stringWithFormat:@"%d.", i+1]
                                  part:[[_parts objectAtIndex:i] objectForKey:@"Name"]
                                   qty:[[_parts objectAtIndex:i] objectForKey:@"PartsUsed"]
                             unitprice:[[_parts objectAtIndex:i] objectForKey:@"CostPerPart"]
                             lineprice:discount
                     ];
                }
                else
                {
                    [self writePartsNo:[NSString stringWithFormat:@"%d.", i+1]
                                  part:[[_parts objectAtIndex:i] objectForKey:@"Name"]
                                   qty:quantity
                             unitprice:nil
                             lineprice:[NSString stringWithFormat:@"%.2f", linePriceFinal]
                     ];
                    
                }
            }
        }
    }

    {
        [self setLaborImage];
        for (int j = 0; j < [_labor count]; j++)
        {
            NSDictionary * labor = [_labor objectAtIndex:j];
            NSLog(@"%@", labor);
            NSString * tLabor, * tHours, * tRate, * tLinePrice;

            tLabor = [labor objectForKey:SVMXC__Activity_Type__c];
            tHours = [labor objectForKey:SVMXC__Actual_Quantity2__c];
            if (![tHours isKindOfClass:[NSString class]])
                tHours = @"0.0";
            tRate = [labor objectForKey:SVMXC__Actual_Price2__c];
            if (![tRate isKindOfClass:[NSString class]])
                tRate = @"0.0";
            
            //pavaman 16th Jan 2011
            tLinePrice = [NSString stringWithFormat:@"%.2f", [tHours floatValue]*[tRate floatValue]];
            
            /* 6773 */
            if (self.shouldShowBillablePrice) {
                double someValue = [[labor objectForKey:SVMXC__Billable_Line_Price__c] doubleValue];
                tLinePrice = [NSString stringWithFormat:@"%.2f", someValue];
            }
            
            /* 6773 */
            if (self.shouldShowBillableQty) {
                tHours = [labor objectForKey:SVMXC__Billable_Quantity__c];
                if (![tHours isKindOfClass:[NSString class]])
                    tHours = @"0.0";
            }
            [self writePartsNo:[NSString stringWithFormat:@"%d.", j+1]
                          part:tLabor
                           qty:tHours
                     unitprice:tRate
                     lineprice:tLinePrice
             ];

        }
    }

    {
        [self setExpenseImage];
        for (int k = 0; k < [_expenses count]; k++)
        {
            NSDictionary * expenses = [_expenses objectAtIndex:k];
            NSLog(@"%@", expenses);
            
            NSString * expenseType = [expenses objectForKey:@"SVMXC__Expense_Type__c"];
            if (![expenseType isKindOfClass:[NSString class]])
                expenseType = @"";
            
            NSString * actualPrice = [expenses objectForKey:@"SVMXC__Actual_Price2__c"];
            if (![actualPrice isKindOfClass:[NSString class]])
                actualPrice = @"0.0";
            NSString * expenseQty = [expenses objectForKey:@"SVMXC__Actual_Quantity2__c"];
            if (![expenseQty isKindOfClass:[NSString class]])
                expenseQty = @"0";
            
            float actual_Price = [actualPrice floatValue] * [expenseQty floatValue];
            actualPrice = [NSString stringWithFormat:@"%.2f", actual_Price];
            
            if (![actualPrice isKindOfClass:[NSString class]])
                actualPrice = @"0.0";
            
            /* 6773 */
            if (self.shouldShowBillablePrice) {
                double someDoubleValue =  [[expenses objectForKey:SVMXC__Billable_Line_Price__c] doubleValue];
                actualPrice = [NSString stringWithFormat:@"%.2f", someDoubleValue];
            }
            if ([expenseType isEqualToString:@"Airfare"])
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:@"Airfare"
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                 ];
            }
            else if ([expenseType isEqualToString:@"Food - Breakfast"])
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:@"Food - Breakfast"
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                 ];
            }
            else if ([expenseType isEqualToString:@"Food - Dinner"])
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:@"Food - Dinner"
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                 ];
            }
            else if ([expenseType isEqualToString:@"Lodging"])
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:@"Lodging"
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                 ];
            }
            else if ([expenseType isEqualToString:@"Parking"])
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:@"Parking"
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                 ];
            }
            else if ([expenseType isEqualToString:@"Entertainment"])
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:@"Entertainment"
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                 ];
            }
            else if ([expenseType isEqualToString:@"Food - Lunch"])
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:@"Food - Lunch"
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                 ];
            }
            else if ([expenseType isEqualToString:@"Gas"])
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:@"Gas"
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                 ];
            }
            else if ([expenseType isEqualToString:@"Mileage"])
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:@"Mileage"
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                 ];
            }
            else if ([expenseType isEqualToString:@"Parts"])
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:@"Parts"
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                ];
            }
            else
            {
                [self writePartsNo:[NSString stringWithFormat:@"%d.", k+1]
                              part:expenseType
                               qty:@""
                         unitprice:@""
                         lineprice:actualPrice
                 ];
            }
        }
    }
        
        NSLog(@"travel array %d",[travelArray count]);
        if([travelArray count] >0) {
            [self setTravelImage];
        }
        for (int t = 0; t < [travelArray count]; t++)
        {
            NSLog(@"%@", [travelArray objectAtIndex:t]);
        
            float linePrice = [[[travelArray objectAtIndex:t] objectForKey:@"SVMXC__Actual_Price2__c"] floatValue];
            linePrice *= [[[travelArray objectAtIndex:t] objectForKey:@"SVMXC__Actual_Quantity2__c"] floatValue];
           
            
            
            NSDictionary * obj = [travelArray objectAtIndex:t];
            
            
            if (self.shouldShowBillablePrice) {
                linePrice = [[obj objectForKey:SVMXC__Billable_Line_Price__c] floatValue];
            }
           
            NSString *quantity = nil;
            
            if (self.shouldShowBillableQty) {
                quantity = [obj objectForKey:SVMXC__Billable_Quantity__c];
            }
            else {
                quantity = [[travelArray objectAtIndex:t] objectForKey:@"SVMXC__Actual_Quantity2__c"];
            }
            
            NSString *unitPrice = [[travelArray objectAtIndex:t] objectForKey:@"SVMXC__Actual_Price2__c"];
            if (unitPrice == nil) {
                unitPrice = @"0.0";
            }
            
            [self writePartsNo:[NSString stringWithFormat:@"%d.", t+1]
                                  part:[[travelArray objectAtIndex:t] objectForKey:@"Name"]
                                   qty:quantity
                             unitprice:unitPrice
                             lineprice:[NSString stringWithFormat:@"%.2f", linePrice]
                              discount:nil
                     ];
        }
	}
 @catch (NSException *exp) {
	NSLog(@"Exception Name PDFCreator :createMainPage %@",exp.name);
	NSLog(@"Exception Reason PDFCreator :createMainPage %@",exp.reason);
    }

}

- (NSDictionary *) getObjectForKey:(NSString *)key
{
	@try{
    for (NSDictionary * dict in reportEssentials)
    {
        NSArray * allkeys = [dict allKeys];
        
        if ([allkeys count] == 1)
        {
            if ([[allkeys objectAtIndex:0] isEqualToString:key])
                return [dict objectForKey:key];
        }
    }
	}@catch (NSException *exp) {
	NSLog(@"Exception Name PDFCreator :getObjectForKey %@",exp.name);
	NSLog(@"Exception Reason PDFCreator :getObjectForKey %@",exp.reason);
    }

    return nil;
}

- (NSString*) getValueFromDisplayValue:(NSString *)displayValue
{
    NSString * value = @"";    
    NSString * internalValue = @"";
    @try{
    for (int i = 0; i < [appDelegate.serviceReportValueMapping count]; i++)
    {
        NSDictionary * dict = [appDelegate.serviceReportValueMapping objectAtIndex:i];
        NSArray * allKeys = [dict allKeys];
        NSString * key = [allKeys objectAtIndex:0];
        if ([key isKindOfClass:[NSNull class]])
            key = @"";
        if ([key isEqualToString:displayValue])
        {
            internalValue = [dict objectForKey:key];
            if ([internalValue isKindOfClass:[NSNull class]])
                internalValue = @"";
            break;
        }
    }
	}@catch (NSException *exp) {
	NSLog(@"Exception Name PDFCreator :getValueFromDisplayValue %@",exp.name);
	NSLog(@"Exception Reason PDFCreator :getValueFromDisplayValue %@",exp.reason);
    }

    NSArray * _array = [internalValue componentsSeparatedByString:@"."];
    if ([_array count] == 2)
    {
        value = [appDelegate.calDataBase getFieldValueFromTable:displayValue];
        
        if (([value length] > 0) && value != nil)
        {
            NSString * tableNmae = [appDelegate.calDataBase getTableName:displayValue];
            
            NSString * api_name = [appDelegate.dataBase getApiNameForNameField:tableNmae];
            
            NSString * name = [appDelegate.dataBase getReferenceObjectNameForPdf:tableNmae Field:api_name Id:value];
            
            if ([name length] == 0)
            {
                NSString * field_value = [appDelegate.calDataBase getValueFromLookupwithId:value];
                if ([field_value length] > 0)
                    value = field_value;
                    
            }
            else 
                value = name;
        }
        
        return value;
               
    }
    else 
    {
        value = [appDelegate.calDataBase getFieldValueFromTable:displayValue];
        return value;
    }
    
    return @"";
}

#pragma mark -
#pragma mark Custom Fields - Begin
- (void) createCustomFields
{
    [self drawHorizontalLine];
    
    CGSize customTextSize = CGSizeZero;
    CGPoint startingPoint = currentPoint;
    
    BOOL isWorkinginOFFline = TRUE;
    @try{
    if(isWorkinginOFFline)
    {
        
        
        for (int i = 0; i < [customFields count]; i++)
        {
            for (int j = 0; j < [appDelegate.WorkDescription  count]; j++)
            {
                NSMutableDictionary * dict = [appDelegate.WorkDescription objectAtIndex:j];
                
                if ([[customFields objectAtIndex:i] isEqualToString:[dict objectForKey:@"api_name"]])
                {
                   // NSLog(@"%@ :: %@ (%@) -> %@", [field name], [field label], [field type], [reportEssentialsDict objectForKey:[field name]]);
                    
                    CGContextSelectFont (pdfContext, "Verdana-Bold", 14, kCGEncodingMacRoman);
                    CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
                    CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
                    
                    //                    NSString * workOrderDetailText = [self getValueFromDisplayValue:[field name]];
                    //                    if (workOrderDetailText == nil || [workOrderDetailText isKindOfClass:[NSNull class]])
                    //                        workOrderDetailText = @"";
                    NSString * _text = [dict objectForKey:@"label"];
                    
                    _text = [NSString stringWithUTF8String:[_text UTF8String]];
                    _text = [_text stringByAppendingFormat:@":"];
                    
                    CGSize _textSize = [_text sizeWithFont:[UIFont fontWithName:@"Verdana-Bold" size:14]];
                    if (_textSize.width > customTextSize.width)
                        customTextSize = _textSize;
                }
            }
        }
        for (int i = 0; i < [customFields count]; i++)
        {
            for (int j = 0; j < [appDelegate.WorkDescription count]; j++)
            {
                NSMutableDictionary *  dict = [appDelegate.WorkDescription objectAtIndex:j];
                CGPoint memoryPoint = currentPoint;
                if ([[customFields objectAtIndex:i] isEqualToString:[dict objectForKey:@"api_name"]])
                {
                   // NSLog(@"%@ :: %@ (%@) -> %@", [field name], [field label], [field type], [reportEssentialsDict objectForKey:[field name]]);
                    
                    CGContextSelectFont (pdfContext, "Verdana-Bold", 14, kCGEncodingMacRoman);
                    CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
                    CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
                    
                    NSString * workOrderDetailText = [self getValueFromDisplayValue:[dict objectForKey:@"api_name"]];
                    if (workOrderDetailText == nil || [workOrderDetailText isKindOfClass:[NSNull class]])
                        workOrderDetailText = @"";
                    NSString * _text = [dict objectForKey:@"label"];
                    
                    _text = [NSString stringWithUTF8String:[_text UTF8String]];
                    _text = [_text stringByAppendingFormat:@":"];
                    
                    char *text = (char *)[_text cStringUsingEncoding:NSUTF8StringEncoding];
                    
                    // Calculate dimensions of text based on text font properties
                    UIFont * font = [UIFont fontWithName:@"Verdana-Bold" size:14];
                    CGSize textSize = [[dict objectForKey:@"label"] sizeWithFont:font];
                    
                    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y, text, strlen(text));
                    
                    currentPoint = CGPointMake(currentPoint.x + textSize.width + spaceBuffer / 2, currentPoint.y);
                    
                    if ([[dict objectForKey:@"type"] isEqualToString:@"boolean"])
                    {
                        BOOL boolVal = [[reportEssentialsDict objectForKey:[dict objectForKey:@"api_name"]] boolValue];
                        if (boolVal)
                        {
                            // Draw true image here
                            [self setBOOLImage:YES atXLocation:(startingPoint.x + customTextSize.width)];
                        }
                        else if (!boolVal)
                        {
                            // Draw flase image here
                            [self setBOOLImage:NO atXLocation:(startingPoint.x + customTextSize.width)];
                        }
                        else
                            [self newLine:16];
                    }
                    else if ([[dict objectForKey:@"type"] isEqualToString:@"date"])
                    {
                        NSDateFormatter * _dateFormatter = [[NSDateFormatter alloc] init];
                        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate * dt = [_dateFormatter dateFromString:[reportEssentialsDict objectForKey:[dict objectForKey:@"api_name"]]];
                        [_dateFormatter setDateFormat:@"EEE, dd MMM yyyy"];
                        NSString * currDate = [_dateFormatter stringFromDate:dt];
                        
                        if ((currDate == nil) || ([currDate length] == 0) || [workOrderDetailText length] == 0)
                            text = "";
                        else
                            text = (char *)[[NSString stringWithFormat:@"%@", currDate] cStringUsingEncoding:NSUTF8StringEncoding];
                        
                        font = [UIFont fontWithName:@"Verdana" size:12];
                        textSize = [[NSString stringWithFormat:@"%@", currDate] sizeWithFont:font];
                        
                        CGContextSelectFont (pdfContext, "Verdana", 12, kCGEncodingMacRoman);
                        
                        CGContextShowTextAtPoint (pdfContext, (startingPoint.x + customTextSize.width) + spaceBuffer, pageRect.size.height-currentPoint.y, text, strlen(text));
                        
                        [_dateFormatter release];
                        
                        [self newLine:(textSize.height > 0)?textSize.height:16];
                        
                        if (currentPoint.y > 850)
                        {
                            [self PDFPageEnd];
                            [self PDFPageBegin];
                        }
                        
                    }
                    else if ([[dict objectForKey:@"type"] isEqualToString:@"datetime"])
                    {
                        NSString * _dateStr = [reportEssentialsDict objectForKey:[dict objectForKey:@"api_name"]];
                        if ([_dateStr isKindOfClass:[NSNull class]])
                            _dateStr = @"";
                        NSString * dateStr = [_dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                        dateStr = [dateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                        dateStr = [dateStr stringByDeletingPathExtension];
                        
                        DateTimeFormatter * dtf = [[[DateTimeFormatter alloc] init] autorelease];
                        NSString * currDate = [dtf getReadableDateFromDate:dateStr];
                        
                        if ((currDate == nil) || ([currDate length] == 0) || [dateStr length] == 0)
                            text = "";
                        else
                            text = (char *)[[NSString stringWithFormat:@"%@", currDate] cStringUsingEncoding:NSUTF8StringEncoding];
                        
                        font = [UIFont fontWithName:@"Verdana" size:12];
                        textSize = [[NSString stringWithFormat:@"%@", currDate] sizeWithFont:font];
                        
                        CGContextSelectFont (pdfContext, "Verdana", 12, kCGEncodingMacRoman);
                        
                        CGContextShowTextAtPoint (pdfContext, (startingPoint.x + customTextSize.width) + spaceBuffer, pageRect.size.height-currentPoint.y, text, strlen(text));
                        
                        [self newLine:(textSize.height > 0)?textSize.height:16];
                        
                        if (currentPoint.y > 850)
                        {
                            [self PDFPageEnd];
                            [self PDFPageBegin];
                        }
                    }
                    else if ([[dict objectForKey:@"type"] isEqualToString:@"longtext"] || [[dict objectForKey:@"type"] isEqualToString:@"textarea"])
                    {
                        const char *text = (char *)[[NSString stringWithFormat:@"%@", [reportEssentialsDict objectForKey:[dict objectForKey:@"api_name"]]] cStringUsingEncoding:NSUTF8StringEncoding];
                        CGSize maxsize;
                        maxsize.height = 44*100;
                        maxsize.width = 600;
                        UIFont * font = [UIFont fontWithName:FONTNAME size:12];
                        NSString *wfText = [NSString stringWithUTF8String:text];
                        CGSize textsize = [wfText sizeWithFont:font constrainedToSize:maxsize];
                        
                        UITextView * wp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, pageRect.size.width - startingPoint.x - customTextSize.width, textsize.height + 30)];
                        [wp setBackgroundColor:[UIColor clearColor]];
                        wp.font = font;
                        wp.text = wfText;
                        UIGraphicsBeginImageContext(wp.bounds.size);
                        CALayer *layer = [wp layer];
                        
                        CGContextRef current_ctx = UIGraphicsGetCurrentContext();
                        [layer renderInContext:current_ctx];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        NSLog(@"%f, %f", currentPoint.x, currentPoint.y);
                        
                        CGRect imageRect = CGRectMake((startingPoint.x + customTextSize.width), pageRect.size.height-currentPoint.y-image.size.height+2*newLineBuffer+6, image.size.width, image.size.height);
                        CGContextDrawImage(pdfContext, imageRect, [image CGImage]);
                        [wp release];
                        
                        [self newLine:image.size.height];
                        
                        if (currentPoint.y > 850)
                        {
                            [self PDFPageEnd];
                            [self PDFPageBegin];
                        }
                    }
                    else
                    {
                        NSString * fieldName = [dict objectForKey:@"api_name"];
                        NSString * str = [self getValueFromDisplayValue:fieldName]; // [reportEssentialsDict objectForKey:fieldName];
                        if (![str isKindOfClass:[NSString class]])
                            str = @"";
                        text = (char *)[[NSString stringWithFormat:@"%@", str] cStringUsingEncoding:NSUTF8StringEncoding];
                        
                        font = [UIFont fontWithName:@"Verdana" size:12];
                        textSize = [[NSString stringWithFormat:@"%@", workOrderDetailText] sizeWithFont:font];
                        
                        CGContextSelectFont (pdfContext, "Verdana", 12, kCGEncodingMacRoman);
                        
                        CGContextShowTextAtPoint (pdfContext, (startingPoint.x + customTextSize.width) + spaceBuffer, pageRect.size.height-currentPoint.y, text, strlen(text));
                        
                        [self newLine:(textSize.height > 0)?textSize.height:16];
                        
                        if (currentPoint.y > 850)
                        {
                            [self PDFPageEnd];
                            [self PDFPageBegin];
                        }
                    }
                }
                
                // reset current point
                currentPoint = CGPointMake(memoryPoint.x, currentPoint.y);
            }
        }
    }


    
     else
    {
        // Find the maximum length of the custom labels
        {
            for (int i = 0; i < [customFields count]; i++)
            {
                for (int j = 0; j < [[appDelegate.workOrderDescription fields] count]; j++)
                {
                    ZKDescribeField * field = [[appDelegate.workOrderDescription fields] objectAtIndex:j];
                    if ([[customFields objectAtIndex:i] isEqualToString:[field name]])
                    {
                        NSLog(@"%@ :: %@ (%@) -> %@", [field name], [field label], [field type], [reportEssentialsDict objectForKey:[field name]]);
                        
                        CGContextSelectFont (pdfContext, "Verdana-Bold", 14, kCGEncodingMacRoman);
                        CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
                        CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
                        
    //                    NSString * workOrderDetailText = [self getValueFromDisplayValue:[field name]];
    //                    if (workOrderDetailText == nil || [workOrderDetailText isKindOfClass:[NSNull class]])
    //                        workOrderDetailText = @"";
                        NSString * _text = [field label];
                        
                        _text = [NSString stringWithUTF8String:[_text UTF8String]];
                        _text = [_text stringByAppendingFormat:@":"];
                        
                        CGSize _textSize = [_text sizeWithFont:[UIFont fontWithName:@"Verdana-Bold" size:14]];
                        if (_textSize.width > customTextSize.width)
                            customTextSize = _textSize;
                    }
                }
            }
            
        }
        
        for (int i = 0; i < [customFields count]; i++)
        {
            for (int j = 0; j < [[appDelegate.workOrderDescription fields] count]; j++)
            {
                ZKDescribeField * field = [[appDelegate.workOrderDescription fields] objectAtIndex:j];
                CGPoint memoryPoint = currentPoint;
                if ([[customFields objectAtIndex:i] isEqualToString:[field name]])
                {
                    NSLog(@"%@ :: %@ (%@) -> %@", [field name], [field label], [field type], [reportEssentialsDict objectForKey:[field name]]);
                    
                    CGContextSelectFont (pdfContext, "Verdana-Bold", 14, kCGEncodingMacRoman);
                    CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
                    CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
                    
                    NSString * workOrderDetailText = [self getValueFromDisplayValue:[field name]];
                    if (workOrderDetailText == nil || [workOrderDetailText isKindOfClass:[NSNull class]])
                        workOrderDetailText = @"";
                    NSString * _text = [field label];
                    
                    _text = [NSString stringWithUTF8String:[_text UTF8String]];
                    _text = [_text stringByAppendingFormat:@":"];
                    
                    char *text = (char *)[_text cStringUsingEncoding:NSUTF8StringEncoding];
                    
                    // Calculate dimensions of text based on text font properties
                    UIFont * font = [UIFont fontWithName:@"Verdana-Bold" size:14];
                    CGSize textSize = [[field label] sizeWithFont:font];
                    
                    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y, text, strlen(text));

                    currentPoint = CGPointMake(currentPoint.x + textSize.width + spaceBuffer / 2, currentPoint.y);

                    if ([[field type] isEqualToString:@"boolean"])
                    {
                        BOOL boolVal = [[reportEssentialsDict objectForKey:[field name]] boolValue];
                        if (boolVal)
                        {
                            // Draw true image here
                            [self setBOOLImage:YES atXLocation:(startingPoint.x + customTextSize.width)];
                        }
                        else if (!boolVal)
                        {
                            // Draw flase image here
                            [self setBOOLImage:NO atXLocation:(startingPoint.x + customTextSize.width)];
                        }
                        else
                            [self newLine:16];
                    }
                    else if ([[field type] isEqualToString:@"date"])
                    {
                        NSDateFormatter * _dateFormatter = [[NSDateFormatter alloc] init];
                        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate * dt = [_dateFormatter dateFromString:[reportEssentialsDict objectForKey:[field name]]];
                        [_dateFormatter setDateFormat:@"EEE, dd MMM yyyy"];
                        NSString * currDate = [_dateFormatter stringFromDate:dt];
                        
                        if ((currDate == nil) || ([currDate length] == 0) || [workOrderDetailText length] == 0)
                            text = "";
                        else
                            text = (char *)[[NSString stringWithFormat:@"%@", currDate] cStringUsingEncoding:NSUTF8StringEncoding];
                        
                        font = [UIFont fontWithName:@"Verdana" size:12];
                        textSize = [[NSString stringWithFormat:@"%@", currDate] sizeWithFont:font];
                        
                        CGContextSelectFont (pdfContext, "Verdana", 12, kCGEncodingMacRoman);
                        
                        CGContextShowTextAtPoint (pdfContext, (startingPoint.x + customTextSize.width) + spaceBuffer, pageRect.size.height-currentPoint.y, text, strlen(text));
                        
                        [_dateFormatter release];
                        
                        [self newLine:(textSize.height > 0)?textSize.height:16];
                        
                        if (currentPoint.y > 850)
                        {
                            [self PDFPageEnd];
                            [self PDFPageBegin];
                        }
                        
                    }
                    else if ([[field type] isEqualToString:@"datetime"])
                    {
                        NSString * _dateStr = [reportEssentialsDict objectForKey:[field name]];
                        if ([_dateStr isKindOfClass:[NSNull class]])
                            _dateStr = @"";
                        NSString * dateStr = [_dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                        dateStr = [dateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                        dateStr = [dateStr stringByDeletingPathExtension];

                        DateTimeFormatter * dtf = [[[DateTimeFormatter alloc] init] autorelease];
                        NSString * currDate = [dtf getReadableDateFromDate:dateStr];
                        
                        if ((currDate == nil) || ([currDate length] == 0) || [dateStr length] == 0)
                            text = "";
                        else
                            text = (char *)[[NSString stringWithFormat:@"%@", currDate] cStringUsingEncoding:NSUTF8StringEncoding];
                        
                        font = [UIFont fontWithName:@"Verdana" size:12];
                        textSize = [[NSString stringWithFormat:@"%@", currDate] sizeWithFont:font];
                        
                        CGContextSelectFont (pdfContext, "Verdana", 12, kCGEncodingMacRoman);
                        
                        CGContextShowTextAtPoint (pdfContext, (startingPoint.x + customTextSize.width) + spaceBuffer, pageRect.size.height-currentPoint.y, text, strlen(text));
                        
                        [self newLine:(textSize.height > 0)?textSize.height:16];
                        
                        if (currentPoint.y > 850)
                        {
                            [self PDFPageEnd];
                            [self PDFPageBegin];
                        }
                    }
                    else if ([[field type] isEqualToString:@"longtext"] || [[field type] isEqualToString:@"textarea"])
                    {
                        const char *text = (char *)[[NSString stringWithFormat:@"%@", [reportEssentialsDict objectForKey:[field name]]] cStringUsingEncoding:NSUTF8StringEncoding];
                        CGSize maxsize;
                        maxsize.height = 44*100;
                        maxsize.width = 600;
                        UIFont * font = [UIFont fontWithName:FONTNAME size:12];
                        NSString *wfText = [NSString stringWithUTF8String:text];
                        CGSize textsize = [wfText sizeWithFont:font constrainedToSize:maxsize];
                        
                        UITextView * wp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, pageRect.size.width - startingPoint.x - customTextSize.width, textsize.height + 30)];
                        [wp setBackgroundColor:[UIColor clearColor]];
                        wp.font = font;
                        wp.text = wfText;
                        UIGraphicsBeginImageContext(wp.bounds.size);
                        CALayer *layer = [wp layer];

                        CGContextRef current_ctx = UIGraphicsGetCurrentContext();
                        [layer renderInContext:current_ctx];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        NSLog(@"%f, %f", currentPoint.x, currentPoint.y);
                        
                        CGRect imageRect = CGRectMake((startingPoint.x + customTextSize.width), pageRect.size.height-currentPoint.y-image.size.height+2*newLineBuffer+6, image.size.width, image.size.height);
                        CGContextDrawImage(pdfContext, imageRect, [image CGImage]);
                        [wp release];
                        
                        [self newLine:image.size.height];
                        
                        if (currentPoint.y > 850)
                        {
                            [self PDFPageEnd];
                            [self PDFPageBegin];
                        }
                    }
                    else
                    {
                        NSString * fieldName = [field name];
                        NSString * str = [self getValueFromDisplayValue:fieldName]; // [reportEssentialsDict objectForKey:fieldName];
                        if (![str isKindOfClass:[NSString class]])
                            str = @"";
                        text = (char *)[[NSString stringWithFormat:@"%@", str] cStringUsingEncoding:NSUTF8StringEncoding];
                        
                        font = [UIFont fontWithName:@"Verdana" size:12];
                        textSize = [[NSString stringWithFormat:@"%@", workOrderDetailText] sizeWithFont:font];
                        
                        CGContextSelectFont (pdfContext, "Verdana", 12, kCGEncodingMacRoman);
                        
                        CGContextShowTextAtPoint (pdfContext, (startingPoint.x + customTextSize.width) + spaceBuffer, pageRect.size.height-currentPoint.y, text, strlen(text));
                        
                        [self newLine:(textSize.height > 0)?textSize.height:16];
                        
                        if (currentPoint.y > 850)
                        {
                            [self PDFPageEnd];
                            [self PDFPageBegin];
                        }
                    }
                }
                
                // reset current point
                currentPoint = CGPointMake(memoryPoint.x, currentPoint.y);
            }
        }
    }
	}@catch (NSException *exp) {
    NSLog(@"Exception Name PDFCreator :createCustomFields %@",exp.name);
    NSLog(@"Exception Reason PDFCreator :createCustomFields %@",exp.reason);
    }

}

- (void) setBOOLImage:(BOOL)flag atXLocation:(CGFloat)location
{
    char *picture = 0;
    
    if (flag)
        picture = "tick";
    else
        picture = "cross";

	CGImageRef image;
    CGDataProviderRef provider;
    CFStringRef picturePath;
    CFURLRef pictureURL;
	
    picturePath = CFStringCreateWithCString (NULL, picture, kCFStringEncodingUTF8);
    pictureURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), picturePath, CFSTR("png"), NULL);
    CFRelease(picturePath);
    if (pictureURL != nil)
    {
        provider = CGDataProviderCreateWithURL (pictureURL);
        CFRelease (pictureURL);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease (provider);
        CGRect rect = CGRectMake(location + spaceBuffer, pageRect.size.height-currentPoint.y, CGImageGetWidth(image), CGImageGetHeight(image));
        CGContextDrawImage (pdfContext, rect, image);
        
        [self newLine:CGImageGetHeight(image)];
        // Analyser
        CGImageRelease (image);
    }
}

#pragma mark -

- (void) createPage
{
    // Set signature image
    [self setSignatureImage];
    
    // [self setSignatureImage:pdfContext inPage:pageRect];
    [self setSignature];
    
    [self setTotalCost:_totalCost];
    
    // We are done drawing to this page, let's end it
	// We could add as many pages as we wanted using CGContextBeginPage/CGContextEndPage
	[self PDFPageEnd];
}

- (void) setHeaderImage
{
    // This code block will create an image that we then draw to the page
	// const char *picture = "customer_signature";
    CGImageRef image;
    CGDataProviderRef provider;

//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *saveDirectory = [paths objectAtIndex:0];
//
//    NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"header_image.png"];
	NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString * filePath = [self getLogoFromDatabase];
    
    BOOL retVal = [fileManager fileExistsAtPath:filePath];
    // if (pictureURL != nil)
    if (retVal)
    {
//        CFRelease (pictureURL);
        
        provider = CGDataProviderCreateWithFilename([filePath UTF8String]);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGContextDrawImage (pdfContext, CGRectMake(pageRect.size.width/2-(CGImageGetWidth(image)/2), pageRect.size.height-(kBoundaryBuffer/2)-CGImageGetHeight(image), CGImageGetWidth(image), CGImageGetHeight(image)), image);
        // CGDataProviderRelease(provider);
     
        [self newLine:CGImageGetHeight(image)];
        // CGImageRelease (image);
    }
    
    NSError *delete_error;
	if ([fileManager fileExistsAtPath:filePath] == YES)
	{
		[fileManager removeItemAtPath:filePath error:&delete_error];		
	}
    
}


//RADHA - servicereportlogo
- (NSString *) getLogoFromDatabase
{
    
    NSString * query = [NSString stringWithFormat:@"SELECT logo FROM servicereprt_logo"];
    
    sqlite3_stmt * stmt;
    
    NSString * imageData = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
       while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
       {
           char * data = (char *)synchronized_sqlite3_column_text(stmt, 0);
           
           if ((data != nil) && strlen(data))
           {
               imageData = [NSString stringWithUTF8String:data];
           }
           
       }
        
    }
    
    synchronized_sqlite3_finalize(stmt);
	@try{
    if ([imageData length] > 0)
    {
        NSData * data = [Base64 decode:imageData];
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *saveDirectory = [paths objectAtIndex:0];	
        NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"header_image.png"];
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
        
        return filePath;

    }
	}@catch (NSException *exp) {
	NSLog(@"Exception Name PDFCreator :getLogoFromDatabase %@",exp.name);
	NSLog(@"Exception Reason PDFCreator :getLogoFromDatabase %@",exp.reason);
    }

    return @"";
}


- (void) setServiceReportImage
{
    // This code block will create an image that we then draw to the page
    
    // draw the seperator first
	const char *picture = "seperator";
	CGImageRef image;
    CGDataProviderRef provider;
    CFStringRef picturePath;
    CFURLRef pictureURL;
	
    picturePath = CFStringCreateWithCString (NULL, picture, kCFStringEncodingUTF8);
    pictureURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), picturePath, CFSTR("png"), NULL);
    CFRelease(picturePath);
    if (pictureURL != nil)
    {
        provider = CGDataProviderCreateWithURL (pictureURL);
        CFRelease (pictureURL);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease (provider);
        CGContextDrawImage (pdfContext, CGRectMake(pageRect.size.width/2-(CGImageGetWidth(image)/2*0.7), pageRect.size.height-CGImageGetHeight(image)*0.7-currentPoint.y, CGImageGetWidth(image)*0.7, CGImageGetHeight(image)*0.7), image);
        
        // Analyser
        // CGImageRelease (image);
        
        [self newLine:CGImageGetHeight(image)];
        
        // Analyser
        CGImageRelease (image);
    }
}

- (void) setReportTitle
{
    NSString * reportTitle = nil;
    //Abinash 28th December
  /*  NSDictionary * dict = nil;
    if ([reportEssentials count] > 0)
        dict = [reportEssentials objectAtIndex:0];
    NSString * workOrdernumber = @"";
    workOrdernumber = [dict objectForKey:@"Name"];
    NSString * title = [[NSString alloc]initWithFormat:@"Service_Report_"];
    
    reportTitle = [title stringByAppendingString:workOrdernumber];*/
    reportTitle = [appDelegate.serviceReport objectForKey:@"IPAD004_SET001"];
    if (![reportTitle isKindOfClass:[NSString class]] || [reportTitle length] == 0)
        reportTitle = [appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_TITLE];
    
    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 22, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char *text = [reportTitle cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Calculate dimensions of text based on text font properties
    CGSize textSize = [reportTitle sizeWithFont:[UIFont fontWithName:@"Verdana-Bold" size:18]];
    
	CGContextShowTextAtPoint (pdfContext, (pageRect.size.width/2) - (textSize.width/2), pageRect.size.height-currentPoint.y, text, strlen(text));
    
    [self newLine:(textSize.height > 0)?textSize.height:16];
}

- (void) setDetailsOfWorkPerformed
{
    [self drawHorizontalLine];
    NSString * detailsTitle = [appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_DETAILS_OF_WORK_PERFORMED];
    
    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 18, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);	
    
    // Calculate dimensions of text based on text font properties
    CGSize textSize = [detailsTitle sizeWithFont:[UIFont fontWithName:@"Verdana-Bold" size:18]];
//    
//	CGContextShowTextAtPoint (pdfContext, (pageRect.size.width/2) - (textSize.width/2), pageRect.size.height-currentPoint.y, text, strlen(text));
	
	
	//
	// Prepare font
	CTFontRef sfont = CTFontCreateWithName(CFSTR("Verdana-Bold"), 18, NULL);
	
	// Create an attributed string
	CFStringRef keys[] = { kCTFontAttributeName };
	CFTypeRef values[] = { sfont };
	CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
											  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	//CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("Hello, World!"), attr);
	CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, (CFStringRef)detailsTitle, attr);
	CFRelease(attr);
	
	// Draw the string
	CTLineRef line = CTLineCreateWithAttributedString(attrString);
	CGContextSetTextMatrix(pdfContext, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	//CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped
	
	CGContextSetTextPosition(pdfContext, (pageRect.size.width/2) - (textSize.width/2), pageRect.size.height-currentPoint.y);
	CTLineDraw(line, pdfContext);
	
	// Clean up
	CFRelease(line);
	CFRelease(attrString);
	CFRelease(sfont);
	//

    
    [self newLine:(textSize.height > 0)?textSize.height:16];
    
    if (currentPoint.y > 850)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];
    }
}
//krishna defect 5813
- (void)setTravelImage {
    
    char *picture = 0;
    
    picture = "travel_header_nw";
    
	CGImageRef image;
    CGDataProviderRef provider;
    CFStringRef picturePath;
    CFURLRef pictureURL;
	
    picturePath = CFStringCreateWithCString (NULL, picture, kCFStringEncodingUTF8);
    pictureURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), picturePath, CFSTR("png"), NULL);
    CFRelease(picturePath);
    if (pictureURL != nil)
    {
        provider = CGDataProviderCreateWithURL (pictureURL);
        CFRelease (pictureURL);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease (provider);
        CGContextDrawImage (pdfContext, CGRectMake(pageRect.size.width/2-(CGImageGetWidth(image)/2*0.7), pageRect.size.height-CGImageGetHeight(image)*0.7-currentPoint.y, CGImageGetWidth(image)*0.7, CGImageGetHeight(image)*0.7), image);
        
        // Analyser
        // CGImageRelease (image);
        
        [self newLine:CGImageGetHeight(image)*0.8];
        
        // Analyser
        CGImageRelease (image);
    }
    
    if (currentPoint.y > 850)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];
    }
}
- (void) setPartsImage
{
    // This code block will create an image that we then draw to the page
	char *picture = 0;
    
    if (srShowLinePrice && srShowDiscount)
        picture = "parts_header";
    else if (srShowLinePrice && !srShowDiscount)
        picture = "parts_header_no_discount";
    else if (!srShowLinePrice && srShowDiscount)
        picture = "parts_header_no_unit_price";
    else
        picture = "parts_header_no_fields";

	CGImageRef image;
    CGDataProviderRef provider;
    CFStringRef picturePath;
    CFURLRef pictureURL;
	
    picturePath = CFStringCreateWithCString (NULL, picture, kCFStringEncodingUTF8);
    pictureURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), picturePath, CFSTR("png"), NULL);
    CFRelease(picturePath);
    if (pictureURL != nil)
    {
        provider = CGDataProviderCreateWithURL (pictureURL);
        CFRelease (pictureURL);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease (provider);
        CGContextDrawImage (pdfContext, CGRectMake(pageRect.size.width/2-(CGImageGetWidth(image)/2*0.7), pageRect.size.height-CGImageGetHeight(image)*0.7-currentPoint.y, CGImageGetWidth(image)*0.7, CGImageGetHeight(image)*0.7), image);
        
        // Analyser
        // CGImageRelease (image);
        
        [self newLine:CGImageGetHeight(image)*0.8];
        
        // Analyser
        CGImageRelease (image);
    }
    
    if (currentPoint.y > 850)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];
    }
}

- (void) setLaborImage
{
    // This code block will create an image that we then draw to the page
	const char *picture = "labor_header";
	CGImageRef image;
    CGDataProviderRef provider;
    CFStringRef picturePath;
    CFURLRef pictureURL;
	
    picturePath = CFStringCreateWithCString (NULL, picture, kCFStringEncodingUTF8);
    pictureURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), picturePath, CFSTR("png"), NULL);
    CFRelease(picturePath);
    if (pictureURL != nil)
    {
        provider = CGDataProviderCreateWithURL (pictureURL);
        CFRelease (pictureURL);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease (provider);
        CGContextDrawImage (pdfContext, CGRectMake(pageRect.size.width/2-(CGImageGetWidth(image)/2*0.7), pageRect.size.height-CGImageGetHeight(image)*0.7-currentPoint.y, CGImageGetWidth(image)*0.7, CGImageGetHeight(image)*0.7), image);
        
        // Analyser
        // CGImageRelease (image);
        
        [self newLine:CGImageGetHeight(image)*0.8];
        
        // Analyser
        CGImageRelease (image);
    }
    
    if (currentPoint.y > 850)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];
    }
}

- (void) setExpenseImage
{
    // This code block will create an image that we then draw to the page
	const char *picture = "expenses_header";
	CGImageRef image;
    CGDataProviderRef provider;
    CFStringRef picturePath;
    CFURLRef pictureURL;
	
    picturePath = CFStringCreateWithCString (NULL, picture, kCFStringEncodingUTF8);
    pictureURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), picturePath, CFSTR("png"), NULL);
    CFRelease(picturePath);
    if (pictureURL != nil)
    {
        provider = CGDataProviderCreateWithURL (pictureURL);
        CFRelease (pictureURL);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease (provider);
        CGContextDrawImage (pdfContext, CGRectMake(pageRect.size.width/2-(CGImageGetWidth(image)/2*0.7), pageRect.size.height-CGImageGetHeight(image)*0.7-currentPoint.y, CGImageGetWidth(image)*0.7, CGImageGetHeight(image)*0.7), image);
        // Analyser
        // CGImageRelease (image);
        
        [self newLine:CGImageGetHeight(image)*0.8];
        
        // Analyser
        CGImageRelease (image);
    }
    
    if (currentPoint.y > 850)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];
    }
}

- (void) setSignatureImage
{
    // This code block will create an image that we then draw to the page
	const char *picture = "signature1";
	CGImageRef image;
    CGDataProviderRef provider;
    CFStringRef picturePath;
    CFURLRef pictureURL;
	
    picturePath = CFStringCreateWithCString (NULL, picture, kCFStringEncodingUTF8);
    pictureURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), picturePath, CFSTR("png"), NULL);
    CFRelease(picturePath);
    if (pictureURL != nil)
    {
        provider = CGDataProviderCreateWithURL (pictureURL);
        CFRelease (pictureURL);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease (provider);
        CGRect signatureRect = CGRectMake(pageRect.size.width/2-(CGImageGetWidth(image)/2*0.7), pageRect.size.height-CGImageGetHeight(image)*0.7-55-currentPoint.y, CGImageGetWidth(image)*0.7, CGImageGetHeight(image)*0.7);
        if (signatureRect.origin.y < 50)
        {
            [self PDFPageEnd];
            [self PDFPageBegin];
            signatureRect = CGRectMake(pageRect.size.width/2-(CGImageGetWidth(image)/2*0.7), pageRect.size.height-CGImageGetHeight(image)*0.7-55-currentPoint.y, CGImageGetWidth(image)*0.7, CGImageGetHeight(image)*0.7);
        }
        CGContextDrawImage (pdfContext, signatureRect, image);
        CGImageRelease (image);
        
        // [self newLine:CGImageGetHeight(image)*0.8];
    }
}

- (void) setSignature
{
	@try{
    // This code block will create an image that we then draw to the page
	// const char *picture = "customer_signature";
	CGImageRef image;
    CGDataProviderRef provider;
    if ([_wonumber isEqualToString:nil])
        _wonumber = @"";
    
    NSData * data = [appDelegate.calDataBase retreiveSignatureimage:_wonumber recordId:_recordId];
    if([data length] > 0)
    {
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
        [dict setValue:[NSNumber numberWithUnsignedInteger:[data length]] forKey:@"AttchedSignSize"];
        SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
        NSString *json = [writer stringWithObject:dict];
        [webView setAccessibilityValue:json];
    }
    else
    {
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
        [dict setValue:[NSNumber numberWithUnsignedInteger:0] forKey:@"AttchedSignSize"];
        SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
        NSString *json = [writer stringWithObject:dict];
        [webView setAccessibilityValue:json];
    }
        
    if (![data isKindOfClass:[NSNull class]])
        data = [data AESDecryptWithPassphrase:@"hello123_!@#$%^&*()"];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths objectAtIndex:0];
    NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"customer_signature.png"];
	
    [fileManager createFileAtPath:filePath contents:data attributes:nil];
    
        
    [fileManager createFileAtPath:filePath contents:data attributes:nil];
    BOOL retVal = [fileManager fileExistsAtPath:filePath];
    // if (pictureURL != nil)
    if (retVal)
    {
        // CFRelease (pictureURL);
        
        provider = CGDataProviderCreateWithFilename([filePath UTF8String]);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGContextDrawImage (pdfContext, CGRectMake(kBoundaryBuffer+xBuffer, pageRect.size.height-CGImageGetHeight(image)*0.2-65 - currentPoint.y - yBuffer*6, CGImageGetWidth(image)*0.2, CGImageGetHeight(image)*0.2), image);
        // CGDataProviderRelease(provider);
        
        // CGImageRelease (image);
    }
    NSError *delete_error;
	if ([fileManager fileExistsAtPath:filePath] == YES)
	{
		[fileManager removeItemAtPath:filePath error:&delete_error];		
	}
	}@catch (NSException *exp) {
	NSLog(@"Exception Name PDFCreator :setSignature %@",exp.name);
	NSLog(@"Exception Reason PDFCreator :setSignature %@",exp.reason);
    }

}

- (void) setTotalCost:(NSString *)totalCost
{
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char *text = [totalCost cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Calculate dimensions of text based on text font properties
    CGSize textSize = [totalCost sizeWithFont:[UIFont fontWithName:FONTNAME size:18]];
    
	CGContextShowTextAtPoint (pdfContext, (pageRect.size.width/2) - (textSize.width/2) + 200, pageRect.size.height-currentPoint.y-yBuffer*14, text, strlen(text));
    
    [self newPara:textSize.height];
}

//  Unused methods
//- (void) setHeaderText:(NSString *)headerText
//{
//    CGContextSelectFont (pdfContext, "Verdana-Bold", 12, kCGEncodingMacRoman);
//	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
//	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
//	const char *text = [headerText cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    // Calculate dimensions of text based on text font properties
//    CGSize textSize = [headerText sizeWithFont:[UIFont fontWithName:FONTNAME size:12]];
//    
//	CGContextShowTextAtPoint (pdfContext, (pageRect.size.width/2) - (textSize.width/2), pageRect.size.height-currentPoint.y, text, strlen(text));
//    // CGContextShowTextAtPoint (pdfContext, (pageRect.size.width/2) - (textSize.width/2) + 180, pageRect.size.height - currentPoint.y - yBuffer*11, text, strlen(text));
//    
//    [self newPara:textSize.height];
//}

- (void) drawHorizontalLine
{
    // CGRect rectangle = CGRectMake(50, pageRect.size.height - currentPoint.y, pageRect.size.width - kBoundaryBuffer, 5);
    // Set clipping context
    // CGContextClipToRect(pdfContext, rectangle);
    
    CGContextMoveToPoint(pdfContext, 50, pageRect.size.height - currentPoint.y);
    CGContextAddLineToPoint(pdfContext, pageRect.size.width - 50, pageRect.size.height - currentPoint.y);
    CGContextStrokePath(pdfContext);
    
    [self newPara:yBuffer];
}

- (void) newPara:(float_t)height;
{
    // currentPoint = CGPointMake(currentPoint.x, currentPoint.y + yBuffer + height);
    currentPoint = CGPointMake(xBuffer, currentPoint.y + yBuffer + height);
    CGContextMoveToPoint(pdfContext, currentPoint.x, currentPoint.y);
}

- (CGPoint) newLine:(float_t)height;
{
    // currentPoint = CGPointMake(currentPoint.x, currentPoint.y + newLineBuffer + height);
    currentPoint = CGPointMake(xBuffer, currentPoint.y + newLineBuffer + height);
    CGContextMoveToPoint(pdfContext, currentPoint.x, currentPoint.y);
    
    return currentPoint;
}

//  Unused methods
//- (void) insertSpaces:(NSUInteger)numSpaces
//{
//    currentPoint = CGPointMake(currentPoint.x + numSpaces * spaceBuffer, currentPoint.y);
//}

//  Unused methods
//- (void) writeText:(NSString *)_text
//{
//    CGContextSelectFont (pdfContext, "Verdana-Bold", 12, kCGEncodingMacRoman);
//	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
//	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
//	const char *text = [_text cStringUsingEncoding:NSUTF8StringEncoding];
//
//    // Calculate dimensions of text based on text font properties
//    CGSize textSize = [_text sizeWithFont:[UIFont fontWithName:FONTNAME size:12]];
//    
//	CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*3, pageRect.size.height-currentPoint.y, text, strlen(text));
//
//    [self newLine:(textSize.height > 0)?textSize.height:16];
//}

- (void) setWorkOrder:(NSString *)wonumber
{
    NSString * workOrderNumber = [NSString stringWithFormat:@"%@:",[appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_WORK_ORDER_NUMBER]];
    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
//	const wchar_t * workOrderNumberText = (wchar_t *)[workOrderNumber cStringUsingEncoding:NSUTF16StringEncoding];
//    NSLog(@"%S", (const wchar_t *)workOrderNumberText);
//	UIGraphicsPushContext(pdfContext);
//	UIGraphicsPopContext();
	
    //
	// Prepare font
	CTFontRef sfont = CTFontCreateWithName(CFSTR("Verdana-Bold"), 14, NULL);
	
	// Create an attributed string
	CFStringRef keys[] = { kCTFontAttributeName };
	CFTypeRef values[] = { sfont };
	CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
											  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	//CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("Hello, World!"), attr);
	CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, (CFStringRef)workOrderNumber, attr);
	CFRelease(attr);
	
	// Draw the string
	CTLineRef line = CTLineCreateWithAttributedString(attrString);
	CGContextSetTextMatrix(pdfContext, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	//CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped
	
	CGContextSetTextPosition(pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10);
	CTLineDraw(line, pdfContext);
	
	// Clean up
	CFRelease(line);
	CFRelease(attrString);
	CFRelease(sfont);
	//
	
    //CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10,(const wchar_t *)workOrderNumberText, strlen(workOrderNumberText));
	

    UIFont * font = [UIFont fontWithName:@"Verdana-Bold" size:14];
    CGSize textSize = [workOrderNumber sizeWithFont:font];
    currentPoint = CGPointMake(currentPoint.x + textSize.width, currentPoint.y);
    
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char *text = [wonumber cStringUsingEncoding:NSUTF8StringEncoding];

    CGContextShowTextAtPoint (pdfContext, currentPoint.x+10, pageRect.size.height-currentPoint.y-10, text, strlen(text));
}

- (void) setDate:(NSDate *)date;
{
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString * dateString = [dateFormatter stringFromDate:date];
    if (dateString == nil)
        dateString = @"";
    
    currentPoint = CGPointMake(425, currentPoint.y);
    
    NSString * workOrderNumber = [NSString stringWithFormat:@"%@:    ",[appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_DATE]];
//    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
//	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
//	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
//	const char * workOrderNumberText = [workOrderNumber cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10, workOrderNumberText, strlen(workOrderNumberText));
	
	
	CTFontRef sfont = CTFontCreateWithName(CFSTR("Verdana-Bold"), 14, NULL);
	
	// Create an attributed string
	CFStringRef keys[] = { kCTFontAttributeName };
	CFTypeRef values[] = { sfont };
	CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
											  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	//CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("Hello, World!"), attr);
	CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, (CFStringRef)workOrderNumber, attr);
	CFRelease(attr);
	
	// Draw the string
	CTLineRef line = CTLineCreateWithAttributedString(attrString);
	CGContextSetTextMatrix(pdfContext, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	//CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped
	
	CGContextSetTextPosition(pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10);
	CTLineDraw(line, pdfContext);
	
	// Clean up
	CFRelease(line);
	CFRelease(attrString);
	CFRelease(sfont);

    UIFont * font = [UIFont fontWithName:@"Verdana-Bold" size:14];
    CGSize textSize = [workOrderNumber sizeWithFont:font];
    currentPoint = CGPointMake(currentPoint.x + textSize.width, currentPoint.y);
    
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char *text = [dateString cStringUsingEncoding:NSUTF8StringEncoding];
    
	CGContextShowTextAtPoint (pdfContext, currentPoint.x+10+3, pageRect.size.height-currentPoint.y-10, text, strlen(text));
    textSize = [dateString sizeWithFont:[UIFont fontWithName:FONTNAME size:12]];

    [self newLine:(textSize.height > 0)?textSize.height:16];
}

- (void) setAccount:(NSArray *)account;
{
	@try{
    if ([account count] == 0)
    {
        [self newLine:yBuffer];
        return;
    }
    
    NSString * workOrderNumber = [NSString stringWithFormat:@"%@:",[appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_ADDRESS]];
//    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
//	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
//	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
//	const char * workOrderNumberText = [workOrderNumber cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10, workOrderNumberText, strlen(workOrderNumberText));
	
	
	//    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
	//	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	//	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	//	const char * workOrderNumberText = [workOrderNumber cStringUsingEncoding:NSUTF8StringEncoding];
	//
	//    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10, workOrderNumberText, strlen(workOrderNumberText));
	
	
	CTFontRef sfont = CTFontCreateWithName(CFSTR("Verdana-Bold"), 14, NULL);
	
	// Create an attributed string
	CFStringRef keys[] = { kCTFontAttributeName };
	CFTypeRef values[] = { sfont };
	CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
											  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	//CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("Hello, World!"), attr);
	CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, (CFStringRef)workOrderNumber, attr);
	CFRelease(attr);
	
	// Draw the string
	CTLineRef line = CTLineCreateWithAttributedString(attrString);
	CGContextSetTextMatrix(pdfContext, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	//CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped
	
	CGContextSetTextPosition(pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10);
	CTLineDraw(line, pdfContext);
	
	// Clean up
	CFRelease(line);
	CFRelease(attrString);
	CFRelease(sfont);

	
    
    UIFont * font = [UIFont fontWithName:@"Verdana-Bold" size:14];
    CGSize textSize = [workOrderNumber sizeWithFont:font];
    currentPoint = CGPointMake(currentPoint.x + textSize.width, currentPoint.y);

    NSMutableString * address = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < [account count]; i++)
    {
        if ([[account objectAtIndex:i] isKindOfClass:[NSString class]])
        {
            if ([address length] == 0)
                [address appendFormat:@"%@", [account objectAtIndex:i]];
            else
            {
                [address appendFormat:@",\r%@", [account objectAtIndex:i]];
            }
        }
    }

////////////////////////////////////////////////////////////////////////////////////////////////////
    
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char *text = [address cStringUsingEncoding:NSUTF8StringEncoding];
    
	CGSize maxsize;
	maxsize.height = 44*100;
	maxsize.width = 600;
    font = [UIFont fontWithName:FONTNAME size:12];
	NSString *wfText = [NSString stringWithUTF8String:text];
	CGSize textsize = [wfText sizeWithFont:font constrainedToSize:maxsize];
    
    UITextView * wp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 230, textsize.height + 40)];
    [wp setBackgroundColor:[UIColor clearColor]];
    wp.font = font;
    wp.text = wfText;
    
	UIGraphicsBeginImageContext(wp.bounds.size);
	CALayer *layer = [wp layer];
	CGContextRef current_ctx = UIGraphicsGetCurrentContext();
	[layer renderInContext:current_ctx];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	CGRect imageRect = CGRectMake(150, pageRect.size.height-currentPoint.y-image.size.height+14, image.size.width, image.size.height);
	CGContextDrawImage(pdfContext, imageRect, [image CGImage]);
	[wp release];

    lastHeight = imageRect.size;
     }@catch (NSException *exp) {
        NSLog(@"Exception Name PDFCreator :setAccount %@",exp.name);
        NSLog(@"Exception Reason PDFCreator :setAccount %@",exp.reason);

    }

}

- (void) setContact:(NSString *)contact;
{
    currentPoint = CGPointMake(425, currentPoint.y);
    
    NSString * workOrderNumber = [NSString stringWithFormat:@"%@:",[appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_CONTACT]];
//    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
//	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
//	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
//	const char * workOrderNumberText = [workOrderNumber cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10, workOrderNumberText, strlen(workOrderNumberText));
    
	
	CTFontRef sfont = CTFontCreateWithName(CFSTR("Verdana-Bold"), 14, NULL);
	
	// Create an attributed string
	CFStringRef keys[] = { kCTFontAttributeName };
	CFTypeRef values[] = { sfont };
	CFDictionaryRef attr = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values,
											  sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	//CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("Hello, World!"), attr);
	CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, (CFStringRef)workOrderNumber, attr);
	CFRelease(attr);
	
	// Draw the string
	CTLineRef line = CTLineCreateWithAttributedString(attrString);
	CGContextSetTextMatrix(pdfContext, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	//CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped
	
	CGContextSetTextPosition(pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10);
	CTLineDraw(line, pdfContext);
	
	// Clean up
	CFRelease(line);
	CFRelease(attrString);
	CFRelease(sfont);

	
	
    UIFont * font = [UIFont fontWithName:@"Verdana-Bold" size:14];
    CGSize textSize = [workOrderNumber sizeWithFont:font];
    currentPoint = CGPointMake(currentPoint.x + textSize.width, currentPoint.y);
    
//    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
//	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
//	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
//	const char *text = [contact cStringUsingEncoding:NSUTF8StringEncoding];
//    
//	CGContextShowTextAtPoint (pdfContext, currentPoint.x+10, pageRect.size.height-currentPoint.y-10, text, strlen(text));
	
	
	CTFontRef sfont1 = CTFontCreateWithName(CFSTR("Verdana-Bold"), 14, NULL);
	
	// Create an attributed string
	CFStringRef keys1[] = { kCTFontAttributeName };
	CFTypeRef values1[] = { sfont1 };
	CFDictionaryRef attr1 = CFDictionaryCreate(NULL, (const void **)&keys1, (const void **)&values1,
											  sizeof(keys1) / sizeof(keys1[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	//CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("Hello, World!"), attr);
	CFAttributedStringRef attrString1 = CFAttributedStringCreate(NULL, (CFStringRef)contact, attr1);
	CFRelease(attr1);
	
	// Draw the string
	CTLineRef line1 = CTLineCreateWithAttributedString(attrString1);
	CGContextSetTextMatrix(pdfContext, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	//CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped
	
	CGContextSetTextPosition(pdfContext, currentPoint.x+10, pageRect.size.height-currentPoint.y-10);
	CTLineDraw(line1, pdfContext);
	
	// Clean up
	CFRelease(line1);
	CFRelease(attrString1);
	CFRelease(sfont1);

    textSize = [contact sizeWithFont:[UIFont fontWithName:FONTNAME size:12]];
    
    phoneNewLine = CGPointMake(currentPoint.x, currentPoint.y+newLineBuffer+textSize.height);
    
    if (lastHeight.height > textSize.height)
        [self newLine:lastHeight.height];
    else
        [self newLine:(textSize.height > 0)?textSize.height:16];
}

- (void) setPhone:(NSString *)phone;
{
    currentPoint = CGPointMake(425, currentPoint.y);
    
    NSString * workOrderNumber = [NSString stringWithFormat:@"%@:",[appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_PHONE]];
//    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
//	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
//	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
//	const char * workOrderNumberText = [workOrderNumber cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-phoneNewLine.y-20, workOrderNumberText, strlen(workOrderNumberText));
	
	
	CTFontRef sfont1 = CTFontCreateWithName(CFSTR("Verdana-Bold"), 14, NULL);
	
	// Create an attributed string
	CFStringRef keys1[] = { kCTFontAttributeName };
	CFTypeRef values1[] = { sfont1 };
	CFDictionaryRef attr1 = CFDictionaryCreate(NULL, (const void **)&keys1, (const void **)&values1,
											   sizeof(keys1) / sizeof(keys1[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	//CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("Hello, World!"), attr);
	CFAttributedStringRef attrString1 = CFAttributedStringCreate(NULL, (CFStringRef)workOrderNumber, attr1);
	CFRelease(attr1);
	
	// Draw the string
	CTLineRef line1 = CTLineCreateWithAttributedString(attrString1);
	CGContextSetTextMatrix(pdfContext, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
	//CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0)); //Use this one if the view's coordinates are flipped
	
	CGContextSetTextPosition(pdfContext, currentPoint.x, pageRect.size.height-phoneNewLine.y-20);
	CTLineDraw(line1, pdfContext);
	
	// Clean up
	CFRelease(line1);
	CFRelease(attrString1);
	CFRelease(sfont1);
    CGSize textSize = CGSizeZero;
    
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char *text = [phone cStringUsingEncoding:NSUTF8StringEncoding];
    
	CGContextShowTextAtPoint (pdfContext, 500, pageRect.size.height-phoneNewLine.y-20, text, strlen(text));
    
    textSize = [phone sizeWithFont:[UIFont fontWithName:FONTNAME size:12]];
    [self newLine:(textSize.height > 0)?textSize.height:16];
}

- (void) setImageWithName:(NSString *)imageName
{
    // This code block will create an image that we then draw to the page
	const char *picture = [imageName UTF8String];
	CGImageRef image;
    CGDataProviderRef provider;
    CFStringRef picturePath;
    CFURLRef pictureURL;
	
    picturePath = CFStringCreateWithCString (NULL, picture, kCFStringEncodingUTF8);
    pictureURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), picturePath, CFSTR("png"), NULL);
    CFRelease(picturePath);
    if (pictureURL != nil)
    {
        provider = CGDataProviderCreateWithURL (pictureURL);
        CFRelease (pictureURL);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease (provider);
        CGContextDrawImage (pdfContext, CGRectMake(pageRect.size.width/2-(CGImageGetWidth(image)/2*0.7), pageRect.size.height-CGImageGetHeight(image)*0.7-currentPoint.y, CGImageGetWidth(image)*0.7, CGImageGetHeight(image)*0.7), image);
        // Analyser
        // CGImageRelease (image);
        
        [self newLine:CGImageGetHeight(image)];
        
        // Analyser
        CGImageRelease (image);
    }
    
    if (currentPoint.y > 850)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];
    }
}

- (void) setDescription:(NSString *)description;
{
    [self setImageWithName:@"problemdescription"];
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char *text = [description cStringUsingEncoding:NSUTF8StringEncoding];
    
	// CGContextShowTextAtPoint (pdfContext, 55, pageRect.size.height - 350, text, strlen(text));
    
    CGSize maxsize;
	maxsize.height = 44*100;
	maxsize.width = 600;
    UIFont * font = [UIFont fontWithName:FONTNAME size:12];
	NSString *wfText = [NSString stringWithUTF8String:text];
	CGSize textsize = [wfText sizeWithFont:font constrainedToSize:maxsize];
    
    UITextView * wp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 600, textsize.height + 30)];
    [wp setBackgroundColor:[UIColor clearColor]];
    wp.font = font;
    wp.text = wfText;
	
	UIGraphicsBeginImageContext(wp.bounds.size);
	CALayer *layer = [wp layer];
	CGContextRef current_ctx = UIGraphicsGetCurrentContext();
	[layer renderInContext:current_ctx];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    NSLog(@"%f, %f", currentPoint.x, currentPoint.y);
    
	CGRect imageRect = CGRectMake(55, pageRect.size.height-currentPoint.y-image.size.height, image.size.width, image.size.height);
	CGContextDrawImage(pdfContext, imageRect, [image CGImage]);
	[wp release];
    
    [self newLine:image.size.height];
    
    if (currentPoint.y > 850)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];
    }
}

- (void) setWorkPerformed:(NSString *)workPerformed;
{
	// Draw the header for work performed first (based on the current graphics context position)
    /*
    [self setImageWithName:@"workperformed"];
    
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
     */
	const char *text = [workPerformed cStringUsingEncoding:NSUTF8StringEncoding];

	CGSize maxsize;
	maxsize.height = 44*100;
	maxsize.width = 600;
    UIFont * font = [UIFont fontWithName:FONTNAME size:12];
	NSString *wfText = [NSString stringWithUTF8String:text];
	CGSize textsize = [wfText sizeWithFont:font constrainedToSize:maxsize];

    UITextView * wp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 600, textsize.height + 30)];
    [wp setBackgroundColor:[UIColor clearColor]];
    wp.font = font;
    wp.text = wfText;

    float yCoOrdinate = pageRect.size.height-currentPoint.y-wp.bounds.size.height;
    NSLog(@"Y = %f",currentPoint.y);
    if(yCoOrdinate < 0)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];        
    }
    NSLog(@"Y = %f",currentPoint.y);    
    [self setImageWithName:@"workperformed"];
    
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
    
    UIGraphicsBeginImageContext(wp.bounds.size);
	CALayer *layer = [wp layer];
	CGContextRef current_ctx = UIGraphicsGetCurrentContext();
	[layer renderInContext:current_ctx];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    yCoOrdinate = pageRect.size.height-currentPoint.y-image.size.height;
    NSLog(@"Y = %f",yCoOrdinate);
	CGRect imageRect = CGRectMake(55, yCoOrdinate, image.size.width, image.size.height);
	CGContextDrawImage(pdfContext, imageRect, [image CGImage]);
	[wp release];
    
    [self newLine:image.size.height];
    
    if (currentPoint.y > 850)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];
    }
}

- (void) writePartsNo:(NSString *)sno part:(NSString *)part qty:(NSString *)qty unitprice:(NSString *)unitprice lineprice:(NSString *)lineprice;
{
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);

	const char *text = [sno cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Calculate dimensions of text based on text font properties
    CGSize textSize = CGSizeZero; // [part sizeWithFont:[UIFont fontWithName:FONTNAME size:18]];
    
    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*3, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    text = [part cStringUsingEncoding:NSUTF8StringEncoding];
    if (text == nil) text = "";
    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*8, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    text = [qty cStringUsingEncoding:NSUTF8StringEncoding];
    if (text == nil) text = "";
    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*35, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    text = [unitprice cStringUsingEncoding:NSUTF8StringEncoding];
    if (text == nil) text = "";
    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*44, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    text = [lineprice cStringUsingEncoding:NSUTF8StringEncoding];
    if (text == nil) text = "";
    textSize = [lineprice sizeWithFont:[UIFont fontWithName:FONTNAME size:12]];
    // Calculate leading edge x coord if trail edge is kept at 700
    CGFloat xCoord = 650 - textSize.width;
//    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*55, pageRect.size.height-currentPoint.y, text, strlen(text));
    CGContextShowTextAtPoint (pdfContext, xCoord, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    [self newLine:(textSize.height > 0)?textSize.height:16];
    
    if (currentPoint.y > 850)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];
    }
}

- (void) writePartsNo:(NSString *)sno part:(NSString *)part qty:(NSString *)qty unitprice:(NSString *)unitprice lineprice:(NSString *)lineprice discount:(NSString *)discount;
{
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
    
	const char *text = [sno cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Calculate dimensions of text based on text font properties
    CGSize textSize = CGSizeZero; // [part sizeWithFont:[UIFont fontWithName:FONTNAME size:18]];
    
    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*3, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    text = [part cStringUsingEncoding:NSUTF8StringEncoding];
    if (text == nil) text = "";
    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*8, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    text = [qty cStringUsingEncoding:NSUTF8StringEncoding];
    if (text == nil) text = "";
    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*26, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    text = [unitprice cStringUsingEncoding:NSUTF8StringEncoding];
    if (text == nil) text = "";
    if (srShowLinePrice)
        CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*35, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    text = [discount cStringUsingEncoding:NSUTF8StringEncoding];
    if (text == nil) text = "";
    if (srShowDiscount)
        CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*46, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    text = [lineprice cStringUsingEncoding:NSUTF8StringEncoding];
    if (text == nil) text = "";
    textSize = [lineprice sizeWithFont:[UIFont fontWithName:FONTNAME size:12]];
    // Calculate leading edge x coord if trail edge is kept at 700
    CGFloat xCoord = 650 - textSize.width;
//    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*53, pageRect.size.height-currentPoint.y, text, strlen(text));
    CGContextShowTextAtPoint (pdfContext, xCoord, pageRect.size.height-currentPoint.y, text, strlen(text));
    
    [self newLine:(textSize.height > 0)?textSize.height:16];
    
    if (currentPoint.y > 850)
    {
        [self PDFPageEnd];
        [self PDFPageBegin];
    }
}

/* Issue 005776 */
- (BOOL)shouldAutorotate {
    if(calledFromSummary) {
        return NO;
    }
    return [super shouldAutorotate];
    
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (calledFromSummary)
    {
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        switch (deviceOrientation)
        {
            case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
                return (interfaceOrientation == UIInterfaceOrientationPortrait);
            case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
                return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationFaceDown:
                return (interfaceOrientation == UIInterfaceOrientationPortrait);
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                return (interfaceOrientation == UIInterfaceOrientationPortrait);
            default:
                YES;
        }
        return NO;
    }

    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    switch (deviceOrientation)
    {
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
            return (interfaceOrientation == UIInterfaceOrientationPortrait);
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            return (interfaceOrientation == UIInterfaceOrientationPortrait);
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            return (interfaceOrientation == UIInterfaceOrientationPortrait);
        default:
            break;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [webView release];
    webView = nil;
    [activity release];
    activity = nil;
    [sendMailButton release];
    sendMailButton = nil;
    [backButton release];
    backButton = nil;
    
    [statusDescription release];
    statusDescription = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    //krishna defect 5813
    [travelArray release];
    [customFields release];
    [super dealloc];
    
    [customFields release];
}

- (IBAction) Help;
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.isPortrait = YES;
    NSString *lang=[appDelegate.dataBase checkUserLanguage];

    NSString *isfileExists = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"service-report_%@",lang] ofType:@"html"];
    if((isfileExists == NULL) ||[lang isEqualToString:@"en_US"] ||  !([lang length]>0))
    {
        help.helpString=@"service-report.html";
    }
    else
    {
        help.helpString = [NSString stringWithFormat:@"service-report_%@.html",lang];
    }
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:help animated:YES completion:nil];
    [help release];
}

@end
