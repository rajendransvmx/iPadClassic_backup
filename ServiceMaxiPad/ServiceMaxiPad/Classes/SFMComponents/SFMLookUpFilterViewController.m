//
//  SFMLookUpFilterViewController.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 02/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMLookUpFilterViewController.h"

@interface SFMLookUpFilterViewController ()
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;

@end

@implementation SFMLookUpFilterViewController

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
    [self setUpUI];
}

- (void)setUpUI
{
    self.filterTableView.backgroundColor = [UIColor clearColor];
    self.filterTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.layer.cornerRadius = 5.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
@end
