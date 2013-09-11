//
//  RouteListViewController.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/12.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "RouteListViewController.h"
#import "UICGRoute.h"
#import "UICGStep.h"

@interface UITextView(HTML)
// - (void)setContentToHTMLString:(id)fp8;
@end

@implementation RouteListViewController

@synthesize tableView, routes;

- (void)dealloc {
	[routes release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	//self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss:)] autorelease];
	// self.title = NSLocalizedString(@"Routes", nil);
	// self.tableView.rowHeight = 60.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismiss:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	//Fix for avoiding crash
	NSUInteger count = 0;
	if (routes != nil && [routes count] > 0)
	{
		count  = [routes count];
	}
	return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (routes == nil)
        return 0;
	UICGRoute *route = [routes objectAtIndex:section];
	//Fix for avoiding crash
	NSUInteger count = 0;
	if (route != nil)
	{
		count = [route numberOfSteps];
	}
	
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	UICGRoute *route = [routes objectAtIndex:section];
    return [route.summaryHtml stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 2.0f, 280.0f, 56.0f)];
		textView.editable = NO;
		textView.scrollEnabled = NO;
		textView.opaque = YES;
		textView.backgroundColor = [UIColor whiteColor];
		textView.tag = 1;
		[cell addSubview:textView];
        [textView release];
		
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
	UICGRoute *route = [routes objectAtIndex:indexPath.section];
	UICGStep *step = [route stepAtIndex:indexPath.row];
    
	UITextView *textView = (UITextView *)[cell viewWithTag:1];
	// [textView setContentToHTMLString:step.descriptionHtml];
    [textView setText:[self flattenHTML:step.descriptionHtml]];
	
    return cell;
}

- (NSString *)flattenHTML:(NSString *)html
{
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
        
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@>", text]
                                               withString:@" "];
        
    } // while //
    
    return html;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

@end
