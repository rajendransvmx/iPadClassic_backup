//
//  ActionMenu.m
//  project
//
//  Created by Samman on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActionMenu.h"
#import "WSIntfGlobals.h"
#import "iServiceAppDelegate.h"
#import "databaseIntefaceSfm.h"
extern void SVMXLog(NSString *format, ...);

@implementation ActionMenu

@synthesize delegate;
@synthesize buttons, popover;

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
    SMLog(@"ActionMenu dealloc");
    [cancel release];
    [save release];
    [quick_save release];
    [summary release];
    [troubleShooting release];
    [chatter release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) buttonClicked:(id)sender
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    @try{
    UIButton * button = (UIButton *)sender;
    // get button tag
    NSInteger tag = button.tag;
    NSDictionary * buttonDict = [buttons objectAtIndex:tag];
    
    if(appDelegate.isWorkinginOffline)
    {
        [delegate dismissActionMenu];
        [delegate offlineActions:buttonDict];
        return;
    }

    
    NSArray * buttonEventArray = [buttonDict objectForKey:gBUTTON_EVENTS];
    NSDictionary * buttonEvent;
    if ([buttonEventArray count] == 0)
        return;
    else
        buttonEvent = [buttonEventArray objectAtIndex:0];
    
    NSString * targetCall = [buttonEvent objectForKey:gBUTTON_EVENT_TARGET_CALL];
    NSString * callType = [buttonEvent objectForKey:gBUTTON_EVENT_CALL_TYPE];
    NSString * eventType = [buttonEvent objectForKey:gBUTTON_EVENT_TYPE];
    {
        if([targetCall isEqualToString:cancel])
        {
            [delegate BackOnSave:targetCall];
        }
        
        if ([callType isEqualToString:gBUTTON_TYPE_TDM_IPAD_ONLY])
        {
            if ([eventType isEqualToString:@"standard"])
                [delegate didSubmitDefaultAction:targetCall];
            else if ([eventType isEqualToString:@"Button Click"])
                [delegate didSubmitAction:targetCall processTitle:button.titleLabel.text];
        }
        else if ([callType isEqualToString:gBUTTON_TYPE_WEBSERVICE])
        {
            [delegate didInvokeWebService:targetCall];
            // return; // Sahana - 28/07/11
        }
        else
        {
            [delegate didSubmitDefaultAction:@""];
            // return;
        }
        
        //iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.didCreateStandalone = NO;
        
        if ([targetCall isEqualToString:save] || [targetCall isEqualToString:quick_save]) 
        {
            [delegate BackOnSave:targetCall];
        }
        else
        {
            [delegate dismissActionMenu];
        }
    }
    }@catch (NSException *e)
    {
        SMLog(@"Exception Name Action Menu :buttonClicked %@",e.name);
        SMLog(@"Exception Reason Action Menu :buttonClicked %@",e.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:e];
        
    }

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    cancel = [[appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON] retain];
    save = [[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_ACTION_BUTTON_SAVE] retain];
    quick_save = [[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_ACTION_BUTTON_QSAVE] retain];
    summary = [[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_ACTIONPOPOVER_LIST_3] retain];
    troubleShooting = [[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_TROUBLESHOOTING] retain];
    chatter = [[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_ACTIONPOPOVER_LIST_1] retain];
    
    UIImage * tableBackgroundImage = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Panel-BG.png"];
    tableBackgroundImage = [tableBackgroundImage stretchableImageWithLeftCapWidth:12 topCapHeight:8];
    self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:tableBackgroundImage] autorelease];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    CGFloat height = [buttons count] * 38;
    
    maxSize = 0;
    for (int i = 0; i < [buttons count]; i++)
    {
    	@try{
        NSDictionary * buttonDict = [buttons objectAtIndex:i];
        NSString * title = @"";
        if(appDelegate.isWorkinginOffline)
        {
            title = [buttonDict objectForKey:SFW_ACTION_DESCRIPTION];
        }
        else
        {
            title = [buttonDict objectForKey:gBUTTON_TITLE];
        }
       
        
        CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:22] constrainedToSize:CGSizeMake(1024, 1024) lineBreakMode:UILineBreakModeWordWrap];
        
        if (size.width > maxSize)
            maxSize = size.width;
        }@catch (NSException *exp) {
            SMLog(@"Exception Name Action Menu :viewDidLoad %@",exp.name);
            SMLog(@"Exception Reason Action Menu :viewDidLoad %@",exp.reason);
            [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
        }

    }
    
    CGSize size = CGSizeMake(maxSize, height);
    self.contentSizeForViewInPopover = size;
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
    return [buttons count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
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
        UIButton * button = [[cell.contentView subviews] objectAtIndex:0];
        [button removeFromSuperview];
    }

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
    
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    @try{
    if(appDelegate.isWorkinginOffline)
    {
        NSDictionary * buttonDict = [buttons objectAtIndex:indexPath.row];
        NSString * title = [buttonDict objectForKey:SFW_ACTION_DESCRIPTION];        
        NSString * enable = [buttonDict objectForKey:SFW_ENABLE_ACTION_BUTTON];
        
        
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.enabled = [enable boolValue];
    }
    else
    {
    
        NSDictionary * buttonDict = [buttons objectAtIndex:indexPath.row];
        NSString * title = [buttonDict objectForKey:gBUTTON_TITLE];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        NSArray * buttonEvent = [buttonDict objectForKey:gBUTTON_EVENTS];
        NSDictionary * buttonEventDict = nil;
        if ([buttonEvent count] > 0)
            buttonEventDict = [buttonEvent objectAtIndex:0];
        NSString * buttonType = [buttonEventDict objectForKey:gBUTTON_EVENT_TYPE];
        if ([buttonType isEqualToString:@"standard"])
        {
            button.enabled = YES;
        }
        else if([title isEqualToString:troubleShooting])
        {
            button.enabled = TRUE;
        }
        else if ([title isEqualToString:summary])
        {
            button.enabled = YES;
        }
        else if ([title isEqualToString:chatter])
        {
            button.enabled = TRUE;        
        }
        else if([title isEqualToString:save])
        {
            button.enabled = TRUE;
        }
        else if([title isEqualToString:quick_save])
        {
            button.enabled = TRUE;
        }
        else if([title isEqualToString:cancel])
        {
            button.enabled = TRUE;
        }
        else
        {
            NSNumber * buttonEnabled = [buttonDict objectForKey:gBUTTON_EVENT_ENABLE];
            button.enabled = [buttonEnabled boolValue];
        }
    
    }
    }@catch (NSException *exp)
    {
        SMLog(@"Exception Name Action Menu :cellForRowAtIndexPath %@",exp.name);
        SMLog(@"Exception Reason Action Menu :cellForRowAtIndexPath %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = indexPath.row;

    [cell.contentView addSubview:button];

    cell.selectionStyle = UITableViewCellEditingStyleNone;

    return cell;
}

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
