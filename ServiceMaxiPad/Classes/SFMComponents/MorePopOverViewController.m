//
//  MorePopOverViewController.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 17/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   MorePopOverViewController.m
 *  @class  MorePopOverViewController
 *
 *  @brief
 *
 *   This is a controller which is used to display the popover on tapping more button.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "MorePopOverViewController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"


@interface MorePopOverViewController ()

@end

@implementation MorePopOverViewController

#pragma mark - life cycle methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createSubViews];
    
    //set content size for popover
    self.preferredContentSize = CGSizeMake(300.0,150.0);
    //self.contentSizeForViewInPopover = CGSizeMake(300.0,150.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method

/**
 * @name - (void)createSubViews
 * @author Shubha
 *
 * @brief it will create all the subviews.
 * @param
 * @param
 *
 * @return
 *
 */

- (void)createSubViews
{
    self.fieldNameLabel = [[EditMenuLabel alloc]initWithFrame:CGRectMake(5,5,290, 40)];
    self.fieldNameLabel.textAlignment = NSTextAlignmentCenter;
    self.fieldNameLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
    self.fieldNameLabel.textColor = [UIColor blackColor];
    self.fieldNameLabel.backgroundColor = [UIColor clearColor];
    [self.fieldNameLabel isLongPressGestureRecognizerEnabled:YES];
    [self.view addSubview:self.fieldNameLabel];
    
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, _fieldNameLabel.frame.size.height + 5, 290, 1)];
    lineView.backgroundColor = [UIColor getUIColorFromHexValue:kSeperatorLineColor];
    [self.view addSubview:lineView];
    
    self.fieldValueTextView = [[UITextView alloc]initWithFrame:CGRectMake(5,lineView.frame.origin.y + 2,290,95)];
    self.fieldValueTextView.editable = FALSE;
    self.fieldValueTextView.selectable = YES;
    self.fieldValueTextView.textAlignment = NSTextAlignmentLeft;
    self.fieldValueTextView.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize16];
    self.fieldValueTextView.backgroundColor = [UIColor clearColor];
    self.fieldValueTextView.textColor = [UIColor blackColor];
    [self.view addSubview:_fieldValueTextView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
