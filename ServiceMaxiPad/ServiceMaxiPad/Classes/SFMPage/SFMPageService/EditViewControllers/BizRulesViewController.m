//
//  BizRulesViewController.m
//  ServiceMaxiPad
//
//  Created by Narendra on 11/8/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "BizRulesViewController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"

@interface BizRulesViewController ()

@property(nonatomic, weak) IBOutlet  UITableView * tableView;
@end

@implementation BizRulesViewController

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
    self.view.backgroundColor = [UIColor colorWithHexString:kPageViewMasterBGColor];
    self.tableView.backgroundColor = [UIColor clearColor];

    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.view.clipsToBounds = YES;
    //clip to bounds should be above set shadow implemetaion.
    
    self.view.layer.cornerRadius = 7.0f;
    self.view.layer.shadowRadius = 3.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.view.layer.shadowOpacity = 1.0f;
     self.view.layer.masksToBounds = NO;
    
    /*UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.view.layer.shadowOpacity = 0.5f;
    self.view.layer.shadowPath = shadowPath.CGPath;*/
    
    //self.tableView.clipsToBounds = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bizRulesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"bizCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bizCell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return BizTableViewHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}
-(void)setbizRulesArray:(NSMutableArray *)array
{
    self.bizRulesArray = array;
    [ self.bizRulesArray addObject:@"sjdfs"];
    [ self.bizRulesArray addObject:@"sjdfs"];

    [ self.bizRulesArray addObject:@"sjdfs"];

    [ self.bizRulesArray addObject:@"sjdfs"];

    [ self.bizRulesArray addObject:@"sjdfs"];

}

@end
