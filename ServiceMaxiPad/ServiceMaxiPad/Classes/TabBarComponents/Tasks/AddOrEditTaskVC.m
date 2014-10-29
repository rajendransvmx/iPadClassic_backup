//
//  AddOrEditTaskVC.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 02/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "AddOrEditTaskVC.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "CheckBox.h"
#import "DateUtil.h"
#import "TagManager.h"


@interface AddOrEditTaskVC ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;
@property (strong, nonatomic) SFMTaskModel *taskModel;
@property (copy, nonatomic) NSString *titleString;
@property (strong, nonatomic) IBOutlet UIToolbar *titleToolBar;
@property (strong, nonatomic) IBOutlet UITableView *priorityTableView;
@property (copy, nonatomic) NSArray *priorityTableDataSource;
@property (nonatomic) NSInteger selectedPriorityIndex;

@end

@implementation AddOrEditTaskVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        self.priorityTableDataSource = @[@"High",@"Normal",@"Low"];
        self.selectedPriorityIndex = 1;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
        {
            self.preferredContentSize = CGSizeMake(420, 470);
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
        self.view.superview.bounds = CGRectMake(0, 0, 420, 470);
    }
    self.view.superview.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.superview.layer.shadowOffset = CGSizeMake(3, 4);
    self.view.superview.layer.shadowRadius = 4.0f;
    self.view.superview.layer.shadowOpacity = 0.60f;
    self.view.superview.layer.masksToBounds = YES;
    self.view.superview.layer.cornerRadius  = 6.0;
}

- (void)setupUI {
    
    /**
     * Changes to title tool bar as to change uibarbuttonitem to support titleview.
     */
    UIButton *titleView = [UIButton buttonWithType:UIButtonTypeCustom];
    titleView.frame = CGRectMake(0, 0, 100, self.titleToolBar.frame.size.height);
    [titleView setTitle:self.titleString forState:UIControlStateNormal];
    [titleView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    titleView.userInteractionEnabled = NO;
    self.titleBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:titleView];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.titleToolBar.items = @[self.cancelBarButton,spacer,self.titleBarButtonItem,spacer1,self.saveBarButton];
    self.descriptionTextView.layer.borderColor = [UIColor colorWithHexString:kActionBgColor].CGColor;
    self.descriptionTextView.layer.borderWidth = 2.0f;
    self.descriptionTextView.layer.cornerRadius = 4.0f;
    self.cancelBarButton.title = [[TagManager sharedInstance]tagByName:kTagCancelButton];
    self.saveBarButton.title = [[TagManager sharedInstance]tagByName:kTagSfmActionButtonSave];
    self.priorityTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.descriptionTextView.text = self.taskModel.taskDescription;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - exposed methods

- (void)showAddNewTaskScreen {
    
    self.titleString = @"New Task";
    self.isNewlyCreadedTask = YES;
    self.taskModel = [[SFMTaskModel alloc]initWithLocalId:nil
                                              description:@"This is where text goes..."
                                                 priority:[self.priorityTableDataSource objectAtIndex:self.selectedPriorityIndex]
                                                 recordId:nil
                                              createdDate:[NSDate date]];
    [(UIViewController *)self.delegate presentViewController:self animated:YES completion:nil];
}

- (void)showEditTaskScreenForTask:(SFMTaskModel *)task {
    
    self.titleString = @"Edit task";
    self.taskModel = [[SFMTaskModel alloc]initWithLocalId:task.localID
                                              description:task.taskDescription
                                                 priority:task.priority
                                                 recordId:task.sfId
                                              createdDate:task.date];

    self.isNewlyCreadedTask = NO;
    self.selectedPriorityIndex = [self.priorityTableDataSource indexOfObject:self.taskModel.priority];
    [(UIViewController *)self.delegate presentViewController:self animated:YES completion:nil];
}

#pragma mark - nav Bar button actions
- (IBAction)cancelButtonClicked:(UIBarButtonItem *)sender {
    
    self.taskModel.priority = [self.priorityTableDataSource objectAtIndex:self.selectedPriorityIndex];
    self.taskModel.taskDescription = self.descriptionTextView.text;
    if ([self.delegate respondsToSelector:@selector(addOrEditTaskVC:userPressedCancelForTask:)]) {
        
        [self.delegate addOrEditTaskVC:self userPressedCancelForTask:self.taskModel];
    }
}

- (IBAction)saveButtonClicked:(UIBarButtonItem *)sender {
    
    self.taskModel.priority = [self.priorityTableDataSource objectAtIndex:self.selectedPriorityIndex];
    self.taskModel.taskDescription = self.descriptionTextView.text;
    if ([self.delegate respondsToSelector:@selector(addOrEditTaskVC:userPressedSaveForTask:)]) {
        
        [self.delegate addOrEditTaskVC:self userPressedSaveForTask:self.taskModel];
    }
}

- (void)dealloc {
    _priorityTableView = nil;
    _descriptionTextView = nil;
    _titleToolBar = nil;
    _saveBarButton = nil;
    _cancelBarButton = nil;
    _titleBarButtonItem = nil;
    _taskModel = nil;
}

#pragma mark - tableview delegate and datasource methods.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.priorityTableDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PriorityTaskCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else
    {   // Refresh cell to as new one :)
        for (UIView *oldView in [cell.contentView subviews]) {
            [oldView removeFromSuperview];
        }
    }
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(34, 3, 250, 44)];
    titleLabel.text = [self.priorityTableDataSource objectAtIndex:indexPath.row];
    CheckBox *checkBox = [[CheckBox alloc]initWithFrame:CGRectMake(-10, 3, 44, 44)];
    checkBox.userInteractionEnabled = NO;
    if(self.selectedPriorityIndex == indexPath.row)
    {
        [checkBox defaultValueForCheckbox:YES];
    }
    [cell.contentView addSubview:checkBox];
    [cell.contentView addSubview:titleLabel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPriorityIndex = indexPath.row;
    [self.priorityTableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *priorityLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    priorityLabel.text = @"priority";
    priorityLabel.backgroundColor = [UIColor whiteColor];
    return priorityLabel;
}

@end
