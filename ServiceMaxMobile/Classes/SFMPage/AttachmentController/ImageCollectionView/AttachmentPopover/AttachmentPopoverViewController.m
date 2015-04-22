//
//  AttachmentPopoverViewController.m
//  ServiceMaxMobile
//
//  Created by Kirti on 11/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "AttachmentPopoverViewController.h"

@interface AttachmentPopoverViewController ()

@end

@implementation AttachmentPopoverViewController
@synthesize attachmentTableView;
@synthesize popoverArray;
@synthesize attachmentDelegate;
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
    attachmentTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    attachmentTableView.scrollEnabled=FALSE;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void )dealloc
{
    attachmentTableView.dataSource=nil;
    attachmentTableView.delegate=nil;
    [attachmentTableView release];
    [super dealloc];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"TableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    //    UIView * backgroundView = nil;
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        for (UIView *subview in [cell.contentView subviews])
        {
            [subview removeFromSuperview];
        }
        
    }
    UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
    cell.backgroundView=bgView;
    cell.textLabel.text=[popoverArray objectAtIndex:indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [attachmentDelegate selectedOption:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [popoverArray count];
}

@end
