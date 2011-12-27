//
//  iPadScrollerViewController.m
//  iPadScroller
//
//  Created by Samman on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iPadScrollerViewController.h"
#import "TapImage.h"
#import "iServiceAppDelegate.h"
#import "ModalViewController.h"
#import "FirstDetailViewController.h"
#import "RecentsViewController.h"
#import "CreateObject.h"
#import "SearchViewController.h"
#import "CalendarController.h"

@implementation iPadScrollerViewController

@synthesize scrollPages;

const NSUInteger kNumImages = 7;

- (void)dealloc
{
	[scrollPages release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - 
- (void) showTasks
{
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }

    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalCalendar = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
    appDelegate.modalCalendar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; //UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:appDelegate.modalCalendar animated:YES];
    [appDelegate.modalCalendar release];
}
- (void) showCreateObject
{
    CreateObject * createObj = [[CreateObject alloc] initWithNibName:@"CreateObject" bundle:nil];
    createObj.modalPresentationStyle = UIModalPresentationFullScreen;
    createObj.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:createObj animated:YES];
    [createObj release];
}

- (void) showSearch
{
}

- (void) showCalendar
{
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }

    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalCalendar = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
    appDelegate.modalCalendar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:appDelegate.modalCalendar animated:YES];
    [appDelegate.modalCalendar release];
}
- (void) showChatter
{
    
}
- (void) showMap
{
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }

    NSString * noEvents = [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_NO_EVENTS];
    NSString * serviceMax = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    if (calendar == nil)
    {   
        calendar = [[CalendarController alloc] initWithNibName:@"CalendarController" bundle:nil];
        [calendar view];
    }
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ( appDelegate.wsInterface.eventArray == nil || [appDelegate.wsInterface.eventArray count] == 0 )
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noEvents delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if (appDelegate.workOrderEventArray && [appDelegate.workOrderEventArray count] > 0)
    {
        [appDelegate.workOrderEventArray removeAllObjects];
    }
    
    NSDate * today = [NSDate date];
    NSDateFormatter * df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"yyyy-MM-dd"];
    appDelegate.dateClicked = [df stringFromDate:today];
    
    // Add events to workOrderEventArray based on today
    for (int i = 0; i < [appDelegate.wsInterface.eventArray count]; i++)
    {
        NSDictionary * dict = [appDelegate.wsInterface.eventArray objectAtIndex:i];
        
        NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * activityDate = [dateFormatter stringFromDate:[dict objectForKey:STARTDATETIME]];
        NSString * apiName = [dict objectForKey:OBJECTAPINAME];

        if ([appDelegate.dateClicked isEqualToString:activityDate])
        {
            if ([apiName isEqualToString:WORKORDER])
            {
                [appDelegate.workOrderEventArray addObject:dict];
            }
        }
    }
    
    // Sort workOrderEventArray
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    for (int i = 0; i < [appDelegate.workOrderEventArray count]; i++)
    {
        for (int j = i+1; j < [appDelegate.workOrderEventArray count]; j++)
        {
            NSDictionary * obji = [appDelegate.workOrderEventArray objectAtIndex:i];
            NSDictionary * objj = [appDelegate.workOrderEventArray objectAtIndex:j];
            
            NSString * objiDate = [dateFormatter stringFromDate:[obji objectForKey:STARTDATETIME]];
            NSString * objjDate = [dateFormatter stringFromDate:[objj objectForKey:STARTDATETIME]];
            
            NSString * iDateStr = [objiDate isKindOfClass:[NSString class]]?objiDate:@"1970-01-01T00:00:00Z";
            NSString * jDateStr = [objjDate isKindOfClass:[NSString class]]?objjDate:@"1970-01-01T00:00:00Z";
            
            iDateStr = [iOSInterfaceObject getLocalTimeFromGMT:iDateStr];
            iDateStr = [iDateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            iDateStr = [iDateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            
            jDateStr = [iOSInterfaceObject getLocalTimeFromGMT:jDateStr];
            jDateStr = [jDateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            jDateStr = [jDateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            
            NSDate * iDate = [dateFormatter dateFromString:iDateStr];
            NSDate * jDate = [dateFormatter dateFromString:jDateStr];
            
            // Compare the dates, if iDate > jDate interchange
            if ([iDate timeIntervalSince1970] > [jDate timeIntervalSince1970])
            {
                [appDelegate.workOrderEventArray exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    if ([appDelegate.workOrderEventArray count] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noEvents delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    else
    {
        if (appDelegate.workOrderInfo)
        {
            appDelegate.workOrderInfo = nil;
            appDelegate.workOrderInfo = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        }
        for (int i = 0; i < [appDelegate.workOrderEventArray count]; i++)
        {
            NSDictionary * dict = [appDelegate.workOrderEventArray objectAtIndex:i];
            appDelegate.wsInterface.didGetWorkOder = FALSE;
            [appDelegate.wsInterface getWorkOrderMapViewForWorkOrderId:[dict objectForKey:WHATID]];
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, FALSE, 0))
            {
                NSLog(@"iPadScrollerViewController showMap in while loop");
                if (appDelegate.wsInterface.didGetWorkOder)
                    break;
            }            
        }
        NSLog(@"%@", appDelegate.workOrderInfo);
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
    recents.modalPresentationStyle = UIModalPresentationFullScreen;
    recents.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:recents animated:YES];
    [recents release];
}
- (void) showHelp
{
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.helpString = @"home.html";
    [self presentModalViewController:help animated:YES];
    [help release];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    itemArray = [[NSArray arrayWithObjects:
                 [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CALENDAR],
                 [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_MAP],
                 [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CREATENEW],
                 [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_RECENTS],
                 [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_TASKS],
                 [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_HELP],
                 nil] retain];

    descriptionArray = [[NSArray arrayWithObjects:
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CALENDAR_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_MAP_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CREATENEW_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_RECENTS_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_TASKS_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_HELP_TEXT],
                         nil] retain];
    
    self.scrollPages = [self getScrollViewNames];
    [scrollViewPreview setBackgroundColor:[UIColor clearColor]];
	scrollViewPreview.pageSize = CGSizeMake(269, 299);
	// Important to listen to the delegate methods.
	scrollViewPreview.delegate = self;

    animateImage.image = [UIImage imageNamed:@"logo.png"];
    animateImage.alpha = 0.0;

    [self performSelector:@selector(fadeInLogo) withObject:nil afterDelay:1];
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        isInternetAvailable = YES;
    }
    else
    {
        isInternetAvailable = NO;
        [appDelegate displayNoInternetAvailable];
    }
}

- (void) fadeInLogo
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:2];
    animateImage.alpha = 1.0;
    [UIView commitAnimations];
}

- (void) animationDidStop:(NSString *)id finished:(NSNumber *)finished context:(id)context
{
}

- (NSMutableArray *) getScrollViewNames
{
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < [itemArray count]; i++)
    {
        NSString * imageName = [NSString stringWithFormat:@"%d.png", i];
        [array addObject:imageName];
    }
    
    return array;
}

- (NSMutableArray *) getScrollViews
{
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < [itemArray count]; i++)
    {
        NSString * imageName = [NSString stringWithFormat:@"%d.png", i];
        TapImage * imageView = [[[TapImage alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
        [array addObject:imageView];
    }
    
    return array;
}

#pragma mark -
#pragma mark BSPreviewScrollViewDelegate methods
-(UIView*)viewForItemAtIndex:(BSPreviewScrollView*)scrollView index:(int)index
{
	// Note that the images are actually smaller than the image view frame, each image
	// is 210x280. Images are centered and because they are smaller than the actual 
	// view it creates a padding between each image. 
	CGRect imageViewFrame = CGRectMake(0.0f, 0.0f, 269, 299);
	
	// TapImage is a subclassed UIImageView that catch touch/tap events 
	TapImage *imageView = [[[TapImage alloc] initWithFrame:imageViewFrame] autorelease];
    imageView.delegate = self;
    imageView.index = index;
	imageView.userInteractionEnabled = YES;
	imageView.image = [UIImage imageNamed:[self.scrollPages objectAtIndex:index]];
	imageView.contentMode = UIViewContentModeCenter;
    
    UIImageView * seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dashboard-box-dividers.png"]];
    [imageView addSubview:seperator];
    [seperator release];
    seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dashboard-box-dividers.png"]];
    seperator.frame = CGRectMake(269, 0, seperator.frame.size.width, seperator.frame.size.height);
    [imageView addSubview:seperator];
    [seperator release];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 269, 31)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.text = [itemArray objectAtIndex:index];
    [imageView addSubview:label];
    [label release];
    
    UILabel * bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 259, 99)];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.textColor = [UIColor blackColor];
    bottomLabel.textAlignment = UITextAlignmentCenter;
    bottomLabel.numberOfLines = 20;
    bottomLabel.lineBreakMode = UILineBreakModeWordWrap;
    bottomLabel.text = [descriptionArray objectAtIndex:index];
    [imageView addSubview:bottomLabel];
    [bottomLabel release];
	
	return imageView;
}

-(int)itemCount:(BSPreviewScrollView*)scrollView
{
	// Return the number of pages we intend to display
	return [self.scrollPages count];
}

#pragma mark - TapImage Delegate Method
- (void) tappedImageWithIndex:(int)index
{
    NSLog(@"%@", [itemArray objectAtIndex:index]);
    NSString * itemSelected = [itemArray objectAtIndex:index];
    if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CALENDAR]])
        [self showCalendar];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_MAP]])
        [self showMap];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CREATENEW]])
        [self showCreateObject];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_RECENTS]])
        [self showRecents];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_TASKS]])
        [self showTasks];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_HELP]])
        [self showHelp];
}

- (void)viewDidUnload
{
    [scrollViewPreview release];
    scrollViewPreview = nil;
    [animateImage release];
    animateImage = nil;
    [refFrame release];
    refFrame = nil;
    [lastFrame release];
    lastFrame = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        return YES;
    }
    // Return YES for supported orientations
    return NO;
}

@end
