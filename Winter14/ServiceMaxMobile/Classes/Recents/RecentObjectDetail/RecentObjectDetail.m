//
//  RecentObjectDetail.m
//  iService
//
//  Created by Samman on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentObjectDetail.h"
#import "RecentsViewController.h"
#import "Utility.h"
#import "CustomToolBar.h"

@implementation RecentObjectDetail
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@synthesize delegate, tableView;
@synthesize recentObjectsArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    delegate = nil;
    [activity release];

    [super dealloc];
}

- (void) DismissSplitView:(id)sender
{
    if ([delegate respondsToSelector:@selector(dismissSelf)])
        [delegate dismissSelf];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) layout
{
    CGRect rect = self.view.frame;
    /*ios7_support shravya-navbar*/
    if ([Utility notIOS7]) {
        self.navigationController.navigationBar.frame = CGRectMake(0, 0, rect.size.width, self.navigationController.navigationBar.frame.size.height);
    }
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    @try{
        UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
        bgImage.frame = CGRectMake(0, -12, bgImage.frame.size.width, bgImage.frame.size.height+12);
        self.tableView.backgroundView = bgImage;
        [bgImage release];
        self.tableView.backgroundColor = [UIColor clearColor];
        
        UIImage *image = [UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"];
        UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)] autorelease];
        [backButton setBackgroundImage:image forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(DismissSplitView:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
        
        UILabel * titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_RECENTS];
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
        
        UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        helpButton.backgroundColor = [UIColor clearColor];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help"] forState:UIControlStateNormal];
        [helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
        [helpButton sizeToFit];
        toolBarWidth += helpButton.frame.size.width + SPACE_BUFFER;
        UIBarButtonItem * helpBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:helpButton] autorelease];
        [arrayForRightBarButton addObject:helpBarButtonItem];
        
        /*ios7_support shravya-custom toolbar*/
        CustomToolBar *myToolBar = [[CustomToolBar alloc] initWithFrame:CGRectMake(0, 0, toolBarWidth + 30, 44)];
        myToolBar.backgroundColor = [UIColor clearColor];
        [myToolBar setItems:arrayForRightBarButton];
        UIView *view = myToolBar;
        SMLog(kLogLevelVerbose,@"%f %f", view.frame.size.width, view.frame.size.height);
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:myToolBar] autorelease];
        [myToolBar release];
        
        [arrayForRightBarButton release];
        arrayForRightBarButton = nil;
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name RecentObjectDetail :viewDidLoad %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason RecentObjectDetail :viewDidLoad %@",exp.reason);
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self layout];
	
}

- (void)viewDidUnload
{
//    [activity release];
    activity = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layout];
    [self.tableView reloadData];
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
    // Return YES for supported orientations
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId
{
    [activity startAnimating];
    appDelegate.sfmPageController = [[[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE] autorelease];
    
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.recordId = recordId;
    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [appDelegate.sfmPageController.detailView view];
    if (appDelegate.wsInterface.errorLoadingSFM == FALSE)
        [(RecentObjectDetail *)delegate presentViewController:appDelegate.sfmPageController animated:YES completion:^(void){}];
    else
        appDelegate.wsInterface.errorLoadingSFM = FALSE;
        
    [activity stopAnimating];
}

- (void) showHelp
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NSString *lang=[appDelegate.dataBase checkUserLanguage];
    NSString *isfileExists = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"recents_%@",lang] ofType:@"html"];
    if((isfileExists == NULL) || [lang isEqualToString:@"en_US"] ||  !([lang length]>0))
    {
        help.helpString=@"recents.html";
    }
    else
    {
        help.helpString = [NSString stringWithFormat:@"recents_%@.html",lang];
    }
    [(RecentsViewController*)delegate presentViewController:help animated:YES completion:^(void){}];
    [help release];
} 

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//8418 - Fix for crash
	NSUInteger rowCount = 0;
    // Return the number of rows in the section.
    @try{
    if ([recentObjectsArray count] > 0)
    {
        SMLog(kLogLevelVerbose,@"%@", [recentObjectsArray objectAtIndex:selectedRootViewRow]);
        NSMutableDictionary * dictionary = [recentObjectsArray objectAtIndex:selectedRootViewRow];
        NSString * key = [[dictionary allKeys] objectAtIndex:0];
        array = [dictionary objectForKey:key];
		rowCount = [array count];
    }
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name RecentObjectDetail :numberOfRowsInSection %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason RecentObjectDetail :numberOfRowsInSection %@",exp.reason);
    }
	
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    @try{
    // Configure the cell...
    NSMutableDictionary * dict = [array objectAtIndex:indexPath.row];
    
    NSString * objectName = [dict objectForKey:NAME_FIELD];
    NSString * date = [dict objectForKey:gDATE_TODAY];
    
    if ([objectName length] == 0)
        cell.textLabel.text = [NSString stringWithFormat:@"%@", date];
    else
        cell.textLabel.text = [NSString stringWithFormat:@"%@       %@", objectName, date];
    
    UIButton * button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 21)] autorelease];
    [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] 
                      forState:UIControlStateNormal];
    [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]];
    bgImage.frame = cell.frame;
    cell.backgroundView = bgImage;
    [bgImage release];
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name RecentObjectDetail :cellForRowAtIndexPath %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason RecentObjectDetail :cellForRowAtIndexPath %@",exp.reason);
    }
    
    cell.backgroundColor = [UIColor clearColor]; /*ios7_support shravya*/
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    appDelegate.showUI = FALSE;
    
    NSMutableDictionary * dict = [array objectAtIndex:indexPath.row];
    
    NSString * objectName = [dict objectForKey:OBJECT_NAME];
    
    NSString * processId = [dict objectForKey:@"SVMXC__ProcessID__c"];
    
   
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    @try{
     if(processId == nil || [processId length] == 0)
     {
        for (NSDictionary * dict in appDelegate.view_layout_array)
        {
            NSString * viewLayoutObjectName = [dict objectForKey:SVMXC_OBJECT_NAME];
            if ([viewLayoutObjectName isEqualToString:objectName])
            {
                processId = [dict objectForKey:SVMXC_ProcessID];
                break;
            }
        }
    }
    
    if(processId == nil || [processId length] == 0)
    {
        NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
        NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];
        
        UIAlertView * alertView =  [[UIAlertView alloc] initWithTitle:warning message:noView delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return;
    }
    else
    {
        [delegate showSFMWithProcessId:processId recordId:[dict objectForKey:RESULTID] objectName:objectName];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name RecentObejctDetail :didSelectRowAtIndexPath %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason RecentObejctDetail :didSelectRowAtIndexPath %@",exp.reason);
    }

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [activity startAnimating];
    activity.frame = CGRectMake(self.view.frame.size.height/2, self.view.frame.size.width/2, activity.frame.size.width, activity.frame.size.height);
    
    NSMutableDictionary * dict = [array objectAtIndex:indexPath.row];
    
    NSString * objectName = [dict objectForKey:OBJECT_NAME];
    NSString * processId = [dict objectForKey:@"SVMXC__ProcessID__c"];
    
    
    //fix for 7451
    /*BOOL status = [Reachability connectivityStatus];*/
    @try{
   
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   
    for (NSDictionary * dict in appDelegate.wsInterface.viewLayoutsArray)
    {
        NSString * viewLayoutObjectName = [dict objectForKey:@"objectName"];
        if ([viewLayoutObjectName isEqualToString:objectName])
        {
            processId = [dict objectForKey:gPROCESS_ID];
            break;
        }
    }
    if(processId == nil || [processId length] == 0){
        
        NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
        NSString * noView = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_PROCESS];
        
        UIAlertView * alertView =  [[UIAlertView alloc] initWithTitle:warning message:noView delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
        return;
    }else{
        
        [delegate showSFMWithProcessId:processId recordId:[dict objectForKey:RESULTID] objectName:objectName];
    }
    
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name RecentObejctDetail :accessoryButtonTappedForRowWithIndexPath %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason RecentObejctDetail :accessoryButtonTappedForRowWithIndexPath %@",exp.reason);
    }
    @finally {
        [activity stopAnimating];
    }
}

- (void) didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	@try{
    appDelegate.showUI = FALSE;
    selectedRootViewRow = indexPath.row;
    
    NSMutableDictionary * dictionary = [recentObjectsArray objectAtIndex:selectedRootViewRow];
    NSString * key = [[dictionary allKeys] objectAtIndex:0];
    array = [dictionary objectForKey:key];
    
    [self.tableView reloadData];
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name RecentObjectDetail :didSelectRowAtIndexPath %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason RecentObjectDetail :didSelectRowAtIndexPath %@",exp.reason);
    }

}

     
- (void) accessoryButtonTapped: (UIControl *) button withEvent:(UIEvent *) event
{
    appDelegate.showUI = FALSE;
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView:button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}

@end
