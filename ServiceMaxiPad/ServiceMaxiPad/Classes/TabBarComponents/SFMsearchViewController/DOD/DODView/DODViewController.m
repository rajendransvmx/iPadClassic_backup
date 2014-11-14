//
//  DODViewController.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 13/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DODViewController.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "SFMSearchFieldModel.h"
#import "SFMRecordFieldData.h"
#import "Utility.h"
#import "DateUtil.h"

@implementation CustomDODButton

-(void)setSelected:(BOOL)selected {
    
    if(selected) {
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor colorWithHexString:kOrangeColor];
    }
    [super setSelected:selected];
}

@end


@interface DODViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CustomDODButton *cancelButton;

@property (nonatomic, weak) id<DownloadOnDemandDelegate> delegate;
@property (nonatomic, strong) SFMSearchObjectModel *searchObject;
@property (nonatomic, strong) TransactionObjectModel *transactionObject;

@end

@implementation DODViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preferredContentSize = CGSizeMake(320, 320);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.preferredContentSize = CGSizeMake(320, 320);
}


- (void)setupUI {
    
    self.titleLabel.text          = @"bla bla bla";
    self.titleLabel.textColor     = [UIColor blackColor];
    self.titleLabel.font          = [UIFont systemFontOfSize:16];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.progressView.progress    = 0.0f;
    
    [self.cancelButton setTitle:@"Download" forState:UIControlStateNormal];
    [self.cancelButton setTitle:@"Cancel Download" forState:UIControlStateSelected];
    
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueLight size:15.0]];
    [self.cancelButton setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateSelected];
    self.cancelButton.selected = NO;
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.layer.borderWidth = 1;
    self.cancelButton.layer.borderColor = [UIColor colorWithHexString:kOrangeColor].CGColor;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonClicked:(UIButton *)sender {
    
    UIButton *button = (UIButton *)sender;
    button.selected = ![button isSelected]; // Important line
    if (button.selected) {
        NSLog(@"Selected");
        NSLog(@"%i",button.tag);
    } else {
        NSLog(@"Un Selected");
        NSLog(@"%i",button.tag);
    }
}

- (void)setupDODWithDelegate:(id<DownloadOnDemandDelegate>)delegate
                searchObject:(SFMSearchObjectModel *)searchModel
        andTransactionObject:(TransactionObjectModel *)transactionModel {
    
    self.searchObject = searchModel;
    self.transactionObject = transactionModel;
    self.delegate = delegate;
    
}

- (NSString *)getCellTitleStringForIndexPath:(NSIndexPath *)indexPath {
    
    SFMSearchFieldModel *fieldModel = [self.searchObject.displayFields objectAtIndex:indexPath.row];
    return [fieldModel getDisplayField];
}


- (NSString *)getCellDetailTitleStringForIndexPath:(NSIndexPath *)indexPath {
    
    SFMSearchFieldModel *fieldModel = [self.searchObject.displayFields objectAtIndex:indexPath.row];
    
    SFMRecordFieldData *fldValue1 = (SFMRecordFieldData *)[self.transactionObject valueForField:[fieldModel getDisplayField]];
    
    NSString *titleString = [self getDisplayStringForValue:fldValue1.displayValue withType:fieldModel.displayType];
    
    return titleString;
    

}

#pragma mark - Tableview delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [self.searchObject.displayFields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"DODCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        //cell font and color set up todo:
    }
    cell.textLabel.text = [self getCellTitleStringForIndexPath:indexPath];
    cell.detailTextLabel.text = [self getCellDetailTitleStringForIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.0f;
}



- (NSString *) getDisplayStringForValue:(NSString *)value withType:(NSString *)displayType {
    if ([Utility isStringEmpty:value] && ![value isKindOfClass:[NSNumber class]]) {
        return @"";
    }
    
    if([displayType isEqualToString:kSfDTDateTime]) {
        
        value = [DateUtil getUserReadableDateForDateBaseDate:value];
    }
    else if ([displayType isEqualToString:kSfDTDate]) {
        
        value = [DateUtil getUserReadableDateForDBDateTime:value];
    }
    
    else if ([displayType isEqualToString:kSfDTBoolean]) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *numValue = (NSNumber *)value;
            value = [numValue stringValue];
        }
        BOOL istrue = [Utility isItTrue:value];
        value = istrue ? kYes : kNo;
    }
    else
    {
        if ([value isKindOfClass:[NSNumber class]]) {
            
            NSNumber *numValue = (NSNumber *)value;
            value = [numValue stringValue];
        }
    }
    return value;
}



@end
