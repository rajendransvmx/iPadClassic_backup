//
//  RecentObjectRoot.m
//  iService
//
//  Created by Samman on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentObjectRoot.h"


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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [recentObjectsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
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
        if (lastSelectedIndexPath == indexPath)
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
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (indexPath == lastSelectedIndexPath)
        return;

    UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
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
    
    lastSelectedIndexPath = [indexPath retain];
}

@end
