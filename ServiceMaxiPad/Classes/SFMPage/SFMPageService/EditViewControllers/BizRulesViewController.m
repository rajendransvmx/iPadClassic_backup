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
#import "BizRuleBaseTableViewCell.h"
#import "BusinessRuleResult.h"
#import "NonTagConstant.h"

@interface BizRulesViewController ()

@property (weak, nonatomic) IBOutlet UIButton *disclosureButton;
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
    self.view.backgroundColor = [UIColor getUIColorFromHexValue:kPageViewMasterBGColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.disclosureButton.backgroundColor = [UIColor getUIColorFromHexValue:kPageViewMasterBGColor];;
    [self.tableView registerNib:[UINib nibWithNibName:@"BizRuleTableViewCell" bundle:nil] forCellReuseIdentifier:@"warningcell"];
    [self.disclosureButton setImage:[UIImage imageNamed:@"up_arrow_gray.png"] forState:UIControlStateNormal];
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    
    // Verifaya
    [self.disclosureButton setAccessibilityLabel:kVBizRuleArrowUpBtn];

    
}
-(void)loadData
{
    self.bizRulesArray = self.dataArray;
    
    [self performSelectorOnMainThread:@selector(loadTableView) withObject:self waitUntilDone:NO];
}
-(void)loadTableView
{
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.view.layer.cornerRadius = 7.0f;
//    [self setCornerRadius];
    self.view.layer.shadowRadius = 3.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.view.layer.shadowOpacity = 1.0f;
    self.view.layer.masksToBounds = NO;
    
    self.disclosureButton.layer.cornerRadius = 7.0f;
}

- (void) setCornerRadius
{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(7.0, 7.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path = maskPath.CGPath;
    self.view.layer.mask = maskLayer;

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
    
    BusinessRuleResult * resultModel = [self.bizRulesArray objectAtIndex:indexPath.row];
    
    NSString * cellType = resultModel.messgaeType;
    
    NSString * identifier = [self getCellIdentifier:cellType];

    BizRuleBaseTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell == nil){
        cell = [[BizRuleBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
   
    cell.titleDescription =  resultModel.message;
    cell.subTitleDescription = resultModel.fieldLabel;
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.checkBoxselected =  resultModel.confirmation;
    
    return cell;
    
}
-(NSString *)getCellIdentifier:(NSString *)str
{
    if([str caseInsensitiveCompare:@"Error"] == NSOrderedSame){
        return @"errorCell";
    }
    else if ([str caseInsensitiveCompare:@"Warning"] == NSOrderedSame){
        return  @"warningcell";;
    }
    return @"errorCell";
}

-(cellType)getCellType:(NSString *)str 
{
    if([str isEqualToString:@"Error"]){
        return error;
    }
    else if ([str isEqualToString:@"Warning"]){
        return warning;
    }
    return error;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return BizTableViewHeight;
}

-(IBAction)footerViewTapped:(id)sender
{
    if([self.deleagte conformsToProtocol:@protocol(BizRuleUIDelegate)]){
        [self hideDisclosureButton];
        [self.deleagte dismissBizRuleUI];
    }
}
-(void)cellTappedAtIndexPath:(NSIndexPath *)indexPath selectedValue:(BOOL)selectedvalue
{
     BusinessRuleResult * resultModel = [self.bizRulesArray objectAtIndex:indexPath.row];
    resultModel.confirmation = selectedvalue;
}

- (void)showDisclosureButton {
    self.disclosureButton.hidden = NO;
}

- (void)hideDisclosureButton {
    self.disclosureButton.hidden = YES;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setCornerRadius];
}
@end
