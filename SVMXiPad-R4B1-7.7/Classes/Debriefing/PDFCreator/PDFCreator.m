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
#import "iServiceAppDelegate.h"
#import "DateTimeFormatter.h"
#import "About.h"

@implementation PDFCreator

@synthesize delegate;

@synthesize woId;
@synthesize _wonumber, _date;
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

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
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
    appDelegate.didUserInteract = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
    if (calledFromSummary)
        [self dismissModalViewControllerAnimated:YES];
    else
        [delegate CloseServiceReport:self];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

    [sendMailButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:PDF_EMAIL] forState:UIControlStateNormal];
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
    
    if (iOSObject == nil)
        iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];
    
    [activity startAnimating];
    
    backButton.enabled = NO;
    sendMailButton.enabled = NO;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths objectAtIndex:0];
    NSString * serviceReport = [appDelegate.wsInterface.tagsDictionary objectForKey:PDF_SERVICE_REPORT];
	saveFileName = [[NSString stringWithFormat:@"%@_%@.pdf",serviceReport, _wonumber] retain];
	newFilePath = [[saveDirectory stringByAppendingPathComponent:saveFileName] retain];
    
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
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        NSLog(@"ModalViewController Internet Reachable");
    }
    else
    {
        NSLog(@"ModalViewController Internet Not Reachable");
        
        if (didRunOperation)
        {
            [activity stopAnimating];
            [appDelegate displayNoInternetAvailable];
            didRunOperation = NO;
        }
    }
}

- (void) CreatePDF
{
    [self CreatePDFFile:newFilePath];
    didRunOperation = YES;
    statusDescription.text = [appDelegate.wsInterface.tagsDictionary objectForKey:PDF_ATTACHING];
    
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
}

- (void) removeAllPDF:(NSString *)pdf
{
    NSString * _query = [NSString stringWithFormat:@"SELECT Id FROM Attachment WHERE Name = '%@'", pdf];
    
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetPDFList:error:context:) context:_query];
}

- (void) didGetPDFList:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [[result records] count]; i++)
    {
        [array addObject:[[[[result records] objectAtIndex:i] fields] objectForKey:@"Id"]];
    }
    if ([array count] > 0)
    {
        NSLog(@"1");
        [[ZKServerSwitchboard switchboard] delete:array target:self selector:@selector(didRemoveAllPDF:error:context:) context:nil];
    }
    else
    {
        NSLog(@"2");
        [self didRemoveAllPDF:nil error:nil context:nil];
    }
    
    // Analyser
    [array release];
}

- (void) didRemoveAllPDF:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    [self attachPDF:newFilePath];
}

- (void) attachPDF:(NSString *)pdf
{
    ZKSObject * obj = [[ZKSObject alloc] initWithType:@"Attachment"];
    NSString * fileName = [pdf stringByDeletingLastPathComponent];
    fileName = [pdf substringFromIndex:[fileName length]+1];
    
    [obj setFieldValue:fileName field:@"Name"];
    [obj setFieldValue:@"Work Order Service Report" field:@"Description"];
    
    NSData * fileData = [NSData dataWithContentsOfFile:pdf];
    NSString * fileString = [Base64 encode:fileData];
    
    [obj setFieldValue:fileString field:@"Body"];
    [obj setFieldValue:woId field:@"ParentId"];
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
    // Download the service report first
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
    
    // Save file
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths objectAtIndex:0];
    
    newFilePath = [[saveDirectory stringByAppendingPathComponent:filename] retain];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:newFilePath contents:data attributes:nil];
    
    // Display created pdf
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
    appDelegate.didUserInteract = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }
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
	
    CFDictionarySetValue(myDictionary, kCGPDFContextTitle, CFSTR("Service Report"));
	CFDictionarySetValue(myDictionary, kCGPDFContextCreator, CFSTR("ServiceMax"));
	
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
        [self presentModalViewController:mailComposer animated:YES];
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
    [controller dismissModalViewControllerAnimated:YES];
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
    //[self setDate:appDelegate.sfmPageController.activityDate];
    [self setDate:[NSDate date]];//#002555
    if (appDelegate.addressType != nil && [appDelegate.addressType length] == 0)
    {
        // [self setAccount:_account];
    }
    else
    {
        if ([appDelegate.addressType isEqualToString:@"Account Bill To"])
        {
            ZKSObject * company = [reportEssentialsDict objectForKey:@"SVMXC__Company__r"];
            if ([company isKindOfClass:[ZKSObject class]])
            {
                _account = [NSArray arrayWithObjects:
                            [[company fields] objectForKey:@"BillingStreet"],
                            [[company fields] objectForKey:@"BillingCity"],
                            [[company fields] objectForKey:@"BillingState"],
                            [[company fields] objectForKey:@"BillingCountry"],
                            [[company fields] objectForKey:@"BillingPostalCode"], nil];
            }
        }
        else if ([appDelegate.addressType isEqualToString:@"Account Ship To"])
        {
            ZKSObject * company = [reportEssentialsDict objectForKey:@"SVMXC__Company__r"];
            if ([company isKindOfClass:[ZKSObject class]])
            {
                _account = [NSArray arrayWithObjects:
                            [[company fields] objectForKey:@"ShippingStreet"],
                            [[company fields] objectForKey:@"ShippingCity"], 
                            [[company fields] objectForKey:@"ShippingState"], 
                            [[company fields] objectForKey:@"ShippingCountry"], 
                            [[company fields] objectForKey:@"ShippingPostalCode"], nil];
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
            ZKSObject * contact = [reportEssentialsDict objectForKey:@"SVMXC__Contact__r"];
            if ([contact isKindOfClass:[ZKSObject class]])
            {
                _account = [NSArray arrayWithObjects:
                            [[contact fields] objectForKey:@"MailingStreet"], 
                            [[contact fields] objectForKey:@"MailingState"],
                            [[contact fields] objectForKey:@"MailingPostalCode"], 
                            [[contact fields] objectForKey:@"MailingCountry"], 
                            [[contact fields] objectForKey:@"MailingCity"], nil];
            }
        }

        [self setAccount:_account];
    }

    ZKSObject * contact = [reportEssentialsDict objectForKey:CONTACT];
    if (![contact isKindOfClass:[ZKSObject class]])
        contact = nil;
    NSDictionary * contactFields = [contact fields];
    NSString * contactName = [contactFields objectForKey:@"Name"];
    if (![contactName isKindOfClass:[NSString class]])
        contactName = @"";
    [self setContact:contactName];
    
    NSString * contactPhone = [contactFields objectForKey:@"Phone"];
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
    
    if (srShowParts || srShowExpenses || srShowLabor)
        [self setDetailsOfWorkPerformed];

    {
        [self setPartsImage];
        
        for (int i = 0; i < [_parts count]; i++)
        {
            NSLog(@"%@", [_parts objectAtIndex:i]);
            float linePrice = [[[_parts objectAtIndex:i] objectForKey:@"CostPerPart"] floatValue];
            linePrice *= [[[_parts objectAtIndex:i] objectForKey:@"PartsUsed"] intValue];
            linePrice *= (1 - ([[[_parts objectAtIndex:i] objectForKey:@"Discount"] floatValue]/100));
            {
                NSDictionary * obj = [_parts objectAtIndex:i];
                NSString * discount = [obj valueForKey:@"Discount"];
                if (srShowLinePrice && srShowDiscount)
                {
                    [self writePartsNo:[NSString stringWithFormat:@"%d.", i+1]
                                  part:[[_parts objectAtIndex:i] objectForKey:@"Name"]
                                   qty:[[_parts objectAtIndex:i] objectForKey:@"PartsUsed"]
                             unitprice:[[_parts objectAtIndex:i] objectForKey:@"CostPerPart"]
                             lineprice:[NSString stringWithFormat:@"%.2f", linePrice] 
                              discount:discount
                     ];
                }
                else if (srShowLinePrice && !srShowDiscount)
                {
                    [self writePartsNo:[NSString stringWithFormat:@"%d.", i+1]
                                  part:[[_parts objectAtIndex:i] objectForKey:@"Name"]
                                   qty:[[_parts objectAtIndex:i] objectForKey:@"PartsUsed"]
                             unitprice:[[_parts objectAtIndex:i] objectForKey:@"CostPerPart"]
                             lineprice:[NSString stringWithFormat:@"%.2f", linePrice]
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
                                   qty:[[_parts objectAtIndex:i] objectForKey:@"PartsUsed"]
                             unitprice:nil
                             lineprice:[NSString stringWithFormat:@"%.2f", linePrice]
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
}

- (NSString*) getValueFromDisplayValue:(NSString *)displayValue
{
    NSString * internalValue = nil;
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
    
    NSArray * _array = [internalValue componentsSeparatedByString:@"."];
    id obj = [reportEssentialsDict objectForKey:[_array objectAtIndex:0]];
    if ([obj isKindOfClass:[ZKSObject class]])
    {
        ZKSObject * zks = (ZKSObject *)obj;
        return [[zks fields] objectForKey:[_array objectAtIndex:1]];
    }
    
    obj = [reportEssentialsDict objectForKey:internalValue];
    
    if ([obj isKindOfClass:[NSString class]])
        return obj;
    
    if ([obj isKindOfClass:[ZKSObject class]])
    {
        // ZKSObject * _obj = obj;
        NSArray * arr = [internalValue componentsSeparatedByString:@"."];
        NSString * str = [[obj fields] objectForKey:[arr objectAtIndex:1]];
        return str;
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

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths objectAtIndex:0];

    NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"header_image.png"];
	NSFileManager * fileManager = [NSFileManager defaultManager];
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
	const char *text = [detailsTitle cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Calculate dimensions of text based on text font properties
    CGSize textSize = [detailsTitle sizeWithFont:[UIFont fontWithName:@"Verdana-Bold" size:18]];
    
	CGContextShowTextAtPoint (pdfContext, (pageRect.size.width/2) - (textSize.width/2), pageRect.size.height-currentPoint.y, text, strlen(text));
    
    [self newLine:(textSize.height > 0)?textSize.height:16];
    
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
    
    NSLog(@"%@", [NSString stringWithUTF8String:picture]);

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
    // This code block will create an image that we then draw to the page
	// const char *picture = "customer_signature";
	CGImageRef image;
    CGDataProviderRef provider;

    // NSURL * pictureURL = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths objectAtIndex:0];
    // pictureURL = [NSURL URLWithString:[saveDirectory stringByAppendingPathComponent:@"customer_signature.png"]];
    NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"customer_signature.png"];
	NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL retVal = [fileManager fileExistsAtPath:filePath];
    // if (pictureURL != nil)
    if (retVal)
    {
        // CFRelease (pictureURL);
        
        provider = CGDataProviderCreateWithFilename([filePath UTF8String]);
        image = CGImageCreateWithPNGDataProvider (provider, NULL, true, kCGRenderingIntentDefault);
        CGContextDrawImage (pdfContext, CGRectMake(kBoundaryBuffer+xBuffer, pageRect.size.height-CGImageGetHeight(image)*0.2-55 - currentPoint.y - yBuffer*6, CGImageGetWidth(image)*0.2, CGImageGetHeight(image)*0.2), image);
        // CGDataProviderRelease(provider);
        
        // CGImageRelease (image);
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

- (void) setHeaderText:(NSString *)headerText
{
    CGContextSelectFont (pdfContext, "Verdana-Bold", 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char *text = [headerText cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Calculate dimensions of text based on text font properties
    CGSize textSize = [headerText sizeWithFont:[UIFont fontWithName:FONTNAME size:12]];
    
	CGContextShowTextAtPoint (pdfContext, (pageRect.size.width/2) - (textSize.width/2), pageRect.size.height-currentPoint.y, text, strlen(text));
    // CGContextShowTextAtPoint (pdfContext, (pageRect.size.width/2) - (textSize.width/2) + 180, pageRect.size.height - currentPoint.y - yBuffer*11, text, strlen(text));
    
    [self newPara:textSize.height];
}

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

- (void) insertSpaces:(NSUInteger)numSpaces
{
    currentPoint = CGPointMake(currentPoint.x + numSpaces * spaceBuffer, currentPoint.y);
}

- (void) writeText:(NSString *)_text
{
    CGContextSelectFont (pdfContext, "Verdana-Bold", 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char *text = [_text cStringUsingEncoding:NSUTF8StringEncoding];

    // Calculate dimensions of text based on text font properties
    CGSize textSize = [_text sizeWithFont:[UIFont fontWithName:FONTNAME size:12]];
    
	CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*3, pageRect.size.height-currentPoint.y, text, strlen(text));

    [self newLine:(textSize.height > 0)?textSize.height:16];
}

- (void) setWorkOrder:(NSString *)wonumber
{
    NSString * workOrderNumber = @"Work Order Number:";
    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char * workOrderNumberText = [workOrderNumber cStringUsingEncoding:NSUTF8StringEncoding];
    
    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10, workOrderNumberText, strlen(workOrderNumberText));
    
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
    
    NSString * workOrderNumber = @"Date:    ";
    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char * workOrderNumberText = [workOrderNumber cStringUsingEncoding:NSUTF8StringEncoding];
    
    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10, workOrderNumberText, strlen(workOrderNumberText));
    
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
    if ([account count] == 0)
    {
        [self newLine:yBuffer];
        return;
    }
    
    NSString * workOrderNumber = @"Address:";
    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char * workOrderNumberText = [workOrderNumber cStringUsingEncoding:NSUTF8StringEncoding];
    
    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10, workOrderNumberText, strlen(workOrderNumberText));
    
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
}

- (void) setContact:(NSString *)contact;
{
    currentPoint = CGPointMake(425, currentPoint.y);
    
    NSString * workOrderNumber = @"Contact:";
    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char * workOrderNumberText = [workOrderNumber cStringUsingEncoding:NSUTF8StringEncoding];
    
    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-currentPoint.y-10, workOrderNumberText, strlen(workOrderNumberText));
    
    UIFont * font = [UIFont fontWithName:@"Verdana-Bold" size:14];
    CGSize textSize = [workOrderNumber sizeWithFont:font];
    currentPoint = CGPointMake(currentPoint.x + textSize.width, currentPoint.y);
    
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char *text = [contact cStringUsingEncoding:NSUTF8StringEncoding];
    
	CGContextShowTextAtPoint (pdfContext, currentPoint.x+10, pageRect.size.height-currentPoint.y-10, text, strlen(text));
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
    
    NSString * workOrderNumber = @"Phone:";
    CGContextSelectFont (pdfContext, CBOLDFONTNAME, 14, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
	const char * workOrderNumberText = [workOrderNumber cStringUsingEncoding:NSUTF8StringEncoding];
    
    CGContextShowTextAtPoint (pdfContext, currentPoint.x, pageRect.size.height-phoneNewLine.y-20, workOrderNumberText, strlen(workOrderNumberText));
    
    UIFont * font = [UIFont fontWithName:@"Verdana-Bold" size:14];
    CGSize textSize = CGSizeZero; // [workOrderNumber sizeWithFont:font];
    
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
    [self setImageWithName:@"workperformed"];
    
    CGContextSelectFont (pdfContext, CFONTNAME, 12, kCGEncodingMacRoman);
	CGContextSetTextDrawingMode (pdfContext, kCGTextFill);
	CGContextSetRGBFillColor (pdfContext, 0, 0, 0, 1);
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

	UIGraphicsBeginImageContext(wp.bounds.size);
	CALayer *layer = [wp layer];
	CGContextRef current_ctx = UIGraphicsGetCurrentContext();
	[layer renderInContext:current_ctx];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

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
    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*36, pageRect.size.height-currentPoint.y, text, strlen(text));
    
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
    CGContextShowTextAtPoint (pdfContext, currentPoint.x + spaceBuffer*28, pageRect.size.height-currentPoint.y, text, strlen(text));
    
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
    [super dealloc];
    
    [customFields release];
}

- (IBAction) Help;
{
    appDelegate.didUserInteract = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.isPortrait = YES;
    help.helpString = @"service-report.html";
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentModalViewController:help animated:YES];
    [help release];
}

@end
