//
//  SelectProcessController.m
//  iService
//
//  Created by Samman on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectProcessController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "databaseIntefaceSfm.h"
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@implementation SelectProcessController

@synthesize delegate;
@synthesize popOver;

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction) Cancel:(id)sender
{
    [popOver dismissPopoverAnimated:YES];
}

- (IBAction) Done:(id)sender
{
    [popOver dismissPopoverAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	@try{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *  header_sfm = [appDelegate.SFMPage objectForKey:@"header"];
    NSString * currentObject = [header_sfm objectForKey:gHEADER_OBJECT_NAME];
    BOOL status;
    status = NO;
    
    /*if ( status == YES )
    {
        for (NSDictionary * dict in appDelegate.wsInterface.viewLayoutsArray)
        {
            if ([currentObject isEqualToString:[dict objectForKey:VIEW_OBJECTNAME]])
            {
                if (array == nil)
                    array = [[NSMutableArray alloc] initWithCapacity:0];
                [array addObject:dict];
            }
        }
    }
    else
    {*/
        //NSDictionary *  header_sfm = [appDelegate.SFMPage objectForKey:@"header"];
       // NSString * currentObject = [header_sfm objectForKey:gHEADER_OBJECT_NAME];
        
        //databaseIntefaceSfm *database = [[databaseIntefaceSfm alloc]init];
       // [app openDB:SFMDATABASE_NAME];
        array = [appDelegate.databaseInterface selectProcessFromDB:currentObject];   
    //}
    
    CGFloat height = [array count] * 38;
    maxSize = 0;
    for (NSDictionary * dict in array)
    {
        NSString * processName = [dict objectForKey:gPROCESS_NAME];
        CGSize size = [processName sizeWithFont:[UIFont systemFontOfSize:22] constrainedToSize:CGSizeMake(1024, 1024) lineBreakMode:UILineBreakModeWordWrap];
        if (size.width > maxSize)
            maxSize = size.width;
    }
    CGSize size = CGSizeMake(maxSize, height);
    //self.contentSizeForViewInPopover = size;
    self.preferredContentSize = size;
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name SelectProcessController :viewDidLoad %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason SelectProcessController :viewDidLoad %@",exp.reason);
    }

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

- (void) buttonClicked:(id)sender
{
	@try{
    UIButton * button = (UIButton *)sender;
    // get button tag
    NSInteger tag = button.tag;
    NSDictionary * dict = [array objectAtIndex:tag];

    // NSString * newProcess = [dict objectForKey:gPROCESS_ID];
    [delegate didSwitchProcess:dict];
    
    [popOver dismissPopoverAnimated:YES];
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name SelectProcessController :buttonClicked %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason SelectProcessController :buttonClicked %@",exp.reason);
    }

}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}

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
	
    if (array != nil && [array count] > 0)
	{
		rowCount =  [array count];
	}
	
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    @try{
    NSDictionary * dict = [array objectAtIndex:indexPath.row];
    SMLog(kLogLevelVerbose,@"%@", dict);
    
    // Configure the cell...
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(2, 2, maxSize-4, 36);
    
    button.titleLabel.textColor = [UIColor blackColor];
    UIImage * normalBtnImg = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button.png"];
    normalBtnImg = [normalBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
    [button setBackgroundImage:normalBtnImg forState:UIControlStateNormal];
    UIImage * highlightBtnImg = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button2.png"];
    highlightBtnImg = [highlightBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
    [button setBackgroundImage:highlightBtnImg forState:UIControlStateHighlighted];
    

    NSString * title = [dict objectForKey:gPROCESS_NAME];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = indexPath.row;
    
    [cell.contentView addSubview:button];
    
    cell.selectionStyle = UITableViewCellEditingStyleNone;
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name SelectProcessController :cellForRowAtIndexPath %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason SelectProcessController :cellForRowAtIndexPath %@",exp.reason);
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end