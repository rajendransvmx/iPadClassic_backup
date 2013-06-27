//
//  SFMChildView.m
//  iService
//
//  Created by Radha S on 6/3/13.
//
//

#import "SFMChildView.h"
#import "cusButton.h"

@interface SFMChildView ()

@end

@implementation SFMChildView
@synthesize childTableview;
@synthesize linkedProcess = _linkedProcess;
@synthesize detailObjectname = _detailObjectname;
@synthesize headerObjectName = _headerObjectName;
@synthesize record_id = _record_id;
@synthesize childViewDelegate = _childViewDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[childTableview release];
	[_linkedProcess release];
    [_detailObjectname release];
    [_headerObjectName release];
    [_record_id release];
    [_childViewDelegate release];
    _childViewDelegate =  nil;
    [super dealloc];
}
- (void)viewDidUnload {
	[self setChildTableview:nil];
	[super viewDidUnload];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger numberOfRows = [self.linkedProcess count]/ITEMCOUNT;
	
	if (([self.linkedProcess count] % ITEMCOUNT) != 0)
	{
		numberOfRows = numberOfRows + 1;
	}	
	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setAutoresizesSubviews:YES];
    }
	
	CGFloat width = self.view.frame.size.width/3;
	
	NSUInteger itemcount = ITEMCOUNT;
	
	NSUInteger row = indexPath.row;
	
	CGFloat final_height = 0;
    CGFloat temp_height  = 0;
	
	NSUInteger array_count = [self.linkedProcess count];
	
	NSUInteger coloumnCount  = 0;
	
	for (int x =0; x < itemcount; x++)
	{
		coloumnCount = (row * itemcount) + x;
		
		if (coloumnCount >= array_count)
		{
			break;
		}
		
		NSDictionary * dict = [self.linkedProcess objectAtIndex:coloumnCount];
		
		NSArray * allKeys = [dict allKeys];
		
		NSString * processName = [dict objectForKey:[allKeys objectAtIndex:0]];
		
		
		CGSize size1 = [processName sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(150, 9999)];
		temp_height = size1.height;
		
		if(temp_height > final_height)
		{
			final_height = temp_height;
		}
	}
	
	if (final_height <= 50)
		final_height = final_height + 20;

	CGFloat XValue = 20;
	
	coloumnCount = 0;
    
	for (int x =0; x < itemcount; x++)
	{
		coloumnCount = (row * itemcount) + x;
		
		if (coloumnCount >= array_count)
		{
			break;
		}
		
		NSDictionary * dict = [self.linkedProcess objectAtIndex:coloumnCount];
		
		NSArray * allKeys = [dict allKeys];
		
		NSString * processName = [dict objectForKey:[allKeys objectAtIndex:0]];
		
		CGRect frame = CGRectMake(XValue, 4, 180, final_height);
		
		cusButton * buttton = nil;
		buttton = [cusButton buttonWithType:UIButtonTypeCustom];		
		buttton.button_info = dict;
        buttton.frame = frame;

        buttton.titleLabel.frame = buttton.bounds;
		buttton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        buttton.userInteractionEnabled = YES;
		
        buttton.enabled = YES;
        
		buttton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		buttton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
		
		buttton.titleLabel.backgroundColor = [UIColor clearColor];
		[buttton setTitle:processName forState:UIControlStateNormal];
		buttton.titleLabel.textColor = [UIColor whiteColor];
		buttton.titleLabel.numberOfLines = 0;
        
        
	
		UIImage * buttonimage = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button.png"];
		buttonimage = [buttonimage stretchableImageWithLeftCapWidth:12 topCapHeight:8];
		[buttton setBackgroundImage:buttonimage forState:UIControlStateNormal];
        
        UIImage * buttontapimage = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button2.png"];
		buttontapimage = [buttontapimage stretchableImageWithLeftCapWidth:12 topCapHeight:8];
		[buttton setBackgroundImage:buttonimage forState:UIControlStateSelected];
        
		[buttton addTarget:self action:@selector(showSFMProcess:) forControlEvents:UIControlEventTouchUpInside];
        
        
		[cell.contentView addSubview:buttton];
        [cell.contentView sizeToFit];
		
		XValue = (XValue + width)- 10;
	}
	
	UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip-Edit.png"]] autorelease];
    bgView.backgroundColor=[UIColor colorWithRed:215 green:241 blue:252 alpha:1];
    
    cell.backgroundView = bgView;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //Radha - Debrief Linked Process change
	childTableview.separatorColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//Calculate the height of the cell using the process array
	
	NSUInteger itemcount = ITEMCOUNT;
	
	NSUInteger row = indexPath.row;
	
	CGFloat final_height = 0;
    CGFloat temp_height  = 0;
	
	NSUInteger array_count = [self.linkedProcess count];

	NSUInteger coloumnCount  = 0;
	
	for (int x =0; x < itemcount; x++)
	{
		coloumnCount = (row * itemcount) + x;
		
		if (coloumnCount >= array_count)
		{
			break;
		}
		
		NSDictionary * dict = [self.linkedProcess objectAtIndex:coloumnCount];
		
		NSArray * allKeys = [dict allKeys];
		
		NSString * processName = [dict objectForKey:[allKeys objectAtIndex:0]];
		
		
		CGSize size1 = [processName sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(150, 9999)];
		temp_height = size1.height;
		
		if(temp_height > final_height)
		{
			final_height = temp_height;
		}
	}
	
	if (final_height <= 50)
	{
		final_height = final_height + 20;
	}	
	return final_height +20;
}

- (BOOL)tableView:(UITableView *)_tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

//Defect Fix :- 7394
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

-(CGFloat) getHeightForChildLinkedProcess {
    
    NSInteger numberOfRows = [self tableView:self.childTableview numberOfRowsInSection:0 ];
    float heightForView = 0.0;
	float height = 0.0;
	
    for (int i=0; i< numberOfRows; i++)
	{
		height = [self tableView:self.childTableview heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];		
        heightForView += height;
    }
	return heightForView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row slected %@", indexPath);
}

- (IBAction) showSFMProcess:(id)sender
{
    NSLog(@"button clicked");
    if ([self.childViewDelegate respondsToSelector:@selector(showSFMPageForChildLinkedProcessWithProcessId:record_id:detailObjectName:)])
    {
		NSString * processId = @"";
        
        cusButton * buttonDetail = (cusButton *)sender;
        
        NSArray * allkeys = [buttonDetail.button_info allKeys];
        
        if ([allkeys count] > 0)
        {
            processId = [allkeys objectAtIndex:0];
        }
        
          [self.childViewDelegate showSFMPageForChildLinkedProcessWithProcessId:processId record_id:self.record_id detailObjectName:self.detailObjectname];
    }
	
}

@end
