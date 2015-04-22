//
//  LookupDetails.m
//  SVNTest
//
//  Created by Samman on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LookupDetails.h"
#import "WSInterface.h"
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);
@implementation LookupDetails

@synthesize delegate;
@synthesize lookupDetailsArray;
@synthesize indexPath;

- (void)dealloc
{
    [lookupDetailTable release];
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
    
//    CGSize size = {320, 600}; // size of view in popover
//    self.contentSizeForViewInPopover = size;
//    
//    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
//    _tableView.dataSource = self;
//    _tableView.delegate = self;
//    [self.view addSubview:_tableView];
    
    /*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"red_btn_image.png"] forState:UIControlStateNormal];
    [button setTitle:@"Select" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    [button.layer setCornerRadius:4.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor: [[UIColor grayColor] CGColor]];
    button.frame=CGRectMake(0.0, 100.0, 60.0, 30.0);
    [button addTarget:self action:@selector(batchDelete) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * selectButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    */
    
    UIBarButtonItem * selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(select:)];

    self.navigationItem.rightBarButtonItem = selectButton;
    [selectButton release];
}

- (void) select:(id)sender
{
    [delegate didSelectDetailAtIndexPath:indexPath];
}

- (void)viewDidUnload
{
    [lookupDetailTable release];
    lookupDetailTable = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize size = {320, 250}; // size of view in popover
    self.contentSizeForViewInPopover = size;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGSize size = {320, 250}; // size of view in popover
    self.contentSizeForViewInPopover = size;
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
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	
	if (lookupDetailsArray != nil && [lookupDetailsArray count] > 0)
	{
		rowCount = [lookupDetailsArray count];
	}
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)_indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    else //Defect Fix - 8973
    {
        for (UIView * view in [cell.contentView subviews])
        {
            [view removeFromSuperview];
        }
    }
    
    // Configure the cell...
    @try{
    NSDictionary * fieldDictionary = [lookupDetailsArray objectAtIndex:_indexPath.row];
    UILabel * fieldLabel_Label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)] autorelease];
    fieldLabel_Label.font = [UIFont fontWithName:@"Verdana-Bold" size:16];
    UILabel * fieldValue_Label = [[[UILabel alloc] initWithFrame:CGRectMake(20, 23, tableView.frame.size.width, 22)] autorelease];
    fieldValue_Label.font = [UIFont fontWithName:@"Verdana" size:14];
    fieldLabel_Label.text = [fieldDictionary objectForKey:gLOOKUP_FIELD_LABEL];
    fieldValue_Label.text = [fieldDictionary objectForKey:gLOOKUP_FIELD_VALUE];
    // cell.textLabel.text = [lookupDetailsArray objectAtIndex:indexPath.row];
    
    [cell.contentView addSubview:fieldLabel_Label];
    [cell.contentView addSubview:fieldValue_Label];
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name LookupDetails :cellForRowAtIndexPath %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason LookupDetails :cellForRowAtIndexPath %@",exp.reason);
    }

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
