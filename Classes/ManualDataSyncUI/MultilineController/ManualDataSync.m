//
//  ManualDataSync.m
//  iService
//
//  Created by Parashuram on 14/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ManualDataSync.h"

#import "iServiceAppDelegate.h"

@implementation ManualDataSync

@synthesize didAppearFromSFMScreen;
@synthesize didAppearFromSyncScreen;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

    
    objectsArray = nil;
    objectsDict = nil;
    
    if (objectsArray == nil)
        objectsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (objectsDict == nil)
        objectsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    objectsArray  = [appDelegate.calDataBase getConflictObjects];    
    
    for(int i=0; i < [objectsArray count]; i++)
    {
        objectDetailsArray = [appDelegate.calDataBase getrecordIdsForObject:[objectsArray objectAtIndex:i]];
        
        [objectsDict setObject:objectDetailsArray forKey:[objectsArray objectAtIndex:i]];
    }

    
    dataSyncRoot = [[ManualDataSyncRoot alloc] initWithNibName:@"ManualDataSyncRoot" bundle:nil];
    UIImageView * bgImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main.png"]] autorelease];
    UIImageView * bgImage1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main.png"]] autorelease];
    dataSyncRoot.tableView.backgroundView = bgImage1;
    dataSyncRoot.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINavigationController * master = [[[UINavigationController alloc] initWithRootViewController:dataSyncRoot] autorelease];
    
     dataSyncDetail = [[ManualDataSyncDetail alloc] initWithNibName:@"ManualDataSyncDetail" bundle:nil];
    dataSyncDetail.objectsDict = objectsDict;
    dataSyncDetail.objectDetailsArray = objectDetailsArray;
    dataSyncDetail.objectsArray = objectsArray;
    dataSyncDetail.dataSync = self;
    dataSyncDetail._tableView.backgroundView = bgImage;
    dataSyncDetail._tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataSyncDetail.didAppearFromSFMScreen = self.didAppearFromSFMScreen;
    dataSyncDetail.rootSyncDelegate = self;
    UINavigationController * detail = [[[UINavigationController alloc] initWithRootViewController:dataSyncDetail] autorelease];
    detail.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	detail.navigationBar.autoresizesSubviews = YES;
    dataSyncRoot.dataSyncRootDelegate = dataSyncDetail;
    
    UISplitViewController * splitView = [[UISplitViewController alloc] init];
    splitView.viewControllers = [NSArray arrayWithObjects:master, detail, nil];
    splitView.delegate = self;
    
	splitView.view.autoresizingMask = UIViewAutoresizingNone;
	[self.view addSubview:splitView.view];
	splitView.view.frame = self.view.frame;
}

//Fix for defect #4825  -- Sync Indicator Vanishes.
-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:YES];
	
//	iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
//	appDelegate.animatedImageView.center = CGPointMake(450, 21);
//    [dataSyncDetail.navigationController.view addSubview:appDelegate.animatedImageView];
}

- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId objectName:(NSString *)objectName
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    
	appDelegate.sfmPageController.conflictExists = TRUE;
	appDelegate.From_SFM_Search = @"";
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.recordId = recordId;
    appDelegate.sfmPageController.objectName = [NSString stringWithFormat:@"%@",objectName];
    
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        appDelegate.SFMPage = nil;
    }
    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    
    
    processInfo * pinfo =  [appDelegate getViewProcessForObject:objectName record_id:recordId processId:processId isswitchProcess:FALSE];
    BOOL process_exists = pinfo.process_exists;
    
    if(process_exists)
    {
        appDelegate.sfmPageController.processId =  pinfo.process_id;
        [appDelegate.sfmPageController.detailView view];
        [self presentViewController:appDelegate.sfmPageController animated:YES completion:^(void){}];
        [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
    }
    else
    {
        
        NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_LAYOUT];
         NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
         NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
        
        UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil, nil];
        [enty_criteris show];
        [enty_criteris release];
        return;
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeRight)||
            (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}

- (BOOL)splitViewController: (UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return YES;
    return NO;
}

- ( void) dissmisController
{
     [self dismissViewControllerAnimated:YES completion:^(void){}];
}

//wsinterface Delegate

-(void)refreshdataSyncUI
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    dataSyncDetail.objectsArray = nil;
    dataSyncRoot.objectsArray = nil;
    dataSyncDetail.objectsArray  = [appDelegate.calDataBase getConflictObjects];
    dataSyncRoot.objectsArray = [appDelegate.calDataBase getConflictObjects];
    [dataSyncDetail.activity stopAnimating];
  
      
    for(int i=0; i < [dataSyncDetail.objectsArray count]; i++)
    {
        dataSyncRoot.objectDetailsArray = [appDelegate.calDataBase getrecordIdsForObject:[dataSyncDetail.objectsArray objectAtIndex:i]];
        
        [dataSyncDetail.objectsDict setObject:dataSyncDetail.objectDetailsArray forKey:[dataSyncDetail.objectsArray objectAtIndex:i]];
    }

    [dataSyncRoot.tableView reloadData];
    dataSyncDetail._tableView.hidden = NO;
    [dataSyncDetail._tableView reloadData];
    
}

-(void) disableRootControls
{
    self.view.userInteractionEnabled = NO;
    dataSyncRoot.tableView.userInteractionEnabled = NO;
}

-(void) enableRootControls
{
    self.view.userInteractionEnabled = YES;
    dataSyncRoot.tableView.userInteractionEnabled = YES;
}

-(void) reloadRootTable
{
	iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

	dataSyncRoot.objectsArray = [appDelegate.calDataBase getConflictObjects];
	[dataSyncRoot.tableView reloadData];
}
#pragma delegate ManualDetail
-(void)showHelp
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.helpString = @"sync.html";
    [self presentViewController:help animated:YES completion:^(void){}];
    [help release];

}
@end
