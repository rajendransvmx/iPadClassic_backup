
//
//  ManualDataSyncDetail.m
//  iService
//
//  Created by Parashuram on 14/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ManualDataSyncDetail.h"
#import "SyncStatusView.h"
#import "MySegmentedControl.h"
#import "AppDelegate.h"
#import "ManualDataSyncRoot.h"
#import "EventViewController.h"
#import "ManualDataSync.h"
#import "MultiLineController.h"
#import "Utility.h"
#import "CustomToolBar.h"
#import "SMXLogger.h"
#import "AttachmentDatabase.h"
#import "SVMXSystemConstant.h"
#import "AttachmentUtility.h"
#import "SMDataPurgeManager.h" //Radha - Data Purge
#import "SVMXSystemConstant.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@interface ManualDataSyncDetail()
//Data Purge
- (void)showSyncDueStatusView;
- (BOOL)checkIfDataPurgeInDue;
- (NSString *)getDPDueMessage;
- (void)showDataPurgeStatusView;
- (CGRect)getFrameForDueView;
- (void)addButtonsToDPDueView;
- (void)continueDataPurge;
- (void)rescheduleDataPurge;
- (void)removeDataPurgeDueView;
- (void)registerForServiceMaxDataPurgeProgressNotification;
- (void)deregisterForServiceMaxDataPurgeProgressNotification;
@end

@implementation ManualDataSyncDetail
@synthesize detailDelagate; //Data Purge


@synthesize rootSyncDelegate;
@synthesize  didAppearFromSFMScreen;
@synthesize  toolbar = _toolbar;
@synthesize  navigationBar; 
@synthesize  _tableView;
@synthesize  syncroniseButton;
@synthesize  popoverController;
@synthesize  toolBar;
@synthesize  dataSync;

@synthesize recordIdArray;
@synthesize objectsArray;
@synthesize objectsDict;
@synthesize objectDetailsArray,activity;
@synthesize internet_Conflicts;

@synthesize attachmentError;

PopoverButtons *popOver_view;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //7221
        statusButton = nil;
        button = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) Layout
{
	UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main.png"]];
    self._tableView.backgroundView = bgImage;
    [bgImage release];
	
	self._tableView.backgroundColor = [UIColor clearColor];
	
	UIImage *image = [UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"];
	UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)] autorelease];
	[backButton setBackgroundImage:image forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(DismissSplitView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
	self.navigationItem.leftBarButtonItem = backBarButtonItem;
	
	UILabel * titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_conflicts];
	titleLabel.font = [UIFont boldSystemFontOfSize:15];
	titleLabel.backgroundColor = [UIColor clearColor];
	[titleLabel sizeToFit];
	self.navigationItem.titleView = titleLabel;
	
	NSMutableArray *arrayForRightBarButton = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSInteger toolBarWidth = 0;
	const int SPACE_BUFFER = 4;
	
	UIBarButtonItem *activityButton = [[[UIBarButtonItem alloc] initWithCustomView:appDelegate.SyncProgress] autorelease];
	[arrayForRightBarButton addObject:activityButton];
	toolBarWidth += appDelegate.SyncProgress.frame.size.width + SPACE_BUFFER;
	if (button == nil) {
        button = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    }
    
	button.backgroundColor = [UIColor clearColor];
	[button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button"] forState:UIControlStateNormal];
	[button setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_synchronize_button] forState:UIControlStateNormal];
	[button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[button addTarget:self action:@selector(ShowActions) forControlEvents:UIControlEventTouchUpInside];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button sizeToFit];
	//Defect Fix :- 7454
	button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	toolBarWidth += button.frame.size.width + SPACE_BUFFER;
	UIBarButtonItem * barButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
	[arrayForRightBarButton addObject:barButton];
	//7221
    if (statusButton == nil)
    {
        statusButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    }
	statusButton.backgroundColor = [UIColor clearColor];
	[statusButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button"] forState:UIControlStateNormal];
	[statusButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button] forState:UIControlStateNormal];
	[statusButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[statusButton addTarget:self action:@selector(showSyncronisationStatus) forControlEvents:UIControlEventTouchUpInside];
	[statusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[statusButton sizeToFit];
	//Defect Fix :- 7454
	statusButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	toolBarWidth += statusButton.frame.size.width + SPACE_BUFFER;
	UIBarButtonItem * statusBarButton = [[[UIBarButtonItem alloc] initWithCustomView:statusButton] autorelease];
	[arrayForRightBarButton addObject:statusBarButton];
	
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    helpButton.backgroundColor = [UIColor clearColor];
    [helpButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
	[helpButton sizeToFit];
	toolBarWidth += helpButton.frame.size.width + SPACE_BUFFER;
    UIBarButtonItem * helpBarButton = [[[UIBarButtonItem alloc] initWithCustomView:helpButton] autorelease];
    [arrayForRightBarButton addObject:helpBarButton];
	
    /*ios7_support shravya-cutom toolbar*/
    CustomToolBar *myToolBar = [[CustomToolBar alloc] initWithFrame:CGRectMake(0, 0, toolBarWidth + 30, 44)];
    myToolBar.backgroundColor = [UIColor clearColor];
    [myToolBar setItems:arrayForRightBarButton];
	UIView *view = myToolBar;
	SMLog(kLogLevelVerbose, @"%f %f", view.frame.size.width, view.frame.size.height);
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:myToolBar] autorelease];
    [myToolBar release];
	
	[arrayForRightBarButton release];
	arrayForRightBarButton = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	CGRect rect = self.view.frame;
    /*ios7_support shravya-navbar*/
    if ([Utility notIOS7]) {
        self.navigationController.navigationBar.frame = CGRectMake(0, 0, rect.size.width, self.navigationController.navigationBar.frame.size.height);
    }
	else
    {
        /*ios7_support Kirti*/
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
	
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.reloadTable = self;
	
    if ([appDelegate.internet_Conflicts count] == 0)
        appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
    
    appDelegate.wsInterface.refreshSyncStatusUIButton = self;
    
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
	//    appDelegate.SyncProgress.center = CGPointMake(450,21);
	//    [self.navigationController.view addSubview:appDelegate.SyncProgress];
    
    //Radha 2012june16
	if ([appDelegate.dataBase checkIfSyncConfigDue])
	{
		if (syncDueView != nil)
			[syncDueView removeFromSuperview];
		[self showSyncDueStatusView]; //Data Purge
	}
    
    /*Radha - Data Purge - Check if datapurge in due*/
    if ([appDelegate doesServerSupportsModule:kMinPkgForDataPurge])
    {
        BOOL isPurgeDue = [self checkIfDataPurgeInDue];
        if (isPurgeDue)
        {
            [self showDataPurgeStatusView];
        }
    }
    
    self.attachmentError = [appDelegate.attachmentDataBase getErrorInAttachmentObject];
    [self  getFileNameForAttachments];
    
}



- (void) showHelp
{
	//Radha Fix for defect - 4690
	
	if (syncStatus.popOver != nil)
		[syncStatus.popOver dismissPopoverAnimated:YES];
	if (popOver_view.popover != nil)
		[self dismisspopover];
    [dataSync showHelp];

}


- (void)viewDidUnload
{
    //[_tableView release];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    @try{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (objectsDict == nil)
        objectsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    objectsArray  = [appDelegate.calDataBase getConflictObjects];   

    for(int i=0; i < [objectsArray count]; i++)
    {
        objectDetailsArray = [appDelegate.calDataBase getrecordIdsForObject:[objectsArray objectAtIndex:i]];
        
        [objectsDict setObject:objectDetailsArray forKey:[objectsArray objectAtIndex:i]];
    } 
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name ManualDataSyncDetail :viewWillAppear %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason ManualDataSyncDetail :viewWillAppear %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }  
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	[self Layout];
    [self registerForServiceMaxDataPurgeProgressNotification]; //Data Purge
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self deregisterForServiceMaxDataPurgeProgressNotification]; //Data Purge
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIDeviceOrientationIsPortrait(interfaceOrientation))
    {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSUInteger rowCount = 0;
	
    if ([appDelegate.internet_Conflicts count] > 0)
    {
        return 1;
    }
    
    if (selectedSection == 0 && HeaderSelected == 1)
	{
		rowCount = [objectsArray count];
		return rowCount;
	}
        
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSUInteger rowCount = 0;
    
    if(selectedSection == 0)
    {
        
        if (appDelegate.internet_Conflicts != nil && [appDelegate.internet_Conflicts count] > 0)
        {
            rowCount = [appDelegate.internet_Conflicts count];
            return rowCount;
        }

        else if ((objectsDict != nil) && ([objectsDict count] > 0) &&  objectsArray != nil && [objectsArray count] > 0)
        {
            if (HeaderSelected == 0)
            {
                rowCount =  [[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]] count];
                return rowCount;
            }
                
            else if (HeaderSelected == 1)
            {
                rowCount = [[objectsDict objectForKey:[objectsArray objectAtIndex:section]] count];
                return rowCount;

            }
            else
                return 0;
        }
        else
            return 0;
        
    }
    else if(selectedSection == 1)
    {
        NSLog(@"%@",self.attachmentError);
        return [self.attachmentError count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSInteger width = 660;
    
    //krishna 8570 ios7
    NSInteger xPad = 40;
    
    UIView *background = nil;
    
    UITableViewCell *cell = [self._tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)];
    }
    else{
        if([[cell.contentView subviews] count] == 0){
            cell.imageView.image = nil;
        }
        else{
            NSArray * subViews = [cell.contentView subviews];
            for (int i = 0; i < [subViews count]; i++){
                [[subViews objectAtIndex:i] removeFromSuperview];
            }
        } 
    }
    cell.accessoryView = nil;
    //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    if(background == nil){
        background = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)] autorelease];
    }
    UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
	
	UIImageView * bgView1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
	
	UIImageView * bgView2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
	
	CGPoint cellContentViewCenter = CGPointMake(self._tableView.center.x, background.center.y);
	cellContentViewCenter.y += 40;
	
	CGFloat borderRight = 124;
    if(selectedSection == 0)
    {
        if ( HeaderSelected == 1 )
        {
            if ([appDelegate.internet_Conflicts count] > 0)
            {
                UILabel * lbl;
                lbl = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
                lbl.text = [[appDelegate.internet_Conflicts objectAtIndex:0] objectForKey:@"sync_type"];
                lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                lbl.textColor = [UIColor blackColor];
                lbl.backgroundColor = [UIColor clearColor];
                lbl.userInteractionEnabled = YES;
                [lbl sizeToFit];
                [background addSubview:lbl];
                lbl.userInteractionEnabled = YES;
                
                UILabel *textView = [[UILabel alloc] initWithFrame:CGRectZero];
                textView.font = [UIFont systemFontOfSize:19.0];
                textView.text = [[appDelegate.internet_Conflicts objectAtIndex:0] objectForKey:@"Error_message"];
                textView.userInteractionEnabled = YES;
                textView.backgroundColor = [UIColor clearColor];
                [textView sizeToFit];
                [background addSubview:textView];
                
                CGPoint backgroundCenter = background.center;
                lbl.center = CGPointMake(backgroundCenter.x/2, backgroundCenter.y);
                textView.center = CGPointMake(3*backgroundCenter.x/2, backgroundCenter.y);
                
                UITapGestureRecognizer * tapMe3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
                [textView addGestureRecognizer:tapMe3];
                [tapMe3 release];
                
                        
                [bgView setBackgroundColor:[appDelegate colorForHex:@"#87AFC7"]];
                cell.backgroundView = bgView;
                
                //krishna 8570 ios7
                if(![Utility notIOS7]) {
                    CGRect someframe = background.frame;
                    someframe.origin.x = xPad;
                    background.frame = someframe;
                }
                
                [cell.contentView addSubview:background];
                [textView release];
                
                return cell;
            }
            
            //Please check this code 
            NSString * syncType = @"";
            NSString * override_flag = @"";
            NSString * api_name = @"";
            NSString * _apiName = @"";
            NSString * name = @"";
            NSString * SFId = @"";
            NSString * error_type = @"";
        
           SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"SFId"];
            api_name = [objectsArray objectAtIndex:indexPath.section];
            syncType = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"sync_type"];
            error_type = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"error_type"];
            
            override_flag = ([appDelegate.calDataBase getOverrideFlagStatusForId:SFId])?[appDelegate.calDataBase getOverrideFlagStatusForId:SFId]:@"";

            
            UILabel * lbl;
            lbl = [[[UILabel alloc] initWithFrame:CGRectMake(10, 9, 300, 30)] autorelease];
            _apiName = [appDelegate.databaseInterface getFieldNameForReferenceTable:api_name tableName:@"SFObjectField"];
            name = [appDelegate.calDataBase getnameFieldForObject:api_name WithId:SFId WithApiName:_apiName];
            api_name = [appDelegate.databaseInterface getFieldNameForReferenceTable:api_name tableName:@"SFObjectField"];
            lbl.text = name;
            lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
            lbl.textColor = [UIColor blackColor];
            lbl.backgroundColor = [UIColor clearColor];
            [background addSubview:lbl];
            lbl.userInteractionEnabled = YES;
            
            UITapGestureRecognizer * tapMe1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [lbl addGestureRecognizer:tapMe1];
            [tapMe1 release];
            
            //Change of implementation.
            NSString * retry  = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_retry];
            NSString * remove = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_remove];
            NSString * hold   = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_hold];
            NSString * force  = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_applymy];
            NSString * get_from_online = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_getFrom];
            NSString * online = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_select_online];
            NSString * changes = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_changes];
            NSString * ignore = @"Ignore";
            
            UISegmentedControl * mySegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@ %@", force, changes],[NSString stringWithFormat:@"%@ %@", get_from_online, online],hold, nil]];
            mySegment.segmentedControlStyle = UISegmentedControlStyleBar;
            /*ios7_support Kirti*/
            if(![Utility notIOS7])
                mySegment.backgroundColor=[UIColor lightGrayColor];
            [mySegment sizeToFit];
                    
            UISegmentedControl * mySegment1 = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:retry,remove,hold,nil]];
            mySegment1.segmentedControlStyle = UISegmentedControlStyleBar;
            /*ios7_support Kirti*/
            if(![Utility notIOS7])
                mySegment1.backgroundColor=[UIColor lightGrayColor];
            [mySegment1 sizeToFit];
                    
            UISegmentedControl * mySegment2 = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:retry, [NSString stringWithFormat:@"%@ %@", get_from_online, online],hold,nil]];
            mySegment2.segmentedControlStyle = UISegmentedControlStyleBar;
            /*ios7_support Kirti*/
            if(![Utility notIOS7])
                mySegment2.backgroundColor=[UIColor lightGrayColor];
            [mySegment2 sizeToFit];
            
            
            //sync_override
            UISegmentedControl * related_record_error_segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:retry,ignore,hold,nil]];
            related_record_error_segment.segmentedControlStyle = UISegmentedControlStyleBar;
            /*ios7_support Kirti*/
            if(![Utility notIOS7])
                related_record_error_segment.backgroundColor=[UIColor lightGrayColor];
            [related_record_error_segment sizeToFit];
            
            

            UIColor *newTintColor = [appDelegate colorForHex:@"#C8C8C8"];
            /*ios7_support Kirti*/
            if([Utility notIOS7])
            {
                newTintColor = [UIColor whiteColor];
            }
            mySegment.tintColor = newTintColor;
            mySegment1.tintColor = newTintColor;
            mySegment2.tintColor = newTintColor;
            related_record_error_segment.tintColor = newTintColor;
            
            if ([syncType isEqualToString:@"PUT_INSERT"] || [syncType isEqualToString:@"GET_INSERT"])
            {
                [bgView setBackgroundColor:[appDelegate colorForHex:[appDelegate.settingsDict objectForKey:@"IPAD018_SET001"]]]; 
                cell.backgroundView = bgView;
                
                [cell.contentView addSubview:mySegment1];
            }
            
            if ([syncType isEqualToString:@"PUT_DELETE"] || [syncType isEqualToString:@"GET_DELETE"])
            {
                [bgView1 setBackgroundColor:[appDelegate colorForHex:[appDelegate.settingsDict objectForKey:@"IPAD018_SET003"]]];
                cell.backgroundView = bgView1;

                [cell.contentView addSubview:mySegment2];
            }
            
            if (([syncType isEqualToString:@"PUT_UPDATE"] || [syncType isEqualToString:@"GET_UPDATE"])&& [error_type isEqualToString:@"ERROR"] )
            {
                [bgView2 setBackgroundColor:[appDelegate colorForHex:[appDelegate.settingsDict objectForKey:@"IPAD018_SET002"]]];
                cell.backgroundView = bgView2;

                [cell.contentView addSubview:mySegment2];
            }
            
            if (([syncType isEqualToString:@"PUT_UPDATE"] || [syncType isEqualToString:@"GET_UPDATE"])&& [error_type isEqualToString:@"CONFLICT"] )
            {
                [bgView2 setBackgroundColor:[appDelegate colorForHex:[appDelegate.settingsDict objectForKey:@"IPAD018_SET002"]]];
                cell.backgroundView = bgView2;

                [cell.contentView addSubview:mySegment];
            }

            if([syncType isEqualToString:RELATED_REC_ERROR] || [syncType isEqualToString:CUSTOM_SYNC_SOAP_FAULT] )
            {
                [bgView2 setBackgroundColor:[appDelegate colorForHex:[appDelegate.settingsDict objectForKey:@"IPAD018_SET001"] ]];
                cell.backgroundView = bgView2;
                [cell.contentView addSubview:related_record_error_segment];
                
            }
            
            [mySegment  addTarget:self action:@selector(segmentControlSelected:) forControlEvents:UIControlEventValueChanged];
            [mySegment1 addTarget:self action:@selector(segmentControlSelected1:) forControlEvents:UIControlEventValueChanged];
            [mySegment2 addTarget:self action:@selector(segmentControlSelected2:) forControlEvents:UIControlEventValueChanged];
            [related_record_error_segment addTarget:self action:@selector(relatedrecordErrorSegmentSelected:) forControlEvents:UIControlEventValueChanged];
            /*ios7_support Kirti*/

            if([Utility notIOS7])
            {
                if ( [override_flag isEqualToString:@"Client_Override"])
                {
                    [[[mySegment subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                }
                else if ([override_flag isEqualToString:@"None"]||[override_flag isEqualToString:@""])
                {
                    [[[mySegment subviews] objectAtIndex:2] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    [[[mySegment1 subviews] objectAtIndex:2] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    [[[mySegment2 subviews] objectAtIndex:2] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    [[[related_record_error_segment subviews] objectAtIndex:2] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                }
                else if ([override_flag isEqualToString:@"Server_Override"]||[override_flag isEqualToString:@""])
                {
                    [[[mySegment subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    [[[mySegment2 subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                }
                else if ([override_flag isEqualToString:@"retry"]||[override_flag isEqualToString:@""])
                {
                    [[[mySegment1 subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    [[[mySegment2 subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    [[[related_record_error_segment subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                }
                else if ([override_flag isEqualToString:@"remove"]||[override_flag isEqualToString:@""])
                {
                    [[[mySegment1 subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    
                }
                 else if([override_flag isEqualToString:@"IGNORE"])
                 {
                     [[[related_record_error_segment subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                 }
                    
            }
            else
            {
                UIFont *font = [UIFont boldSystemFontOfSize:14.0f];
                NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                                       forKey:NSFontAttributeName];
                [mySegment setTitleTextAttributes:attributes
                                                forState:UIControlStateNormal];
                [mySegment1 setTitleTextAttributes:attributes
                                         forState:UIControlStateNormal];
                [mySegment2 setTitleTextAttributes:attributes
                                         forState:UIControlStateNormal];
                [related_record_error_segment setTitleTextAttributes:attributes
                                         forState:UIControlStateNormal];
                [mySegment setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                [mySegment1 setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                [mySegment2 setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                [related_record_error_segment setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                if ( [override_flag isEqualToString:@"Client_Override"])
                {
                    mySegment.selectedSegmentIndex=0;
                }
                else if ([override_flag isEqualToString:@"None"]||[override_flag isEqualToString:@""])
                {
                    mySegment.selectedSegmentIndex=2;
                    mySegment1.selectedSegmentIndex=2;
                    mySegment2.selectedSegmentIndex=2;
                    related_record_error_segment.selectedSegmentIndex=2;
                }
                else if ([override_flag isEqualToString:@"Server_Override"]||[override_flag isEqualToString:@""])
                {
                    mySegment.selectedSegmentIndex=1;
                    mySegment2.selectedSegmentIndex=1;
                }
                else if ([override_flag isEqualToString:@"retry"]||[override_flag isEqualToString:@""])
                {
                    mySegment1.selectedSegmentIndex=0;
                    mySegment2.selectedSegmentIndex=0;
                    related_record_error_segment.selectedSegmentIndex=0;
                }
                else if ([override_flag isEqualToString:@"remove"]||[override_flag isEqualToString:@""])
                {
                    mySegment1.selectedSegmentIndex=1;
                }
                else if([override_flag isEqualToString:@"IGNORE"])
                {
                    related_record_error_segment.selectedSegmentIndex=1;
                }
                
            }
            
            cellContentViewCenter.x = (self._tableView.frame.size.width - mySegment.frame.size.width/2) - borderRight;
            mySegment.center = cellContentViewCenter;
            
            cellContentViewCenter.x = (self._tableView.frame.size.width - mySegment1.frame.size.width/2) - borderRight;
            mySegment1.center = cellContentViewCenter;
            
            cellContentViewCenter.x = (self._tableView.frame.size.width - mySegment2.frame.size.width/2) - borderRight;
            mySegment2.center = cellContentViewCenter;
                 
                 
            cellContentViewCenter.x = (self._tableView.frame.size.width - related_record_error_segment.frame.size.width/2) - borderRight;
            related_record_error_segment.center = cellContentViewCenter;

            [mySegment release];
            [mySegment1 release];
            [mySegment2 release];
            [related_record_error_segment release];
                 
            mySegment = nil;
            mySegment1 = nil;
            mySegment2 = nil;
            related_record_error_segment = nil;
                 
                 
            UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(180, 3, 200, 50)];
            textView.font = [UIFont systemFontOfSize:19.0];
            textView.text = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"Error_message"];
            textView.userInteractionEnabled = YES;
            textView.backgroundColor = [UIColor clearColor];
            
            UITapGestureRecognizer * tapMe2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [textView addGestureRecognizer:tapMe2];
            [tapMe2 release];
            
            [background addSubview:textView];
            
            //krishna 8570 ios7
            //header pressed
            if(![Utility notIOS7]) {
                CGRect someframe = background.frame;
                someframe.origin.x = xPad-10;//extra 10 to mentain the consistency.
                background.frame = someframe;
            }

            [cell.contentView addSubview:background];
            [textView release];
            
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaBold" size:19]; 
            
            //New Code.
            if ([syncType isEqualToString:@"PUT_DELETE"] || [syncType isEqualToString:RELATED_REC_ERROR]  || [syncType isEqualToString:CUSTOM_SYNC_SOAP_FAULT])
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }else{
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            }
        }
        if ( selectedSection == 0 && HeaderSelected == 0)
        {
                if ([appDelegate.internet_Conflicts count] > 0)
                {
                    UILabel * lbl;
                    lbl = [[[UILabel alloc] initWithFrame:CGRectMake(10, 9, 300, 30)] autorelease];
                    lbl.text = [[appDelegate.internet_Conflicts objectAtIndex:0] objectForKey:@"Error_message"];
                    lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                    lbl.textColor = [UIColor blackColor];
                    lbl.backgroundColor = [UIColor clearColor];
                    lbl.userInteractionEnabled = YES;
                    [background addSubview:lbl];
                    
                    
                    UILabel * textView = [[UILabel alloc] initWithFrame:CGRectMake(180, 3, 300, 50)];
                    textView.font = [UIFont systemFontOfSize:19.0];
                    textView.text = [[appDelegate.internet_Conflicts objectAtIndex:0] objectForKey:@"sync_type"];
                    textView.userInteractionEnabled = YES;
                    textView.backgroundColor = [UIColor clearColor];
                    [background addSubview:textView];
                    
                    UITapGestureRecognizer * tapMe3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
                    [textView addGestureRecognizer:tapMe3];
                    [tapMe3 release];
                    
            
                  

                    [bgView setBackgroundColor:[appDelegate colorForHex:@"#87AFC7"]];
                    cell.backgroundView = bgView;        

                    //krishna 8570 ios7
                    
                    //first time + internet conflict
                    if(![Utility notIOS7]) {
                        CGRect someframe = background.frame;
                        someframe.origin.x = xPad;
                        background.frame = someframe;
                    }

                    
                    [cell.contentView addSubview:background];
                    [textView release];
                   
                    
                    return cell;
                }

                NSString * syncType = @"";
                NSString * api_name = @"";
                NSString * _apiName = @"";
                NSString * name = @"";
                NSString * SFId = @"";
                NSString * override_flag = @"";
                NSString * error_type = @"";
                
                SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"SFId"];
                api_name = [objectsArray objectAtIndex:selectedRow];
                syncType = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"sync_type"];
                 error_type = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"error_type"];
                override_flag = ([appDelegate.calDataBase getOverrideFlagStatusForId:SFId])?[appDelegate.calDataBase getOverrideFlagStatusForId:SFId]:@"";
                SMLog(kLogLevelVerbose,@"%@", override_flag);
                
                
                UILabel * lbl;
                lbl = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
                _apiName = [appDelegate.databaseInterface getFieldNameForReferenceTable:api_name tableName:@"SFObjectField"];
                name = [appDelegate.calDataBase getnameFieldForObject:api_name WithId:SFId WithApiName:_apiName];
                lbl.text = name;
                lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                lbl.textColor = [UIColor blackColor];
                lbl.backgroundColor = [UIColor clearColor];
                [lbl sizeToFit];
                [background addSubview:lbl];
                lbl.userInteractionEnabled = YES;
                
                UITapGestureRecognizer * tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
                [lbl addGestureRecognizer:tapMe];
                [tapMe release];
                
                
                //Change of implementation.
                NSString * retry  = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_retry];
                NSString * remove = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_remove];
                NSString * hold   = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_hold];
                NSString * force  = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_applymy];
                NSString * get_from_online = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_getFrom];
                NSString * online = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_select_online];
                NSString * changes = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_changes];
                NSString * ignore = @"Ignore";

                UISegmentedControl * mySegment =[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@ %@", force, changes],[NSString stringWithFormat:@"%@ %@", get_from_online, online],hold, nil]];
                mySegment.segmentedControlStyle = UISegmentedControlStyleBar;
                /*ios7_support Kirti*/
                if(![Utility notIOS7])
                    mySegment.backgroundColor=[UIColor lightGrayColor];
                [mySegment sizeToFit];

                UISegmentedControl * mySegment1 = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:retry,remove,hold,nil]];
                mySegment1.segmentedControlStyle = UISegmentedControlStyleBar;
                /*ios7_support Kirti*/
                if(![Utility notIOS7])
                    mySegment1.backgroundColor=[UIColor lightGrayColor];
                [mySegment1 sizeToFit];
                
                UISegmentedControl * mySegment2 = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:retry,[NSString stringWithFormat:@"%@ %@", get_from_online, online],hold,nil]];
                mySegment2.segmentedControlStyle = UISegmentedControlStyleBar;
                /*ios7_support Kirti*/
                if(![Utility notIOS7])
                    mySegment2.backgroundColor=[UIColor lightGrayColor];
                [mySegment2 sizeToFit];
                
                
                //sync_override
                UISegmentedControl * related_record_error_segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:retry,ignore,hold,nil]];
                related_record_error_segment.segmentedControlStyle = UISegmentedControlStyleBar;
                /*ios7_support Kirti*/
                if(![Utility notIOS7])
                    related_record_error_segment.backgroundColor=[UIColor lightGrayColor];
                [related_record_error_segment sizeToFit];
                
                
                

                if ([syncType isEqualToString:@"PUT_INSERT"] || [syncType isEqualToString:@"GET_INSERT"])
                {
                    [bgView setBackgroundColor:[appDelegate colorForHex:[appDelegate.settingsDict objectForKey:@"IPAD018_SET001"]]];
                    cell.backgroundView = bgView;
                    
                    [cell.contentView addSubview:mySegment1];
                }
                
                if ([syncType isEqualToString:@"PUT_DELETE"] || [syncType isEqualToString:@"GET_DELETE"])
                {
                    [bgView1 setBackgroundColor:[appDelegate colorForHex:[appDelegate.settingsDict objectForKey:@"IPAD018_SET003"]]];
                    cell.backgroundView = bgView1;
                    
                    [cell.contentView addSubview:mySegment2];
                }
                
                if (([syncType isEqualToString:@"PUT_UPDATE"] || [syncType isEqualToString:@"GET_UPDATE"])&& [error_type isEqualToString:@"ERROR"] )
                {
                    [bgView2 setBackgroundColor:[appDelegate colorForHex:[appDelegate.settingsDict objectForKey:@"IPAD018_SET002"]]];
                    cell.backgroundView = bgView2;
                    
                    [cell.contentView addSubview:mySegment2];
                }
                
                if (([syncType isEqualToString:@"PUT_UPDATE"] || [syncType isEqualToString:@"GET_UPDATE"])&& [error_type isEqualToString:@"CONFLICT"] )
                {
                    [bgView2 setBackgroundColor:[appDelegate colorForHex:[appDelegate.settingsDict objectForKey:@"IPAD018_SET002"]]];
                    cell.backgroundView = bgView2;
                    
                    [cell.contentView addSubview:mySegment];
                }
                
                if([syncType isEqualToString:RELATED_REC_ERROR] || [syncType isEqualToString:CUSTOM_SYNC_SOAP_FAULT])
                {
                    [bgView2 setBackgroundColor:[appDelegate colorForHex:[appDelegate.settingsDict objectForKey:@"IPAD018_SET002"]]];
                    cell.backgroundView = bgView1;
                    [cell.contentView addSubview:related_record_error_segment];
                }

                UIColor *newTintColor = [appDelegate colorForHex:@"#C8C8C8"];
                /*ios7_support Kirti*/
                if(![Utility notIOS7])
                {
                    newTintColor = [UIColor whiteColor];
                }
                mySegment.tintColor = newTintColor;
                mySegment1.tintColor = newTintColor;
                mySegment2.tintColor = newTintColor;
                related_record_error_segment.tintColor = newTintColor;
                
                [mySegment addTarget:self action:@selector(segmentControlSelected:) forControlEvents:UIControlEventValueChanged];
                
                [mySegment1 addTarget:self action:@selector(segmentControlSelected1:) forControlEvents:UIControlEventValueChanged];
                [mySegment2 addTarget:self action:@selector(segmentControlSelected2:) forControlEvents:UIControlEventValueChanged];
                [related_record_error_segment addTarget:self action:@selector(relatedrecordErrorSegmentSelected:) forControlEvents:UIControlEventValueChanged];
                /*ios7_support Kirti*/

                if([Utility notIOS7])
                {
                    if ( [override_flag isEqualToString:@"Client_Override"])
                    {
                        [[[mySegment subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    }
                    else if ([override_flag isEqualToString:@"None"]||[override_flag isEqualToString:@""])
                    {
                        [[[mySegment subviews] objectAtIndex:2] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                        [[[mySegment1 subviews] objectAtIndex:2] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                        [[[mySegment2 subviews] objectAtIndex:2] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                        [[[related_record_error_segment subviews] objectAtIndex:2] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    }
                    else if ([override_flag isEqualToString:@"Server_Override"]||[override_flag isEqualToString:@""])
                    {
                        [[[mySegment subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                        [[[mySegment2 subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    }
                    else if ([override_flag isEqualToString:@"retry"]||[override_flag isEqualToString:@""])
                    {
                        [[[mySegment1 subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                        [[[mySegment2 subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                        [[[related_record_error_segment subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    }
                    else if ([override_flag isEqualToString:@"remove"]||[override_flag isEqualToString:@""])
                    {
                        [[[mySegment1 subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                        
                    }
                    else if([override_flag isEqualToString:@"IGNORE"])
                    {
                        [[[related_record_error_segment subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    }
                    
                }
                else
                {
                    UIFont *font = [UIFont boldSystemFontOfSize:14.0f];
                    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                                           forKey:NSFontAttributeName];
                    [mySegment setTitleTextAttributes:attributes
                                             forState:UIControlStateNormal];
                    [mySegment1 setTitleTextAttributes:attributes
                                              forState:UIControlStateNormal];
                    [mySegment2 setTitleTextAttributes:attributes
                                              forState:UIControlStateNormal];
                    [related_record_error_segment setTitleTextAttributes:attributes
                                                                forState:UIControlStateNormal];
                    [mySegment setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    [mySegment1 setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    [mySegment2 setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    [related_record_error_segment setTintColor:[appDelegate colorForHex:@"#1589FF"]];
                    if ( [override_flag isEqualToString:@"Client_Override"])
                    {
                        mySegment.selectedSegmentIndex=0;
                        
                    }
                    else if ([override_flag isEqualToString:@"None"]||[override_flag isEqualToString:@""])
                    {
                        mySegment.selectedSegmentIndex=2;
                        mySegment1.selectedSegmentIndex=2;
                        mySegment2.selectedSegmentIndex=2;
                        related_record_error_segment.selectedSegmentIndex=2;
                        
                    }
                    else if ([override_flag isEqualToString:@"Server_Override"]||[override_flag isEqualToString:@""])
                    {
                        mySegment.selectedSegmentIndex=1;
                        mySegment2.selectedSegmentIndex=1;
                    }
                    else if ([override_flag isEqualToString:@"retry"]||[override_flag isEqualToString:@""])
                    {
                        mySegment1.selectedSegmentIndex=0;
                        mySegment2.selectedSegmentIndex=0;
                        related_record_error_segment.selectedSegmentIndex=0;
                    }
                    else if ([override_flag isEqualToString:@"remove"]||[override_flag isEqualToString:@""])
                    {
                        mySegment1.selectedSegmentIndex=1;
                        
                    }
                    else if([override_flag isEqualToString:@"IGNORE"])
                    {
                        related_record_error_segment.selectedSegmentIndex=1;
                    }
                    
                }
                cellContentViewCenter.x = (self._tableView.frame.size.width - mySegment.frame.size.width/2) - borderRight;
                mySegment.center = cellContentViewCenter;
                
                cellContentViewCenter.x = (self._tableView.frame.size.width - mySegment1.frame.size.width/2) - borderRight;
                mySegment1.center = cellContentViewCenter;
                
                cellContentViewCenter.x = (self._tableView.frame.size.width - mySegment2.frame.size.width/2) - borderRight;
                mySegment2.center = cellContentViewCenter;
                
                
                cellContentViewCenter.x = (self._tableView.frame.size.width - related_record_error_segment.frame.size.width/2) - borderRight;
                related_record_error_segment.center = cellContentViewCenter;
                
                [mySegment release];
                [mySegment1 release];
                [mySegment2 release];
                [related_record_error_segment release];
                
                mySegment = nil;
                mySegment1 = nil;
                mySegment2 = nil;
                related_record_error_segment = nil;
                
                UILabel *textView = [[UILabel alloc] initWithFrame:CGRectZero];
                textView.font = [UIFont systemFontOfSize:19.0];
             
                textView.text = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"Error_message"];
                textView.userInteractionEnabled = YES;
                textView.backgroundColor = [UIColor clearColor];
                [textView sizeToFit];
                
                UITapGestureRecognizer * _tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
                [textView addGestureRecognizer:_tapMe];
                [_tapMe release];
                
                [background addSubview:textView];
                
                //krishna 8570 ios7
                CGPoint backgroundCenter = background.center;
                
                if(![Utility notIOS7]) {
                    CGRect someframe = background.frame;
                    someframe.origin.x = xPad;
                    background.frame = someframe;
                }

                [cell.contentView addSubview:background];
                [textView release];
                
                CGRect rect = lbl.frame;
                rect.size.width = 250;
                lbl.frame = rect;
                
                rect = textView.frame;
                rect.size.width = 350;
                textView.frame = rect;
                
                lbl.center = CGPointMake(backgroundCenter.x/2 - 40, backgroundCenter.y);
                textView.center = CGPointMake(3*backgroundCenter.x/2 - 80, backgroundCenter.y);
                
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                
                //New Code.
                if ([syncType isEqualToString:@"PUT_DELETE"] || [syncType isEqualToString:RELATED_REC_ERROR] || [syncType isEqualToString:CUSTOM_SYNC_SOAP_FAULT])
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                }

            }
    }
    else if(selectedSection == 1)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self addViewsToattachmentView:cell indexPath:indexPath];
        cell.backgroundView = bgView;
    }
    return cell;
}

//- (NSString *)getRestAPIErrorMessage:(int)restApiErrorCode
//{
//    NSString *errorMessage = nil;
//    switch (restApiErrorCode)
//    {
//        case SMAttachmentRequestErrorCodeDataCorruption:
//        {
//            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:DATA_CORRUPTION_ERROR];
//        }
//            break;
//            
//        case SMAttachmentRequestErrorCodeFileNotFound:
//        {
//             errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:FILE_NOT_FOUND_ERROR];
//        }
//            break;
//            
//        case SMAttachmentRequestErrorCodeFileNotSaved:
//        {
//            
//             errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:FILE_NOT_FOUND_LOCALLY];
//        }
//            
//        break;
//            
//        case SMAttachmentRequestErrorCodeUnauthorizedAccess:
//        {
//            
//            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:UNAUTHORIZED_ACCESS];
//        }
//        break;
//        
//        case SMAttachmentRequestErrorCodeRequestTimeOut:
//        {
//            
//            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:NETWORK_CONNECTION_TIMEOUT];
//        }
//        break;
//        
//        case SMAttachmentRequestErrorCodeUnknown:
//        {
//            
//            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:UNKNOWN_ERROR];
//        }
//        break;
//            
//        default:
//           //errorMessage = [SVMXSystemConstant restAPIErrorMessageByErrorCode:restApiErrorCode];
//            errorMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:UNKNOWN_ERROR];//9237
//            break;
//    }
//    
//
//    return errorMessage;
//    
//}

-(void)addViewsToattachmentView:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary * dict = [attachmentError objectAtIndex:indexPath.row];
    NSString * errorMsg = [dict objectForKey:mkErrorMsg];
    NSString * errorCode = [dict objectForKey:mkErrorCode];
    NSString * filename = [dict objectForKey:mkFileName];
    NSString * syncFlag = [dict objectForKey:mkSyncFlag];
    NSString * action = [dict objectForKey:mkAction];
     NSString *  attachmentid = [dict objectForKey:mkAttachmentTrailerId];
    
    int restApiErrorCode = [errorCode intValue];
    NSString * value  = [AttachmentUtility getAttachmentAPIErrorMessage:restApiErrorCode];//9212
    
 //  NSString * value = [SVMXSystemConstant restAPIErrorMessageByErrorCode:[errorCode intValue]];
    
    
    NSString * actionMsg1 = ([action isEqualToString:@"DOWNLOAD"])?@"Error in downloading file: ":@"Error in uploading file: ";
    NSString * actionMsg = [NSString stringWithFormat:@"%@ %@",actionMsg1,filename];
    
    CGRect actionLabelrect = CGRectMake(10, 5, 480, 30);
    CGRect  errorMsg_label =  CGRectMake(10, 35, 480, 30);
    
    UILabel * Actionlabel = [self addLabelForFrame:actionLabelrect text:actionMsg];
    UILabel * errorlabel   = [self addLabelForFrame:errorMsg_label text:value];
   
    
    [cell.contentView addSubview:Actionlabel];
    [cell.contentView addSubview:errorlabel];
    
    [Actionlabel release];
    [errorlabel release];
    
    
    NSString * retry  = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_retry];
    NSString * remove = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_remove];
   
    if([syncFlag length] == 0)
    {
        [appDelegate.attachmentDataBase updateSyncFlagWithAttachmentId:attachmentid Withsyncflag:@"Remove"];
    }
    
    NSArray * itemsArray = [NSArray arrayWithObjects:remove,retry, nil];
    MySegmentedControl * segmentControl_ = [self getSegmentControllerWithFrame:CGRectMake(490, 20, 30, 30) itemsArray:itemsArray setIndex:[self getIndex:syncFlag]];
    segmentControl_.myIndexPath = indexPath;
    [cell.contentView addSubview:segmentControl_];
    
}
-(NSInteger)getIndex:(NSString *)syncFlag
{
    NSInteger index = 0;
    if ([syncFlag isEqualToString:@"Retry"])
    {
        index = 1;
    }
    return index;
}
-(MySegmentedControl *)getSegmentControllerWithFrame:(CGRect)frame itemsArray:(NSArray *)itemsArray setIndex:(NSInteger)index
{
    MySegmentedControl *mainSegment = [[MySegmentedControl alloc] initWithItems:itemsArray];
    
    [mainSegment setSegmentedControlStyle:UISegmentedControlStyleBar];
    mainSegment.frame = frame;
    [mainSegment sizeToFit];
    mainSegment.selectedSegmentIndex = index;
    [mainSegment addTarget:self action:@selector(AttachmentSegmentControl:) forControlEvents: UIControlEventValueChanged];
    return mainSegment;
}
-(UILabel *)addLabelForFrame:(CGRect)frame text:(NSString *)text
{
      UILabel * Action_label = [[UILabel alloc] initWithFrame:frame];
    Action_label.text = text;
    Action_label.backgroundColor=[UIColor clearColor];
    //defect #9192
    Action_label.userInteractionEnabled = TRUE;
    UITapGestureRecognizer * tapObject = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    [Action_label addGestureRecognizer:tapObject];
    [tapObject release];
    return Action_label;
    
}
-(void)AttachmentSegmentControl:(id)sender
{
    MySegmentedControl *attachmentsegment = (MySegmentedControl *)sender;
    NSIndexPath * path =  attachmentsegment.myIndexPath;
    int row = path.row;
//    NSIndexPath *indexpath = [self._tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];;
//    int row = indexpath.row;
    int index = attachmentsegment.selectedSegmentIndex;
    NSString * syncflag = (index == 0)?@"Remove":@"Retry";
    NSDictionary * dict = [attachmentError objectAtIndex:row];
    [dict setValue:syncflag forKey:mkSyncFlag];
    NSString * attachmentId = [dict objectForKey:mkAttachmentTrailerId];
    [appDelegate.attachmentDataBase updateSyncFlagWithAttachmentId:attachmentId Withsyncflag:syncflag];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedSection == 0)
        return 70.0;
    else
        return 70.0;
}


 - (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
	NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
	NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];

    NSString * SFId          = @"";
    NSString * objectAPIName = @"";
    NSString * sync_type     = @"";
    NSString * processId     = @"";
    NSString * localId = @"";
    @try{
    if (selectedSection == 0 && HeaderSelected == 0)
    {
        objectAPIName = [objectsArray objectAtIndex:selectedRow];
        sync_type = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"sync_type"];
        
        if ([sync_type isEqualToString:@"PUT_INSERT"])
        {
            localId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"local_id"];
        }
        else 
        {
            SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"SFId"]; 
        }
       
        if ( [objectsDict count] > 0)
        {
            if ([[[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"record_type"] isEqualToString:@"MASTER"])
            {
                SMLog(kLogLevelVerbose,@"%@", appDelegate.view_layout_array);
                for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
                {
                    NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                    NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                    SMLog(kLogLevelVerbose,@"%@ %@", object_label, objectAPIName);
                    if ([object_label isEqualToString:objectAPIName])
                    {
                        processId = ([dict objectForKey:VIEW_SVMXC_ProcessID]!=nil)?[dict objectForKey:VIEW_SVMXC_ProcessID]:@"";
                        break;
                    }
                }
                //Radha 2012june11
                if ([SFId length])
                    localId = [self getlocalIdForSFId:SFId ForObject:objectAPIName];
                [dataSync showSFMWithProcessId:processId recordId:localId objectName:objectAPIName];
                
            }
            else if ([[[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"record_type"] isEqualToString:@"DETAIL"])
            {
				if ([SFId length])
					localId = [self getlocalIdForSFId:SFId ForObject:objectAPIName];

				processInfo * pinfo =  [appDelegate getViewProcessForObject:objectAPIName record_id:localId processId:@"" isswitchProcess:FALSE];
				BOOL process_exist = pinfo.process_exists;
				
				//check For view process
				if(process_exist)
				{
					NSString * process_id = pinfo.process_id;
					[dataSync showSFMWithProcessId:process_id recordId:localId objectName:objectAPIName];

				}
				else{
					
					NSString *parent_obj_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectAPIName field_name:@"parent_name"];
					NSString * parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectAPIName field_name:@"parent_column_name"];
					
					SMLog(kLogLevelVerbose,@"%@ %@", parent_obj_name, parent_column_name);
					
					SMLog(kLogLevelVerbose,@"%@", SFId);
					NSString * parent_local_id = @"";
					
					if ([SFId length] > 0 && SFId != nil && ![SFId isEqualToString:@""])
					{
						parent_local_id = [appDelegate.dataBase getParentColumnValueFromchild:parent_obj_name childTable:objectAPIName sfId:SFId];
					}
					else
					{
						parent_local_id = [appDelegate.dataBase getParentlocalIdchild:parent_obj_name childTable:objectAPIName local_id:localId];
					}
										
					//If the detail does not have a parent reference i.e parent_local_id = nil
					if ( parent_local_id == nil || [parent_local_id isEqualToString:@""] )
					{						
						UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
						[alert1 show];
						[alert1 release];

					}
					else
					{
						processInfo * pinfo =  [appDelegate getViewProcessForObject:parent_obj_name record_id:parent_local_id processId:@"" isswitchProcess:FALSE];
						
						BOOL process_exist = pinfo.process_exists;
						
						if(process_exist)
						{
							NSString * process_id = pinfo.process_id;
							[dataSync showSFMWithProcessId:process_id recordId:parent_local_id objectName:parent_obj_name];
						}

					}
					
				}
                
            }
            
        }
    }
    
    else if (HeaderSelected == 1)
    {
		NSString * local_Id = @"";
        objectAPIName = [objectsArray objectAtIndex:indexPath.section];
        sync_type = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"sync_type"];
        
        SMLog(kLogLevelVerbose,@"%@", objectsDict);
        if ([sync_type isEqualToString:@"PUT_INSERT"])
        {
            local_Id = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"local_id"];
        }
        else 
        {
            SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"SFId"]; 
        }
        if ( [objectsDict count] > 0)
        {
            if ([[[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"record_type"] isEqualToString:@"MASTER"])
            {
                SMLog(kLogLevelVerbose,@"%@", appDelegate.view_layout_array);
                for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
                {
                    NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                    NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                    SMLog(kLogLevelVerbose,@"%@ %@", object_label, objectAPIName);
                    if ([object_label isEqualToString:objectAPIName])
                    {
                        processId = ([dict objectForKey:VIEW_SVMXC_ProcessID]!=nil)?[dict objectForKey:VIEW_SVMXC_ProcessID]:@"";
                        break;
                    }
                }
				
				if ([SFId length] && ([local_Id isEqualToString:@""] || local_Id == nil))
                    local_Id = [self getlocalIdForSFId:SFId ForObject:objectAPIName];
				
                [dataSync showSFMWithProcessId:processId recordId:local_Id objectName:objectAPIName];                
            }	
            
            else if ([[[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"record_type"] isEqualToString:@"DETAIL"])
            {
				if ([SFId length] && ([local_Id isEqualToString:@""] || local_Id == nil))
					local_Id = [self getlocalIdForSFId:SFId ForObject:objectAPIName];

 				processInfo * pinfo =  [appDelegate getViewProcessForObject:objectAPIName record_id:local_Id processId:@"" isswitchProcess:FALSE];
				BOOL process_exist = pinfo.process_exists;
				
				//check For view process
				if( process_exist )
				{
					NSString * process_id = pinfo.process_id;
					[dataSync showSFMWithProcessId:process_id recordId:local_Id objectName:objectAPIName];
					
				}
				else{
					
					NSString *parent_obj_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectAPIName field_name:@"parent_name"];
					NSString * parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectAPIName field_name:@"parent_column_name"];
					
					SMLog(kLogLevelVerbose,@"%@ %@", parent_obj_name, parent_column_name);
					
					SMLog(kLogLevelVerbose,@"%@", SFId);
					NSString * parent_local_id = @"";
					
					if ( [SFId length] > 0 && SFId != nil && ![SFId isEqualToString:@""] )
					{
						parent_local_id = [appDelegate.dataBase getParentColumnValueFromchild:parent_obj_name childTable:objectAPIName sfId:SFId];
					}
					else
					{
						parent_local_id = [appDelegate.dataBase getParentlocalIdchild:parent_obj_name childTable:objectAPIName local_id:local_Id];
					}
					
					//If the detail does not have a parent reference i.e parent_local_id = nil
					if ( parent_local_id == nil || [parent_local_id isEqualToString:@""] )
					{
						UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:warning message:noView delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
						
						[alert1 show];
						[alert1 release];
						
					}
					else
					{
						processInfo * pinfo =  [appDelegate getViewProcessForObject:parent_obj_name record_id:parent_local_id processId:@"" isswitchProcess:FALSE];
						
						BOOL process_exist = pinfo.process_exists;
						
						if(process_exist)
						{
							NSString * process_id = pinfo.process_id;
							[dataSync showSFMWithProcessId:process_id recordId:parent_local_id objectName:parent_obj_name];
						}

					}
					
				}
            }
            
        }
        
    }
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name ManualDataSync :accessoryButtonTappedForRowWithIndexPath %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason ManualDataSync :accessoryButtonTappedForRowWithIndexPath %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView * view = nil;
    UILabel * label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [self colorForHex:@"2d5d83"];
    
    label.font = [UIFont boldSystemFontOfSize:16];
    
    SMLog(kLogLevelVerbose,@"%d", section);
        
    //Create header view and add label as a subview
    view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 31)] autorelease];
    UIImageView * imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_section_header_bg.png"]] autorelease];
    imageView.frame = CGRectMake(12, 0, _tableView.frame.size.width, 31);
    [view addSubview:imageView];
//    [view addSubview:label];
    
    if ( selectedSection == 0 )
    {
        UILabel *headerLabel1   = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel1.backgroundColor = [UIColor clearColor];
        headerLabel1.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_recordId_label];
        headerLabel1.textColor = [UIColor blackColor];
        [headerLabel1 setFont:[UIFont fontWithName:@"Arial" size:17]];
        [headerLabel1 sizeToFit];
        [view addSubview:headerLabel1];
        [headerLabel1 release];
            
        UILabel *headerLabel2   = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel2.backgroundColor = [UIColor clearColor];
        headerLabel2.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_error_message];
        headerLabel2.textColor = [UIColor blackColor];
        [headerLabel2 setFont:[UIFont fontWithName:@"Arial" size:17]];
        [headerLabel2 sizeToFit];
        [view addSubview:headerLabel2];
        [headerLabel2 release];
        
        CGPoint viewCenter = view.center;
        
        headerLabel1.center = CGPointMake(viewCenter.x/2 - 80, viewCenter.y );
        headerLabel2.center = CGPointMake(3*viewCenter.x/2 - 100, viewCenter.y );
            
    //        UILabel *headerLabel3   = [[UILabel alloc] initWithFrame:CGRectMake(460, 10, 185, 20)];
    //        headerLabel3.backgroundColor = [UIColor clearColor];
    //        headerLabel3.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_apply_changes];
    //        headerLabel3.textColor = [UIColor blackColor];
    //        [headerLabel3 setFont:[UIFont fontWithName:@"Arial" size:17]];
    //        [view addSubview:headerLabel3];
    //        [headerLabel3 release];
         //}
  }
    return view;
}

//  Unused methods
//- (void) _didSelectRow:(NSInteger )row ForSection:(NSInteger )section
//{ 
//    selectedRow = row;
//    selectedSection = section;
//}

- (void) headerSelected
{
    HeaderSelected  = 1;
    selectedSection = 0;
    [self._tableView reloadData];
}

- (void) rowSelected
{
    HeaderSelected = 0;
}


- (UIColor *) colorForHex:(NSString *)hexColor
{
    hexColor = [hexColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
	hexColor = [[hexColor stringByTrimmingCharactersInSet:
				 [NSCharacterSet whitespaceAndNewlineCharacterSet]
				 ] uppercaseString];  
	
    if ([hexColor length] > 6) 
		return [UIColor whiteColor];  
	
    if ([hexColor length] != 6) 
		return [UIColor whiteColor];  
	
    NSRange range;  
    range.location = 0;  
    range.length = 2; 
	
    NSString * rString = [hexColor substringWithRange:range];  
	
    range.location = 2;  
    NSString *gString = [hexColor substringWithRange:range];  
	
    range.location = 4;  
    NSString * bString = [hexColor substringWithRange:range];  
	
    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
	
    UIColor * color = [UIColor colorWithRed:((float) r / 255.0f)  
                                      green:((float) g / 255.0f)  
                                       blue:((float) b / 255.0f)  
                                      alpha:1.0f];
    return color;
}

- (void) custom_Button
{
    SMLog(kLogLevelVerbose,@"I have Selected Custom button");
}


- (void) custom_Button1
{
    SMLog(kLogLevelVerbose,@"I have Selected Custom button");
}


- (void) showSyncronisationStatus
{
    [syncStatus.popOver dismissPopoverAnimated:YES];
    [popOver_view.popover dismissPopoverAnimated:YES];
    syncStatus = [[SyncStatusView alloc] init];
    syncStatus.popOver = [[UIPopoverController alloc] initWithContentViewController:syncStatus];
    
    if ([appDelegate doesServerSupportsModule:kMinPkgForDataPurge])
    {
        [syncStatus.popOver setPopoverContentSize:CGSizeMake(600, 570) animated:YES];
    }
    else
    {
        [syncStatus.popOver setPopoverContentSize:CGSizeMake(600, 394) animated:YES];
    }
	syncStatus.popOver.delegate = self;
	
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:statusButton];
    [syncStatus.popOver presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [barButton release];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController_
{
	[popoverController_ release];
    popoverController_ = nil;
	syncStatus.popOver = nil;
}

- (void) ShowActions
{
    [syncStatus.popOver dismissPopoverAnimated:YES];
    [popOver_view.popover dismissPopoverAnimated:YES];
    if( popOver_view == nil )
        popOver_view = [[PopoverButtons alloc] init];
    
    popOver_view.delegate = self;
    UIPopoverController * popoverController_temp = [[UIPopoverController alloc] initWithContentViewController:popOver_view];
    //Data Purge
    if ([appDelegate doesServerSupportsModule:kMinPkgForDataPurge])
    {
        [popoverController_temp setPopoverContentSize:CGSizeMake(214, 355) animated:YES];// sahana  25thsept
    }
    else
    {
        [popoverController_temp setPopoverContentSize:CGSizeMake(214, 296) animated:YES];
    }
    
    popoverController_temp.delegate = self;
    
    popOver_view.popover = popoverController_temp;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [popoverController_temp presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [barButton release];
    
}


- (void) DisclosureButtonTapped:(id) sender
{
    //btn merge
    if ( appDelegate._manualDataSync.didAppearFromSFMScreen && !appDelegate.showUI)
    {
        [dataSync dissmisController];
    }
    else
    {
        NSIndexPath *indexPath = nil;
        if([Utility notIOS7])
            indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
        else
            indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
        NSString * SFId          = @"";
        NSString * objectAPIName = @"";
        NSString * sync_type     = @"";
        NSString * processId     = @"";
        @try{
        if (selectedSection == 0 && HeaderSelected == 0)
        {
            objectAPIName = [objectsArray objectAtIndex:selectedRow];
            sync_type = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"sync_type"];
            
            if ([sync_type isEqualToString:@"PUT_INSERT"])
            {
                SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"local_id"];
            }
            else 
            {
                SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"SFId"]; 
            }
            NSString * localId = @"";
            if ( [objectsDict count] > 0)
            {
                if ([[[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"record_type"] isEqualToString:@"MASTER"])
                {
                    SMLog(kLogLevelVerbose,@"%@", appDelegate.view_layout_array);
                    for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
                    {
                        NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                        NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                        SMLog(kLogLevelVerbose,@"%@ %@", object_label, objectAPIName);
                        if ([object_label isEqualToString:objectAPIName])
                        {
                            processId = ([dict objectForKey:VIEW_SVMXC_ProcessID]!=nil)?[dict objectForKey:VIEW_SVMXC_ProcessID]:@"";
                            break;
                        }
                    }
                    NSString * localId = [self getlocalIdForSFId:SFId ForObject:objectAPIName];
                    [dataSync showSFMWithProcessId:processId recordId:localId objectName:objectAPIName];
                    
                }
                else if ([[[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"record_type"] isEqualToString:@"DETAIL"])
                {
                    NSString *parent_obj_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectAPIName field_name:@"parent_name"];
                    NSString * parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectAPIName field_name:@"parent_column_name"];
                    
                    SMLog(kLogLevelVerbose,@"%@ %@", parent_obj_name, parent_column_name);
                    localId = [appDelegate.databaseInterface selectLocalIdFrom:objectAPIName WithId:SFId andParentColumnName:parent_column_name andSyncType:sync_type];
                    SMLog(kLogLevelVerbose,@"%@", localId);
                    
                    for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
                    {
                        NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                        NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                        if ([object_label isEqualToString:objectAPIName])
                        {
                            processId = ([dict objectForKey:VIEW_SVMXC_ProcessID]!=nil)?[dict objectForKey:VIEW_SVMXC_ProcessID]:@"";
                            break;
                        }
                    }
                    
                    [dataSync showSFMWithProcessId:processId recordId:localId objectName:parent_obj_name];

                }

            }
        }
        
        else if (HeaderSelected == 1)
        {
            objectAPIName = [objectsArray objectAtIndex:indexPath.section];
            sync_type = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"sync_type"];
            
            SMLog(kLogLevelVerbose,@"%@", objectsDict);
            if ([sync_type isEqualToString:@"PUT_INSERT"])
            {
                SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"local_id"];
            }
            else 
            {
                SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"SFId"]; 
            }
            NSString * localId = @"";
            if ( [objectsDict count] > 0)
            {
                if ([[[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"record_type"] isEqualToString:@"MASTER"])
                {
                    SMLog(kLogLevelVerbose,@"%@", appDelegate.view_layout_array);
                    for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
                    {
                        NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                        NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                        SMLog(kLogLevelVerbose,@"%@ %@", object_label, objectAPIName);
                        if ([object_label isEqualToString:objectAPIName])
                        {
                            processId = ([dict objectForKey:VIEW_SVMXC_ProcessID]!=nil)?[dict objectForKey:VIEW_SVMXC_ProcessID]:@"";
                            break;
                        }
                    }
                    NSString * localId = [self getlocalIdForSFId:SFId ForObject:objectAPIName];
                    [dataSync showSFMWithProcessId:processId recordId:localId objectName:objectAPIName];
                    
                }
                
                else if ([[[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"record_type"] isEqualToString:@"DETAIL"])
                {
                    NSString *parent_obj_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectAPIName field_name:@"parent_name"];
                    NSString * parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectAPIName field_name:@"parent_column_name"];
                    
                    SMLog(kLogLevelVerbose,@"%@ %@", parent_obj_name, parent_column_name);
                    localId = [appDelegate.databaseInterface selectLocalIdFrom:objectAPIName WithId:SFId andParentColumnName:parent_column_name andSyncType:sync_type];
                    SMLog(kLogLevelVerbose,@"%@", localId);
                    
                    for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
                    {
                        NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                        NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                        if ([object_label isEqualToString:objectAPIName])
                        {
                            processId = ([dict objectForKey:VIEW_SVMXC_ProcessID]!=nil)?[dict objectForKey:VIEW_SVMXC_ProcessID]:@"";
                            break;
                        }
                    }
                    [dataSync showSFMWithProcessId:processId recordId:localId objectName:parent_obj_name];
                    
                }
                
            }

        }
        }@catch (NSException *exp) {
            SMLog(kLogLevelError,@"Exception Name ManualDataSync :DisclosureButtonTapped %@",exp.name);
            SMLog(kLogLevelError,@"Exception Reason ManualDataSync :DisclosureButtonTapped %@",exp.reason);
            [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
        }
    }
 }

- (NSString *) getlocalIdForSFId:(NSString *)SFId ForObject:(NSString *)Objectname
{
    //7220: Added single quote for table name.
    NSString * query = [NSString stringWithFormat:@"SELECT local_id FROM '%@' WHERE Id = '%@'", Objectname, SFId];
    
    NSString * localId = @"";
    sqlite3_stmt *stmt;
    
    int ret = synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL);
    if(ret == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _localId = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if (_localId != nil && strlen(_localId))
                localId = [NSString stringWithUTF8String:_localId];
            
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    return localId;
    
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) 
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (IBAction) segmentControlSelected:(id)sender
{  
    NSString * objectName = @"";
    NSString *SFId = @"";
    
    MySegmentedControl *segmentedControl = (MySegmentedControl *) sender;
    NSIndexPath *indexPath = nil;
    if([Utility notIOS7])
        indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    else
        indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    
    if (HeaderSelected == 1)
    {
        SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"SFId"];
        objectName = [objectsArray objectAtIndex:indexPath.section];

    }
    else if (HeaderSelected == 0)
    {
        objectName = [objectsArray objectAtIndex:selectedRow];
        SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"SFId"];
    }
    
    UIColor *newSelectedTintColor = [appDelegate colorForHex:@"#1589FF"];
    for(id v in [segmentedControl subviews])
    {
        if([v isSelected])
            [v setTintColor:newSelectedTintColor];
        else
        {
            /*ios7_support Kirti*/
            if(![Utility notIOS7])
                [v setTintColor:newSelectedTintColor];
            else
                [v setTintColor:[appDelegate colorForHex:@"#C8C8C8"]];
        }
    }
	
    if ([segmentedControl selectedSegmentIndex] == 0) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"Client_Override"];
    if ([segmentedControl selectedSegmentIndex] == 1) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"Server_Override"];
    if ([segmentedControl selectedSegmentIndex] == 2) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"None"];

    
}

- (IBAction) segmentControlSelected1:(id)sender
{  
    NSString * objectName = @"";
    NSString *SFId = @"";
    MySegmentedControl *segmentedControl = (MySegmentedControl *) sender;
    NSIndexPath *indexPath = nil;
    if([Utility notIOS7])
        indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    else
        indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    UIColor * newSelectedTintColor = [appDelegate colorForHex:@"#1589FF"];
    
    SMLog(kLogLevelVerbose,@"%@", objectsDict);
	
    if (HeaderSelected == 1)
    {
        SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"SFId"];
        objectName = [objectsArray objectAtIndex:indexPath.section];
    }
	
    else if (HeaderSelected == 0)
    {
        objectName = [objectsArray objectAtIndex:selectedRow];
        SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"SFId"];
    }
    
    for(id v in [segmentedControl subviews])
    {
        if([v isSelected])
            [v setTintColor:newSelectedTintColor];
        
        else
        {
            /*ios7_support Kirti*/
            if(![Utility notIOS7])
                [v setTintColor:newSelectedTintColor];
            else
                [v setTintColor:[appDelegate colorForHex:@"#C8C8C8"]];
            
        }
    }

	
	if ([segmentedControl selectedSegmentIndex] == 0)
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"retry"];
    if ([segmentedControl selectedSegmentIndex] == 1) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"remove"];
	if ([segmentedControl selectedSegmentIndex] == 2) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"None"];

}


- (IBAction) segmentControlSelected2:(id)sender
{  
    NSString * objectName = @"";
    NSString *SFId = @"";
    MySegmentedControl *segmentedControl = (MySegmentedControl *) sender;
    NSIndexPath *indexPath = nil;
    if([Utility notIOS7])
        indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    else
        indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    UIColor *newSelectedTintColor = [appDelegate colorForHex:@"#1589FF"];
    
    SMLog(kLogLevelVerbose,@"%@", objectsDict);
    if (HeaderSelected == 1)
    {
        SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"SFId"];
        objectName = [objectsArray objectAtIndex:indexPath.section];
        
    }
    else if (HeaderSelected == 0)
    {
        objectName = [objectsArray objectAtIndex:selectedRow];
        SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"SFId"];
    }
    
    for(id v in [segmentedControl subviews])
    {
        if([v isSelected])
            [v setTintColor:newSelectedTintColor];
        
        else
        {
            /*ios7_support Kirti*/
            if(![Utility notIOS7])
                [v setTintColor:newSelectedTintColor];
            else
                [v setTintColor:[appDelegate colorForHex:@"#C8C8C8"]];
        }

    }
//    if ([segmentedControl selectedSegmentIndex] == 0)
//        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"Undo"];
//    if ([segmentedControl selectedSegmentIndex] == 1) 
//        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"None"];
	
	if ([segmentedControl selectedSegmentIndex] == 0) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"retry"];
    if ([segmentedControl selectedSegmentIndex] == 1) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"Server_Override"];
	if ([segmentedControl selectedSegmentIndex] == 2) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"None"];

}

-(void)relatedrecordErrorSegmentSelected:(id)sender
{
 
    NSString * objectName = @"";
    NSString *SFId = @"";
    
    MySegmentedControl *segmentedControl = (MySegmentedControl *) sender;
    NSIndexPath *indexPath = nil;
    if([Utility notIOS7])
        indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    else
        indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];

    if (HeaderSelected == 1)
    {
        SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"SFId"];
        objectName = [objectsArray objectAtIndex:indexPath.section];
        
    }
    else if (HeaderSelected == 0)
    {
        objectName = [objectsArray objectAtIndex:selectedRow];
        SFId = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"SFId"];
    }
    
    UIColor *newSelectedTintColor = [appDelegate colorForHex:@"#1589FF"];
    for(id v in [segmentedControl subviews])
    {
        if([v isSelected])
            [v setTintColor:newSelectedTintColor];
        else
        {
            /*ios7_support Kirti*/
            if(![Utility notIOS7])
                [v setTintColor:newSelectedTintColor];
            else
                [v setTintColor:[appDelegate colorForHex:@"#C8C8C8"]];
        }
    }
	
    if ([segmentedControl selectedSegmentIndex] == 0)
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"retry"];
    if ([segmentedControl selectedSegmentIndex] == 1)
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"IGNORE"];
    if ([segmentedControl selectedSegmentIndex] == 2)
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"None"];

}

//  Unused methods
//- (void) deleteUndoneRecords
//{
//    [appDelegate.calDataBase selectUndoneRecords];
//}

#pragma mark - Table view delegate


- (void) accessoryButtonTapped:(UIControl *)_button withEvent:(UIEvent *)event
{
    NSIndexPath * indexPath = [self._tableView indexPathForRowAtPoint:[[[event touchesForView:_button] anyObject] locationInView: self._tableView]];
    if ( indexPath == nil )
        return;
    
    [self._tableView.delegate tableView: self._tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}


- (void) DismissSplitView : (id) sender
{
    [dataSync dissmisController];
}

#pragma mark TapRecognised
-(void)tapRecognized:(id)sender
{ 
    UITapGestureRecognizer * tap = sender;
    if ([tap.view isKindOfClass:[UILabel  class]])    
    {
        UILabel * label = (UILabel *) tap.view;
        if(label.text == nil)
            return;
        //if the text length is 0 then dont show the popover
        if([label.text length] == 0)
            return;
        
        // content View class
        labelPopover = [[DataSyncLabelPopover alloc ] init];
        
        // calculating the size for the popover
        UIFont * font = [UIFont systemFontOfSize:17.0];
        CGSize size =[label.text  sizeWithFont:font];
        
        //subview for the content view
        UITextView * contentView_textView;
        if(size.width > 240)
        {
            labelPopover.view.frame = CGRectMake(0, 0, labelPopover.view.frame.size.width, 40); //7325
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, labelPopover.view.frame.size.width, 32)];//7325
        }
        else
        {
            labelPopover.view.frame = CGRectMake(0, 0, labelPopover.view.frame.size.width, 34);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, labelPopover.view.frame.size.width, 32)];//7325
        }
        
        contentView_textView.text = label.text;
		//7325
        contentView_textView.font = font;
        contentView_textView.userInteractionEnabled = YES;
        contentView_textView.editable = NO;
		[contentView_textView setScrollEnabled:YES];
		[contentView_textView setScrollsToTop:YES];
        contentView_textView.textAlignment = UITextAlignmentCenter;
        [labelPopover.view addSubview:contentView_textView];
        
        CGSize size_po = CGSizeMake(labelPopover.view.frame.size.width, labelPopover.view.frame.size.height);
        label_popOver = [[UIPopoverController alloc] initWithContentViewController:labelPopover];
        [label_popOver setPopoverContentSize:size_po animated:YES];
        
        label_popOver.delegate = self;
        
        [label_popOver presentPopoverFromRect:CGRectMake(label.frame.size.width/2,0, 10, 10) inView:label permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        
        [contentView_textView release];
        [labelPopover release];
        
    }
    
}

-(void) showSyncUIStatus
{
    [appDelegate setSyncStatus:appDelegate.SyncStatus];
}


//can remove 
- (void) ReloadSyncTable
{
    if ([appDelegate.internet_Conflicts count] == 0)
    {
        objectsArray  = [appDelegate.calDataBase getConflictObjects];  
        for(int i = 0; i < [objectsArray count]; i++)
        {
            objectDetailsArray = [appDelegate.calDataBase getrecordIdsForObject:[objectsArray objectAtIndex:i]];
            [objectsDict setObject:objectDetailsArray forKey:[objectsArray objectAtIndex:i]];
        }  
        
        //update selectedRow value to reflect changes in the Detail view
        int count = objectsArray.count;
        if( (count-1) <= selectedRow )
        {
            selectedRow = count - 1;
        }
        
        [rootSyncDelegate reloadRootTable];
    }
    
    self.attachmentError = [appDelegate.attachmentDataBase getErrorInAttachmentObject];
    [self  getFileNameForAttachments];
    
    [self._tableView reloadData];
}


- (void) didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HeaderSelected = 0;
    selectedRow = indexPath.row;
    selectedSection = indexPath.section;

    [self._tableView reloadData];

}

-(void) didSelectHeader:(id)sender
{
    [self headerSelected];
}

-(void)dismisspopover
{
    [popOver_view.popover dismissPopoverAnimated:YES];
//    if ([objectsArray count]>0)
//    {
//        [activity startAnimating];
//        //self._tableView.hidden = YES;
//    }
}

//Radha
- (void) activityStart
{
    [activity startAnimating];
}

-(void) activityStop
{
    [activity stopAnimating];
}

- (void) throwException
{
   NSException * exception = [NSException exceptionWithName:@"Error" reason: @"Synchronize Configuration Failed"
                                      userInfo: nil];
    appDelegate.isMetaSyncExceptionCalled = TRUE;
    
    
    @throw exception;
}

- (void) disableControls
{
    self.view.userInteractionEnabled = NO;
    [rootSyncDelegate disableRootControls];
}

- (void) enableControls
{
    self.view.userInteractionEnabled = YES;
    [rootSyncDelegate enableRootControls];
}


-(void) resetTableview
{
    if (syncDueView != nil)
    {
        [syncDueView removeFromSuperview];
        [syncDueView release];
        syncDueView = nil;
    }
    /*Radha - Data purge - Check if DP is in due and reset the table view*/
    if (dataPurgeDueView != nil)
    {
        dataPurgeDueView.frame = CGRectMake(0, 10, dataPurgeDueView.frame.size.width, dataPurgeDueView.frame.size.height);
        
        CGFloat YAxis = 0.0;
        YAxis = dataPurgeDueView.frame.size.height + 20;
        self._tableView.frame = CGRectMake(0, YAxis, self._tableView.frame.size.width, self.view.frame.size.height-90); //9889 Defect Fix
    }
    else
    {
        self._tableView.frame = CGRectMake(0,0,self._tableView.frame.size.width, self.view.frame.size.height);
    }
}

//To clear the data purge view after completion of config sync 9889 - Defect Fix
- (void) resetPurgeViewIfExists
{
    [self removeDataPurgeDueView];
    [self resetTableviewForDp];
}


- (void) showInternetAletView
{
    NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
    NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_INTERNET_NOT_AVAILABLE];
    NSString *  retry = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_retry];
    NSString * ll_try_later = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_i_ll_try];
    
    UIAlertView * internet_alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:retry otherButtonTitles:ll_try_later, nil];
	[internet_alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
	[internet_alertView release];
}

#pragma mark-AlertViewDelagate
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	@try{
    if([resetAnApplication isEqual:alertView])
	{
		if (buttonIndex == 0)
		{
			
            /* Fix for - 005616 */
            
            if (![appDelegate isInternetConnectionAvailable])
            {
                appDelegate.shouldShowConnectivityStatus = TRUE;
                [appDelegate displayNoInternetAvailable];
                return;
            }
            
			[self disableControls];				//-------------> Disable controls if users continues with resetting application.
			[appDelegate invalidateAllTimers];
            //7113: Aparna
            [appDelegate removeSyncHistoryPlist];
			[appDelegate.dataBase removecache];
			appDelegate.wsInterface.didOpComplete = FALSE;
			
			appDelegate.isMetaSyncExceptionCalled = FALSE;
			appDelegate.isIncrementalMetaSyncInProgress = FALSE;
			appDelegate.isSpecialSyncDone = FALSE;
			appDelegate.metaSyncRunning = NO;
			appDelegate.eventSyncRunning = NO;
			
            
            //krishna opdocs
            [appDelegate clearDocumentDirectoryForOPDOCS];
            [appDelegate moveJavascriptFiles];
            //[appDelegate installCoreLibrary];//8639- commented after disucssing with OPDoc developers
            
			//[appDelegate.dataBase clearDatabase];
			//Remove database
            // Reset application :
            // Vipind-db-optmz - 3
            [appDelegate.dataBase closeDatabase:appDelegate.db];
            [appDelegate releaseMainDatabase];
			[appDelegate.dataBase deleteDatabase:DATABASENAME1];
            
            if(appDelegate.db == nil)
            {
                [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
            }
            SMXLogger *logger = [SMXLogger sharedInstance];
            logger.isLoggerTableCreated = FALSE;
			appDelegate.IsLogedIn = ISLOGEDIN_TRUE;
			appDelegate.do_meta_data_sync = ALLOW_META_AND_DATA_SYNC;
			[dataSync dissmisController];

		}
		else if(buttonIndex == 1)
		{
			[self enableControls];
		}
	}
	else
	{
		if (buttonIndex == 0)
		{
			if(![appDelegate isInternetConnectionAvailable])
			{
				[self showInternetAletView];
			}
			else
			{
                @try
                {
                    // Fix for defect 007410
                    [self disableControls];
                    [appDelegate.dataBase clearDatabase];
                    SMXLogger *logger = [SMXLogger sharedInstance];
                    logger.isLoggerTableCreated = FALSE;
                    [appDelegate.dataBase doMetaSync];
                }
                @catch (NSException *e)
                {
                    if(![appDelegate isInternetConnectionAvailable])
                    {
                         appDelegate.internetAlertFlag = FALSE;
                        [self showInternetAletView];
                    }
                    SMLog(kLogLevelError,@"ManualDataSyncDetail :didDismissWithButtonIndex - Exception Name  %@",e.name);
                    SMLog(kLogLevelError,@"ManualDataSyncDetail :didDismissWithButtonIndex - Exception Reason  %@",e.reason);
                }
			   
			}
		}
		
		
		if (buttonIndex == 1)
		{
			[appDelegate.dataBase clearDatabase];
			[appDelegate.dataBase copyTempsqlToSfm];
		}
    }
    }
    @catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name ManualDataSyncDetail :didDismissWithButtonIndex %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason ManualDataSyncDetail :didDismissWithButtonIndex %@",exp.reason);
    }
}

//Radha 2012june16
#pragma mark - MetaSyncDue - Movetableview
- (void) moveTableView
{
    if (syncDueView != nil && dataPurgeDueView != nil)
    {
        CGFloat YAxis = 0.0;
        CGFloat height = syncDueView.frame.size.height;
        CGFloat height1 = dataPurgeDueView.frame.size.height;
        
        YAxis = height + height1 + 30; //9889 Defect Fix
        
        self._tableView.frame = CGRectMake(self._tableView.frame.origin.x, YAxis, self._tableView.frame.size.width, self.view.frame.size.height-90);
    }
    else
    {
        CGFloat YAxis = 0.0;
        if (syncDueView != nil)
            YAxis = syncDueView.frame.size.height + 20; //9889 Defect Fix
        else if (dataPurgeDueView != nil)
             YAxis = dataPurgeDueView.frame.size.height + 20; //9889 Defect Fix
            
        self._tableView.frame = CGRectMake(self._tableView.frame.origin.x, YAxis, self._tableView.frame.size.width, self.view.frame.size.height-90);
    }
}

- (void)showSyncDueStatusView
{
    syncDueView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]];
    
    //syncDueView.frame = CGRectMake(0, 10, 800, 70);
    
    syncDueView.frame = [self getFrameForDueView];
    
    UITextView * textview = [[[UITextView alloc] initWithFrame:CGRectMake(230, 3, 250, 50)] autorelease]; //9889 Defect Fix
    textview.backgroundColor = [UIColor clearColor];
    textview.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_metasync_due];
    textview.font = [UIFont systemFontOfSize:19.0];
    [syncDueView addSubview:textview];
    
    [self.view addSubview:syncDueView];
    [self moveTableView];

}
#pragma mark - End

- (void)dealloc 
{
    [attachmentError release];
    
	self.popoverController = nil;
    syncStatus.popOver = nil;
    popOver_view.popover = nil;
    
    //7221:
    [statusButton release];
    [button release];
    
    [popOver_view release];
    [objectsArray release];
    [_tableView release];
    [activity release];
    [syncDueView release];
    [dataPurgeDueView release];
    [super dealloc];
}

//Sahana seprt 25th 2012
-(void)dismissSyncScreen
{
	[popOver_view.popover dismissPopoverAnimated:YES];
	
	NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE];
    NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
    NSString * continue_ = [appDelegate.wsInterface.tagsDictionary objectForKey:login_continue];
	NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:RESET_APPLICATION];
	NSString * message_ = @"Are you sure you want to reset application?";

	NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];
	if(_stringNumber < (kMinPkgForRESETTag * 100000))
	{
		message = message_;
	}

	resetAnApplication = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:continue_ otherButtonTitles:cancel, nil];
	
	[resetAnApplication show];
}


//7221:
- (void) refreshView
{
    [statusButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button] forState:UIControlStateNormal];
    [button setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_synchronize_button] forState:UIControlStateNormal];
    UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
	titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_conflicts];
	[titleLabel sizeToFit];
    [_tableView reloadData];
    
}

//009142: Download error conflict does not show the file name.
-(void)getFileNameForAttachments
{
    for ( NSMutableDictionary * dict in self.attachmentError) {
        NSString * parentAttachmentId = [dict objectForKey:mkAttachmentTrailerId];
       NSString * fileName = [appDelegate.attachmentDataBase getColoumnFromAttachment:@"name" forLocalId:parentAttachmentId];
        if(fileName != nil)
        {
        [dict setObject:fileName forKey:mkFileName];
        }
    }
}
#pragma mark - Data Purge
- (BOOL)checkIfDataPurgeInDue
{
    BOOL isInDue = NO;
    isInDue =  [[SMDataPurgeManager sharedInstance] isSchedulePurgeInDue]; //9862 Defect Fix
    
    return isInDue;
}

- (NSString *)getDPDueMessage
{
   return [[SMDataPurgeManager sharedInstance] dataPurgeDueMessage];
}
- (void)showDataPurgeStatusView
{
    if (dataPurgeDueView != nil)
    {
        return;
    }
    
    dataPurgeDueView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]];
    
    CGRect frame = [self getFrameForDueView];
    
    dataPurgeDueView.frame = frame;
    
//    CGRect textViewFrame;
    int XAxisPadding = 112;
//    int YAxisPadding = 7;
    
    NSString * dueMessage = [self getDPDueMessage];
    
    CGSize size1 = [dueMessage sizeWithFont:[UIFont systemFontOfSize:19] constrainedToSize:CGSizeMake(CGRectGetMaxX(dataPurgeDueView.frame), 9999)];
    
    
    //NSLog(@"%f", CGRectGetMidX(dataPurgeDueView.frame), CGRectGetMinY(dataPurgeDueView.frame));
    
//    textViewFrame.origin.x = CGRectGetMidX(dataPurgeDueView.frame) - XAxisPadding;
//    textViewFrame.origin.y = CGRectGetMinY(dataPurgeDueView.frame) - YAxisPadding;
//    textViewFrame.size.width = size1.width + XAxisPadding;
//    textViewFrame.size.height = 50;
    
    UITextView * textview = [[UITextView alloc] initWithFrame:CGRectMake(230, 3, size1.width + XAxisPadding, 50)]; //9889 Defect Fix
    textview.backgroundColor = [UIColor clearColor];
    textview.text = dueMessage;
    textview.font = [UIFont systemFontOfSize:19.0];
    textview.userInteractionEnabled = NO;
    dataPurgeDueView.userInteractionEnabled = YES;
    [dataPurgeDueView addSubview:textview];
    [textview release];
    
    [self.view addSubview:dataPurgeDueView];
    
    [self addButtonsToDPDueView];
    
    [self moveTableView];
    
}

- (CGRect)getFrameForDueView;
{
    CGRect rect;
    
    rect.origin.x = 0;
    rect.size.width = self._tableView.frame.size.width;
    
    if ((syncDueView != nil) && (dataPurgeDueView != nil))
    {
        rect.size.height = syncDueView.frame.size.height + 10;
        rect.origin.y = syncDueView.frame.size.height + 20;
    }
    else
    {
    	rect.size.height = 70;
        rect.origin.y = 10;
    }
   
    return rect;
}
- (void)addButtonsToDPDueView;
{
    UIImage * buttonImage = nil;
    
    CGRect frame;
    NSString * title = [Utility getValueForTagFromTagDict:login_continue];
    
    //9889 Defect Fix
    CGSize size1 = [title sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGRectGetMaxX(dataPurgeDueView.frame), 9999)];
    
    frame.origin.x = 230;
    frame.origin.y = 40;
    frame.size.width = size1.width + 22;
    frame.size.height = 30;
    
    UIButton * continueButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    continueButton.frame = frame;
    buttonImage = [UIImage imageNamed:@"SFM-Screen-Done-Back-Button"];
    [continueButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [continueButton setTitle:title forState:UIControlStateNormal];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    continueButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    continueButton.userInteractionEnabled = YES;
    [continueButton addTarget:self action:@selector(continueDataPurge) forControlEvents:UIControlEventTouchUpInside];

    title = [Utility getValueForTagFromTagDict:conflict_remove];
    
    frame.origin.x = CGRectGetMaxX(continueButton.frame)+20;

    UIButton * removeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    removeButton.frame = frame;
    buttonImage = [UIImage imageNamed:@"SFM-Screen-Done-Back-Button"];
    [removeButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [removeButton setTitle:title forState:UIControlStateNormal];
    [removeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [removeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    removeButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    removeButton.userInteractionEnabled = YES;
    [removeButton addTarget:self action:@selector(rescheduleDataPurge) forControlEvents:UIControlEventTouchUpInside];

    [dataPurgeDueView addSubview:continueButton];
    [dataPurgeDueView addSubview:removeButton];
}


- (void)continueDataPurge
{
    [self presentProgessView];
    [[SMDataPurgeManager sharedInstance] startSchedulePurging];
}

- (void)rescheduleDataPurge
{
    [self removeDataPurgeDueView];
    [self resetTableviewForDp];
    [[SMDataPurgeManager sharedInstance] reschedulePurgingForNextInterval:[NSDate date]];
}


- (void)removeDataPurgeDueView
{
    if (dataPurgeDueView)
    {
        [dataPurgeDueView removeFromSuperview];
        dataPurgeDueView = nil;
    }
}


- (void)resetTableviewForDp
{
    /*Radha - Data purge - Check if DP is in due and reset the table view*/
    if (syncDueView != nil)
    {
        syncDueView.frame = CGRectMake(0, 10, syncDueView.frame.size.width, syncDueView.frame.size.height);

        CGFloat YAxis = 0.0;
        YAxis = syncDueView.frame.size.height + 20;
        self._tableView.frame = CGRectMake(0, YAxis, self._tableView.frame.size.width, self.view.frame.size.height-90); //9889 Defect Fix
    }
    else
    {
        self._tableView.frame = CGRectMake(0,0,self._tableView.frame.size.width, self.view.frame.size.height);
    }
    
}

- (void)presentProgessView
{
    [self removeDataPurgeDueView];
    [self resetTableviewForDp];
    [detailDelagate addTranspertViewAndPresentProgressBar];
}

- (void)registerForServiceMaxDataPurgeProgressNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDataPurgeStatusView)
                                                 name:kNotificationDataPurgeDueAlert
                                               object:nil];
}

- (void)deregisterForServiceMaxDataPurgeProgressNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationDataPurgeDueAlert
                                                  object:nil];
    
}

#pragma END - Data Purge

@end
