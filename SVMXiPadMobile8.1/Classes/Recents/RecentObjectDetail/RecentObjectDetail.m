//
//  RecentObjectDetail.m
//  iService
//
//  Created by Samman on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentObjectDetail.h"
#import "RecentsViewController.h"

@implementation RecentObjectDetail

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
    UIView * bgImageView = [[[UIView alloc] initWithFrame:bgImage.frame] autorelease];
    bgImage.frame = CGRectMake(0, -12, bgImage.frame.size.width, bgImage.frame.size.height+12);
    [bgImageView addSubview:bgImage];
    self.tableView.backgroundView = bgImage;
    [bgImage release];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Add a Back button to the detail
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 37)] autorelease];
    [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(DismissSplitView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    // Set title for detail
    UILabel * titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)] autorelease];
    titleLabel.textAlignment = UITextAlignmentCenter;

    titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_RECENTS];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLabel;
    
    //Add a help button to detail- radha 16 August 2011
    UIButton * helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 35)];
    [helpButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help.png"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * helpBarButton = [[UIBarButtonItem alloc] initWithCustomView:helpButton];
    self.navigationItem.rightBarButtonItem = helpBarButton;
    [helpButton release];
    [helpBarButton release];
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

- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId
{
    [activity startAnimating];
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.recordId = recordId;
    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [appDelegate.sfmPageController.detailView view];
    if (appDelegate.wsInterface.errorLoadingSFM == FALSE)
        [(RecentObjectDetail *)delegate presentModalViewController:appDelegate.sfmPageController animated:YES];
    else
        appDelegate.wsInterface.errorLoadingSFM = FALSE;
    [appDelegate.sfmPageController release];
    [activity stopAnimating];
}

- (void) showHelp
{
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.helpString = @"recents.html";  
    [(RecentsViewController*)delegate presentModalViewController:help animated:YES];
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
    // Return the number of rows in the section.
    
    if ([recentObjectsArray count] != 0)
    {
        NSLog(@"%@", [recentObjectsArray objectAtIndex:selectedRootViewRow]);
        NSMutableDictionary * dictionary = [recentObjectsArray objectAtIndex:selectedRootViewRow];
        NSString * key = [[dictionary allKeys] objectAtIndex:0];
        array = [dictionary objectForKey:key]; 
    }
    
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
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
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
  /*  activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activity setColor:[UIColor colorWithRed:98 green:189 blue:228 alpha:1.0]];
    [activity startAnimating];
    activity.frame = CGRectMake(self.view.frame.size.height/2, self.view.frame.size.width/2, activity.frame.size.width, activity.frame.size.height);
    [self.view addSubview:activity];*/
    appDelegate.showUI = FALSE;
    
    NSMutableDictionary * dict = [array objectAtIndex:indexPath.row];
    
    NSString * objectName = [dict objectForKey:OBJECT_NAME];
    
    NSString * processId = [dict objectForKey:@"SVMXC__ProcessID__c"];
    
   
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
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
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    /*if (!appDelegate.isInternetConnectionAvailable)
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
//    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    [activity setColor:[UIColor colorWithRed:98 green:189 blue:228 alpha:1.0]];
    [activity startAnimating];
    activity.frame = CGRectMake(self.view.frame.size.height/2, self.view.frame.size.width/2, activity.frame.size.width, activity.frame.size.height);
//    [self.view addSubview:activity];
    
    NSMutableDictionary * dict = [array objectAtIndex:indexPath.row];
    
    NSString * objectName = [dict objectForKey:OBJECT_NAME];
    NSString * processId = [dict objectForKey:@"SVMXC__ProcessID__c"];
    
    BOOL status = [Reachability connectivityStatus];
    if(status)
    {
        appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
       
        for (NSDictionary * dict in appDelegate.wsInterface.viewLayoutsArray)
        {
            NSString * viewLayoutObjectName = [dict objectForKey:@"objectName"];
            if ([viewLayoutObjectName isEqualToString:objectName])
            {
                processId = [dict objectForKey:gPROCESS_ID];
                break;
            }
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
    
    [activity stopAnimating];
}

- (void) didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    appDelegate.showUI = FALSE;
    selectedRootViewRow = indexPath.row;
    
    NSMutableDictionary * dictionary = [recentObjectsArray objectAtIndex:selectedRootViewRow];
    NSString * key = [[dictionary allKeys] objectAtIndex:0];
    array = [dictionary objectForKey:key];
    
    [self.tableView reloadData];
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
