//
//  RouteController.m
//  iService
//
//  Created by Samman Banerjee on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RouteController.h"
#import "UICGRoute.h"
#import "UICGStep.h"
extern void SVMXLog(NSString *format, ...);

@implementation RouteController

@synthesize directionArray;
@synthesize workOrderArray;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

- (void) scrollToSection:(NSNumber *)index
{
    NSInteger section = 0;
    if([index intValue] < 0)
        section = [directionArray count]-1;
    else
        section = [index intValue];
    UICGRoute *route = [directionArray objectAtIndex:section];
    if(![route numberOfSteps])
    {
        SMLog(@"[%@]Route Data is NULL",NSStringFromSelector(_cmd));
        return;
    } 
    // scroll to annotationIndexth section
    if ([index intValue] < 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[directionArray count]-1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return;
    }

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[index intValue]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [directionArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    UICGRoute *route = [directionArray objectAtIndex:section];
    return [route numberOfSteps];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	UICGRoute *route = [directionArray objectAtIndex:section];
    if (section == [workOrderArray count])
        section = 0;
    NSDictionary * dict = [workOrderArray objectAtIndex:section];
    NSString * sectionDetail = [NSString stringWithFormat:@"%@\r-- -- -- -- -- --\r%@\r-- -- -- -- -- --\r%@", [dict objectForKey:@"WorkOrderNumber"], [dict objectForKey:@"WorkOrderAddress"], [route.summaryHtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "]];
    return sectionDetail;
    // return [route.summaryHtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
}

- (RouteControllerCell *) createCustomCellWithId:(NSString *) cellIdentifier
{
	NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"RouteControllerCell" owner:self options:nil];
	NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
	RouteControllerCell * customCell = nil;
	
    NSObject* nibItem = nil;
	
    while ( (nibItem = [nibEnumerator nextObject]) != nil)
	{
		if ( [nibItem isKindOfClass: [RouteControllerCell class]])
		{
			customCell = (RouteControllerCell *) nibItem;
			if ([customCell.reuseIdentifier isEqualToString:cellIdentifier ])
				break; // OneTeamUS We have a winner
			else
				customCell = nil;
		}
	}
	return customCell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RouteControllerCell";
    
    RouteControllerCell *cell = (RouteControllerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [self createCustomCellWithId:CellIdentifier];
    }
    else
        cell.imageView.image = nil;
    
    // Configure the cell...
    
    /*
    if (indexPath.row == 0)
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_greenA.png"];
    }
    
    if (indexPath.row == ([directionArray count]-1))
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_greenB.png"];
    }
    */
    
    cell.backgroundColor = [UIColor blueColor];
    
    UICGRoute *route = [directionArray objectAtIndex:indexPath.section];
	UICGStep *step = [route stepAtIndex:indexPath.row];

	[cell setCellText:step.descriptionHtml];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [directionArray release];
    [super dealloc];
}


@end

