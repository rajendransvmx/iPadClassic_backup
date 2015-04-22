//
//  AttachmentPopoverViewController.m
//  ServiceMax
//
//  Created by Anoop on 13/11/13.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

#import "AttachmentPopoverViewController.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"

@interface AttachmentPopoverViewController ()

@property(nonatomic, strong) NSArray *optionsArray;

@end

@implementation AttachmentPopoverViewController
@synthesize attachmentTableView;
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
    self.view.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
    attachmentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    attachmentTableView.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
    attachmentTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    attachmentTableView.scrollEnabled = FALSE;
    NSString *addFromCamera = [[TagManager sharedInstance] tagByName:kTagAddFromCamera];
    NSString *takeNewPicture = [[TagManager sharedInstance] tagByName:kTagTakeNewPic];
    NSString *takeNewVideo = [[TagManager sharedInstance] tagByName:kTagTakeNewVideo];
    _optionsArray = [[NSArray alloc] initWithObjects:addFromCamera, takeNewPicture,takeNewVideo, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void )dealloc
{
    attachmentTableView.dataSource = nil;
    attachmentTableView.delegate = nil;
    attachmentTableView = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"TableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SimpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
        cell.contentView.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
    }
    
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:16.0f];
    cell.textLabel.textColor = [UIColor colorWithHexString:kOrangeColor];
    cell.textLabel.text = [_optionsArray objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.attachmentDelegate && [self.attachmentDelegate respondsToSelector:@selector(selectedOption:)])
    {
        [self.attachmentDelegate selectedOption:indexPath.row];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_optionsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

@end
