//
//  TextSizeDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 22/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "TextSizeDetailViewController.h"

@interface TextSizeDetailViewController ()

@end

@implementation TextSizeDetailViewController

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
    //self.smSplitViewController.navigationItem.titleView = [UILabel navBarTitleLabel:@"Text Size"];
    [self.smPopover dismissPopoverAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
