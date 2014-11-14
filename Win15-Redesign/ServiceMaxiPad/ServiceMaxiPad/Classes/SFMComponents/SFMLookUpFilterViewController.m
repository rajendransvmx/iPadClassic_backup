//
//  SFMLookUpFilterViewController.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 02/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMLookUpFilterViewController.h"
#import "SFMLookUpFilter.h"
#import "StyleManager.h"

@interface SFMLookUpFilterViewController ()
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;

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
    [self.filterTableView registerNib:[UINib nibWithNibName:@"SFMLookUpFilterCell" bundle:nil] forCellReuseIdentifier:@"LookUpFilterCellIdentifier"];
}

- (void)setUpUI
{
    self.filterTableView.backgroundColor = [UIColor clearColor];
    self.filterTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.layer.cornerRadius = 5.0;
    
    [self.applyButton setTitleColor:[UIColor colorWithHexString:@"#E15001"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)applyChanges:(id)sender {
    
    if ([self.delegate conformsToProtocol:@protocol(LookUpFilterDelegate)]) {
        [self.delegate applyFilterChanges:self.dataSource];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFMLookUpFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LookUpFilterCellIdentifier"
                                                                forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[SFMLookUpFilterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LookUpFilterCellIdentifier"];
    }
    SFMLookUpFilter *filterModel = [self.dataSource objectAtIndex:indexPath.row];
    
    [self updateCheckBoxTypeForCell:cell model:filterModel];
    [cell setFilterNameForLabel:filterModel.name];
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)updateCheckBoxTypeForCell:(SFMLookUpFilterCell *)cell model:(SFMLookUpFilter *)filter
{
    if (filter.objectPermission) {
        
        if (filter.allowOverride) {
            
            switch (filter.defaultOn) {
                case 0:
                    [cell setCheckboxImageForType:CheckBoxStateTypeUnchecked];
                    break;
                case 1:
                    [cell setCheckboxImageForType:CheckBoxStateTypeChecked];
                default:
                    break;
            }
            cell.userInteractionEnabled = YES;
        }
        else {
            switch (filter.defaultOn) {
                case 0:
                    [cell setCheckboxImageForType:CheckBoxStateTypeUncheckedDisabled];
                    break;
                case 1:
                    [cell setCheckboxImageForType:CheckBoxStateTypeCheckedDisabled];
                default:
                    break;
            }
            cell.userInteractionEnabled = NO;
        }
        [cell setValueForCheckBox:filter.defaultOn];
    }
    else {
        cell.userInteractionEnabled = NO;
        [cell setCheckboxImageForType:CheckBoxStateTypeUncheckedDisabled];
        [cell setValueForCheckBox:NO];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - Dlegate Method

- (void)filterValueChanged:(BOOL)value forInexpath:(NSIndexPath *)indexPath
{
    if ([self.dataSource count] >= indexPath.row) {
        SFMLookUpFilter *filter = [self.dataSource objectAtIndex:indexPath.row];
        filter.defaultOn = value;
    }
}

#pragma mark - END


- (CGSize )getPoPOverContentSize
{
    CGFloat tableViewHeight = 150;
    if ([self.dataSource count] > 1) {
        tableViewHeight = 30;
        int numberOfRows = [self.dataSource count] * 2;
        for (int rowIndex = 1; rowIndex<numberOfRows; rowIndex++) {
            tableViewHeight += 50;
        }
        if (tableViewHeight > 400) {
            tableViewHeight = 380;
        }

    }
    CGSize size = CGSizeMake(400, tableViewHeight);
    return size;
}
@end
