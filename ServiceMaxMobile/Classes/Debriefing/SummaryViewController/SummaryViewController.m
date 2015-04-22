//
//  SummaryViewController.m
//  Debriefing
//
//  Created by Sanchay on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "SummaryViewController.h"
#import "PDFCreator.h"
#import "HelpController.h"
#import "About.h"
#import "Utility.h"

/*Accessibility Changes*/
#import "AccessibilitySummaryAndPdfConstants.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@implementation SummaryViewController

@synthesize delegate;
@synthesize signimagedata , encryptedImage;
@synthesize prevInterfaceOrientation;
@synthesize workOrderDetails;

//krishna defect 5813
@synthesize travel;
@synthesize shouldShowBillablePrice;
@synthesize shouldShowBillableQty;

@synthesize Parts, Labour, Expenses;
@synthesize workDescription;
@synthesize reportEssentials;

//Shrinivas
@synthesize recordId;
@synthesize objectApiName;



- (IBAction) displayUser:(id)sender
{
    UIButton * button = (UIButton *)sender;
    About * about = [[[About alloc] initWithNibName:@"About" bundle:nil] autorelease];
    UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:about];
    [popover setContentViewController:about animated:YES];
    [popover setPopoverContentSize:about.view.frame.size];
    popover.delegate = self;
    // [[[popover contentViewController] view] setAlpha:0.0f];
    [popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    if ([[popoverController contentViewController] isKindOfClass:[About class]])
        return YES;
    
    return YES;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
	
	self.navigationController.delegate = self;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    @try{
    NSString * serviceReport = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SUMMARY_BACK_HEADER];
    totalAmount.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SUMMARY_TOTAL_AMT];
    
    //Radha 23 sep 2011
    NSDictionary * dict = nil;
    if ([reportEssentials count] > 0)
         dict = [reportEssentials objectAtIndex:0];
    NSString * workOrderNumber = @"";
    workOrderNumber = [dict objectForKey:@"Name"];
    if (workOrderNumber == nil)
    {
        workOrderNumber = @"";
    }
    
    titleLabel.text = [NSString stringWithFormat:@"%@ %@",serviceReport, workOrderNumber];

    // titleLabel.text = [NSString stringWithFormat:serviceReport,@"%@", [[workOrderDetails objectForKey:WORKORDERNAME] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:WORKORDERNAME]:@""];
    
    if (appDelegate.workOrderCurrency == nil)
        appDelegate.workOrderCurrency = @"";
    
    workPerformedView.text = [[workOrderDetails objectForKey:SVMXCWORKPERFORMED] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:SVMXCWORKPERFORMED]:@"";
    
    [self setTotalCost];
    if(![Utility notIOS7])
    {
        [self moveAllSubviewDown:self.view];
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
        
    
        UIImage *navImage = [Utility getRightNavigationBarImage];
        [self.navigationController.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
    
	//pavaman 17th Jan 2011
  /*  NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths objectAtIndex:0];	
    NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"customer_signature.png"];
	
	NSError *delete_error;
	if ([fileManager fileExistsAtPath:filePath] == YES)
	{
		[fileManager removeItemAtPath:filePath error:&delete_error];		
	} */
    
    //delete all rows in the sinature table
    //[AppDelegate.calDataBase deleteAllSignatureData];
    
    /*Accessibility Changes*/
    [self setAccessibilityIdentifierForInstanceVariable];
        
        
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name SummaryViewController :viewDidLoad %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason SummaryViewController :viewDidLoad %@",exp.reason);
    }
	
}

/*Accessibility Changes*/
- (void) setAccessibilityIdentifierForInstanceVariable
{
    displayUser.isAccessibilityElement = YES;
    [displayUser setAccessibilityIdentifier:kAccDisplayUser];
    
    pdf.isAccessibilityElement = YES;
    [pdf setAccessibilityIdentifier:kAccPdf];
    
    backButton.isAccessibilityElement = YES;
    [backButton setAccessibilityIdentifier:kAccBackButton];
    
    helpButton.isAccessibilityElement = YES;
    [helpButton setAccessibilityIdentifier:kAccHelpButton];
    
    signatureButton.isAccessibilityElement = YES;
    [signatureButton setAccessibilityIdentifier:kAccSummarySignature];
    
    LblTotalCost.isAccessibilityElement = YES;
    [LblTotalCost setAccessibilityIdentifier:kAccTotalAmount];

}

- (void)moveAllSubviewDown:(UIView *)parentView {
    
    NSArray *allSubViews = [parentView subviews];
    for (int counter = 0; counter < [allSubViews count]; counter++) {
        
        UIView *childView = [allSubViews objectAtIndex:counter];
        CGRect childFrame = childView.frame;
        childFrame.origin.y = childFrame.origin.y+20;
        childView.frame = childFrame;
        if ([childView isKindOfClass:[UIToolbar class]]) {
            childView.hidden = YES;
        }
    }
}

- (void) PopulateData
{
//	Parts = [[NSMutableArray alloc] initWithCapacity:0];
//	Labour = [[NSMutableArray alloc] initWithCapacity:0];
//	Expenses = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSDictionary *Dictionaries = nil;

    if (![appDelegate.tempSummary isKindOfClass:[NSDictionary class]])
    {
        appDelegate.tempSummary = [NSDictionary dictionaryWithDictionary:appDelegate.Dictionaries];
        Dictionaries = appDelegate.tempSummary;
    }
    else
    {
        Dictionaries = appDelegate.tempSummary;
    }
	
	//load Parts
	NSMutableArray *_Parts = [(NSMutableArray *)[(NSDictionary *)[Dictionaries valueForKey:@"Dictionaries"] valueForKey:@"Parts"]retain];
	NSMutableDictionary *_Labour = [(NSMutableDictionary *)[(NSDictionary *)[Dictionaries valueForKey:@"Dictionaries"] valueForKey:@"Labour"]retain];
	NSMutableDictionary *_Expenses = [(NSMutableDictionary *)[(NSDictionary *)[Dictionaries valueForKey:@"Dictionaries"] valueForKey:@"Expenses"]retain];
	@try{
	for( int i = 0; i < [_Parts count]; i++ )
	{
		{
			NSDictionary *dict = (NSDictionary *)[_Parts objectAtIndex:i];
			if( ![(NSString *)[dict valueForKey:KEY_PARTSUSED] isEqualToString:@"0"] && [(NSArray *)[dict allKeys] count] != 0 )
			{
				[Parts addObject:dict];
			}
		}
	}
	
	NSArray *allkeys = [_Labour allKeys];
	for( int i = 0; i < [allkeys count]; i++ )
	{
		NSString *key = [allkeys objectAtIndex:i];
		if( [key isEqualToString:RATE_REPAIR] || [key isEqualToString:RATE_INSTALLATION] || [key isEqualToString:RATE_CLEANUP] || [key isEqualToString:RATE_CALIBRATION] || [key isEqualToString:RATE_SERVICE] )
			continue;
        if ([key Contains:@"_"])
            continue;
		if( ![(NSString *)[_Labour valueForKey:[allkeys objectAtIndex:i]] isEqualToString:@"0.0"] )
		{
			NSArray *keys = [NSArray arrayWithObjects:LABOUR_NAME, LABOUR_RATE, LABOUR_HOURS, nil];
			NSArray *values = [NSArray arrayWithObjects:[allkeys objectAtIndex:i], [_Labour valueForKey:[NSString stringWithFormat:@"Rate_%@", key]], [_Labour valueForKey:key], nil];
			NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
            if (![[dict objectForKey:LABOUR_NAME] Contains:@"_"])
                [Labour addObject:dict];
		}
        
        if( [key Contains:DESCRIPTION] )
			continue;
        if( [key Contains:MODIFY] )
			continue;
	}
	allkeys = nil;
	
	allkeys = [_Expenses allKeys];
	for( int i = 0; i < [allkeys count]; i++ )
	{
		NSString *key = [allkeys objectAtIndex:i];
        if( [key Contains:DESCRIPTION] )
			continue;
        if( [key Contains:MODIFY] )
			continue;
		SMLog(kLogLevelVerbose,@"%@", [_Expenses valueForKey:key]);
		if([[_Expenses valueForKey:key] isKindOfClass:[NSString class]] && ![[_Expenses valueForKey:key] floatValue] == 0.0 )
		{
			NSDictionary *dict = [NSDictionary dictionaryWithObject:[_Expenses valueForKey:key] forKey:key];
			[Expenses addObject:dict];
		}
	}
    
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name SummaryViewController :PopulateData %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason SummaryViewController :PopulateData %@",exp.reason);
    }
    // Analyser
    @finally {
        [_Parts release];
        [_Labour release];
        [_Expenses release];
    }
}

- (IBAction) createPDF;
{
   /* if (![appDelegate isInternetConnectionAvailable])
    {
        [AppDelegate displayNoInternetAvailable];
        return;
    } */
    
    //sahana Aug 16th
    if(!appDelegate)
      appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    @try{
    //temp change commented the enable_summary_generation flag
    
     //BOOL enable_summary_generation = [[header_sfm objectForKey:gENABLE_SUMMURY_GENERATION] boolValue];
    // if(enable_summary_generation)
	 
	//Radha - Fix for the defect 6337
	BOOL showParts, showLabour ,showExpenses;
	
	showParts = showLabour = showExpenses = FALSE;
	
	showParts = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET006"] boolValue];
	showLabour = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET007"] boolValue];
	showExpenses = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET008"] boolValue];

    {
        PDFCreator * pdfCreator = [[PDFCreator alloc] initWithNibName:@"PDFCreator" bundle:nil];
        pdfCreator.delegate = self;
        pdfCreator.reportEssentials = self.reportEssentials;
        pdfCreator.woId = [[workOrderDetails objectForKey:WHATID] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:WHATID]:@"";
        
        pdfCreator.shouldShowBillableQty = self.shouldShowBillableQty;
        pdfCreator.shouldShowBillablePrice = self.shouldShowBillablePrice;
        
        NSDictionary * dict = nil;
        if ([reportEssentials count] > 0)
            dict = [reportEssentials objectAtIndex:0];
        NSString * workOrderNumber = [dict objectForKey:@"Name"];
        if (![workOrderNumber isKindOfClass:[NSString class]])
            workOrderNumber = @"";
        pdfCreator._wonumber = workOrderNumber;
        pdfCreator._recordId = recordId;
        pdfCreator._date = [self getFormattedDate:[[workOrderDetails objectForKey:ACTIVITYDATE] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:ACTIVITYDATE]:@"2001-01-01T00:00:00Z"];
        pdfCreator._account = [NSArray arrayWithObjects:[[workOrderDetails objectForKey:ACCOUNTBILLINGSTREET] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:ACCOUNTBILLINGSTREET]:@"",
                               [[workOrderDetails objectForKey:ACCOUNTBILLINGCITY] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:ACCOUNTBILLINGCITY]:@"",
                               [[workOrderDetails objectForKey:ACCOUNTBILLINGSTATE] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:ACCOUNTBILLINGSTATE]:@"",
                               [[workOrderDetails objectForKey:ACCOUNTBILLINGPOSTALCODE] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:ACCOUNTBILLINGPOSTALCODE]:@"",
                               nil];
        pdfCreator._contact = [[workOrderDetails objectForKey:CONTACTNAME] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:CONTACTNAME]:@"";
        pdfCreator._phone = [[workOrderDetails objectForKey:CONTACTPHONE] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:CONTACTPHONE]:@"";

        //pavaman 16th Jan 2011
        pdfCreator._description = [[workOrderDetails objectForKey:WORKORDERDESCRIPTION] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:WORKORDERDESCRIPTION]:@"";
     
        pdfCreator._workPerformed = [[workOrderDetails objectForKey:SVMXCWORKPERFORMED] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:SVMXCWORKPERFORMED]:@"";
        pdfCreator._totalCost = LblTotalCost.text;
 		//Radha - Fix for the defect 6337
		if (showParts)
			pdfCreator._parts = Parts;
		if (showLabour)
			pdfCreator._labor = Labour;
		if (showExpenses)
			pdfCreator._expenses = Expenses;
        
        //krishna defect : 5813
        pdfCreator.travelArray = travel;
        
        pdfCreator.modalPresentationStyle = UIModalPresentationFullScreen;
        pdfCreator.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        // MOST IMPORTANT FLAG
        pdfCreator.createPDF = YES;
        pdfCreator.calledFromSummary = YES;
        
        pdfCreator.workOrderDetails = self.workOrderDetails;
        
        /* Created as fix for 005776*/
        UINavigationController *navigationControllerTemp = [[[UINavigationController alloc] initWithRootViewController:pdfCreator] autorelease];
        navigationControllerTemp.modalPresentationStyle = UIModalPresentationFullScreen;
        navigationControllerTemp.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [navigationControllerTemp setNavigationBarHidden:YES];
        [self presentViewController:navigationControllerTemp animated:YES completion:nil];

        }
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name SummaryViewController :createPDF %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason SummaryViewController :createPDF %@",exp.reason);
    }

}

- (NSString *) getFormattedDate:(NSString *)date
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if ([date length] > 10)
        date = [date substringToIndex:10];
    NSDate * thisDate = [dateFormatter dateFromString:date];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    date = [dateFormatter stringFromDate:thisDate];
    [dateFormatter release];
    return date;
}

#pragma mark -
#pragma mark PDFCreator delegate method
- (void) attachPDF:(NSString *)pdf target:(id)target
{
    [delegate attachPDF:pdf target:target selector:@selector(didAttachPDF:error:context:) context:nil];
}

- (IBAction) Done
{
    /*if (![appDelegate isInternetConnectionAvailable])
    {
        [AppDelegate displayNoInternetAvailable];
        return;
    }*/
    
//    if ([delegate respondsToSelector:@selector(CloseSummaryView)])
//        [delegate performSelector:@selector(CloseSummaryView)];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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
            break;
    }
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
/* Fix for - 005882*/
- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
   // return 4;// ([Parts count]?1:0) + ([Labour count]?1:0) + ([Expenses count]?1:0);
    
    //krishna hardcoded : defect 5813
    
    // ([Parts count]?1:0) + ([Labour count]?1:0) + ([Expenses count]?1:0) + (([travel count]?1:0);
    if([travel count] > 0) {
        return 5;
    }
    else return 4;//([Parts count]?1:0) + ([Labour count]?1:0) + ([Expenses count]?1:0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	
	switch (section)
    {
        case 0:
            return 1;
		case 1:
			if (Parts != nil && [Parts count] > 0)
			{
				rowCount = [Parts count];
			}
			return  rowCount;
			break;
		case 2:
			if (Labour != nil && [Labour count] > 0)
			{
				rowCount = [Labour count];
			}
			return  rowCount;
			break;
		case 3:
			if (Expenses != nil && [Expenses count] > 0)
			{
				rowCount = [Expenses count];
			}
			return  rowCount;
			break;
        case 4:
            //Krishna defect 5813
            if(travel != nil && [travel count] > 0) {
				rowCount = [travel count];
            }
			return  rowCount;
            break;
		default:
			break;
	}
    return 0;
}

- (void) setTotalCost
{
    /* 6773 */
    NSUInteger count = [Parts count];
    @try{
    for (int i = 0; i < count; i++)
    {
        NSDictionary *dict = [Parts objectAtIndex:i];
        float costPerPart = 0.0;
        costPerPart = [[dict objectForKey:KEY_COSTPERPART] floatValue];
        float discount = [[dict valueForKey:@"Discount"] floatValue];
        double cost = [[dict valueForKey:KEY_PARTSUSED] floatValue] * costPerPart * (1 - (discount/100));//#3014
        
        if(self.shouldShowBillablePrice){
            double billableValue = [[dict valueForKey:KEY_BILLABLE_PRICE] doubleValue];
            totalCost += billableValue;
        }
        else {
             totalCost += cost;
        }
       
    }
    
    count = [Labour count];
    for (int i = 0; i < count; i++)
    {
        NSDictionary *dict = [Labour objectAtIndex:i];
        if ((dict != nil) && (![dict isKindOfClass:[NSNull class]]))
        {
            NSString * actualPrice = [dict valueForKey:SVMXC__Actual_Price2__c];
            if (![actualPrice isKindOfClass:[NSString class]])
                actualPrice = @"0.0";
            
            NSString * actualQuantity = [dict valueForKey:SVMXC__Actual_Quantity2__c];
            if (![actualQuantity isKindOfClass:[NSString class]])
                actualQuantity = @"0.0";

            double cost = [actualPrice floatValue] * [actualQuantity floatValue];
             if(self.shouldShowBillablePrice){
                 double billableValue = [[dict valueForKey:SVMXC__Billable_Line_Price__c] doubleValue];
                 totalCost += billableValue;

             }
             else {
                 totalCost += cost;
             }
            
        }
    }
    
    count = [Expenses count];
    for (int i = 0; i < count; i++)
    {
        NSDictionary *dict = [Expenses objectAtIndex:i];
        
        NSString * actualPrice = [dict objectForKey:SVMXC__Actual_Price2__c];
        if (![actualPrice isKindOfClass:[NSString class]])
            actualPrice = @"0.0";
        
        NSString * actualQuantity = [dict objectForKey:SVMXC__Actual_Quantity2__c];
        if (![actualQuantity isKindOfClass:[NSString class]])
            actualQuantity = @"0.0";
        
        double cost = [actualPrice floatValue] * [actualQuantity floatValue];
        
         if(self.shouldShowBillablePrice){
             double billableValue = [[dict valueForKey:SVMXC__Billable_Line_Price__c] doubleValue];
             totalCost += billableValue;
         }
         else{
               totalCost += cost;
         }
      
    }
        
    NSArray *travelArrayTemp = self.travel;
    count = [travelArrayTemp count];
    for (int i = 0; i < count; i++)
    {
        NSDictionary *dict = [travelArrayTemp objectAtIndex:i];
        
        NSString * actualPrice = [dict objectForKey:SVMXC__Actual_Price2__c];
        if (![actualPrice isKindOfClass:[NSString class]])
            actualPrice = @"0.0";
        
        NSString * actualQuantity = [dict objectForKey:SVMXC__Actual_Quantity2__c];
        if (![actualQuantity isKindOfClass:[NSString class]])
            actualQuantity = @"0.0";
        
        double cost = [actualPrice floatValue] * [actualQuantity floatValue];
        
        if(self.shouldShowBillablePrice){
            double billableValue = [[dict valueForKey:SVMXC__Billable_Line_Price__c] doubleValue];
            totalCost += billableValue;
        }
        else{
            totalCost += cost;
        }
   }
    
    }@catch (NSException *exp) {
		SMLog(kLogLevelError,@"Exception Name SmmaryViewController :setTotalCost %@",exp.name);
		SMLog(kLogLevelError,@"Exception Reason SummaryViewController :setTotalCost %@",exp.reason);
    }

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = nil; // [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	UIView *view = nil;
	@try{
	switch (indexPath.section)
	{
        case 0:
        {
			NSString * wfText = [[workOrderDetails objectForKey:SVMXCWORKPERFORMED] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:SVMXCWORKPERFORMED]:@"";
            
            if ([reportEssentials count] > 0)
            {
                NSDictionary * dict = [reportEssentials objectAtIndex:0];
                wfText = [[dict objectForKey:SVMXCWORKPERFORMED] isKindOfClass:[NSString class]]?[dict objectForKey:SVMXCWORKPERFORMED]:@"";
            }
            
			CGSize maxsize;
			maxsize.height = 44*100;
			maxsize.width = 768;
			CGSize textsize = CGSizeZero; 
			WorkPerformedCellView * workPerformedCell = [[[WorkPerformedCellView alloc] initWithFrame:CGRectMake(0, 0, 768, 44)] autorelease];
            
			maxsize.width = workPerformedCell.workPerformed.frame.size.width;
			textsize = [wfText sizeWithFont:workPerformedCell.workPerformed.font constrainedToSize:maxsize];

			CGRect textframe = workPerformedCell.workPerformed.frame;
			textframe.size.height = textsize.height;
			
            //008501
            if (![Utility notIOS7]) {
                  textframe.origin.y = 1;
            }
          
            
			workPerformedCell.workPerformed.frame = textframe;
            
            workPerformedCell.workPerformed.text = wfText;

            view = workPerformedCell;

			break;
        }
		case 1:
		{
			PartsCellView *partcell = [[[PartsCellView alloc] initWithFrame:CGRectMake(0, 0, 768, 44)] autorelease];
			NSDictionary *dict = [Parts objectAtIndex:indexPath.row];
			partcell.SrNo.text = [NSString stringWithFormat:@"%d.", indexPath.row + 1];
			partcell.Parts.text = [[dict valueForKey:KEY_NAME] isKindOfClass:[NSString class]]?[dict valueForKey:KEY_NAME]:@"";
			
            /* 6773 */
            if (self.shouldShowBillableQty) {
                partcell.Qty.text = [[dict valueForKey:KEY_BILLABLE_QUANTITY] isKindOfClass:[NSString class]]?[dict valueForKey:KEY_BILLABLE_QUANTITY]:@"";
            }
            else {
                partcell.Qty.text = [[dict valueForKey:KEY_PARTSUSED] isKindOfClass:[NSString class]]?[dict valueForKey:KEY_PARTSUSED]:@"";
            }
            
            float costPerPart = 0.0;
            costPerPart = [[dict objectForKey:KEY_COSTPERPART] floatValue];
            partcell.UnitPrice.text = [self getFormattedCost:costPerPart];
            NSString * discountStr = [dict valueForKey:@"Discount"];
            if (![discountStr isKindOfClass:[NSString class]])
                discountStr = @"";
            float discount = [discountStr floatValue];
            NSString * keyPartsUsedStr = [dict valueForKey:KEY_PARTSUSED];
            if (![keyPartsUsedStr isKindOfClass:[NSString class]])
                keyPartsUsedStr = @"";
			double cost = [keyPartsUsedStr floatValue] * costPerPart * (1 - (discount/100));
			LblTotalCost.text = [NSString stringWithFormat:@"%@%@",appDelegate.workOrderCurrency, [self getFormattedCost:totalCost]];
           
            /* 6773 */
            if (self.shouldShowBillablePrice) {
                      double billableCost =   [[dict objectForKey:KEY_BILLABLE_PRICE] doubleValue];
                      partcell.LinePrice.text = [self getFormattedCost:billableCost];
            }
            else {
                partcell.LinePrice.text = [self getFormattedCost:cost];
               
            }
            
            view = partcell;
			break;
		}
		case 2:
		{
			LabourCellView *labourcell = [[[LabourCellView alloc] initWithFrame:CGRectMake(0, 0, 768, 44)] autorelease];
			NSDictionary *dict = [Labour objectAtIndex:indexPath.row];
			labourcell.SrNo.text = [NSString stringWithFormat:@"%d.", indexPath.row + 1];
			labourcell.Labour.text = [[dict valueForKey:@"SVMXC__Activity_Type__c"] isKindOfClass:[NSString class]]?[dict valueForKey:@"SVMXC__Activity_Type__c"]:@"";
            NSString * laborRateStr = [dict valueForKey:@"SVMXC__Actual_Price2__c"];
            if (![laborRateStr isKindOfClass:[NSString class]])
                laborRateStr = @"";
            double laborRate = [laborRateStr floatValue];
            labourcell.Rate.text = [self getFormattedCost:laborRate];
            NSString * laborRateHours = [dict valueForKey:@"SVMXC__Actual_Quantity2__c"];
            if (![laborRateHours isKindOfClass:[NSString class]])
                laborRateHours = @"";
            
            /* 6773 */
            if (self.shouldShowBillableQty) {
                NSString *someValue =  [dict valueForKey:SVMXC__Billable_Quantity__c];
                if (![someValue isKindOfClass:[NSString class]]) {
                    someValue = @"";
                }
                labourcell.Hours.text = someValue;
            }
            else {
                labourcell.Hours.text = laborRateHours;
            }
			
		//	float cost = [laborRateStr intValue] * [laborRateHours floatValue];
            //Abinash 28 december
            double cost = [laborRateStr doubleValue] * [laborRateHours doubleValue];
			 LblTotalCost.text = [NSString stringWithFormat:@"%@%@", appDelegate.workOrderCurrency, [self getFormattedCost:totalCost]];
            
            /* 6773 */
            if (self.shouldShowBillablePrice) {
                double billableCost =  [[dict valueForKey:SVMXC__Billable_Line_Price__c] doubleValue];
                labourcell.LinePrice.text = [self getFormattedCost:billableCost];
            }
            else {
                labourcell.LinePrice.text = [self getFormattedCost:cost];
            }
            
			view = labourcell;
			break;
		}
		case 3:
		{
			ExpensesCellView *expensecell = [[[ExpensesCellView alloc] initWithFrame:CGRectMake(0, 0, 768, 44)] autorelease];
			NSDictionary *dict = [Expenses objectAtIndex:indexPath.row];
			expensecell.SrNo.text = [NSString stringWithFormat:@"%d.", indexPath.row + 1];
            NSString * expenseType = [dict objectForKey:@"SVMXC__Expense_Type__c"];
            NSString * expenseQty = [dict valueForKey:@"SVMXC__Actual_Quantity2__c"];
            if (expenseType == nil || [expenseType isKindOfClass:[NSNull class]])
                expenseType = @"";
            
            if (expenseQty == nil || [expenseQty isKindOfClass:[NSNull class]])
                expenseQty = @"0.0";
			
            expensecell.Expenses.text = expenseType;
            NSString * linePrice = [dict objectForKey:@"SVMXC__Actual_Price2__c"];
            if (linePrice == nil || [linePrice isKindOfClass:[NSNull class]])
                linePrice = @"";
            
            CGFloat linePriceValue = [linePrice floatValue] * [expenseQty floatValue];
           
            /* 6773 */
            if (self.shouldShowBillablePrice) {
                 double billableValue =  [[dict valueForKey:SVMXC__Billable_Line_Price__c] doubleValue];
                 expensecell.LinePrice.text = [self getFormattedCost:billableValue];
            }
            else {
                 expensecell.LinePrice.text = [self getFormattedCost:linePriceValue];
            }
           
			LblTotalCost.text = [NSString stringWithFormat:@"%@%@",appDelegate.workOrderCurrency, [self getFormattedCost:totalCost]];
			view = expensecell;
			break;
		}
        case 4:
        {
            TravelcellView *travelcell = [[[TravelcellView alloc] initWithFrame:CGRectMake(0, 0, 768, 44)] autorelease];
            NSDictionary *dict = [travel objectAtIndex:indexPath.row];
			travelcell.SrNo.text = [NSString stringWithFormat:@"%d.", indexPath.row + 1];
			travelcell.Travel.text = [[dict valueForKey:KEY_NAME] isKindOfClass:[NSString class]]?[dict valueForKey:KEY_NAME]:@"";
            
           
            if(self.shouldShowBillableQty){
                travelcell.Qty.text = [[dict valueForKey:SVMXC__Billable_Quantity__c] isKindOfClass:[NSString class]]?[dict valueForKey:SVMXC__Billable_Quantity__c]:@"";
            }
            else {
                travelcell.Qty.text = [[dict valueForKey:SVMXC__Actual_Quantity2__c] isKindOfClass:[NSString class]]?[dict valueForKey:SVMXC__Actual_Quantity2__c]:@"";
            }
			
            float costPerPart = 0.0;
          
            costPerPart = [[dict objectForKey:SVMXC__Actual_Price2__c] floatValue];
            travelcell.UnitPrice.text = [self getFormattedCost:costPerPart];
            
            
            NSString * keyPartsUsedStr = [dict valueForKey:SVMXC__Actual_Quantity2__c];
            if (![keyPartsUsedStr isKindOfClass:[NSString class]])
                keyPartsUsedStr = @"";
            
            NSString * billablePrice = [dict valueForKey:SVMXC__Billable_Line_Price__c];
            if (![billablePrice isKindOfClass:[NSString class]])
                billablePrice = @"";
            
            double cost = [keyPartsUsedStr floatValue] * costPerPart;
            
			LblTotalCost.text = [NSString stringWithFormat:@"%@%@",appDelegate.workOrderCurrency, [self getFormattedCost:totalCost]];
            
            if (self.shouldShowBillablePrice) {
                double billableCost =  [billablePrice doubleValue];
                travelcell.LinePrice.text = [self getFormattedCost:billableCost];
            }
            else {
                travelcell.LinePrice.text = [self getFormattedCost:cost];
            }
         
            view = travelcell;
			break;
       }
		default:
			break;
	}

    // Configure the cell...
	view.backgroundColor = [UIColor clearColor];
	view.opaque = NO;
	cell.backgroundColor = [UIColor clearColor];
	cell.opaque = NO;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	[cell.contentView addSubview:view];
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name SummaryViewController :cellForRowAtIndexPath %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason SummaryViewController :cellForRowAtIndexPath %@",exp.reason);
    }

	return cell;
}

- (NSString *) getFormattedCost:(double)cost
{
    
    NSMutableString * formattedString = [NSMutableString stringWithFormat:@"%.2f", cost];
   
    @try {
        
        NSArray *componentsString = [formattedString componentsSeparatedByString:@"."];
        if (componentsString > 0) {
            
            NSString *mainString = [componentsString objectAtIndex:0];
            NSMutableString * decimalCostStr = [NSMutableString stringWithFormat:@"%@",mainString];
            int strLength = [decimalCostStr length];
            for (int i = 0; i < strLength; i++)
            {
                if ((i > 0) && (i%3 == 0))
                {
                    // insert a ',' after the current position
                    [decimalCostStr insertString:@"," atIndex:strLength-i];
                }
            }
            
            if ([componentsString count] > 1) {
                
                NSString *floatValue = [componentsString objectAtIndex:1];
                
                [decimalCostStr appendFormat:@".%@",floatValue];
            }
            
            return decimalCostStr;
        }
        else {
            return formattedString;
        }
    }
    @catch (NSException *exception) {
        
    }   
    return formattedString;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) 
	{
		NSString * wfText = [[workOrderDetails objectForKey:SVMXCWORKPERFORMED] isKindOfClass:[NSString class]]?[workOrderDetails objectForKey:SVMXCWORKPERFORMED]:@"";
		@try{
        if ([wfText length] == 0)
        {
            if ([reportEssentials count] > 0)
            {
                NSDictionary * dict = [reportEssentials objectAtIndex:0];
                wfText = [[dict objectForKey:SVMXCWORKPERFORMED] isKindOfClass:[NSString class]]?[dict objectForKey:SVMXCWORKPERFORMED]:@"";
            }
        }

		UIFont *wfFont = [UIFont fontWithName:@"Helvetica" size:17];
		CGSize maxsize;
		maxsize.height = 44*100;
		maxsize.width = 637;
		CGSize textsize = [wfText sizeWithFont:wfFont constrainedToSize:maxsize];
            
        //008501
        if (![Utility notIOS7]) {
            return textsize.height + 5;
        }

		return textsize.height;
		}@catch (NSException *exp) {
		SMLog(kLogLevelError,@"Exception Name SmmaryViewController :setTotalCost %@",exp.name);
		SMLog(kLogLevelError,@"Exception Reason SummaryViewController :setTotalCost %@",exp.reason);
		}

	}
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{	
	UIView *headerView = nil;
	NSArray *objs = nil;
	
	switch (section)
	{
        case 0:
            objs = [[NSBundle mainBundle] loadNibNamed:@"WorkPerformedHeaderToolBar" owner:self options:nil];
			break;
		case 1:
			objs = [[NSBundle mainBundle] loadNibNamed:@"PartsHeaderToolBar" owner:self options:nil];
			break;
		case 2:
			objs = [[NSBundle mainBundle] loadNibNamed:@"LabourHeaderToolBar" owner:self options:nil];
			break;
		case 3:
			objs = [[NSBundle mainBundle] loadNibNamed:@"ExpensesHeaderToolBar" owner:self options:nil];
			break;
            
        //Krishna defect : 5813 
        case 4:
            objs = [[NSBundle mainBundle] loadNibNamed:@"TravelHeaderToolBar" owner:self options:nil];
			break;

		default:
			break;
	}
	
	headerView = (UIView *)[objs objectAtIndex:0];
	[headerView setFrame:CGRectMake(0, 0, 768, 30)];

	return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
	// ...
	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
	*/
}

#pragma mark -
#pragma mark ShowSignature method

- (IBAction) ShowSignature
{
	sign = [[SignatureViewController alloc] initWithNibName:[SignatureViewController description] bundle:nil];
	sign.view.center = CGPointMake(768/2, 717);
	sign.parent = self;
	if( signimagedata != nil )
	{
		sign.imageData = [signimagedata retain];
		[sign SetImage];
	}
	[self.view addSubview:sign.view];
}

- (void) SignatureDone
{
	signature.image = [UIImage imageWithData:signimagedata];
    NSString * WONumner = @"";
    NSString * workOrderNumber = @"";
    @try{
    if ([reportEssentials count] > 0)
    {
        NSDictionary * dict = [reportEssentials objectAtIndex:0];
        
        WONumner = [dict objectForKey:@"Name"];
        if (![WONumner isEqualToString:nil] && [WONumner length] > 0 )
            workOrderNumber = [WONumner substringFromIndex:7];
    }
    
    [appDelegate.calDataBase insertSignatureData:encryptedImage WithId:WONumner RecordId:recordId apiName:objectApiName WONumber:WONumner flag:@"ServiceReport" andSignName:@""];
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name SmmaryViewController :setTotalCost %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason SummaryViewController :setTotalCost %@",exp.reason);
    }

}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [summarytable release];
    summarytable = nil;

    [LblTotalCost release];
    LblTotalCost = nil;
	[signature release];
    signature = nil;
    [workPerformedView release];
    workPerformedView = nil;
    
    [titleLabel release];
    titleLabel = nil;
    [totalAmount release];
    totalAmount = nil;
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc
{
    [totalAmount release];
    //krishna defect 5813
    [travel release];
    [displayUser release];
    [pdf release];
    [backButton release];
    [helpButton release];
    [signatureButton release];
    [super dealloc];
}

- (IBAction) Help
{    
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

@end

