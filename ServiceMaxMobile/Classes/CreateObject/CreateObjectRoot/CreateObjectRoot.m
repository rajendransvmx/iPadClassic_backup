//
//  CreateObjectRoot.m
//  iService
//
//  Created by Samman on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreateObjectRoot.h"
#import "Utility.h"

//extern void NSLog(NSString *format, ...);

@implementation CreateObjectRoot

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        firstTimeLoad = YES;
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
    
    lastSelectedIndexPath = nil;

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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	
	if (appDelegate.objectLabelName_array != nil && [appDelegate.objectLabelName_array count] > 0)
	{
		rowCount = [appDelegate.objectLabelName_array count];
	}
	
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    else
    {
        NSArray * _array = [cell.contentView subviews];
        for (UIView * view in _array)
            [view removeFromSuperview];
    }
    
    // Configure the cell...
    @try{
    NSDictionary * dict = [appDelegate.objectLabelName_array objectAtIndex:indexPath.row];
    NSArray * arr = [dict allValues];
    NSString * objectName = @"";
    if ([arr count] > 0)
        objectName = [arr objectAtIndex:0];
    UIImage * image = nil;
    UIImageView * bgImage = nil;
    
    cell.textLabel.text = objectName;
    
    if (firstTimeLoad)
    {
        firstTimeLoad = NO;

        image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
        image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        bgImage = [[UIImageView alloc] initWithImage:image];
        [bgImage setContentMode:UIViewContentModeScaleToFill];

        cell.backgroundView = bgImage;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        cell.textLabel.textColor = [UIColor whiteColor];

        lastSelectedIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
    }
    else
    {

        if ([indexPath isEqual:lastSelectedIndexPath])
        {
            image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
            image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
            bgImage = [[UIImageView alloc] initWithImage:image];
            [bgImage setContentMode:UIViewContentModeScaleToFill];
            
            cell.backgroundView = bgImage;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        else
        {
            image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
            image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
            bgImage = [[UIImageView alloc] initWithImage:image];
            [bgImage setContentMode:UIViewContentModeScaleToFill];

            cell.backgroundView = bgImage;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
            cell.textLabel.textColor = [appDelegate colorForHex:@"2d5d83"];
        }
    }

    [bgImage release];
    }@catch (NSException *exp) {
        NSLog(@"Exception Name CreateObjectRoot :cellForRowAtIndexPath %@",exp.name);
        NSLog(@"Exception Reason CreateObjectRoot :cellForRowAtIndexPath %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Table view delegate

//Fat Finger
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        // Navigation logic may go here. Create and push another view controller.
        if ([delegate respondsToSelector:@selector(didSelectRowAtIndexPath:)])
        {
            [delegate didSelectRowAtIndexPath:indexPath];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIImage * image = nil;
        
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
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
        /*ios7_support shravya*/
        image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
        if ([Utility notIOS7]) {
            image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
        }
        else {
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(8, 11, 0, 0) resizingMode:UIImageResizingModeStretch];
        }
        UIImageView * lastSelectedCellBGImage = [[UIImageView alloc] initWithImage:image];
        [lastSelectedCellBGImage setContentMode:UIViewContentModeScaleToFill];
        lastSelectedCell.backgroundView = lastSelectedCellBGImage;
        lastSelectedCell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        lastSelectedCell.textLabel.textColor = [appDelegate colorForHex:@"2d5d83"];
        lastSelectedIndexPath = [indexPath retain];
        [lastSelectedCell setNeedsLayout]; /*ios7_support shravya*/
    }
    @catch (NSException * error)
    {
        NSLog(@"Create Object Error: %@", error.description);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:error];
    }
}

@end
