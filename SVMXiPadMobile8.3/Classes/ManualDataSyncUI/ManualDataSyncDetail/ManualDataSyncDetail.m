
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
#import "iServiceAppDelegate.h"
#import "ManualDataSyncRoot.h"
#import "EventViewController.h"
#import "ManualDataSync.h"

@implementation ManualDataSyncDetail

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





- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    appDelegate.reloadTable = self;
    
    if ([appDelegate.internet_Conflicts count] == 0)
        appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
    
    appDelegate.wsInterface.refreshSyncStatusUIButton = self;

    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main.png"]];
    self._tableView.backgroundView = bgImage;
    [bgImage release];
    
    navigationBar.delegate = self;
    navigationBar.frame = CGRectMake(0, 0, 200, 25);
    
    self._tableView.backgroundColor = [UIColor clearColor];
    
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)] autorelease];
    [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(DismissSplitView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    UILabel * titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(200, 5, 200, 38)] autorelease];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_conflicts];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.backgroundColor = [UIColor clearColor];

    [self.navigationController.view addSubview:titleLabel];
    NSMutableArray *arrayForRightBarButton=[[NSMutableArray alloc]init ];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(85, 5, 100, 38);
    button.backgroundColor = [UIColor clearColor];
    [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button"] forState:UIControlStateNormal];
    [button setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_synchronize_button] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [button addTarget:self action:@selector(ShowActions) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem * barButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];

    [arrayForRightBarButton addObject:barButton];
    statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    statusButton.frame = CGRectMake(20, 5, 60, 38);
    statusButton.backgroundColor = [UIColor clearColor];
    [statusButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button"] forState:UIControlStateNormal];
    [statusButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button] forState:UIControlStateNormal];
    [statusButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [statusButton addTarget:self action:@selector(showSyncronisationStatus) forControlEvents:UIControlEventTouchUpInside];
    [statusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem * statusBarButton = [[[UIBarButtonItem alloc] initWithCustomView:statusButton] autorelease];        
    [arrayForRightBarButton addObject:statusBarButton];
    UIButton *helpButton = [[UIButton alloc] initWithFrame:CGRectMake(190, 5, 43, 35)];
    helpButton.backgroundColor = [UIColor clearColor];
    [helpButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * helpBarButton = [[[UIBarButtonItem alloc] initWithCustomView:helpButton] autorelease];
    [arrayForRightBarButton addObject:helpBarButton];
    UIToolbar *myToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(450, 0, 230, 40)];
    myToolBar.backgroundColor = [UIColor clearColor];
    [myToolBar setItems:arrayForRightBarButton]; 
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:myToolBar] autorelease];
    [myToolBar release];
    
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
    appDelegate.animatedImageView.center = CGPointMake(450,21);
    [self.navigationController.view addSubview:appDelegate.animatedImageView];
    
    //Radha 2012june16
     if ([appDelegate.dataBase checkIfSyncConfigDue])
     {
         if (syncDueView != nil)
             [syncDueView removeFromSuperview];
         [self moveTableView];
     }

}

- (void) showHelp
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.helpString = @"sync.html";  
    [self presentModalViewController:help animated:YES];
    [help release];
}


- (void)viewDidUnload
{
    //[_tableView release];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    objectsArray = nil;
    objectsDict = nil;
    
    if (objectsArray == nil)
        objectsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (objectsDict == nil)
        objectsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    objectsArray  = [appDelegate.calDataBase getConflictObjects];   
    [objectsArray retain];
    
    for(int i=0; i < [objectsArray count]; i++)
    {
        objectDetailsArray = [appDelegate.calDataBase getrecordIdsForObject:[objectsArray objectAtIndex:i]];
        
        [objectsDict setObject:objectDetailsArray forKey:[objectsArray objectAtIndex:i]];
    }   
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([appDelegate.internet_Conflicts count] > 0)
    {
        return 1;
    }
    
    if (selectedSection == 0 && HeaderSelected == 1)
        return [objectsArray count];
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([appDelegate.internet_Conflicts count] > 0)
    {
        return [appDelegate.internet_Conflicts count];
    }

    if ((objectsDict != nil) && ([objectsDict count] > 0) && [objectsArray count] > 0)
    {
        if (HeaderSelected == 0)
            return [[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]] count];
        else if (HeaderSelected == 1)
            return [[objectsDict objectForKey:[objectsArray objectAtIndex:section]] count];
        else
            return 0;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSInteger width = 0;
	width = 660;
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
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    if(background == nil){
        background = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)] autorelease];
    }
    UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
    [cell.contentView addSubview:background];
    cell.backgroundView = bgView;
    
    if ( HeaderSelected == 1 )
    {
        if ([appDelegate.internet_Conflicts count] > 0)
        {
            UILabel * lbl;
            lbl = [[[UILabel alloc] initWithFrame:CGRectMake(10, 9, 300, 30)] autorelease];
            lbl.text = [[appDelegate.internet_Conflicts objectAtIndex:0] objectForKey:@"sync_type"];
            lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
            lbl.textColor = [UIColor blackColor];
            lbl.backgroundColor = [UIColor clearColor];
            [background addSubview:lbl];
            lbl.userInteractionEnabled = YES;
            
            UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(180, 3, 200, 50)];
            textView.font = [UIFont systemFontOfSize:19.0];
            textView.text = [[appDelegate.internet_Conflicts objectAtIndex:0] objectForKey:@"Error_message"];
            textView.userInteractionEnabled = YES;
            textView.backgroundColor = [UIColor clearColor];
            [background addSubview:textView];
            
            UITapGestureRecognizer * tapMe3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [textView addGestureRecognizer:tapMe3];
            [tapMe3 release];
            
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_retry];
            
            UIButton * retry = [UIButton buttonWithType:UIButtonTypeCustom];
            [retry setFrame:CGRectMake(420, 17, 100, 30)];
            [retry setTitle:title forState:UIControlStateNormal];
            
            retry.enabled = TRUE;
            UIImage * normalBtnImg = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button.png"];
            normalBtnImg = [normalBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
            
            [retry setBackgroundImage:normalBtnImg forState:UIControlStateNormal];
            
            UIImage * highlightBtnImg = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button2.png"];
            highlightBtnImg = [highlightBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
            [retry setBackgroundImage:highlightBtnImg forState:UIControlStateHighlighted];
        
            NSString * data_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_data_sync];
            NSString * event_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_events];
            NSString * meta_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_meta_data_configuration];

            if ([lbl.text isEqualToString:data_sync])
                [retry addTarget:self action:@selector(retryDataSyncAgain) forControlEvents:UIControlEventTouchUpInside];
            else if ([lbl.text isEqualToString:meta_sync])
                [retry addTarget:self action:@selector(retryMetaDataSyncAgain) forControlEvents:UIControlEventTouchUpInside];
            else if ([lbl.text isEqualToString:event_sync])
                [retry addTarget:self action:@selector(retryEventSyncAgain) forControlEvents:UIControlEventTouchUpInside];
            
            //retryEventSyncAgain
            
            [background addSubview:retry];            
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
        
        
        NSString * mobile = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_mobile_select];
        NSString * online = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_select_online];
               
        MySegmentedControl *mySegment = [[MySegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:online,mobile, nil]];
        mySegment.frame = CGRectMake(420, 20, 150, 30);
        mySegment.segmentedControlStyle = UISegmentedControlStyleBar;
        
        UIColor *newTintColor = [appDelegate colorForHex:@"#C8C8C8"];
        mySegment.tintColor = newTintColor;
        
        if ( [override_flag isEqualToString:@"Server_Override"])
        {
            [[[mySegment subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
        }
        else if ( [override_flag isEqualToString:@"Client_Override"])
        {
            [[[mySegment subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
        }
            
        NSString * undo = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_undo];
        NSString * hold = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_hold];
        
        MySegmentedControl *mySegment1 = [[MySegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:undo,hold,nil]];
        mySegment1.frame = CGRectMake(420, 20, 140, 30);
        mySegment1.segmentedControlStyle = UISegmentedControlStyleBar;
        mySegment1.tintColor = newTintColor;
        
        if ( [override_flag isEqualToString:@"Undo"])
        {
            [[[mySegment1 subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
        }
        else if ([override_flag isEqualToString:@"None"]||[override_flag isEqualToString:@""])
        {
            [[[mySegment1 subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
        }

        [mySegment addTarget:self action:@selector(segmentControlSelected:) forControlEvents:UIControlEventValueChanged];
        [mySegment1 addTarget:self action:@selector(segmentControlSelected1:) forControlEvents:UIControlEventValueChanged];
        
        if ([error_type isEqualToString:@"ERROR"])
        {
            [cell.contentView addSubview:mySegment1];
        }
        else if ([error_type isEqualToString:@"CONFLICT"])
        {
            [cell.contentView addSubview:mySegment];
        }
        [mySegment release];
        [mySegment1 release];
        
            
        UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(180, 3, 200, 50)];
        textView.font = [UIFont systemFontOfSize:19.0];
        textView.text = [[[objectsDict objectForKey:[objectsArray objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row] objectForKey:@"Error_message"];
        textView.userInteractionEnabled = YES;
        textView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer * tapMe2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [textView addGestureRecognizer:tapMe2];
        [tapMe2 release];
        
        [background addSubview:textView];
        [cell.contentView addSubview:background];
        [textView release];
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaBold" size:19];  
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
            [background addSubview:lbl];
            lbl.userInteractionEnabled = YES;
            
            UILabel * textView = [[UILabel alloc] initWithFrame:CGRectMake(180, 3, 200, 50)];
            textView.font = [UIFont systemFontOfSize:19.0];
            textView.text = [[appDelegate.internet_Conflicts objectAtIndex:0] objectForKey:@"sync_type"];
            textView.userInteractionEnabled = YES;
            textView.backgroundColor = [UIColor clearColor];
            [background addSubview:textView];
            
            UITapGestureRecognizer * tapMe3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [textView addGestureRecognizer:tapMe3];
            [tapMe3 release];
            
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_retry];
            [title sizeWithFont:[UIFont fontWithName:@"HelveticaBold" size:19]];
            
            UIButton * retry = [UIButton buttonWithType:UIButtonTypeCustom];
            [retry setFrame:CGRectMake(420, 17, 100, 30)];
            [retry setTitle:title forState:UIControlStateNormal];
            
            retry.enabled = TRUE;
            UIImage * normalBtnImg = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button.png"];
            normalBtnImg = [normalBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
            
            [retry setBackgroundImage:normalBtnImg forState:UIControlStateNormal];
            
            UIImage * highlightBtnImg = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button2.png"];
            highlightBtnImg = [highlightBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
            [retry setBackgroundImage:highlightBtnImg forState:UIControlStateHighlighted];
            
            NSString * data_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_data_sync];
            NSString * event_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_events];
            NSString * meta_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_meta_data_configuration];
            
            if ([lbl.text isEqualToString:data_sync])
                [retry addTarget:self action:@selector(retryDataSyncAgain) forControlEvents:UIControlEventTouchUpInside];
            else if ([lbl.text isEqualToString:meta_sync])
                [retry addTarget:self action:@selector(retryMetaDataSyncAgain) forControlEvents:UIControlEventTouchUpInside];
            else if ([lbl.text isEqualToString:event_sync])
                [retry addTarget:self action:@selector(retryEventSyncAgain) forControlEvents:UIControlEventTouchUpInside];
            
            [background addSubview:retry];            

            
            [cell.contentView addSubview:background];
            [textView release];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaBold" size:19];
            
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
        NSLog(@"%@", override_flag);
        
        
        UILabel * lbl;
        lbl = [[[UILabel alloc] initWithFrame:CGRectMake(10, 9, 300, 30)] autorelease];
        _apiName = [appDelegate.databaseInterface getFieldNameForReferenceTable:api_name tableName:@"SFObjectField"];
        name = [appDelegate.calDataBase getnameFieldForObject:api_name WithId:SFId WithApiName:_apiName];
        lbl.text = name;
        lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
        lbl.textColor = [UIColor blackColor];
        lbl.backgroundColor = [UIColor clearColor];
        [background addSubview:lbl];
        lbl.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [lbl addGestureRecognizer:tapMe];
        [tapMe release];
        
        NSString * mobile = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_mobile_select];
        NSString * online = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_select_online];

        
        MySegmentedControl *mySegment = [[MySegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:online,mobile, nil]];
        mySegment.frame = CGRectMake(420, 20, 150, 30);
        mySegment.segmentedControlStyle = UISegmentedControlStyleBar;
        
        NSString * undo = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_undo];
        NSString * hold = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_hold];
                
        MySegmentedControl *mySegment1 = [[MySegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:undo,hold,nil]];
        mySegment1.frame = CGRectMake(420, 20, 140, 30);
        mySegment1.segmentedControlStyle = UISegmentedControlStyleBar;
        
        if ([error_type isEqualToString:@"ERROR"])
        {
            [cell.contentView addSubview:mySegment1];
        }
        else if ([error_type isEqualToString:@"CONFLICT"])
        {
            [cell.contentView addSubview:mySegment];
        }

        UIColor *newTintColor = [appDelegate colorForHex:@"#C8C8C8"];
        mySegment.tintColor = newTintColor;
        [mySegment addTarget:self action:@selector(segmentControlSelected:) forControlEvents:UIControlEventValueChanged];
        
        if ( [override_flag isEqualToString:@"Server_Override"])
        {
            [[[mySegment subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
        }
        else if ( [override_flag isEqualToString:@"Client_Override"])
        {
            [[[mySegment subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
        }

        
        mySegment1.tintColor = newTintColor;
        [mySegment1 addTarget:self action:@selector(segmentControlSelected1:) forControlEvents:UIControlEventValueChanged];
        
        if ( [override_flag isEqualToString:@"Undo"])
        {
            [[[mySegment1 subviews] objectAtIndex:0] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
        }
        else if ([override_flag isEqualToString:@"None"]||[override_flag isEqualToString:@""])
        {
            [[[mySegment1 subviews] objectAtIndex:1] setTintColor:[appDelegate colorForHex:@"#1589FF"]];
        }

        [mySegment release];
        [mySegment1 release];
    
        UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(180, 3, 200, 50)];
        textView.font = [UIFont systemFontOfSize:19.0];
     
        textView.text = [[[objectsDict objectForKey:[objectsArray objectAtIndex:selectedRow]]objectAtIndex:indexPath.row] objectForKey:@"Error_message"];
        textView.userInteractionEnabled = YES;
        textView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer * _tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [textView addGestureRecognizer:_tapMe];
        [_tapMe release];
        
        [background addSubview:textView];
        [cell.contentView addSubview:background];
        [textView release];
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaBold" size:19];
    }
    return cell;
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
    NSString * SFId          = @"";
    NSString * objectAPIName = @"";
    NSString * sync_type     = @"";
    NSString * processId     = @"";
    NSString * localId = @"";
    
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
                NSLog(@"%@", appDelegate.view_layout_array);
                for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
                {
                    NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                    NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                    NSLog(@"%@ %@", object_label, objectAPIName);
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
                NSString *parent_obj_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectAPIName field_name:@"parent_name"];
                NSString * parent_column_name = [appDelegate.databaseInterface getchildInfoFromChildRelationShip:SFCHILDRELATIONSHIP ForChild:objectAPIName field_name:@"parent_column_name"];
                
                NSLog(@"%@ %@", parent_obj_name, parent_column_name);
                localId = [appDelegate.databaseInterface selectLocalIdFrom:objectAPIName WithId:SFId andParentColumnName:parent_column_name andSyncType:sync_type];
                NSLog(@"%@", localId);
                
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
        
        NSLog(@"%@", objectsDict);
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
                NSLog(@"%@", appDelegate.view_layout_array);
                for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
                {
                    NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                    NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                    NSLog(@"%@ %@", object_label, objectAPIName);
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
                
                NSLog(@"%@ %@", parent_obj_name, parent_column_name);
                localId = [appDelegate.databaseInterface selectLocalIdFrom:objectAPIName WithId:SFId andParentColumnName:parent_column_name andSyncType:sync_type];
                NSLog(@"%@", localId);
                
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

}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = nil;
    UILabel * label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [self colorForHex:@"2d5d83"];
    
    label.font = [UIFont boldSystemFontOfSize:16];
    
    NSLog(@"%d", section);
        
    //Create header view and add label as a subview
    view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 31)] autorelease];
    UIImageView * imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_section_header_bg.png"]] autorelease];
    imageView.frame = CGRectMake(12, 0, _tableView.frame.size.width, 31);
    [view addSubview:imageView];
    [view addSubview:label];
    
    //if ( selectedSection == 0 )
    //{
        UILabel *headerLabel1   = [[UILabel alloc] initWithFrame:CGRectMake(53, 10, 75, 20)];
        headerLabel1.backgroundColor = [UIColor clearColor];
        headerLabel1.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_recordId_label];
        headerLabel1.textColor = [UIColor blackColor];
        [headerLabel1 setFont:[UIFont fontWithName:@"Arial" size:17]];
        [view addSubview:headerLabel1];
        [headerLabel1 release];
        
        UILabel *headerLabel2   = [[UILabel alloc] initWithFrame:CGRectMake(220, 10, 140, 20)];
        headerLabel2.backgroundColor = [UIColor clearColor];
        headerLabel2.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_error_message];
        headerLabel2.textColor = [UIColor blackColor];
        [headerLabel2 setFont:[UIFont fontWithName:@"Arial" size:17]];
        [view addSubview:headerLabel2];
        [headerLabel2 release];
        
        UILabel *headerLabel3   = [[UILabel alloc] initWithFrame:CGRectMake(460, 10, 185, 20)];
        headerLabel3.backgroundColor = [UIColor clearColor];
        headerLabel3.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_apply_changes];
        headerLabel3.textColor = [UIColor blackColor];
        [headerLabel3 setFont:[UIFont fontWithName:@"Arial" size:17]];
        [view addSubview:headerLabel3];
        [headerLabel3 release];
     //}
    
    return view;
}


- (void) _didSelectRow:(NSInteger )row ForSection:(NSInteger )section
{ 
    selectedRow = row;
    selectedSection = section;
}

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
    NSLog(@"I have Selected Custom button");
}


- (void) custom_Button1
{
    NSLog(@"I have Selected Custom button");
}


- (void) showSyncronisationStatus
{
    [syncStatus.popOver dismissPopoverAnimated:YES];
    [popOver_view.popover dismissPopoverAnimated:YES];
    syncStatus = [[SyncStatusView alloc] init];
    syncStatus.popOver = [[UIPopoverController alloc] initWithContentViewController:syncStatus];
    [syncStatus.popOver setPopoverContentSize:CGSizeMake(600, 340) animated:YES];
   
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:statusButton];
    [syncStatus.popOver presentPopoverFromBarButtonItem:barButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [barButton release];
}

- (void) ShowActions
{
    [syncStatus.popOver dismissPopoverAnimated:YES];
    [popOver_view.popover dismissPopoverAnimated:YES];
    popOver_view = [[PopoverButtons alloc] init];
    
    popOver_view.delegate = self;
    UIPopoverController * popoverController_temp = [[UIPopoverController alloc] initWithContentViewController:popOver_view];
    
    [popoverController_temp setPopoverContentSize:CGSizeMake(214, 175) animated:YES];
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
        NSIndexPath * indexPath  = [self._tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
        NSString * SFId          = @"";
        NSString * objectAPIName = @"";
        NSString * sync_type     = @"";
        NSString * processId     = @"";
        
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
                    NSLog(@"%@", appDelegate.view_layout_array);
                    for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
                    {
                        NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                        NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                        NSLog(@"%@ %@", object_label, objectAPIName);
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
                    
                    NSLog(@"%@ %@", parent_obj_name, parent_column_name);
                    localId = [appDelegate.databaseInterface selectLocalIdFrom:objectAPIName WithId:SFId andParentColumnName:parent_column_name andSyncType:sync_type];
                    NSLog(@"%@", localId);
                    
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
            
            NSLog(@"%@", objectsDict);
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
                    NSLog(@"%@", appDelegate.view_layout_array);
                    for (int v = 0; v < [appDelegate.view_layout_array count]; v++)
                    {
                        NSDictionary * dict = [appDelegate.view_layout_array objectAtIndex:v];
                        NSString * object_label = [dict objectForKey:VIEW_OBJECTNAME];
                        NSLog(@"%@ %@", object_label, objectAPIName);
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
                    
                    NSLog(@"%@ %@", parent_obj_name, parent_column_name);
                    localId = [appDelegate.databaseInterface selectLocalIdFrom:objectAPIName WithId:SFId andParentColumnName:parent_column_name andSyncType:sync_type];
                    NSLog(@"%@", localId);
                    
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
    }
 }

- (NSString *) getlocalIdForSFId:(NSString *)SFId ForObject:(NSString *)Objectname
{
    NSString * query = [NSString stringWithFormat:@"SELECT local_id FROM %@ WHERE Id = '%@'", Objectname, SFId];
    
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
    NSIndexPath *indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
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
            [v setTintColor:[appDelegate colorForHex:@"#C8C8C8"]];
    }
    if ([segmentedControl selectedSegmentIndex] == 0) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"Server_Override"];
    if ([segmentedControl selectedSegmentIndex] == 1) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"Client_Override"];
    if ([segmentedControl selectedSegmentIndex] == 2) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"None"];

    
}

- (IBAction) segmentControlSelected1:(id)sender
{  
    NSString * objectName = @"";
    NSString *SFId = @"";
    MySegmentedControl *segmentedControl = (MySegmentedControl *) sender;
    NSIndexPath *indexPath = [self._tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    UIColor *newSelectedTintColor = [appDelegate colorForHex:@"#1589FF"];
    
    NSLog(@"%@", objectsDict);
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
            [v setTintColor:[appDelegate colorForHex:@"#C8C8C8"]];
    }   
    if ([segmentedControl selectedSegmentIndex] == 0) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"Undo"];
    if ([segmentedControl selectedSegmentIndex] == 1) 
        [appDelegate.calDataBase updateOverrideFlagWithObjectName:objectName andSFId:SFId WithStatus:@"None"];
}

- (void) deleteUndoneRecords
{
    [appDelegate.calDataBase selectUndoneRecords];
}
             
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
            labelPopover.view.frame = CGRectMake(0, 0, labelPopover.view.frame.size.width, 90);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, labelPopover.view.frame.size.width, 90)];
        }
        else
        {
            labelPopover.view.frame = CGRectMake(0, 0, labelPopover.view.frame.size.width, 34);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, labelPopover.view.frame.size.width, 34)];  
        }
        
        contentView_textView.text = label.text;
        contentView_textView.font = font;
        contentView_textView.userInteractionEnabled = YES;
        contentView_textView.editable = NO;
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
    [self._tableView reloadData];
}


- (void) retryDataSyncAgain
{
    BOOL retVal = [appDelegate pingServer];
    
    
    if(retVal == YES)
    {
        //appDelegate.SyncStatus = SYNC_GREEN;
        [appDelegate setSyncStatus:SYNC_GREEN];
        //[appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        //[appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        [appDelegate callDataSync];
        
    }
}

-(void) retryMetaDataSyncAgain
{
    BOOL retVal = [appDelegate pingServer];
    
    if(retVal == YES)
    {
        
        if ([self.internet_Conflicts count] > 0)
        {
            [appDelegate.calDataBase removeInternetConflicts];
            [self.internet_Conflicts removeAllObjects];
            [appDelegate.reloadTable ReloadSyncTable];
        }

        //appDelegate.SyncStatus = SYNC_GREEN;
        
        [appDelegate setSyncStatus:SYNC_GREEN];
        //[appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        //[appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        //[appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
        [popOver_view synchronizeConfiguration];        
    }

}

-(void) retryEventSyncAgain
{
    BOOL retVal = [appDelegate pingServer];
    
    
    if(retVal == YES)
    {
        //appDelegate.SyncStatus = SYNC_GREEN;
        
        [appDelegate setSyncStatus:SYNC_GREEN];
        //[appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        //[appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        [popOver_view startSyncEvents];        
    }
    
}

- (void) didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    if ([objectsArray count]>0)
    {
        [activity startAnimating];
        self._tableView.hidden = YES;
    }
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
    [syncDueView removeFromSuperview];
    [syncDueView release];
    self._tableView.frame = CGRectMake(0,0,self._tableView.frame.size.width, self.view.frame.size.height);
}

//Radha 2012june16
#pragma mark - MetaSyncDue - Movetableview
- (void) moveTableView
{
    syncDueView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]];

    syncDueView.frame = CGRectMake(0, 10, 800, 70);
    
    UITextView * textview = [[[UITextView alloc] initWithFrame:CGRectMake(180, 3, 250, 50)] autorelease];
    textview.backgroundColor = [UIColor clearColor];
    textview.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_metasync_due];
    textview.font = [UIFont systemFontOfSize:19.0];
    [syncDueView addSubview:textview];

    
    [self.view addSubview:syncDueView];
    self._tableView.frame = CGRectMake(self._tableView.frame.origin.x, 100, self._tableView.frame.size.width, self.view.frame.size.height-100);
}
#pragma mark - End

- (void)dealloc 
{
    [self.popoverController release];
    [syncStatus.popOver release];
    [popOver_view.popover release];
    [popOver_view release];
    [objectsArray release];
    [_tableView release];
    [activity release];
    [syncDueView release];
    [super dealloc];
}
@end
