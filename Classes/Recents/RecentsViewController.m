//
//  RecentsViewController.m
//  iService
//
//  Created by Samman on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentsViewController.h"
#import "About.h"

@implementation RecentsViewController

@synthesize array;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    // [[[popover contentViewController] view] setAlpha:0.0f];
    [popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction) back
{
    [self dismissModalViewControllerAnimated:YES];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Load appDelegate.recentObject from the plist
    [appDelegate.recentObject removeAllObjects];
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:OBJECT_HISTORY_PLIST];
    appDelegate.recentObject = [NSArray arrayWithContentsOfFile:plistPath];
    
    NSMutableArray * countArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for (int rec = 0; rec < [appDelegate.recentObject count]; rec++)
    {
        NSDictionary * recentDict = [appDelegate.recentObject objectAtIndex:rec];
        
        NSString * object = [recentDict objectForKey:@"OBJECT_NAME"];
        NSString * recordID = [recentDict objectForKey:@"resultIds"];
        
        BOOL result = [appDelegate.dataBase checkIfRecordExistForObjectWithRecordId:object Id:recordID];
        
        if (result == FALSE)
        {
            [countArray addObject:[NSString stringWithFormat:@"%d", rec]];
        }
    }
    
    //Remove deleted record from recentObject
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int del = 0; del < [countArray count]; del++)
    {
        int value = [[countArray objectAtIndex:del] intValue];
        [indexSet addIndex:value];
//        [appDelegate.recentObject removeObjectAtIndex:value];
    }
    [appDelegate.recentObject removeObjectsAtIndexes:indexSet];
    
    
    NSMutableArray * recentObjectsArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < [appDelegate.recentObject count]; i++)
    {
        NSDictionary * dict = [appDelegate.recentObject objectAtIndex:i];
        NSString * recentObjectLabel = [dict objectForKey:OBJECT_LABEL];
        
        // run a loop thru the recentObjectsArray
        // find out key of dictionary for each loop
        // check if any key == recentObject
        // if yes then add object_name
        // if no key == recentObject then
        // add key + object_name to dictionary
        // add dictionary to recentObjectsArray
        
        BOOL flag = NO;
        
        for (int j = 0; j < [recentObjectsArray count]; j++)
        {
            NSMutableDictionary * recentObjectDictionary = [recentObjectsArray objectAtIndex:j];
            NSString * key = [[recentObjectDictionary allKeys] objectAtIndex:0];
            
            if ([key isEqualToString:recentObjectLabel])
            {
               // NSMutableArray * objectArray = [dict objectForKey:key];
                NSMutableArray * objectArray = [recentObjectDictionary objectForKey:key];
                [objectArray addObject:dict];
                flag = YES;
            }
        }
        
        if (!flag)
        {
            NSMutableDictionary * newDictionary = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
            NSMutableArray * newArray = [[[NSMutableArray alloc] initWithObjects:dict, nil] autorelease];
            [newDictionary setObject:newArray forKey:recentObjectLabel];
            [recentObjectsArray addObject:newDictionary];
        }
    }
    
    // Sort recentObjectsArray before displaying
    //Abinash Fixed
    for (int i = 0; i < [recentObjectsArray count]; i++)
    {
        NSDictionary * dict1 = [recentObjectsArray objectAtIndex:i];
        NSString * key1 = [[dict1 allKeys] objectAtIndex:0];
        for (int j = i + 1; j < [recentObjectsArray count]; j++)
        {
            NSDictionary * dict2 = [recentObjectsArray objectAtIndex:j];
            NSString * key2 = [[dict2 allKeys] objectAtIndex:0];
           
            int result = strcmp([key1 UTF8String], [key2 UTF8String]);
            
            if (result > 0 )
            {
                // perform swap
                [recentObjectsArray exchangeObjectAtIndex:i withObjectAtIndex:j];
                key1 = key2;
            }
        }
    }

    RecentObjectRoot * rootView = [[RecentObjectRoot alloc] initWithNibName:@"RecentObjectRoot" bundle:nil];
    rootView.recentObjectsArray = recentObjectsArray;
    UIImageView * bgImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]] autorelease];
    rootView.tableView.backgroundView = bgImage;
    UINavigationController * master = [[[UINavigationController alloc] initWithRootViewController:rootView] autorelease];
    
    RecentObjectDetail * detailView = [[RecentObjectDetail alloc] initWithNibName:@"RecentObjectDetail" bundle:nil];
    detailView.recentObjectsArray = recentObjectsArray;
    detailView.delegate = self;
    UINavigationController * detail = [[[UINavigationController alloc] initWithRootViewController:detailView] autorelease];
    
    rootView.delegate = detailView;
    
    UISplitViewController * splitView = [[UISplitViewController alloc] init];
    splitView.viewControllers = [NSArray arrayWithObjects:master, detail, nil];
    splitView.delegate = self;

    self.view = splitView.view;
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidUnload
{
    [mTable release];
    mTable = nil;
    [activity release];
    activity = nil;
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

- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId objectName:(NSString *)objectName
{
    [activity startAnimating];
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    
    //Radha 25th feb 
    NSString * _processId =  [appDelegate.switchViewLayouts objectForKey:objectName];
    appDelegate.sfmPageController.processId = (_processId != nil)?_processId:processId;
    
    appDelegate.sfmPageController.recordId = recordId;
    appDelegate.sfmPageController.objectName = objectName;
    
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        [appDelegate.SFMPage release];
        appDelegate.SFMPage = nil;
    }
    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    
    processInfo * pinfo =  [appDelegate getViewProcessForObject:objectName record_id:recordId processId:appDelegate.sfmPageController.processId isswitchProcess:FALSE];
    BOOL process_exists = pinfo.process_exists;
       
    if(process_exists)
    {
        appDelegate.sfmPageController.processId =  pinfo.process_id;
        [appDelegate.sfmPageController.detailView view];
        [self presentModalViewController:appDelegate.sfmPageController animated:YES];
        [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
    }
    else
    {
        UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:@"" message:@" Record does Not match  an Entry Criteria" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [enty_criteris show];
        [enty_criteris release];
        return;
    }
    [activity stopAnimating];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [appDelegate.recentObject count];
    for (int i = 0; i < [appDelegate.recentObject count]; i++)
    {
        BOOL shouldShowObject = NO;
        NSDictionary * recentObjectDict = [appDelegate.recentObject objectAtIndex:i];
        NSString * objectName = [recentObjectDict objectForKey:OBJECT_NAME];
        for (int j = 0; j < [appDelegate.wsInterface.viewLayoutsArray count]; j++)
        {
            NSDictionary * viewLayoutDict = [appDelegate.wsInterface.viewLayoutsArray objectAtIndex:j];
            NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
            if ([objName isEqualToString:objectName])
            {
                shouldShowObject = YES;
                break;
            }
        }
        if (!shouldShowObject)
            count--;
    }
    return count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellIdentifier";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }

    NSDictionary * dict = nil;

    for (int i = 0; i < [appDelegate.recentObject count]; i++)
    {
        BOOL shouldShowObject = NO;
        NSDictionary * recentObjectDict = [appDelegate.recentObject objectAtIndex:i];
        NSString * objectName = [recentObjectDict objectForKey:OBJECT_NAME];
        for (int j = 0; j < [appDelegate.wsInterface.viewLayoutsArray count]; j++)
        {
            NSDictionary * viewLayoutDict = [appDelegate.wsInterface.viewLayoutsArray objectAtIndex:j];
            NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
            if ([objName isEqualToString:objectName])
            {
                shouldShowObject = YES;
                //sahana
                dict = [appDelegate.recentObject objectAtIndex:[appDelegate.recentObject count]-1-indexPath.row];
                break;
            }
        }

        if (shouldShowObject)
            break;
    }
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    if([dict count] > 5 )
    {
        NSString * date = [dict objectForKey:gDATE_TODAY];
         cell.textLabel.text = [NSString stringWithFormat:@"%@ %@  %@", [dict objectForKey:OBJECT_LABEL], [dict objectForKey:NAME_FIELD],date];
        return cell;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [dict objectForKey:OBJECT_LABEL], [dict objectForKey:NAME_FIELD]];
   
    return cell;
}

- (void) dismissSelf
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate Methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [appDelegate.recentObject objectAtIndex:indexPath.row];    
    
    [self showSFMWithProcessId:[dict objectForKey:PROCESSID] recordId:[dict objectForKey:RESULTID]];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [appDelegate.recentObject objectAtIndex:indexPath.row];    
    
    [self showSFMWithProcessId:[dict objectForKey:PROCESSID] recordId:[dict objectForKey:RESULTID]];
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
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return YES;
    return NO;
}

@end
