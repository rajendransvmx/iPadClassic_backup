//
//  CreateObjectDetail.m
//  iService
//
//  Created by Samman on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreateObjectDetail.h"
#import "CreateObject.h"
extern void SVMXLog(NSString *format, ...);

@implementation CreateObjectDetail

@synthesize delegate, tableView;

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
    [super dealloc];
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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
    // UIView * bgImageView = [[UIView alloc] initWithFrame:bgImage.frame];
    bgImage.frame = CGRectMake(0, -12, bgImage.frame.size.width, bgImage.frame.size.height+12);
    // [bgImageView addSubview:bgImage];
    self.tableView.backgroundView = bgImage;
    [bgImage release];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Add a Back button to the detail
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)] autorelease];
    [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(DismissSplitView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    // Set title for detail
    UILabel * titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)] autorelease];
    titleLabel.textAlignment = UITextAlignmentCenter;

    titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CREATENEW];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLabel;
    
    //Add a help button to the detail - Radha 16 August 2011
    UIButton * helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)];
    [helpButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help.png"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * helpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:helpButton];
    self.navigationItem.rightBarButtonItem = helpBarButtonItem;
    [helpButton release];
    [helpBarButtonItem release];
}

- (void) DismissSplitView:(id)sender
{
    if ([delegate respondsToSelector:@selector(dismissSelf)])
        [delegate dismissSelf];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        // Do something
        return NO;
    }
    
	return YES;
}

- (void) showSFMCreateObjectWithProcessID:(NSString *)processId processTitle:(NSString *)processTitle object_name:(NSString *)objectName
{
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:NO];
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.recordId = nil;
    appDelegate.sfmPageController.detailView.detailTitle = processTitle;
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [(CreateObjectDetail *)delegate presentModalViewController:appDelegate.sfmPageController animated:YES];
    [appDelegate.sfmPageController.detailView  didReceivePageLayoutOffline];
    [appDelegate.sfmPageController release];
    
    [activity stopAnimating];
}

- (void) showHelp
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.helpString = @"create-new.html";  
    [(CreateObject*)delegate presentModalViewController:help animated:YES];
    [help release];

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger count = [appDelegate.StandAloneCreateProcess  count];
    if(count > selectedRootViewRow)
      return  [[appDelegate.StandAloneCreateProcess objectAtIndex:selectedRootViewRow] count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    else
    {
        NSArray * _array = [cell.contentView subviews];
        for (UIView * view in _array)
            [view removeFromSuperview];
    }
    
    // Configure the cell...
    
    NSDictionary * dict = [[appDelegate.StandAloneCreateProcess objectAtIndex:selectedRootViewRow] objectAtIndex:indexPath.row];
    NSString * row_tittle = [dict objectForKey:SVMXC_Name];

    UILabel * object_Name  = [[[UILabel alloc] initWithFrame:CGRectMake(5, 2, self.view.frame.size.width - 25, 40)] autorelease];
    
    object_Name.text =row_tittle ;
    object_Name.font = [UIFont boldSystemFontOfSize:16.0];
    object_Name.textColor = [UIColor blackColor];
    object_Name.backgroundColor = [UIColor clearColor];
    NSString * object_description = [dict objectForKey:SVMXC_Description];
    CGFloat height ;
    CGSize size;
    if([object_description isEqualToString:@""])
    {
        height= 0;
    }
    else
    {
        size = [object_description sizeWithFont:[UIFont systemFontOfSize:14]];
        height = size.height;
    }
    
    UILabel * description = [[[UILabel alloc] initWithFrame:CGRectMake(5,42, self.view.frame.size.width - 25, height)] autorelease];
    [description setBackgroundColor:[UIColor clearColor]];
    description.text =  [dict objectForKey:SVMXC_Description];
    description.font = [UIFont systemFontOfSize:14];
    
    description.numberOfLines = 0; //multiline
    
    [cell.contentView addSubview:object_Name];
    [cell.contentView addSubview:description];
    
    cell.backgroundColor = [UIColor clearColor];
    
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
    appDelegate.showUI = FALSE;
    NSString * processId = nil;
    BOOL status;
    status = [Reachability connectivityStatus];
   

    [activity startAnimating];
    
    for (int i = 0; i < [appDelegate.wsInterface.createProcessArray count]; i++)
    {
        if(i == indexPath.row)
        {
            break;
        }
    }
    
    NSDictionary * dict = [[appDelegate.StandAloneCreateProcess objectAtIndex:selectedRootViewRow] objectAtIndex:indexPath.row];
    NSString * processTitle = [dict objectForKey:SVMXC_Name];
    processId = [dict objectForKey:SVMXC_ProcessID];
    SMLog(@"%@", processId);
    
    //sahana offline
    NSString * object_name = [dict objectForKey:SVMXC_OBJECT_NAME];
    //NSString * object_name = appDelegate.sfmPageController.objectName;
   [delegate showSFMCreateObjectWithProcessID:processId processTitle:processTitle object_name:object_name];
    [activity stopAnimating];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSString * processId = nil;
    
//    activity.frame = CGRectMake(self.view.frame.size.height/2, self.view.frame.size.width/2, activity.frame.size.width, activity.frame.size.height);

    [activity startAnimating];

    for (int i = 0; i < [appDelegate.wsInterface.createProcessArray count]; i++)
    {
        if(i == indexPath.row)
        {
            break;
        }
    }
    
    NSDictionary * dict = [[appDelegate.StandAloneCreateProcess objectAtIndex:selectedRootViewRow] objectAtIndex:indexPath.row];
    NSString * processTitle = [dict objectForKey:SVMXC_Name];
    processId = [dict objectForKey:SVMXC_ProcessID];
    SMLog(@"%@", processId);
    
    //sahana offline
    NSString * object_name = [dict objectForKey:SVMXC_OBJECT_NAME];
    [delegate showSFMCreateObjectWithProcessID:processId processTitle:processTitle object_name:object_name];
    [activity stopAnimating];
}

- (void) didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    appDelegate.showUI = FALSE;
    selectedRootViewRow = indexPath.row;
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [[appDelegate.StandAloneCreateProcess objectAtIndex:selectedRootViewRow] objectAtIndex:indexPath.row];
    
    NSString * object_description = [dict objectForKey:SVMXC_Description];
    if([object_description isEqualToString:@""])
    {
        return 41.0;
    }
    
    CGSize size = [object_description sizeWithFont:[UIFont systemFontOfSize:14]];
    return  (41.0+size.height+10.0);
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
