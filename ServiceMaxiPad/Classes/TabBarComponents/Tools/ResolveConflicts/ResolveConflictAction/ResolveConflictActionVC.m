//
//  ResolveConflictActionVC.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ResolveConflictActionVC.h"
#import "SyncErrorConflictModel.h"
#import "CheckBox.h"
#import "TagManager.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "ResolveConflictsHelper.h"
#import "StringUtil.h"

@interface ResolveConflictActionVC ()<UITableViewDataSource, UITableViewDelegate>
/*
 * titleBarButtonItem outlet is set to Strong as we are allocating new bar button item through code.
 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem; /* TitleView */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;        /* ApplyButton */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;      /* CancelButton */
@property (weak, nonatomic) IBOutlet UIToolbar *titleToolBar;               /* Used To hold the top bar buttons */
@property (weak, nonatomic) IBOutlet UITableView *resolutionTableView;      /* Used to display various resolution options */
@property (weak, nonatomic) IBOutlet UILabel *objectLabel;                  /* object name:eg-Work Order */
@property (weak, nonatomic) IBOutlet UILabel *objectNameLabel;              /* record value:eg:WO-234342 */
@property (weak, nonatomic) IBOutlet UIView *accountView;                   /* Used to hold accound text and account number */
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;                 /* account text:eg-account */
@property (weak, nonatomic) IBOutlet UILabel *accountNameLabel;             /* account value:eg-Servicemax developer */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountViewHeightConstraint; /* Used to hide/unhide accountview */
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;                 /* detail text */
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;           /* conflict error message */

@property (copy, nonatomic) NSArray *resolutionTableDataSource;             /* resolution options */
@property (nonatomic) NSInteger selectedResolutionIndex;                    /* track user selection */
@property (strong, nonatomic) SyncErrorConflictModel *conflictModel;        /* local pointer to store the given conflict */
@end

@implementation ResolveConflictActionVC

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        self.selectedResolutionIndex = 0;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
        {
            /*
             * feature available only after iOS 8.
             */
            self.preferredContentSize = CGSizeMake(420, 420);
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    if(!([[[UIDevice currentDevice] systemVersion] floatValue] >= 8))
    {
        /*
         * Backward compactibility, not required after iOS 8.
         */
        self.view.superview.bounds = CGRectMake(0, 0, 420, 420);
    }
    self.view.superview.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.view.superview.layer.shadowOffset  = CGSizeMake(3, 4);
    self.view.superview.layer.shadowRadius  = 4.0f;
    self.view.superview.layer.shadowOpacity = 0.60f;
    self.view.superview.layer.masksToBounds = YES;
    self.view.superview.layer.cornerRadius  = 6.0;
}

- (void)setupUI {
    
    /**
     * Changes to title tool bar as to change uibarbuttonitem to support titleview.
     * Reset any UI text to defaults so we won't see any when view appears.
     */
    UIButton *titleView = [UIButton buttonWithType:UIButtonTypeCustom];
    
    titleView.frame = CGRectMake(0,
                                 0,
                                 200,
                                 self.titleToolBar.frame.size.height);
    
    [titleView setTitle:[[TagManager sharedInstance]tagByName:kTag_Sync_Conflict_Resolution]
               forState:UIControlStateNormal];
    
    [titleView setTitleColor:[UIColor blackColor]
                    forState:UIControlStateNormal];
    
    titleView.userInteractionEnabled = NO;
    
    self.titleBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:titleView];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:self
                                                                           action:nil];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:self
                                                                            action:nil];
    self.titleToolBar.items = @[self.cancelBarButton,
                                spacer,self.titleBarButtonItem,
                                spacer1,self.saveBarButton];
    
    self.resolutionTableView.layer.borderColor = [UIColor getUIColorFromHexValue:kActionBgColor].CGColor;
    self.resolutionTableView.layer.borderWidth = 2.0f;
    self.resolutionTableView.layer.cornerRadius = 4.0f;
    
    self.cancelBarButton.title     = [[TagManager sharedInstance]tagByName:kTagCancelButton];
    self.saveBarButton.title       = [[TagManager sharedInstance]tagByName:kTag_Apply];
    self.resolutionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.objectLabel.text          = @"";
    self.objectNameLabel.text      = @"";
    self.accountLabel.text         = [[TagManager sharedInstance]tagByName:kTag_acInfo];
    self.accountNameLabel.text     = @"";
    self.detailsTextView.text      = @"";
    self.detailsLabel.text         = [[TagManager sharedInstance]tagByName:kTag_details];
    self.objectNameLabel.textColor = [UIColor getUIColorFromHexValue:kOrangeColor];
    self.objectLabel.textColor     = [UIColor grayColor];
    self.objectLabel.font          = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize14];
    self.accountLabel.textColor    = [UIColor grayColor];
    self.accountLabel.font         = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize14];
    self.detailsLabel.textColor    = [UIColor grayColor];
    self.detailsLabel.font         = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize14];
    
    if (!self.conflictModel.isWorkOrder) {
        /*
         * Hiding account information for non work order objects.
         */
        self.accountViewHeightConstraint.constant = 0;
        
    } else {
        
        self.accountNameLabel.text = self.conflictModel.svmxAcValue;
        if ([StringUtil isStringEmpty:self.conflictModel.svmxAcValue]) {
            self.accountNameLabel.text = @"- - - -";
        }
    }
    
    NSString *text = [NSString stringWithFormat:@" %@",[[TagManager sharedInstance]tagByName:kTag_number]];
    self.objectLabel.text     = [self.conflictModel.objectLabel stringByAppendingString:text];
    
    self.objectNameLabel.text = self.conflictModel.recordValue;
    if ([StringUtil isStringEmpty:self.conflictModel.recordValue]) {
        self.objectNameLabel.text = @"- - - -";
    }
    self.detailsTextView.text = self.conflictModel.errorMessage;
}

#pragma mark - tableview delegate and datasource methods.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resolutionTableDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ResolutionTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        /*
         * Let's allocate new cell.
         */
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else
    {   /* Refresh cell to as new one :)
         * Since we don't have a custom cell to override prepareforreuse.
         */
        for (UIView *oldView in [cell.contentView subviews]) {
            [oldView removeFromSuperview];
        }
    }
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 300, 40)];
    titleLabel.font     = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize16];
    titleLabel.text     = [self.resolutionTableDataSource objectAtIndex:indexPath.row];
    CheckBox *checkBox  = [[CheckBox alloc]initWithFrame:CGRectMake(5,5, 30, 30)];
    checkBox.userInteractionEnabled = NO;
    if(self.selectedResolutionIndex == indexPath.row)
    {
        [checkBox defaultValueForCheckbox:YES];
    }
    [cell.contentView addSubview:checkBox];
    [cell.contentView addSubview:titleLabel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedResolutionIndex = indexPath.row;
    [self.resolutionTableView reloadData];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *headerView = [[UIView alloc] init];
    
    CGRect frame       = CGRectZero;
    frame.size.height  = 30;
    frame.size.width   = self.view.frame.size.width;
    
    UILabel *headerLbl = [[UILabel alloc] initWithFrame:frame];
    headerLbl.text     = [[TagManager sharedInstance]tagByName:kTag_Resolution];
    headerLbl.textAlignment = NSTextAlignmentCenter;
    headerLbl.font     = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
    headerLbl.textColor = [UIColor blackColor];

    [headerView addSubview:headerLbl];
    
    return headerView;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc] init];
    
    CGRect frame       = CGRectZero;
    frame.origin.x     = 5;
    frame.size.height  = 30;
    frame.size.width   = self.view.frame.size.width - 10;
    
    UILabel *footerLbl = [[UILabel alloc] initWithFrame:frame];
    footerLbl.font     = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize14];
    footerLbl.text     = [[TagManager sharedInstance]tagByName:kTag_ResolutionAtNextSync];
    footerLbl.textColor = [UIColor grayColor];
    
    [footerView addSubview:footerLbl];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}
#pragma mark - End
- (void)configureAndShowActionsForConflict:(SyncErrorConflictModel *)conflict {
    
    if (!conflict) {
        return;
    }
    self.conflictModel = conflict;
    self.resolutionTableDataSource = [ResolveConflictsHelper fetchLocalizedUserResolutionOptionsForConflict:conflict];
    
    if ([self.resolutionTableDataSource count] && ![StringUtil isStringEmpty:conflict.overrideFlag]) {
        
        /*
         * Lets set the selected option as per received conflict.
         */
        
        for (NSString *resolution in self.resolutionTableDataSource) {
            
            NSString *databaseString = [ResolveConflictsHelper getDatabaseStringForLocalizedUserResolution:resolution];
            if ([databaseString isEqualToString:conflict.overrideFlag]) {
                self.selectedResolutionIndex = [self.resolutionTableDataSource indexOfObject:resolution];
            }
        }
    }
    [(UIViewController *)self.delegate presentViewController:self animated:YES completion:nil];
}

- (IBAction)cancelClicked:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        /*
         * Check if delegate has implemented delegate methods, if yes then call.
         */
        if ([self.delegate respondsToSelector:@selector(resolveConflictActionVC:userPressedCancelForConflict:)]) {
            
            [self.delegate resolveConflictActionVC:self userPressedCancelForConflict:self.conflictModel];
        }
    }];
}

- (IBAction)saveClicked:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        /*
         * Check if delegate has implemented delegate methods, if yes then call.
         */
        if ([self.delegate respondsToSelector:@selector(resolveConflictActionVC:userPressedApplyForConflict:)]) {
            
            NSString *localizedResoluton = [self.resolutionTableDataSource objectAtIndex:self.selectedResolutionIndex];
            self.conflictModel.overrideFlag = [ResolveConflictsHelper getDatabaseStringForLocalizedUserResolution:localizedResoluton];
            [self.delegate resolveConflictActionVC:self userPressedApplyForConflict:self.conflictModel];
        }
    }];
}

- (IBAction)navigationButtonClicked:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        /*
         * Check if delegate has implemented delegate methods, if yes then call.
         */
        if ([self.delegate respondsToSelector:@selector(resolveConflictActionVC:userPressedNavigateForConflict:)]) {
            
            [self.delegate resolveConflictActionVC:self userPressedNavigateForConflict:self.conflictModel];
        }

        
    }];
}



@end
