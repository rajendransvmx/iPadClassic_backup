//
//  RecentObjectRoot.m
//  iService
//
//  Created by Samman on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentObjectRoot.h"
#import "Utility.h"

@implementation RecentObjectRoot

@synthesize delegate;
@synthesize recentObjectsArray;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        firstTimeLoad = YES;
    }
    return self;
}

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
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
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	
    if (recentObjectsArray != nil && [recentObjectsArray count] > 0)
	{
		rowCount =  [recentObjectsArray count];
	}
	
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    @try{
    // Configure the cell...
    NSDictionary * dictionary = [recentObjectsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[dictionary allKeys] objectAtIndex:0];
    
    if (firstTimeLoad)
    {
        firstTimeLoad = NO;
        
        UIImage * image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
        image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
        UIImageView * bgImage = [[UIImageView alloc] initWithImage:image];
        [bgImage setContentMode:UIViewContentModeScaleToFill];
        cell.backgroundView = bgImage;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        cell.textLabel.textColor = [UIColor whiteColor];
        [bgImage release];
        
        lastSelectedIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
    }
    else
    {
        if ([lastSelectedIndexPath isEqual:indexPath])
        {
            UIImage * image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
            image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
            UIImageView * bgImage = [[UIImageView alloc] initWithImage:image];
            [bgImage setContentMode:UIViewContentModeScaleToFill];
            cell.backgroundView = bgImage;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
            cell.textLabel.textColor = [UIColor whiteColor];
            [bgImage release];
        }
        else
        {
            UIImage * image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
            image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
            UIImageView * bgImage = [[UIImageView alloc] initWithImage:image];
            [bgImage setContentMode:UIViewContentModeScaleToFill];
            cell.backgroundView = bgImage;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
            cell.textLabel.textColor = [appDelegate colorForHex:@"2d5d83"];
            [bgImage release];
        }
    }
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name RecentObjectRoot :cellForRowAtIndexPath %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason RecentObjectRoot :cellForRowAtIndexPath %@",exp.reason);
    }
    cell.backgroundColor = [UIColor clearColor]; /*ios7_support shravya*/
    return cell;
}

#pragma mark - Table view delegate
//Fat Finger
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if ([delegate respondsToSelector:@selector(didSelectRowAtIndexPath:)])
    {
        [delegate didSelectRowAtIndexPath:indexPath];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIImage * image = nil;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (indexPath == lastSelectedIndexPath)
        return;

    UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
    /*ios7_support shravya*/
    if ([Utility notIOS7]) {
        image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    }
    else {
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(8, 11, 0, 0) resizingMode:UIImageResizingModeStretch];
    }
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:image];
    [bgImage setContentMode:UIViewContentModeScaleToFill];
    selectedCell.backgroundView = bgImage;
    selectedCell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    selectedCell.textLabel.textColor = [UIColor whiteColor];
    [bgImage release];
    
    UITableViewCell * lastSelectedCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
    image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    UIImageView * lastSelectedCellBGImage = [[UIImageView alloc] initWithImage:image];
    [lastSelectedCellBGImage setContentMode:UIViewContentModeScaleToFill];
    lastSelectedCell.backgroundView = lastSelectedCellBGImage;
    lastSelectedCell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    lastSelectedCell.textLabel.textColor = [appDelegate colorForHex:@"2d5d83"];
    [lastSelectedCellBGImage release];
    [lastSelectedCell setNeedsLayout]; /*ios7_support shravya*/
    lastSelectedIndexPath = [indexPath retain];
    
//    if ([lastSelectedIndexPath isEqual:indexPath]) 
//    {
//        
//        UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
//        UIView * cellBackgroundView = selectedCell.backgroundView;
//        UIImageView * bgImage = (UIImageView *)[cellBackgroundView viewWithTag:BGIMAGETAG];
//        image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
//        image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
//        [bgImage setImage:image];
//        [bgImage setContentMode:UIViewContentModeScaleToFill];
//        UILabel * selectedCellLabel = (UILabel *)[cellBackgroundView viewWithTag:CELLLABELTAG];
//        selectedCellLabel.textColor = [UIColor whiteColor];
//    }
//    else
//    {
//        UITableViewCell * lastSelectedCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
//        UIView * lastSelectedCellBackgroundView = lastSelectedCell.backgroundView;
//        UIImageView * lastSelectedCellBGImage = (UIImageView *)[lastSelectedCellBackgroundView viewWithTag:BGIMAGETAG];
//        image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
//        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
//        [lastSelectedCellBGImage setImage:image];
//        [lastSelectedCellBGImage setContentMode:UIViewContentModeScaleToFill];
//        UILabel * lastSelectedCellLabel = (UILabel *)[lastSelectedCellBackgroundView viewWithTag:CELLLABELTAG];
//        lastSelectedCellLabel.textColor = [UIColor blackColor];
//        
//    }
//    
//    UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
//    UIView * cellBackgroundView = selectedCell.backgroundView;
//    UIImageView * bgImage = (UIImageView *)[cellBackgroundView viewWithTag:BGIMAGETAG];
//    image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
//    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
//    [bgImage setImage:image];
//    [bgImage setContentMode:UIViewContentModeScaleToFill];
//    UILabel * selectedCellLabel = (UILabel *)[cellBackgroundView viewWithTag:CELLLABELTAG];
//    selectedCellLabel.textColor = [UIColor whiteColor];
//
//    lastSelectedIndexPath = [indexPath retain];    

}

@end