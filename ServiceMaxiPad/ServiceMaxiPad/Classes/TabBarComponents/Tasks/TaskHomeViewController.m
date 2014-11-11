//
//  TaskHomeViewController.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 02/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TaskHomeViewController.h"
#import "StyleManager.h"
#import "MSCMoreOptionTableViewCell.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "SFMTaskModel.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "AddOrEditTaskVC.h"
#import "ViewControllerFactory.h"
#import "TaskHelper.h"
#import "DateUtil.h"
#import "SyncManager.h"
#import "PlistManager.h"
#import "SyncProgressDetailModel.h"


static NSString *reusableIdentifier = @"TaskCell";

@interface TaskHomeViewController ()<MSCMoreOptionTableViewCellDelegate,AddOrEditTaskVCDelegate>
@property (nonatomic, copy) NSDictionary *dataSource;
@property (nonatomic, strong) AddOrEditTaskVC *addOrEditTaskVC;
@property (nonatomic, strong) UILabel *noRecordsInfoLabel;
@end

@implementation TaskHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]tagByName:kTagHomeTask]];
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0+
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *addNewTaskNavButton = [[UIBarButtonItem alloc]initWithTitle:@"+ Add" style:UIBarButtonItemStylePlain target:self action:@selector(addNewTask)];
    self.navigationItem.rightBarButtonItem = addNewTaskNavButton;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setSeparatorColor:[UIColor colorWithHexString:kActionBgColor]];
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDataSyncStatusNotification:)
                                                 name:kDataSyncStatusNotification
                                               object:[SyncManager sharedInstance]];
}
#pragma mark - Data Sync Status/Last Sync Time Update
- (void)receivedDataSyncStatusNotification:(NSNotification *)notification
{
//    id statusObject = [notification.userInfo objectForKey:@"syncstatus"];
//    if ([statusObject isKindOfClass:[SyncProgressDetailModel class]]) {
//        SyncProgressDetailModel *progressObject = [notification.userInfo objectForKey:@"syncstatus"];
//        if ((progressObject.syncStatus == SyncStatusSuccess)||
//            (progressObject.syncStatus == SyncStatusFailed) ||
//            (progressObject.syncStatus == SyncStatusConflict))
//        {
            if (!self.addOrEditTaskVC) {
                [self refreshTasksFromDatabase];
            }
//        }
//    }
//    
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"SFMTaskTableViewCell";
    MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell)
    {
        cell = [[MSCMoreOptionTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.delegate = self;
    }
    else
    {
        //reset cell while reuse.
        cell.accessoryView = nil;
        cell.textLabel.text = @"";
    }
	[cell setConfigurationBlock:^(UIButton *deleteButton, UIButton *moreOptionButton, CGFloat *deleteButtonWitdh, CGFloat *moreOptionButtonWidth) {
        CGFloat width = 80.0f;
        *deleteButtonWitdh = width;
        [moreOptionButton setTitle:@"Edit" forState:UIControlStateNormal];
        [moreOptionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [moreOptionButton setBackgroundColor:[UIColor colorWithHexString:kActionBgColor]];
        [deleteButton setBackgroundColor:[UIColor redColor]];
        deleteButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        deleteButton.titleLabel.numberOfLines = 1;
        moreOptionButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        moreOptionButton.titleLabel.numberOfLines = 1;
        *moreOptionButtonWidth = *deleteButtonWitdh;
	}];
    SFMTaskModel *model = [self modelFromDataSourceForIndexPath:indexPath];
    cell.textLabel.text = model.taskDescription;
    cell.textLabel.numberOfLines = 3;
    cell.detailTextLabel.text = [DateUtil stringFromDate:model.date inFormat:kDateFormatType8];
    if ([model.priority isEqualToString:[[TagManager sharedInstance] tagByName:kTagAddTaskPriorityHigh]])
    {
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HighPriorityImage"]];
    }
    else if ([model.priority isEqualToString:[[TagManager sharedInstance] tagByName:kTagAddTaskPriorityLow]])
    {
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LowPriorityImage"]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Called when 'delete' button is pushed.
        [self deleteTaskForIndexPath:indexPath];
        // Hide 'more'- and 'delete'-confirmation view
        [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
            if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
                [cell hideDeleteConfirmation];
            }
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[self.dataSource objectForKey:[self sectionTitleForSection:section]] count];
    if (!count) {
        /*
         * There are no records so lets add the label.
         */
        
        if (!self.noRecordsInfoLabel) {
            
            self.noRecordsInfoLabel = [[UILabel alloc]init];
            self.noRecordsInfoLabel.text = @"No tasks found. Try adding new task.";
            [self.noRecordsInfoLabel sizeToFit];
            self.noRecordsInfoLabel.center = self.view.center;
            self.noRecordsInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
            [self.view addSubview:self.noRecordsInfoLabel];
        }
        
    } else {
        /*
         * There are records so lets remove the label.
         */
        [self.noRecordsInfoLabel removeFromSuperview];
        self.noRecordsInfoLabel = nil;
    }
    return count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MSCMoreOptionTableViewCellDelegate

- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath {
    // Called when 'more' button is pushed.
    [self editTaskForIndexPath:indexPath];
    // Hide 'more'- and 'delete'-confirmation view
    [tableView.visibleCells enumerateObjectsUsingBlock:^(MSCMoreOptionTableViewCell *cell, NSUInteger idx, BOOL *stop) {
        if ([[tableView indexPathForCell:cell] isEqual:indexPath]) {
            [cell hideDeleteConfirmation];
        }
    }];
}

#pragma mark - Add/Edit/Delete Task

- (void)addNewTask{
    
    self.addOrEditTaskVC = [ViewControllerFactory createViewControllerByContext:ViewControllerAddOrEditTask];
    self.addOrEditTaskVC.delegate = self;
    [self.addOrEditTaskVC showAddNewTaskScreen];
    
}

- (void)editTaskForIndexPath:(NSIndexPath *)indexPath {
    
    self.addOrEditTaskVC = [ViewControllerFactory createViewControllerByContext:ViewControllerAddOrEditTask];
    self.addOrEditTaskVC.delegate = self;
    [self.addOrEditTaskVC showEditTaskScreenForTask:[self modelFromDataSourceForIndexPath:indexPath]];
}

- (void)deleteTaskForIndexPath:(NSIndexPath *)indexPath {
    
    SFMTaskModel *model = [self modelFromDataSourceForIndexPath:indexPath];
    
    [TaskHelper deleteTask:model];
    
    [self refreshTasksFromDatabase];
}

- (void)refreshTasksFromDatabase
{
    [self.addOrEditTaskVC dismissViewControllerAnimated:YES completion:nil];
    self.addOrEditTaskVC = nil;
    self.dataSource = nil;
    [self.tableView reloadData];
}

- (NSDictionary *)getDataSourceFromDatabase {
 
    return [self convertTasksArrayIntoDataSourceStructure:[TaskHelper fetchAllTask]];
}

- (NSDictionary *)convertTasksArrayIntoDataSourceStructure:(NSArray *)tasks {
    
    NSMutableDictionary *dataSource = [[NSMutableDictionary alloc]initWithCapacity:0];
    NSArray *lowPriorityTasks = [self getSortedTasksForPriority:[[TagManager sharedInstance] tagByName:kTagAddTaskPriorityLow] fromTasks:tasks];
    [dataSource setObject:lowPriorityTasks forKey:[[TagManager sharedInstance] tagByName:kTagAddTaskPriorityLow]];
    NSArray *highPriorityTasks = [self getSortedTasksForPriority:[[TagManager sharedInstance] tagByName:kTagAddTaskPriorityHigh] fromTasks:tasks];
    [dataSource setObject:highPriorityTasks forKey:[[TagManager sharedInstance] tagByName:kTagAddTaskPriorityHigh]];
    NSArray *normalPriorityTasks = [self getSortedTasksForPriority:[[TagManager sharedInstance] tagByName:kTagAddTaskPriorityNormal] fromTasks:tasks];
    [dataSource setObject:normalPriorityTasks forKey:[[TagManager sharedInstance] tagByName:kTagAddTaskPriorityNormal]];
    
    return dataSource;
}

- (NSArray *)getSortedTasksForPriority:(NSString *)priority fromTasks:(NSArray *)tasks{
    
    NSPredicate *predExists = [NSPredicate predicateWithFormat:@"priority MATCHES[c] %@", priority];
    NSMutableArray *aList = [NSMutableArray arrayWithArray:[[[tasks filteredArrayUsingPredicate:predExists]reverseObjectEnumerator] allObjects]];
    [aList sortUsingComparator:^NSComparisonResult(SFMTaskModel *task1, SFMTaskModel *task2) {
        return [task2.date compare:task1.date];
    }];
    return aList;
}

- (NSString *)sectionTitleForSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section) {
        case 0:
            title = [[TagManager sharedInstance] tagByName:kTagAddTaskPriorityHigh];
            break;
        case 1:
            title = [[TagManager sharedInstance] tagByName:kTagAddTaskPriorityNormal];
            break;
        case 2:
            title = [[TagManager sharedInstance] tagByName:kTagAddTaskPriorityLow];
            break;
        default:
            break;
    }
    return title;
}

- (SFMTaskModel *)modelFromDataSourceForIndexPath:(NSIndexPath *)index {
    
    SFMTaskModel *model;
    NSArray *listOfModels = [self.dataSource objectForKey:[self sectionTitleForSection:index.section]];
    if ([listOfModels count] > index.row) {
        model = [listOfModels objectAtIndex:index.row];
    }
    return model;
}
#pragma mark - data Source setter
- (NSDictionary *)dataSource {
    
    if (_dataSource == nil) {
        
        _dataSource = [self getDataSourceFromDatabase];
    }
    return _dataSource;
}

#pragma mark AddOrEditTaskDelegate
- (void)addOrEditTaskVC:(AddOrEditTaskVC *)addOrEditTaskVC userPressedSaveForTask:(SFMTaskModel *)task {

    if (addOrEditTaskVC.isNewlyCreadedTask) {
        [TaskHelper addNewTask:task];
    }
    else {
        [TaskHelper updateTask:task];
    }
    
    //Add the new task to database.
    [self refreshTasksFromDatabase];
}
- (void)addOrEditTaskVC:(AddOrEditTaskVC *)addOrEditTaskVC userPressedCancelForTask:(SFMTaskModel *)task {
    
    [self refreshTasksFromDatabase];
    //Do nothing as user has pressed cancel button.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
