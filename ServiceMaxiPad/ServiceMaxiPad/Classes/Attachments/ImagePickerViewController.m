//
//  ImagePickerViewController.m
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ImagePickerViewController.h"

@interface ImagePickerViewController ()

@end

@implementation ImagePickerViewController
@synthesize attachmentTableView;
@synthesize popoverArray;
@synthesize attachmentDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    attachmentTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    attachmentTableView.scrollEnabled=FALSE;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"TableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    //    UIView * backgroundView = nil;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        for (UIView *subview in [cell.contentView subviews])
        {
            [subview removeFromSuperview];
        }
        
    }
    UIImageView * bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
