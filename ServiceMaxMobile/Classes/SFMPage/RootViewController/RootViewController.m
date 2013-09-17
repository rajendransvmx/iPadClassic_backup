//
//  RootViewController.m
//  project
//
//  Created by Developer on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "WSIntfGlobals.h"
#import "SFMPageController.h"
//extern void NSLog(NSString *format, ...);

@implementation RootViewController
	

@synthesize detailViewController, appDelegate, delegate;
@synthesize isinViewMode;
@synthesize AdditionalInfo;
@synthesize Work_order;
@synthesize account_history;
@synthesize product_history;
@synthesize addition_info_items;
@synthesize tableView,errorTableView, conflictsArray;
@synthesize errorDictonary;
@synthesize isErrorDisplayed;

#pragma mark Server Switchboard Results

- (void)loginResult:(ZKLoginResult *)result error:(NSError *)error
{
    if (result && !error)
    {
        NSLog(@"Hey, we logged in (with the new switchboard)!");
        
        didLogin = YES;
        
        appDelegate.loginResult = [result retain];
    }
    else if (error)
    {
            [appDelegate CustomizeAletView:error alertType:SOAP_ERROR Dict:nil exception:nil];
    }
}
//  Unused Methods
//-(void)receivedErrorFromAPICall:(NSError *)err 
//{
//	[appDelegate popupActionSheet:err.description];
//}

- (void)describeSObject:(NSString *)sObjectType
{
    [[ZKServerSwitchboard switchboard] describeSObject:sObjectType target:self selector:@selector(describeSObjectResult:error:context:) context:nil];
}

- (void)describeSObjects:(NSArray *)sObjectTypes
{
    [[ZKServerSwitchboard switchboard] describeSObjects:sObjectTypes target:self selector:@selector(describeSObjectsResult:error:context:) context:nil];
}

- (void)describeSObjectResult:(id)result error:(NSError *)error context:(id)context
{
    NSLog(@"describeSObjectResult: %@ error: %@ context: %@", result, error, context);
    if (result && !error)
    {
    }
    else if (error)
    {
        [appDelegate CustomizeAletView:error alertType:SOAP_ERROR Dict:nil exception:nil];
    }
}

- (void)describeSObjectsResult:(id)result error:(NSError *)error context:(id)context
{
    NSLog(@"describeSObjectsResult: %@ error: %@ context: %@", result, error, context);
    if (result && !error)
    {
    }
    else if (error)
    {
	    [appDelegate CustomizeAletView:error alertType:SOAP_ERROR Dict:nil exception:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = self.view.frame;
    frame.size.height = 768;
    self.view.frame = frame;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    UIImageView * bgImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]] autorelease];
    [self.tableView setBackgroundView:bgImage];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.errorTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.errorTableView];
    self.errorTableView.dataSource=self;
    self.errorTableView.delegate=self;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    NSMutableDictionary *bizRuleError= [errorDictonary objectForKey:@"RULE_ERROR"];
    self.conflictsArray = [bizRuleError objectForKey:@"errors"];
    NSLog(@"self.frame %@",NSStringFromCGRect(self.view.frame));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void) displaySwitchViews
{
    
      if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"])
    {
        UIButton * selectProcessButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)];
        [selectProcessButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Switch-Views-button"] forState:UIControlStateNormal];
        [selectProcessButton addTarget:self action:@selector(selectProcess:) forControlEvents:UIControlEventTouchUpInside];
        selProcessBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:selectProcessButton];
        self.navigationItem.leftBarButtonItem = selProcessBarButtonItem;
        [selectProcessButton release];
        
        
    }
	else
	{
		self.navigationItem.leftBarButtonItem = nil;
	}
}


- (void) showLastModifiedTimeForSFMRecord
{
    
	//Adding the label to display the timestamp.
    if(lastModifiedTime == nil)
    {
        lastModifiedTime = [[UILabel alloc] initWithFrame:CGRectMake(65, -10, 250, 45)];
        lastModifiedTime.backgroundColor = [UIColor clearColor];
        lastModifiedTime.font=[UIFont fontWithName:@"Verdana" size:12];
        lastModifiedTime.text = [appDelegate.wsInterface.tagsDictionary objectForKey:Last_updated_on];//@"Last Updated On:";
        lastModifiedTime.textColor = [appDelegate colorForHex:@"2d5d83"];
        [self.navigationController.view addSubview:lastModifiedTime];
        [lastModifiedTime release];
    }
    
    if(timeStamp == nil)
    {
        timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(65, 4, 250, 50)];//2
        timeStamp.text = @"";
        timeStamp.backgroundColor = [UIColor clearColor];
        
        [self.navigationController.view addSubview:timeStamp];
        [timeStamp release];
    }
    
    BOOL check_On_demand = [appDelegate.databaseInterface checkOndemandRecord:appDelegate.sfmPageController.recordId];
    if(check_On_demand)
    {
        NSString * recordTimeStamp = @"";
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        NSDateFormatter * formatter1 = [[NSDateFormatter alloc] init];
        
        [formatter1 setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss a"];
        [formatter1 setTimeZone:[NSTimeZone defaultTimeZone]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        recordTimeStamp = [appDelegate.databaseInterface getTimeLastModifiedTimeOfTheRecordForRecordId:appDelegate.sfmPageController.recordId];
        NSDate * _gmtDate = [formatter dateFromString:recordTimeStamp];
        recordTimeStamp = [formatter1 stringFromDate:_gmtDate];
        
        NSString * str1 = nil;
        NSString * str2 = nil;
        NSString * str3 = nil;
        if ( [recordTimeStamp length] > 17)
            str1 = [recordTimeStamp substringFromIndex:17];
        if ( [str1 length] > 2)
            str2 = [str1 substringToIndex:2];
        
        int i;
        i = [str2 intValue];
        if (i > 12)
        {
            i = i - 12;
        }
        str3 = [NSString stringWithFormat:@"%d", i];
        NSLog(@"%@", str3);
        NSRange range = NSMakeRange(17,2);
        NSLog(@"%@", [recordTimeStamp stringByReplacingCharactersInRange:range withString:str3]);
        recordTimeStamp = [recordTimeStamp stringByReplacingCharactersInRange:range withString:str3];
        timeStamp.backgroundColor = [UIColor clearColor];
        timeStamp.font=[UIFont fontWithName:@"Verdana" size:12];
        timeStamp.textColor = [appDelegate colorForHex:@"2d5d83"];
        timeStamp.text = recordTimeStamp;
        [formatter release];
        [formatter1 release];
	}
    else
    {
        lastModifiedTime.text = @"";
        timeStamp.text = @"";
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void) selectProcess:(id)sender
{
    if (switchProcess)
    {
        [switchProcess.popOver dismissPopoverAnimated:YES];
        switchProcess = nil;
        return;
    }
    
    if (appDelegate.SFMPage != nil)
    {
        switchProcess = [[[SelectProcessController alloc] initWithNibName:@"SelectProcessController" bundle:nil] autorelease];
        switchProcess.delegate = self;
        UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:switchProcess];
        switchProcess.popOver = popover;
        [popover presentPopoverFromBarButtonItem:selProcessBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        switchProcess = nil;
    }
}

//sahana  popover dalegate methods
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
{
    [popoverController release];

}


// SwitchProcessDelegate Method
- (void) didSwitchProcess:(NSDictionary *)objectDictionary
{
    delegate = appDelegate.sfmPageController.detailView;
    [delegate didSwitchProcess:objectDictionary];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.errorTableView == tableView)
    {
        return SectionHeaderHeight+4;
    }
    else
    {
        CGFloat  HeaderHeight = 0.0;;
        switch (section) 
        {
            case 0:
            {
                HeaderHeight = SectionHeaderHeight;//20th June
                
                break;
            }
            case 1:
            {
                HeaderHeight = SectionHeaderHeight;
                break;
            }
            case 2:
            {
                HeaderHeight = SectionHeaderHeight;
                break;
            }
        }
        return HeaderHeight;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    if (self.errorTableView == tableView)
    {
        
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, SectionHeaderHeight)];
        headerView.image = [UIImage imageNamed:@"SFM-View-line-header-bg.png"];
        [headerView setUserInteractionEnabled:YES];
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(20, 7, 170, 30)] autorelease];//y was  6
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        
        label.font = [UIFont boldSystemFontOfSize:16];
        NSString * errorTitle = [appDelegate.wsInterface.tagsDictionary objectForKey:BIZ_RULE_ERROR_TITLE];
        label.text = errorTitle;
        [headerView addSubview:label];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestute:)];
        [headerView addGestureRecognizer:tapGesture];
        [tapGesture release];
        UIView *dummyView=[[UIView alloc]initWithFrame:CGRectMake(0, SectionHeaderHeight,320,4)];
        dummyView.backgroundColor=[UIColor clearColor];
        dummyView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]];
        dummyView.userInteractionEnabled=FALSE;
        [headerView addSubview:dummyView];
        [dummyView release];
        if(!isErrorDisplayed)
            isErrorDisplayed=YES;
        return [headerView autorelease];
    }
    else
    {
        UIImageView * view = nil;
        NSString * sectionTitle = nil;
        @try{
            switch (section)
            {
                case 0:
                {
                    //   sectionTitle = @"Header Info";
                    
                    sectionTitle = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_HEADER];
                    // Create label with section title
                    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(20, 7, 170, 30)] autorelease];//y was  6
                    
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor whiteColor];
                    
                    label.font = [UIFont boldSystemFontOfSize:16];
                    label.text = sectionTitle;
                    
                    // Create header view and add label as a subview
                    view  = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, SectionHeaderHeight)] autorelease];
                    
                    view.image = [UIImage imageNamed:@"SFM-View-line-header-bg.png"];
                    [view addSubview:label];
                    
                    UIButton * header_button = [[[UIButton alloc]  initWithFrame:CGRectMake(290, 7, 28, 28)] autorelease];//6 44 44
                    header_button.tag = section;
                    NSDictionary *header = [appDelegate.SFMPage objectForKey:@"header"];
                    NSArray * header_sections = [header objectForKey:@"hdr_Sections"];
                    NSInteger count = [header_sections count];
                    
                    [header_button  setBackgroundImage:[UIImage imageNamed:@"SFM-View-showall-icon_mod.png"] forState:UIControlStateNormal];
                    [header_button addTarget:self action:@selector(didSelectHeader:) forControlEvents:UIControlEventTouchUpInside];
                    
                    // [view_header bringSubviewToFront:header_button];
                    // [view_header addSubview:header_button];
                    view.tag = section;
                    
                    UIView * lView = [[[UIView alloc] initWithFrame:view.frame] autorelease];
                    [lView addSubview:view];
                    if(count >1)
                    {
                        [lView addSubview:header_button];
                    }
                    
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestute:)];
                    [lView addGestureRecognizer:tapGesture];
                    [tapGesture release];
                    return lView;
                    break;
                }
                case 1:
                {
                    sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
                    
                    if (sectionTitle == nil)
                    {
                        return nil;
                    }
                    // Create label with section title
                    UILabel *label = [[[UILabel alloc] init] autorelease];
                    label.frame = CGRectMake(20, 7, 170, 30);
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor whiteColor];
                    
                    label.font = [UIFont boldSystemFontOfSize:16];
                    label.text = sectionTitle;
                    
                    // Create header view and add label as a subview
                    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, SectionHeaderHeight)];//320 width before changing
                    view.image = [UIImage imageNamed:@"SFM-View-line-header-bg.png"];
                    [view autorelease];
                    [view addSubview:label];
                    NSArray *details = [appDelegate.SFMPage objectForKey:@"details"];
                    NSInteger count = [details count];
                    
                    UIButton * lines_button = [[[UIButton alloc]  initWithFrame:CGRectMake(290, 10, 28, 28)] autorelease];//x = 250
                    lines_button.enabled = YES;
                    lines_button.userInteractionEnabled = YES;
                    lines_button.tag = section;
                    
                    [lines_button  setBackgroundImage:[UIImage imageNamed:@"SFM-View-showall-icon_mod.png"] forState:UIControlStateNormal];
                    [lines_button  addTarget:self action:@selector(didSelectHeader:) forControlEvents:UIControlEventTouchUpInside];
                    view.tag = section;
                    
                    
                    UIView * lView = [[[UIView alloc] initWithFrame:view.frame] autorelease];
                    [lView addSubview:view];
                    if(count >1)
                    {
                        [lView addSubview:lines_button];
                    }
                    return lView;
                    break;
                    
                }
                    
                case 2:
                {
                    sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
                    if (sectionTitle == nil)
                    {
                        return nil;
                    }
                    
                    // Create label with section title
                    UILabel *label = [[[UILabel alloc] init] autorelease];
                    label.frame = CGRectMake(20, 7, 170, 30);
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor whiteColor];
                    
                    label.font = [UIFont boldSystemFontOfSize:16];
                    label.text = sectionTitle;
                    
                    // Create header view and add label as a subview
                    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, SectionHeaderHeight)];//320 width before changing
                    view.image = [UIImage imageNamed:@"SFM-View-line-header-bg.png"];
                    [view autorelease];
                    [view addSubview:label];
                    
                    UIButton * lines_button = [[[UIButton alloc]  initWithFrame:CGRectMake(290, 10, 28, 28)] autorelease];
                    lines_button.enabled = YES;
                    lines_button.userInteractionEnabled = YES;
                    lines_button.tag = section;
                    [lines_button  setBackgroundImage:[UIImage imageNamed:@"SFM-View-showall-icon_mod.png"] forState:UIControlStateNormal];
                    [lines_button  addTarget:self action:@selector(didSelectHeader:) forControlEvents:UIControlEventTouchUpInside];
                    view.tag = section;
                    NSInteger count;
                    if(account_history && product_history)
                    {
                        count = 2;
                    }
                    else
                    {
                        count = 1;
                    }
                    
                    UIView * lView = [[[UIView alloc] initWithFrame:view.frame] autorelease];
                    [lView addSubview:view];
                    if(count > 1)
                    {
                        [lView addSubview:lines_button];
                    }
                    return lView;
                    break;
                }
                    
                default:
                    break;
            }
        }@catch (NSException *exp) {
            NSLog(@"Exception Name RootViewController :viewForHeaderInSection %@",exp.name);
            NSLog(@"Exception Reason RootViewController :viewForHeaderInSection %@",exp.reason);
        }
        
        return view;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.errorTableView)
    {
        return nil;
    }
    else
    {

        if (section == 0)
        {
            NSDictionary *header = [appDelegate.SFMPage objectForKey:@"header"];
            return [header objectForKey:@"hdr_Object_Label"];
        }
        else if (section == 1)
        {
            return [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_LINE];
        }
        else if (section == 2)
        {
            return [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_ADD_INFO];
        }
        else return @"";
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    
    if (tableView == self.errorTableView)
    {
        return 1;
    }
    else{
        if([appDelegate.SFMPage count] == 0 )
        {
            return 0;
        }
        if([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"])
        {
            isinViewMode = TRUE;
        }
        else
        {
            isinViewMode = FALSE;
        }
        
        //check whether the product history and Account history has to be added
        @try{
            NSDictionary * header = [appDelegate.SFMPage objectForKey:@"header"];
            NSString * header_object_name = [header objectForKey:gHEADER_OBJECT_NAME];
            if([header_object_name hasSuffix:@"Service_Order__c"])
            {
                Work_order = TRUE;
            }
            else
            {
                Work_order = FALSE;
            }
            
            
            NSArray * details = [appDelegate.SFMPage objectForKey:@"details"];
            
            
            if(isinViewMode && Work_order)
            {
                product_history = [[header objectForKey:gHEADER_SHOW_PRODUCT_HISTORY] boolValue];
                account_history = [[header  objectForKey:gHEADER_SHOW_ACCOUNT_HISTORY] boolValue];
                if(product_history || account_history)
                {
                    if([details count] == 0)
                        return   gNUM_SECTION_IN_TABLE_ADDITIONALINFO-1;
                    return gNUM_SECTION_IN_TABLE_ADDITIONALINFO;
                }
            }
            
            if ([details count] == 0)
                return gNUM_SECTIONS_IN_TABLE - 1;
        }@catch (NSException *exp) {
            NSLog(@"Exception Name RootViewController :numberOfSectionsInTableView %@",exp.name);
            NSLog(@"Exception Reason RootViewController :numberOfSectionsInTableView %@",exp.reason);
        }
        
        return gNUM_SECTIONS_IN_TABLE;
        
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Fix for avoiding crash
	NSUInteger rowCount = 0;
	
    if (tableView == self.errorTableView)
    {
        self.conflictsArray = [errorDictonary objectForKey:@"RULE_ERROR"];
        NSLog(@"Errors Count %d",[self.conflictsArray count]);
		if (self.conflictsArray != nil && [self.conflictsArray count] > 0)
			rowCount = [self.conflictsArray count];
        return rowCount;
    }
    
    else
    {
        @try{
            switch (section)
            {
                case 0:
                {
                    NSDictionary *header = [appDelegate.SFMPage objectForKey:@"header"];
                    NSArray * header_sections = [header objectForKey:@"hdr_Sections"];
					if (header_sections != nil && [header_sections count] > 0)
						rowCount = [header_sections count];
					return rowCount;
                }
                case 1:
                {
                    NSArray *details = [appDelegate.SFMPage objectForKey:@"details"];
					if (details != nil && [details count] > 0)
						rowCount = [details count];
					return rowCount;
                }
                case 2:
                {
                    if(account_history && product_history)
                    {
                        NSDictionary * productDictionary = nil, * accountDictionary = nil;
                        productDictionary = [NSDictionary dictionaryWithObject:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_PRODUCTHISTORY] forKey:PRODUCT_ADDITIONALINFO];
                        accountDictionary = [NSDictionary dictionaryWithObject:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_ACCOUNTHISTORY] forKey:ACCOUNT_ADITIONALINFO];
                        addition_info_items = [[NSArray alloc] initWithObjects:productDictionary, accountDictionary, nil];
                        // addition_info_items = [[NSArray alloc] initWithObjects:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_PRODUCTHISTORY], [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_ACCOUNTHISTORY], nil];
                        appDelegate.additionalInfo = addition_info_items;
                        return 2;
                    }
                    //sahana  22nd Aug 2011
                    if(product_history == TRUE)
                    {
                        NSDictionary * productDictionary = nil;
                        productDictionary = [NSDictionary dictionaryWithObject:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_PRODUCTHISTORY] forKey:PRODUCT_ADDITIONALINFO];
                        addition_info_items = [[NSArray alloc] initWithObjects:productDictionary, nil];
                        // addition_info_items = [[NSArray alloc] initWithObjects:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_ACCOUNTHISTORY], nil];
                        appDelegate.additionalInfo = addition_info_items;
                        return 1;
                    }
                    if(account_history == TRUE)
                    {
                        NSDictionary * accountDictionary = nil;
                        accountDictionary = [NSDictionary dictionaryWithObject:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_ACCOUNTHISTORY] forKey:ACCOUNT_ADITIONALINFO];
                        addition_info_items = [[NSArray alloc] initWithObjects:accountDictionary, nil];
                        // addition_info_items = [[NSArray alloc] initWithObjects: [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_PRODUCTHISTORY], nil];
                        appDelegate.additionalInfo = addition_info_items;
                        return 1;
                    }
                }
                    break;
                default:
                    break;
            }
        }@catch (NSException *exp) {
            NSLog(@"Exception Name RootViewController :numberOfRowsInSection %@",exp.name);
            NSLog(@"Exception Reason RootViewController :numberOfRowsInSection %@",exp.reason);
        }
        
        return 1;
        
    }
}

#define CELL_CONTENT_HEIGHT 768.0f
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    
    if (tableView == self.errorTableView) {
        //Set the maximum size
        NSString *text = [[self.conflictsArray objectAtIndex:[indexPath row]] objectForKey:@"message"];
        [text uppercaseString];
        CGSize constraint = CGSizeMake(self.view.frame.size.width-15, CELL_CONTENT_HEIGHT);
        
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        NSLog(@"%@",NSStringFromCGSize(size));
        CGFloat minimumHeight=SectionHeaderHeight;
        if (size.height < minimumHeight)
        {
            size.height = minimumHeight;
        }
        if(indexPath.row ==0)
        {
            size.height=size.height+10;
        }
        return size.height;
    }
    else{
        switch (indexPath.section)
        {
            case 0:
            {
                NSString * cellText = [[appDelegate.wsInterface GetHeaderSectionForSequenceNumber:indexPath.row] objectForKey:@"section_Title"];
                if(indexPath.row != 0)
                {
                    if ([cellText isEqualToString:@""])
                        return 0; //return 0;
                }
            }
                
                break;
            case 1:
                
                break;
                
            case 2:
                
                break;
                
            default:
                break;
                
        }
        return SectionHeaderHeight;
    }    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (tableView == self.errorTableView)
    {
        static NSString *erorCellIdentifier = @"Error Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:erorCellIdentifier];
        UILabel * cellLabel = [[UILabel alloc] init] ;
        NSString * colourCode = @"#F75D59";
        UIColor * color = [appDelegate colorForHex:colourCode];
        //        self.errorTableView.backgroundColor=color;
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:erorCellIdentifier] autorelease];
        }
        else
        {
            for (UIView *subview in [cell.contentView subviews])
            {
                [subview removeFromSuperview];
            }
        }
        // defect 007565
        CGSize constraint = CGSizeMake(self.view.frame.size.width-15, CELL_CONTENT_HEIGHT);
        
        NSString *errorString=[[self.conflictsArray objectAtIndex:indexPath.row]objectForKey:@"message" ];
        [errorString uppercaseString];
        CGSize size = [errorString sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        cellLabel.frame = CGRectMake(5, 0, tableView.bounds.size.width-10, size.height);
        cellLabel.text = errorString;
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        cellLabel.numberOfLines = 0;
        cellLabel.backgroundColor = [UIColor clearColor];
        cellLabel.font=[UIFont boldSystemFontOfSize:18.0];
        cellLabel.lineBreakMode=NSLineBreakByWordWrapping;
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor=color;
        [cell.contentView addSubview:cellLabel];
        [cellLabel release];
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        else
        {
            cell.backgroundView = nil;
        }
        
        UILabel * cellLabel = [[[UILabel alloc] init] autorelease];
        cellLabel.backgroundColor = [UIColor clearColor];
        cellLabel.frame = CGRectMake(0, 0, 270, 44);
        cellLabel.lineBreakMode=NSLineBreakByWordWrapping;
        UIView * bgView = nil;
        UIImageView * bgImage = nil;
        UIImage * image = nil;
        
        @try{
            switch (indexPath.section)
            {
                case 0:
                    bgView = [[[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, SectionHeaderHeight)] autorelease];
                {
                    NSString * section_title =  [[appDelegate.wsInterface GetHeaderSectionForSequenceNumber:indexPath.row] objectForKey:@"section_Title"];
                    if(indexPath.row != 0 && [section_title isEqualToString:@""])
                    {
                        // return cell;
                        // return 0;
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"invisible cell"] autorelease];
                        cell.frame = CGRectMake(0, 0, 300, 0);
                        cell.backgroundColor = [UIColor clearColor];
                        return cell;
                        
                    }
                    if([section_title isEqualToString:@""])
                    {
                        NSDictionary *header = [appDelegate.SFMPage objectForKey:@"header"];
                        section_title = [header objectForKey:@"hdr_Object_Label"];
                        section_title = [section_title stringByAppendingString:@" information"];
                        
                    }
                    if(section_title == nil)
                    {
                        NSDictionary *header = [appDelegate.SFMPage objectForKey:@"header"];
                        section_title = [header objectForKey:@"hdr_Object_Label"];
                        section_title = [section_title stringByAppendingString:@" information"];
                    }
                    
                    cellLabel.text = section_title;
                    NSLog(@"%@", cellLabel.text);
                }
                    if ([indexPath isEqual:lastSelectedIndexPath])
                    {
                        image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
                        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                        bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];
                        [bgImage setContentMode:UIViewContentModeScaleToFill];
                        cellLabel.textColor = [UIColor whiteColor];
                    }
                    else
                    {
                        image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
                        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                        bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];
                        [bgImage setContentMode:UIViewContentModeScaleToFill];
                        cellLabel.textColor = [UIColor blackColor];
                    }
                    break;
                    
                case 1:
                    bgView = [[[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, SectionHeaderHeight)] autorelease];
                {
                    NSArray *details = [appDelegate.SFMPage objectForKey:@"details"];
                    cellLabel.text = [[details objectAtIndex:indexPath.row] objectForKey:@"details_Object_Label"];
                }
                    if ([indexPath isEqual:lastSelectedIndexPath])
                    {
                        image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
                        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                        bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];
                        [bgImage setContentMode:UIViewContentModeScaleToFill];
                        cellLabel.textColor = [UIColor whiteColor];
                    }
                    else
                    {
                        image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
                        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                        bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];
                        [bgImage setContentMode:UIViewContentModeScaleToFill];
                        cellLabel.textColor = [UIColor blackColor];
                    }
                    break;
                case 2:
                    bgView = [[[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, SectionHeaderHeight)] autorelease];
                    if(product_history || account_history)
                    {
                        // cellLabel.text = [addition_info_items objectAtIndex:indexPath.row];
                        NSDictionary * additional_info_dict = [addition_info_items objectAtIndex:indexPath.row];
                        cellLabel.text = [additional_info_dict objectForKey:[[additional_info_dict allKeys] objectAtIndex:0]];
                    }
                    if ([indexPath isEqual:lastSelectedIndexPath])
                    {
                        image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
                        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                        bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];
                        [bgImage setContentMode:UIViewContentModeScaleToFill];
                        cellLabel.textColor = [UIColor whiteColor];
                    }
                    else
                    {
                        image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
                        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
                        bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];
                        [bgImage setContentMode:UIViewContentModeScaleToFill];
                        cellLabel.textColor = [UIColor blackColor];
                    }
                    break;
                default:
                    break;
            }
        }@catch (NSException *exp) {
            NSLog(@"Exception Name RootViewController :cellForRowAtIndexPath %@",exp.name);
            NSLog(@"Exception Reason RootViewController :cellForRowAtIndexPath %@",exp.reason);
        }
        
        if ([cellLabel.text length] > 0)
        {
            bgImage.frame = CGRectMake(0, 0, 300, SectionHeaderHeight);
            bgImage.tag = BGIMAGETAG;
            [bgView addSubview:bgImage];
            cellLabel.center = bgView.center;
            cellLabel.tag = CELLLABELTAG;
            [bgView addSubview:cellLabel];
            cell.backgroundView = bgView;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        return cell;
        
    }
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
}

-(void) didSelectHeader:(id)sender
{
    UITableViewCell * lastSelectedCell = [self.tableView cellForRowAtIndexPath:lastSelectedIndexPath];
    UIView * lastSelectedCellBackgroundView = lastSelectedCell.backgroundView;
    UIImageView * lastSelectedCellBGImage = (UIImageView *)[lastSelectedCellBackgroundView viewWithTag:BGIMAGETAG];
    [lastSelectedCellBGImage setImage:[UIImage imageNamed:@"SFM_left_button_UP.png"]];
    UILabel * lastSelectedCellLabel = (UILabel *)[lastSelectedCellBackgroundView viewWithTag:CELLLABELTAG];
    lastSelectedCellLabel.textColor = [UIColor blackColor];
    
    lastSelectedIndexPath = nil;
    
    delegate = appDelegate.sfmPageController.detailView;

    UIButton * buttn = (UIButton *) sender;
    [delegate didselectSection:buttn.tag];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.errorTableView)
    {
        if(errorDictonary != nil || errorDictonary != NULL)
        {
            NSMutableDictionary *SFMPageDetailDict=[errorDictonary objectForKey:@"SFMPPAGE_DETAILS"];
            NSLog(@"SFMPageHeaderDetail %@",SFMPageDetailDict);
            if([[SFMPageDetailDict allKeys] count]>0 && SFMPageDetailDict != nil && SFMPageDetailDict != NULL)
            {
                
                NSString *str= [[[[self.conflictsArray objectAtIndex:indexPath.row] objectForKey:@"ruleInfo"] objectForKey:@"bizRule"] objectForKey:@"SVMXC__Source_Object_Name__c"];
                NSLog(@"test string %@",str);
                
                if([[SFMPageDetailDict objectForKey:@"header"] isEqualToString:str])
                {
                    [appDelegate.sfmPageController.detailView  didselectSection:0];
                }
                else if([[[SFMPageDetailDict objectForKey:@"details"] objectAtIndex:0] isEqualToString:str]) // Defect 007562
                {
                    [appDelegate.sfmPageController.detailView  didselectSection:1];
                }
            }
            
        }
    }
    else
    {
        if(appDelegate.isSFMReloading)
        {
            return;
        }
        
         delegate = appDelegate.sfmPageController.detailView;
		//Radha :- Implementation  for  Required Field alert in Debrief UI
		[self highlightSelectRowWithIndexpath:indexPath];        
		[delegate didSelectRow:indexPath.row ForSection:indexPath.section];
     }

}
//Radha :- Implementation  for  Required Field alert in Debrief UI :- Highlighth's selected row
- (void) highlightSelectRowWithIndexpath:(NSIndexPath *)indexPath
{
    UIImage * image = nil;

    if (lastSelectedIndexPath == indexPath)
    {
        UITableViewCell * selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIView * cellBackgroundView = selectedCell.backgroundView;
        UIImageView * bgImage = (UIImageView *)[cellBackgroundView viewWithTag:BGIMAGETAG];
        image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
        image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
        [bgImage setImage:image];
        [bgImage setContentMode:UIViewContentModeScaleToFill];
        UILabel * selectedCellLabel = (UILabel *)[cellBackgroundView viewWithTag:CELLLABELTAG];
        selectedCellLabel.textColor = [UIColor whiteColor]; 
    }
    else
    {
        
        UITableViewCell * lastSelectedCell = [self.tableView cellForRowAtIndexPath:lastSelectedIndexPath];
        UIView * lastSelectedCellBackgroundView = lastSelectedCell.backgroundView;
        UIImageView * lastSelectedCellBGImage = (UIImageView *)[lastSelectedCellBackgroundView viewWithTag:BGIMAGETAG];
        image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        [lastSelectedCellBGImage setImage:image];
        [lastSelectedCellBGImage setContentMode:UIViewContentModeScaleToFill];
        UILabel * lastSelectedCellLabel = (UILabel *)[lastSelectedCellBackgroundView viewWithTag:CELLLABELTAG];
        lastSelectedCellLabel.textColor = [UIColor blackColor];
    }
    
    UITableViewCell * selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIView * cellBackgroundView = selectedCell.backgroundView;
    UIImageView * bgImage = (UIImageView *)[cellBackgroundView viewWithTag:BGIMAGETAG];
    image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    [bgImage setImage:image];
    [bgImage setContentMode:UIViewContentModeScaleToFill];
    UILabel * selectedCellLabel = (UILabel *)[cellBackgroundView viewWithTag:CELLLABELTAG];
    selectedCellLabel.textColor = [UIColor whiteColor];
    
    lastSelectedIndexPath = [indexPath retain];
}
- (void) refreshTable
{
    lastSelectedIndexPath = nil;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{   
    [selProcessBarButtonItem release];
    [super viewDidUnload];
    errorTableView.dataSource=nil;
    errorTableView.delegate=nil;
    errorTableView=nil;
    tableView.dataSource=nil;
    tableView.delegate=nil;
    tableView=nil;
    [conflictsArray release];
}

- (void)dealloc
{
    [detailViewController release];
    [tableView release];
    [errorTableView release];
    [super dealloc];
}
- (NSIndexPath *)getSelectedIndexPath {
    return lastSelectedIndexPath;
}

- (void)hideTableViewToRemoveError
{
    [UIView beginAnimations:@"animateDiaplyErrorTable" context:nil];
    [UIView setAnimationDuration:0.3];
    //    [self displayErrors];
    
    self.tableView.frame = CGRectMake(0,50, self.view.frame.size.width, self.view.frame.size.height);
    [self.view bringSubviewToFront:self.tableView];
    [UIView commitAnimations];
}

- (void)moveTableViewToDisplayError
{
    [UIView beginAnimations:@"animateRemoveErrorTable" context:nil];
    [UIView setAnimationDuration:0.3];
    
    [self.view bringSubviewToFront:self.errorTableView];
    [self displayErrors];
    [self.view bringSubviewToFront:self.tableView];
    [UIView commitAnimations];
    
}

- (void)handleTapGestute:(UITapGestureRecognizer *)gestureRecognizer
{
    if(self.errorTableView.frame.size.height >0)
    {
        if (isErrorDisplayed)
        {
            [self hideTableViewToRemoveError];
            isErrorDisplayed = NO;
        }
        else
        {
            [self moveTableViewToDisplayError];
            isErrorDisplayed = YES;
        }
    }
}

- (CGFloat) heightForTableView:(UITableView *)_tableView
{
    CGFloat tableViewHeight = 0;
    
    for (int i = 0; i < [_tableView numberOfSections]; i++)
    {
        CGRect sectionRect = [_tableView rectForSection:i];
        tableViewHeight += sectionRect.size.height;
    }
    
    NSLog(@"tableViewHeight %f",tableViewHeight);
    
    return tableViewHeight;
}

- (void) displayErrors
{
    
    self.conflictsArray = [errorDictonary objectForKey:@"RULE_ERROR"];
    [self.errorTableView reloadData];
    [self.tableView reloadInputViews];
    NSLog(@"self.frame %@",NSStringFromCGRect(self.view.frame));
    
    CGFloat errorTableViewHeight = [self heightForTableView:self.errorTableView];
    
    CGFloat maxHeight = self.view.frame.size.height/2.50;
    
    NSLog(@"maxHeight %f",maxHeight);
    
    
    if (errorTableViewHeight>maxHeight) {
        errorTableViewHeight = maxHeight;
    }
    
    NSLog(@"errorTableViewHeight %f",errorTableViewHeight);
    
    CGRect errorTableViewframe = CGRectMake(0, 0, self.view.bounds.size.width, errorTableViewHeight);
    [self.errorTableView setFrame:errorTableViewframe];
    UIImageView * bgImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]] autorelease];
    [self.errorTableView setBackgroundView:bgImage];
    [self.tableView setFrame:CGRectMake(0, errorTableViewHeight, self.view.bounds.size.width, self.view.bounds.size.height-errorTableViewHeight)];
}

- (void) hideErrors
{
    [self.errorTableView setFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.errorTableView reloadData];
    [self.tableView reloadInputViews];
}


@end
