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
#import <Photos/Photos.h>

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
    self.view.backgroundColor = [UIColor getUIColorFromHexValue:kActionBgColor];
    attachmentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    attachmentTableView.backgroundColor = [UIColor getUIColorFromHexValue:kActionBgColor];
    attachmentTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    attachmentTableView.scrollEnabled = FALSE;
    NSString *addFromCamera = [[TagManager sharedInstance] tagByName:kTagAddFromCamera];
    NSString *takeNewPicture = [[TagManager sharedInstance] tagByName:kTagTakeNewPic];
    NSString *takeNewVideo = [[TagManager sharedInstance] tagByName:kTagTakeNewVideo];
    _optionsArray = [[NSArray alloc] initWithObjects:addFromCamera, takeNewPicture,takeNewVideo, nil];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [attachmentTableView reloadData]; // IPH-3186
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
        cell.backgroundColor = [UIColor getUIColorFromHexValue:kActionBgColor];
        cell.contentView.backgroundColor = [UIColor getUIColorFromHexValue:kActionBgColor];
    }
    
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:16.0f];
    cell.textLabel.text = [_optionsArray objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus]; //IPH-3186
    
    switch (indexPath.row) {
        case 0:
        {
            if (photoStatus == PHAuthorizationStatusRestricted || photoStatus == PHAuthorizationStatusDenied) { //IPH-3186
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
            else {
                cell.textLabel.textColor = [UIColor getUIColorFromHexValue:kOrangeColor];
            }
        }
            break;
        case 1:
        case 2:
        {
            AVAuthorizationStatus cameraStatus = (AVAuthorizationStatus)[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (cameraStatus == AVAuthorizationStatusRestricted || cameraStatus == AVAuthorizationStatusDenied || photoStatus == PHAuthorizationStatusRestricted || photoStatus == PHAuthorizationStatusDenied) { //IPH-3186
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
            else {
                cell.textLabel.textColor = [UIColor getUIColorFromHexValue:kOrangeColor];
            }
        }
            break;
        default:
            break;
    }
    
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
