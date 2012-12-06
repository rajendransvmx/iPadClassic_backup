//
//  MPickContent.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MPickContent.h"


@implementation MPickContent
@synthesize pickListContent;
@synthesize lastIndexPath;
@synthesize index;
@synthesize MPickerDelegate;
@synthesize lookUp;
@synthesize dict;
@synthesize dictArray;
@synthesize flag;
@synthesize releasPODelegate;
@synthesize initialString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [pickListContent release];
    
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
    //new code
    if(flag == TRUE)
    {
        dictArray = [[NSMutableArray alloc]  initWithCapacity:[pickListContent count]];
        NSArray * array = [initialString componentsSeparatedByString:@";"];
        for( int i=0;i<[pickListContent count];i++)
        {
            NSString * str = [pickListContent objectAtIndex:i];
            
            BOOL flag1 = FALSE;
            for(int j = 0; j< [array count]; j++)
            {
                if([[array objectAtIndex:j] isEqualToString:str])
                {
                    flag1 = TRUE;
                }
            }
            if(flag1)
            {
                dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",[pickListContent objectAtIndex:i] , nil];
            }
            else
            {
                dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"",[pickListContent objectAtIndex:i] , nil];
            }
            
            [dictArray addObject:dict];
  
        }
        
        if ([dictArray count] == 0)
        {
            self.view.frame = CGRectMake(0, 0, 320, 80);
            [self showEmptyList];
        }
    } 

    [super viewDidLoad];
    
}

- (void) showEmptyList
{
    UIView * emptyView = [[UIView alloc] initWithFrame:self.view.frame];
    
    emptyView.backgroundColor = [UIColor blackColor];
    emptyView.alpha = 0.7;
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(emptyView.center.x, emptyView.center.y, 200, 31)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Verdana-Bold" size:18];
    label.textColor = [UIColor whiteColor];
    label.text = @"Empty List";
    label.center = emptyView.center;
    label.textAlignment = UITextAlignmentCenter;
    [emptyView addSubview:label];
    
    [self.view addSubview:emptyView];
    
    [emptyView release];
}

- (void)viewDidUnload
{
    [dictArray release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
     return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
       
    return [pickListContent  count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger  row = [indexPath row];
   
   static NSString * identifier = @"cellidentifier";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if(cell == nil)
    {
       cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
       cell.accessoryType=UITableViewCellAccessoryNone;
    }
    
    //cell.accessoryType=UITableViewCellAccessoryNone;

    
    cell.textLabel.text=[pickListContent  objectAtIndex:row];
    
    if([[[dictArray objectAtIndex:row] objectForKey:[pickListContent  objectAtIndex:row]]isEqualToString: @"1"])
    {
          cell.accessoryType =UITableViewCellAccessoryCheckmark;
    }
    
        
    return cell;
           
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;    
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];

    
    if (cell.accessoryType ==UITableViewCellAccessoryNone)
    {
        cell.accessoryType =UITableViewCellAccessoryCheckmark;
     //   [index  insertObject:[pickListContent objectAtIndex:row]atIndex:row];
        int i;
    
        
        for( i=0;i< [pickListContent count];i++)
        {
            if([[pickListContent objectAtIndex:i] isEqualToString: cell.textLabel.text])
            {
                ++pickListcount;
                break;                            
            }
        }
    
        [[dictArray objectAtIndex:i]  setValue:@"1" forKey:[pickListContent objectAtIndex:i]];   
    }
    else
    {
        cell.accessoryType =UITableViewCellAccessoryNone;
      
        
        int j;
        
        for(j=0;j< [pickListContent count];j++)
        {
            if([[pickListContent objectAtIndex:j] isEqualToString: cell.textLabel.text])
            {
                break;                            
            }
        }
        
        [[dictArray objectAtIndex:j]  setValue:@"" forKey:[pickListContent objectAtIndex:j]];
    
    }
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

#pragma mark - PopOverControllerdelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [MPickerDelegate setTextfield:dictArray];
    [releasPODelegate  releasPopover];
}


@end
