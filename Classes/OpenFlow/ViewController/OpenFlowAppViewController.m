//
//  OpenFlowAppViewController.m
//  OpenFlowApp
//
//  Created by Samman on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenFlowAppViewController.h"
#import "iServiceAppDelegate.h"
#import "ModalViewController.h"
#import "FirstDetailViewController.h"
#import "RecentsViewController.h"
#import "CreateObject.h"
#import "SearchViewController.h"

@implementation OpenFlowAppViewController

- (void)dealloc
{
    [itemList release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    itemList = [[NSArray arrayWithObjects:@"Tasks", @"Create Object", @"Search", @"Calendar", @"Map", @"Recents", @"Help", nil] retain];
    
    afopenflowView = [[AFOpenFlowView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
	afopenflowView.viewDelegate = self;
    
    [self.view addSubview:afopenflowView];
    
    NSString *imageName;
    for (int i=0; i < 7; i++)
    {
		imageName = [[NSString alloc] initWithFormat:@"%d.png", i];
		[afopenflowView setImage:[UIImage imageNamed:imageName] forIndex:i];
		[imageName release];
    }

    [afopenflowView setNumberOfImages:7];
    
    [afopenflowView setSelectedCover:3];
    [afopenflowView centerOnSelectedCover:YES];
    
    selectedItem.text = [itemList objectAtIndex:3];
}

- (void)viewDidUnload
{
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

- (void)imageDidLoad:(NSArray *)arguments
{
	UIImage *loadedImage = (UIImage *)[arguments objectAtIndex:0];
	NSNumber *imageIndex = (NSNumber *)[arguments objectAtIndex:1];
    
	[afopenflowView setImage:loadedImage forIndex:[imageIndex intValue]];
}

#pragma mark - 
- (void) showTasks
{
    iServiceAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.modalCalendar = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
    appDelegate.modalCalendar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; //UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:appDelegate.modalCalendar animated:YES];
    [appDelegate.modalCalendar release];
}
- (void) showCreateObject
{
    CreateObject * createObj = [[CreateObject alloc] initWithNibName:@"CreateObject" bundle:nil];
    createObj.modalPresentationStyle = UIModalPresentationFormSheet;
    createObj.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:createObj animated:YES];
    [createObj release];
}
- (void) showSearch
{
    /*
    SearchViewController * search = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    search.modalPresentationStyle = UIModalPresentationFormSheet;
    search.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:search animated:YES];
    [search release];
    */
}
- (void) showCalendar
{
    iServiceAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.modalCalendar = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
    appDelegate.modalCalendar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; //UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:appDelegate.modalCalendar animated:YES];
    [appDelegate.modalCalendar release];
}
- (void) showChatter
{
    
}
- (void) showMap
{
    if (calendar == nil)
    {   
        calendar = [[CalendarController alloc] initWithNibName:@"CalendarController" bundle:nil];
        [calendar view];
    }
    
    iServiceAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString * serviceMax = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    NSString * noEvents = [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_NO_EVENTS];

    int flag = FALSE;
    
    if ( appDelegate.wsInterface.eventArray == nil || [appDelegate.wsInterface.eventArray count] == 0 )
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noEvents delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    NSDate * today = [NSDate date];
    NSDateFormatter * df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"yyyy-MM-dd"];
    appDelegate.dateClicked = [df stringFromDate:today];
    
    for (int i = 0; i < [appDelegate.wsInterface.eventArray count]; i++)
    {
        NSDictionary * dict = [appDelegate.wsInterface.eventArray objectAtIndex:i];
        
        NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * activityDate = [dateFormatter stringFromDate:[dict objectForKey:STARTDATETIME]];
        
        if ([appDelegate.dateClicked isEqualToString:activityDate])
        {
            flag = TRUE;
            break;
        }
    }
    if ( flag == FALSE )
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noEvents delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    else
    {
        FirstDetailViewController * mapView = [[FirstDetailViewController alloc] initWithNibName:@"FirstDetailView" bundle:nil];
        mapView.currentDate = [calendar getTodayString];
        mapView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        mapView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentModalViewController:mapView animated:YES];
        [mapView release];
    }
}
- (void) showRecents
{
    RecentsViewController * recents = [[RecentsViewController alloc] initWithNibName:@"RecentsViewController" bundle:nil];
    recents.modalPresentationStyle = UIModalPresentationFormSheet;
    recents.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:recents animated:YES];
    [recents release];
}
- (void) showHelp
{
    
}

#pragma mark - AFOpenFlow DataSource Methods
- (UIImage *)defaultImage
{
	return [UIImage imageNamed:@"3.png"];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index
{
}

#pragma mark - AFOpenFlow Delegate Methods

- (void)didSelectItem:(int)index
{
    NSLog(@"Selected item %@", [itemList objectAtIndex:index]);
    switch (index) {
        case 0:
            [self showTasks];
            break;
        case 1:
            [self showCreateObject];
            break;
        case 2:
            [self showSearch];
            break;
        case 3:
            [self showCalendar];
            break;
        case 4:
            [self showMap];
            break;
        case 5:
            [self showRecents];
            break;
        case 6:
            [self showHelp];
            break;
        default:
            break;
    }
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index;
{
    selectedItem.text = [itemList objectAtIndex:index];
}

@end
