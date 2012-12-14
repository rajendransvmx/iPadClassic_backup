//
//  RootViewController.m
//  project
//
//  Created by Developer on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "iServiceAppDelegate.h"
#import "WSIntfGlobals.h"
#import "SFMPageController.h"
extern void SVMXLog(NSString *format, ...);

@implementation RootViewController
	

@synthesize detailViewController, appDelegate, delegate;
@synthesize isinViewMode;
@synthesize AdditionalInfo;
@synthesize Work_order;
@synthesize account_history;
@synthesize product_history;
@synthesize addition_info_items;

#pragma mark Server Switchboard Results

- (void)loginResult:(ZKLoginResult *)result error:(NSError *)error
{
    if (result && !error)
    {
        SMLog(@"Hey, we logged in (with the new switchboard)!");
        
        didLogin = YES;
        
        appDelegate.loginResult = [result retain];
    }
    else if (error)
    {
        [self receivedErrorFromAPICall: error];
    }
}

-(void)receivedErrorFromAPICall:(NSError *)err 
{
	[appDelegate popupActionSheet:err.description];
}

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
    SMLog(@"describeSObjectResult: %@ error: %@ context: %@", result, error, context);
    if (result && !error)
    {
    }
    else if (error)
    {
        [self receivedErrorFromAPICall: error];
    }
}

- (void)describeSObjectsResult:(id)result error:(NSError *)error context:(id)context
{
    SMLog(@"describeSObjectsResult: %@ error: %@ context: %@", result, error, context);
    if (result && !error)
    {
    }
    else if (error)
    {
        [self receivedErrorFromAPICall:error];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
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
        SMLog(@"%@", str3);
        NSRange range = NSMakeRange(17,2);
        SMLog(@"%@", [recordTimeStamp stringByReplacingCharactersInRange:range withString:str3]);
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
    
    CGFloat  HeaderHeight = 0.0;;
    //return SectionHeaderHeight;
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
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIImageView * view = nil;
    NSString * sectionTitle = nil;
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
    return view;
  
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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

    return gNUM_SECTIONS_IN_TABLE;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) 
    {
        case 0:
        {
            NSDictionary *header = [appDelegate.SFMPage objectForKey:@"header"];
            NSArray * header_sections = [header objectForKey:@"hdr_Sections"];
            return [header_sections count];
        }
        case 1:
        {
            NSArray *details = [appDelegate.SFMPage objectForKey:@"details"];
            return [details count];
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
    
    return 1;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    UIView * bgView = nil;
    UIImageView * bgImage = nil;
    UIImage * image = nil;
    
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
                SMLog(@"%@", cellLabel.text);
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
    
    return cell;
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
    if(appDelegate.isSFMReloading)
    {
        return;
    }
    
    delegate = appDelegate.sfmPageController.detailView;

    [delegate didSelectRow:indexPath.row ForSection:indexPath.section];

    UIImage * image = nil;

    if (lastSelectedIndexPath == indexPath)
    {
        UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
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
        
        UITableViewCell * lastSelectedCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
        UIView * lastSelectedCellBackgroundView = lastSelectedCell.backgroundView;
        UIImageView * lastSelectedCellBGImage = (UIImageView *)[lastSelectedCellBackgroundView viewWithTag:BGIMAGETAG];
        image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        [lastSelectedCellBGImage setImage:image];
        [lastSelectedCellBGImage setContentMode:UIViewContentModeScaleToFill];
        UILabel * lastSelectedCellLabel = (UILabel *)[lastSelectedCellBackgroundView viewWithTag:CELLLABELTAG];
        lastSelectedCellLabel.textColor = [UIColor blackColor];
    }
    
    UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
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
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [detailViewController release];
    [super dealloc];
}

@end
