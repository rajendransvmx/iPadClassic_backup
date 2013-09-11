//
//  CreateObject.m
//  iService
//
//  Created by Samman on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreateObject.h"
#import "About.h"
extern void SVMXLog(NSString *format, ...);

@implementation CreateObject

@synthesize array;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
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

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) showSFMCreateObjectWithProcessID:(NSString *)processId processTitle:(NSString *)processTitle object_name:(NSString *)objectName
{
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        appDelegate.SFMPage = nil;
    }
    
    appDelegate.sfmPageController = [[[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:NO] autorelease];
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.recordId = nil;
    //sahana offline
    appDelegate.sfmPageController.objectName = [NSString stringWithFormat:@"%@",objectName];
    
    appDelegate.sfmPageController.detailView.detailTitle = processTitle;
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentViewController:appDelegate.sfmPageController animated:YES completion:^(void){}];
    [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline ];

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.autoresizingMask = UIViewAutoresizingNone;
    mTable.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

    tableArray = [appDelegate.wsInterface.createProcessArray retain];

    CreateObjectRoot * rootView = [[CreateObjectRoot alloc] initWithNibName:@"CreateObjectRoot" bundle:nil];
    UIImageView * bgImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]] autorelease];
    rootView.tableView.backgroundView = bgImage;
    UINavigationController * master = [[[UINavigationController alloc] initWithRootViewController:rootView] autorelease];

    CreateObjectDetail * detailView = [[[CreateObjectDetail alloc] initWithNibName:@"CreateObjectDetail" bundle:nil] autorelease];
    detailView.delegate = self;
    UINavigationController * detail = [[[UINavigationController alloc] initWithRootViewController:detailView] autorelease];
    
    rootView.delegate = detailView;

    UISplitViewController * splitView = [[UISplitViewController alloc] init];
    splitView.viewControllers = [NSArray arrayWithObjects:master, detail, nil];
    splitView.delegate = self;

	splitView.view.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:splitView.view];
	splitView.view.frame = self.view.frame;
}

- (void) dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void)viewDidUnload
{
    [mTable release];
    mTable = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        return YES;
    
    return NO;
}

- (IBAction) back
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (IBAction) createObject
{
    
}

- (void) DismissSplitView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	
	if (appDelegate.StandAloneCreateProcess != nil && [appDelegate.StandAloneCreateProcess count] > 0 )
	{
		rowCount = [[appDelegate.StandAloneCreateProcess objectAtIndex:section] count];
	}
    return rowCount;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
//    UIView * backgroundView = nil;
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, cell.frame.size.height)] autorelease];
    }
    else
    {
        for (UIView *subview in [cell.contentView subviews]) 
        {
            [subview removeFromSuperview];
        }

     
    }
//    if(backgroundView == nil)
//        backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, cell.frame.size.height)] autorelease];
	@try{
    CGRect rect = cell.frame;
    SMLog(@"%@",rect);
    NSDictionary * dict = [[appDelegate.StandAloneCreateProcess objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString * row_tittle = [dict objectForKey:SVMXC_Name];
    
    UILabel * object_Name  = [[[UILabel alloc] initWithFrame:CGRectMake(5, 2, 320, 40)] autorelease];
    
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
    
    UILabel * description = [[[UILabel alloc] initWithFrame:CGRectMake(5,42, 860, height)] autorelease];
     [description setBackgroundColor:[UIColor clearColor]];
    description.text =  [dict objectForKey:SVMXC_Description];
    description.font = [UIFont systemFontOfSize:14];
    
    description.numberOfLines = 0; //multiline

    [cell.contentView addSubview:object_Name];
    [cell.contentView addSubview:description];

    cell.backgroundColor = [UIColor clearColor];
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	 }@catch (NSException *exp) {
	SMLog(@"Exception Name CreateObject :cellForRowAtIndexPath %@",exp.name);
	SMLog(@"Exception Reason CreateObject :cellForRowAtIndexPath %@",exp.reason);
	 [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSString * processId = nil;
    
//    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    [activity setColor:[UIColor colorWithRed:98 green:189 blue:228 alpha:1.0]];
//    [activity startAnimating];
//    activity.frame = CGRectMake(self.view.frame.size.height/2, self.view.frame.size.width/2, activity.frame.size.width, activity.frame.size.height);
//    [self.view addSubview:activity];
    
    for (int i = 0; i < [appDelegate.wsInterface.createProcessArray count]; i++)
    {
//        NSDictionary * dict = [appDelegate.wsInterface.createProcessArray objectAtIndex:i];
        if(i == indexPath.row)
        {
//            processId = [dict objectForKey:SVMXC_ProcessID];
            break;
        }
    }
	@try{
    NSDictionary * dict = [[appDelegate.StandAloneCreateProcess objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString * processTitle = [dict objectForKey:SVMXC_Name];
    processId = [dict objectForKey:SVMXC_ProcessID];
    SMLog(@"%@", processId);
    [self showSFMCreateObjectWithProcessID:processId processTitle:processTitle];
	}@catch (NSException *exp) {
        SMLog(@"Exception Name CreateObject :accessoryButtonTappedForRowWithIndexPath %@",exp.name);
        SMLog(@"Exception Reason CreateObject :accessoryButtonTappedForRowWithIndexPath %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [[appDelegate.StandAloneCreateProcess objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    NSString * object_description = [dict objectForKey:SVMXC_Description];
    if([object_description isEqualToString:@""])
    {
        return 41.0;
    }
    
    CGSize size = [object_description sizeWithFont:[UIFont systemFontOfSize:14]];
    return  (41.0+size.height+10.0);
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	
	if (appDelegate.objectNames_array != nil && [appDelegate.objectNames_array count] > 0)
	{
		rowCount = [appDelegate.objectNames_array count];
	}
    return rowCount;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section; 
{
    return [appDelegate.objectLabel_array objectAtIndex:section];
}

#pragma mark - SplitViewController Delegate

// Called when a button should be added to a toolbar for a hidden view controller
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{
    
}

// Called when the view is shown again in the split view, invalidating the button and popover controller
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
}

// Called when the view controller is shown in a popover so the delegate can take action like hiding other popovers.
- (void)splitViewController: (UISplitViewController*)svc popoverController: (UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController
{
    
}

// Returns YES if a view controller should be hidden by the split view controller in a given orientation.
// (This method is only called on the leftmost view controller and only discriminates portrait from landscape.)
- (BOOL)splitViewController: (UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    //Defect Ref: 5066
    return NO;
}

@end
