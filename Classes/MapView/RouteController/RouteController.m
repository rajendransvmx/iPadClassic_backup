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

// V3:KRI
- (NSArray *)getStepsForLegAtIndex:(NSInteger)legIndex {

    NSArray *stepsArr = nil;
    
    //Only one route
    UICGRoute *route = [directionArray objectAtIndex:0];
    
    if (route != nil) {
        NSDictionary *k = [route.legsArray objectAtIndex:legIndex];
        stepsArr = [k objectForKey:@"steps"];
    }
    return stepsArr;
}
// V3:KRI
- (NSArray *)getLegsForRoute {
    
    UICGRoute *route = [directionArray objectAtIndex:0];
    if(route != nil) {
    return route.legsArray;
    }
    return nil;
}
#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}
// V3:KRI
- (void) scrollToSection:(NSNumber *)index
{
    NSInteger section = 0;
    if([index intValue] < 0)
        section = [[self getLegsForRoute] count]-1;
    else
        section = [index intValue];
//    UICGRoute *route = [directionArray objectAtIndex:0];
    if([[self getLegsForRoute] count] <= 0)
    {
        SMLog(@"[%@]Route Data is NULL",NSStringFromSelector(_cmd));
        return;
    } 
    // scroll to annotationIndexth section
    if ([index intValue] < 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[[self getLegsForRoute] count]-1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return;
    }

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[index intValue]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark Table view data source
// V3:KRI
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
	//Fix for avoiding crash
	NSArray * array = [self getLegsForRoute];
	
	NSUInteger count = 0;
	if (array != nil && [array count] > 0)
	{
		count  = [array count];
	}
	return count;
    //return [[self getLegsForRoute] count];
}

// V3:KRI
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    UICGRoute *route = [directionArray objectAtIndex:section];
//    return [route numberOfSteps];
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	NSArray * array = [self getStepsForLegAtIndex:section];
	
    if (array != nil && [array count] > 0)
	{
		rowCount =  [array count];
	}
	
    return rowCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	UICGRoute *route = [directionArray objectAtIndex:0];
    if (section == [workOrderArray count])
        section = 0;
    
    NSDictionary *legDict = [route.legsArray objectAtIndex:section];
    NSString *distance = [[legDict objectForKey:@"distance"] objectForKey:@"text"];
    NSString *duration = [[legDict objectForKey:@"duration"] objectForKey:@"text"];
    
    NSString *requiredFormatString = [NSString stringWithFormat:@"%@ ( about %@ )",distance,duration];
    
    
    NSDictionary * dict = [workOrderArray objectAtIndex:section];
    NSString * sectionDetail = [NSString stringWithFormat:@"%@\r-- -- -- -- -- --\r%@\r-- -- -- -- -- --\r%@", [dict objectForKey:@"WorkOrderNumber"], [dict objectForKey:@"WorkOrderAddress"],requiredFormatString];
                                
                                //[route.summaryHtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "]];
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
    
    //UICGRoute *route = [directionArray objectAtIndex:0];
	NSDictionary *step = [[self getStepsForLegAtIndex:indexPath.section] objectAtIndex:indexPath.row];//[route stepAtIndex:indexPath.row];
    
    
    
	[cell setCellText:[step objectForKey:@"instructions"]];
    
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
- (NSString *)trimHTML:(NSString *)html
{
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        [theScanner scanUpToString:@">" intoString:&text] ;
        html = [html stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@>", text]
                                               withString:@" "];
    }
    return html;
}


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Krishna Map 7005
    NSDictionary *step = [[self getStepsForLegAtIndex:indexPath.section] objectAtIndex:indexPath.row];//[route stepAtIndex:indexPath.row];
    
	NSString *cellText = [step objectForKey:@"instructions"];
    cellText = [self trimHTML:cellText];
    //Since width of the text view is 199 the constraint size width should be 30-40 pixel less than width to adequate the words to be within the required area 160
    //constraint height is 1000, coz its the max allowed limit.
    
    float constraintWidth = 160;
    float constraintHeight = 1000;
    
    CGSize cellTextSize = [cellText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f] constrainedToSize:CGSizeMake(constraintWidth, constraintHeight)];
    
    float retValue = 0.0f;
    float padding = 10.0f;
    
    retValue = cellTextSize.height + padding;
    return retValue;
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

