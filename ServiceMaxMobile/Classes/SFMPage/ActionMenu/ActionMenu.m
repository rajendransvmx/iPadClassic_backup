//
//  ActionMenu.m
//  project
//
//  Created by Samman on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActionMenu.h"
#import "WSIntfGlobals.h"
#import "AppDelegate.h"
#import "databaseIntefaceSfm.h"
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

static const NSInteger padding = 12;
static const NSInteger buttonHeight = 38;
static const NSInteger seperatorHeight = 1;

@implementation ActionMenu

@synthesize delegate;
@synthesize buttons, popover;
//8915
@synthesize buttonDisplayDict;
@synthesize buttonTypeArray;
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
    SMLog(kLogLevelVerbose,@"ActionMenu dealloc");
    [cancel release];
    [save release];
    [quick_save release];
    [summary release];
    [troubleShooting release];
    [chatter release];
    //8915
    [buttonDisplayDict release];
    if([buttonTypeArray count] > 0) {
        [buttonTypeArray release];
        buttonTypeArray = nil;
    }
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
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    @try{
        UIButton * button = (UIButton *)sender;
        int index = button.tag;
    // get button tag
        NSInteger row     = index % 100;
        NSInteger section = index /100;
        
        NSDictionary * buttonDict = nil;
        NSString *str = [self.buttonTypeArray objectAtIndex:section]; //get the key eg: getprice
        NSArray *arr = [buttonDisplayDict objectForKey:str];     //get the array with getprice
        
        if([arr count] > 0) {
            buttonDict = [arr objectAtIndex:row];     //based on value get the dict
        }
    
    if(appDelegate.isWorkinginOffline)
    {
        //[delegate dismissActionMenu];//Shravya-8639. Henceforth the dismiss action menu is called from offlineActions.
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
        
        //AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
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
        SMLog(kLogLevelError,@"Exception Name Action Menu :buttonClicked %@",e.name);
        SMLog(kLogLevelError,@"Exception Reason Action Menu :buttonClicked %@",e.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:e];
        
    }

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    
    //8915
    //get categorized array of button dict
    self.buttonDisplayDict = [self getDataSourceArrayForArray:buttons];
    
    int buttonCount = [buttons count];
    int sectionCount = [self.buttonTypeArray count];
    CGFloat height = (buttonCount * buttonHeight) + ((buttonCount +1) * padding) + (sectionCount -1) * padding;
    
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
        
            if (size.width > maxSize) {
                //8915 calculation gives rounded up value, hence trimming characters
            maxSize = size.width + 5;
            }
        }@catch (NSException *exp) {
            SMLog(kLogLevelError,@"Exception Name Action Menu :viewDidLoad %@",exp.name);
            SMLog(kLogLevelError,@"Exception Reason Action Menu :viewDidLoad %@",exp.reason);
            [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
        }

    }
    //8915
    CGSize size = CGSizeMake(maxSize+padding, height); //starting and ending padding
    self.contentSizeForViewInPopover = size;
}
//8915
- (NSMutableDictionary *) getDataSourceArrayForArray:(NSMutableArray *)buttonDictarray {
    
    NSMutableDictionary * dict = [[[NSMutableDictionary alloc] initWithCapacity:0]autorelease];
    self.buttonTypeArray = [NSMutableArray array];
    
    for(NSDictionary * tempDict in buttons)
    {
        NSString * value = [tempDict objectForKey:SFW_ACTION_TYPE];
        if([[dict allKeys] containsObject:value])
        {
            NSMutableArray * arry =[dict objectForKey:value];
            [arry addObject:tempDict];
            [dict setValue:arry forKey:value];
        }
        else{
            NSMutableArray * tempArray =  [NSMutableArray array];
            [tempArray addObject:tempDict];
            [dict setValue:tempArray forKey:value];
            [self.buttonTypeArray addObject:value];
        }
    }
    return dict;
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
    return [self.buttonTypeArray count];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //8915 - seperator
    UIView *customView = [[[UIView alloc] init] autorelease];
    customView.backgroundColor = [UIColor clearColor];
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup-seperator.png"]];
    [customView addSubview:img];
    [img release];
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return padding;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	
    NSString *key = [self.buttonTypeArray objectAtIndex:section];
    NSArray *arr = [buttonDisplayDict objectForKey:key];
    rowCount =[arr count];
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return buttonHeight+padding;
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

    button.frame = CGRectMake(padding, 0, maxSize-padding, buttonHeight);

    button.titleLabel.textColor = [UIColor blackColor];
    
    UIImage * normalBtnImg = [UIImage imageNamed:@"action-btn-content.png"];
    normalBtnImg = [normalBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
    [button setBackgroundImage:normalBtnImg forState:UIControlStateNormal];
    UIImage * highlightBtnImg = [UIImage imageNamed:@"action-btn-content-hover.png"];
    highlightBtnImg = [highlightBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
    [button setBackgroundImage:highlightBtnImg forState:UIControlStateHighlighted];
  
    NSString * key =[self.buttonTypeArray objectAtIndex:indexPath.section];
    NSArray *arr = [buttonDisplayDict objectForKey:key];
    NSDictionary *buttonDict = [arr objectAtIndex:indexPath.row];
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    @try{
    if(appDelegate.isWorkinginOffline)
    {
        NSString * title = [buttonDict objectForKey:SFW_ACTION_DESCRIPTION];
        NSString * enable = [buttonDict objectForKey:SFW_ENABLE_ACTION_BUTTON];
        
        
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.enabled = [enable boolValue];
    }
    else
    {
    
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
        SMLog(kLogLevelError,@"Exception Name Action Menu :cellForRowAtIndexPath %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Action Menu :cellForRowAtIndexPath %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = indexPath.row + (indexPath.section * 100); //categorising 8915

    [cell.contentView addSubview:button];

    cell.selectionStyle = UITableViewCellEditingStyleNone;
    cell.backgroundColor=[UIColor clearColor];
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
