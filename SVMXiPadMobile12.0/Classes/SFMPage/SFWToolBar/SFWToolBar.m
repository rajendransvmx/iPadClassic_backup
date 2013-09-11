//
//  SFWToolBar.m
//  iService
//
//  Created by Pavamanaprasad Athani on 26/12/11.
//  Copyright (c) 2011 Bit Order Technologies. All rights reserved.
//

#import "SFWToolBar.h"
#import "cusButton.h"
#import "databaseIntefaceSfm.h"
#import <QuartzCore/QuartzCore.h>

extern void SVMXLog(NSString *format, ...);

@implementation SFWToolBar
@synthesize buttonsArray_offline;
@synthesize wizard_info;
@synthesize ipad_only_array;
@synthesize ipad_only_view;
@synthesize delegate;
@synthesize popOver;
@synthesize wizard_buttons;
@synthesize sfw_tableview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
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
    // Do any additional setup after loading the view from its nib.
    //[self showIpadOnlyButtons];
    
    wizard_buttons = [[NSMutableDictionary alloc] initWithCapacity:0];
    
	@try{
    NSMutableArray * array = [wizard_info objectForKey:SFW_WIZARD_INFO];
    
    for(int i = 0; i < [array count]; i++)
    {
        NSDictionary * dict = [array objectAtIndex:i];
        NSString * wizard_id = [dict objectForKey:WIZARD_ID];
        NSMutableArray * buttons_ = [[NSMutableArray alloc] initWithCapacity:0];
        for(int j = 0 ; j < [buttonsArray_offline count];j++)
        {
            NSDictionary * dict = [buttonsArray_offline objectAtIndex:j];
            NSString * id_  = [dict objectForKey:WIZARD_ID];
            if([id_ isEqualToString:wizard_id])
            {
                [buttons_ addObject:dict];
            }
        }
        
        [wizard_buttons setObject:buttons_ forKey:wizard_id];
    }
	}@catch (NSException *exp) {
	SMLog(@"Exception Name SFWToolBar :viewDidLoad %@",exp.name);
	SMLog(@"Exception Reason SFWToolBar :viewDidLoad %@",exp.reason);
    }

    
}

-(void)showIpadOnlyButtons;
{
    SMLog(@"%@", ipad_only_array);                      
                                 
                                 
    SMLog(@"%f, %f", ipad_only_view.frame.size.width, ipad_only_view.frame.size.height);
    ipad_only_view.frame = CGRectMake(10, 0, 1024, 62);
    CGPoint p = CGPointZero;
    p.x  = ipad_only_view.frame.origin.x;
    p.y = ipad_only_view.frame.origin.y;
    float field_width = 160;
    @try{
    for (int i = 0 ; i <[ipad_only_array count] ; i++) 
    {
        NSDictionary * dict = [ipad_only_array objectAtIndex:i];
        NSString * title = [dict objectForKey:SFW_ACTION_DESCRIPTION];
        CGRect frame = CGRectMake(i*field_width, 6 , BUTTON_WIDTH , BUTTON_HEIGHT);
              
        cusButton * btn = [[cusButton alloc] initWithFrame:frame buttonTitle:title buttonInfo:dict];
        btn.frame = frame;
        //btn.button_info = dict;
        UIImage * normalBtnImg = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button.png"];
        normalBtnImg = [normalBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
        [btn setBackgroundImage:normalBtnImg forState:UIControlStateNormal];
        
        UIImage * highlightBtnImg = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button2.png"];
        highlightBtnImg = [highlightBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
        [btn setBackgroundImage:highlightBtnImg forState:UIControlStateHighlighted];

        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag = i;
    
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [ipad_only_view addSubview:btn];
    }
     }@catch (NSException *exp) {
        SMLog(@"Exception Name SFWToolBar :showIpadOnlyButtons %@",exp.name);
        SMLog(@"Exception Reason SFWToolBar :showIpadOnlyButtons %@",exp.reason);
    }
}


- (void)viewDidUnload
{
    [ipad_only_view release];
    ipad_only_view = nil;
    [sfw_tableview release];
    sfw_tableview = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    SMLog(@" buttonsArray_offline %@ ", buttonsArray_offline);
    @try{
    NSMutableArray * array = [wizard_info objectForKey:SFW_WIZARD_INFO];
    NSDictionary * dict = [array objectAtIndex:section];
    NSString * wizard_id = [dict objectForKey:WIZARD_ID];
      
    NSArray * allKeys = [wizard_buttons allKeys];
    for(int i = 0; i< [allKeys count]; i++)
    {
        NSString * key = [allKeys objectAtIndex:i];
        if([key isEqualToString:wizard_id])
        {
            NSArray *  wizard = [wizard_buttons objectForKey:wizard_id];
           
           NSInteger quotient = [wizard count] / 6;
           NSInteger reminder = [wizard count] % 6;
           if(reminder != 0)
           {
              return quotient +1;
           }
           else
           {
               return quotient;
           }
            
        }
    }
	}@catch (NSException *exp) {
	SMLog(@"Exception Name SFWToolBar :numberOfRowsInSection %@",exp.name);
	SMLog(@"Exception Reason SFWToolBar :numberOfRowsInSection %@",exp.reason);
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString * identifier = @"cell";
    
    static int backgroudTag = 8001;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UITableViewCell * cell  = [tableView dequeueReusableCellWithIdentifier:identifier];
    UIView * background = nil;
    NSInteger width = 1024;
    if(cell == nil)
    {
        cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
       // background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, cell.frame.size.height)];
       
    }
    else
    {
        cell.backgroundView = nil;
        if([[cell.contentView  subviews] count] == 0)
        {
            // Do nothing
            cell.backgroundView = nil;
        }
        else
        {
            // Vipin 28th Jan : Reset content view 
            background = [cell.contentView viewWithTag:backgroudTag];
            background = nil;
            
            //sahana 16th August
            for(int j = 0; j< [[cell.contentView subviews] count]; j++)
            {
                background = [[cell.contentView subviews] objectAtIndex:j];
                
                NSArray * backgroundSubViews = [background subviews];
                
                for (int i = 0; i < [backgroundSubViews count]; i++)
                {
                    [[backgroundSubViews objectAtIndex:i] removeFromSuperview];
                }
                [background removeFromSuperview];
            }
            background = nil;
        }
    }
    
    NSInteger section = indexPath.section;
    int row = indexPath.row;
    float field_width = 160;
    
    CGFloat final_height = 0;
    CGFloat temp_height  = 0;

    @try{
    NSMutableArray * array = [wizard_info objectForKey:SFW_WIZARD_INFO];
    NSDictionary * dict = [array objectAtIndex:section];
    NSString * wizard_id = [dict objectForKey:WIZARD_ID];
    
    NSArray * allKeys = [wizard_buttons allKeys];
    for(int i = 0; i< [allKeys count]; i++)
    {
        NSString * key = [allKeys objectAtIndex:i];
        if([key isEqualToString:wizard_id])
        {
            NSArray *  wizard = [wizard_buttons objectForKey:wizard_id];
            
            int x = row * 6;
                      
            for(int j = x ; j < (x+6) ;j++)
            {
                if(j >= [wizard count])
                {
                    break;
                }
                
                NSDictionary * each_button = [wizard objectAtIndex:j];
                NSString * str = [each_button objectForKey:SFW_ACTION_DESCRIPTION];
                CGSize size1 = [str sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(150, 9999)];
                temp_height = size1.height;
                
                if(temp_height > final_height)
                {
                    final_height = temp_height;
                }
            }
            if(background == nil)
            {
                if(final_height < 40)
                    final_height =  50;
                else
                    final_height = final_height + 20;
               
                background = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, final_height)] autorelease];
                background.tag = backgroudTag;
            }
            
            for(int j = x, index =0  ; j < (x+6) ;j++, index++)
            {
                if(j >= [wizard count])
                {
                    break;
                }
                
                NSDictionary * each_button = [wizard objectAtIndex:j];
                NSString * title = [each_button objectForKey:SFW_ACTION_DESCRIPTION];
                NSString * enable = [each_button  objectForKey:SFW_ENABLE_ACTION_BUTTON];
                
                NSString * action_type = [each_button objectForKey:@"action_type"];
                CGRect frame = CGRectMake(20+index*field_width, 6 , CELL_BUTTON_WIDTH , background.frame.size.height);
                
                cusButton * btn = nil; // [[cusButton alloc] initWithFrame:frame buttonTitle:title buttonInfo:each_button];
                btn = [cusButton buttonWithType:UIButtonTypeCustom];
                btn.button_info = each_button;
                btn.frame = frame;
                
                btn.titleLabel.frame = btn.bounds;
                
                //RDAHA 
                if ([action_type isEqualToString:@"SFW_Custom_Actions"])
                {
                    [[btn layer] setBorderWidth:3.0f];
                    [btn.layer setBorderColor:[[UIColor greenColor] CGColor]];
                    btn.accessibilityValue = @"{border_color: green}";
                }
                else
                {
                    btn.accessibilityValue = @"{border_color: none}";
                }
                
                /******shrinivas*******/
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
                /******shrinivas*******/
                
                btn.titleLabel.backgroundColor = [UIColor clearColor];
                [btn setTitle:title forState:UIControlStateNormal];
                btn.titleLabel.textColor = [UIColor whiteColor];
                btn.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
                btn.titleLabel.numberOfLines = 0;
                //sahana wizard 
                btn.enabled = [enable boolValue];
                
                UIImage * normalBtnImg = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button.png"];
                normalBtnImg = [normalBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
                [btn setBackgroundImage:normalBtnImg forState:UIControlStateNormal];

                
                UIImage * highlightBtnImg = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button2.png"];
                highlightBtnImg = [highlightBtnImg stretchableImageWithLeftCapWidth:12 topCapHeight:8];
                [btn setBackgroundImage:highlightBtnImg forState:UIControlStateHighlighted];
        
                 btn.tag = i;
                btn.isAccessibilityElement = YES;
                [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [background addSubview:btn];

            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.contentView addSubview:background];
        
	}@catch (NSException *exp) {
	SMLog(@"Exception Name SFWToolBar :cellForRowAtIndexPath %@",exp.name);
	SMLog(@"Exception Reason SFWToolBar :cellForRowAtIndexPath %@",exp.reason);
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    NSMutableArray * array = [wizard_info objectForKey:SFW_WIZARD_INFO];
    if([array count] > 0 && array != nil)
    {
        return [array count];
    }
    else
    {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSString * wizard_description=@"";
    @try
    {

    NSMutableArray * array = [wizard_info objectForKey:SFW_WIZARD_INFO];
    NSDictionary * dict = [array objectAtIndex:section];
   // NSString * wizard_description = [dict objectForKey:WIZARD_DESCRIPTION];
    wizard_description = [dict objectForKey:WIZARD_TITLE]; //RADHA
    
    NSString * wizard_id = [dict objectForKey:WIZARD_ID];
    
    NSArray * allKeys = [wizard_buttons allKeys];
    for(int i = 0; i< [allKeys count]; i++)
    {
        NSString * key = [allKeys objectAtIndex:i];
        if([key isEqualToString:wizard_id])
        {
            NSArray *  wizard = [wizard_buttons objectForKey:wizard_id];
            if([wizard count] == 0)
            {
                return  @"";
            }
        }
    }
	}@catch (NSException *exp) {
	SMLog(@"Exception Name SFWToolBar :titleForHeaderInSection %@",exp.name);
	SMLog(@"Exception Reason SFWToolBar :titleForHeaderInSection %@",exp.reason);
    }

    return wizard_description;
}

- (void)dealloc 
{
    [ipad_only_view release];
    [sfw_tableview release];
    [super dealloc];
}


- (void) buttonClicked:(id)sender
{
    cusButton * custButton =(cusButton *)sender;
    NSDictionary * dict = custButton.button_info;
    [delegate offlineActions:dict];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    int section = indexPath.section;
    int row = indexPath.row;
        
    NSMutableArray * array = [wizard_info objectForKey:SFW_WIZARD_INFO];
    NSDictionary * dict = [array objectAtIndex:section];
    NSString * wizard_id = [dict objectForKey:WIZARD_ID];
    
    CGFloat final_height = 0;
    CGFloat temp_height  = 0;
    @try{
    NSArray * allKeys = [wizard_buttons allKeys];
    for(int i = 0; i< [allKeys count]; i++)
    {
        NSString * key = [allKeys objectAtIndex:i];
        if([key isEqualToString:wizard_id])
        {
            NSArray *  wizard = [wizard_buttons objectForKey:wizard_id];
            int x = row * 6;
            
            
            /*if(x == 0)
            {
                count = [wizard count]; 
            }
            else
            {
                count = [wizard count] % x;
            }*/
            
            for(int j = x ; j < (x+6) ;j++)
            {
               
                if(j >= [wizard count])
                {
                    break;
                }
                NSDictionary * each_button = [wizard objectAtIndex:j];
                NSString * str = [each_button objectForKey:SFW_ACTION_DESCRIPTION];
               // CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:17] forWidth:CELL_BUTTON_WIDTH lineBreakMode:UILineBreakModeWordWrap];
                CGSize size1 = [str sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(150, 9999)];
                temp_height = size1.height;

                if(temp_height > final_height)
                {
                    final_height = temp_height;
                }
            }
        }
    }
	}@catch (NSException *exp) {
	SMLog(@"Exception Name SFWToolBar :cellForRowAtIndexPath %@",exp.name);
	SMLog(@"Exception Reason SFWToolBar :cellForRowAtIndexPath %@",exp.reason);
    }

    if(final_height < 40)
        return 60;
    else
        return final_height+30;
}

@end
