//
//  TaskHomeViewController.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 02/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TaskHomeViewController.h"
#import "StyleManager.h"
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
#import "NSNotificationCenter+UniqueNotif.h"


static NSString *reusableIdentifier = @"TaskCell";

@interface TaskHomeViewController ()<UITableViewDelegate,UITableViewDataSource,AddOrEditTaskVCDelegate>
@property (nonatomic, copy) NSDictionary *dataSource;
@property (nonatomic, strong) AddOrEditTaskVC *addOrEditTaskVC;
@end

@implementation TaskHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = nil;
    self.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]tagByName:kTagHomeTask]];
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0+
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *addNewTaskNavButton = [[UIBarButtonItem alloc]initWithTitle:@"+ Add" style:UIBarButtonItemStylePlain target:self action:@selector(addNewTask)];
    self.navigationItem.rightBarButtonItem = addNewTaskNavButton;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setSeparatorColor:[UIColor colorWithHexString:kActionBgColor]];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.dataSource = nil;
    [self.tableView reloadData];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                             selector:@selector(receivedDataSyncStatusNotification:)
                                                 name:kDataSyncStatusNotification
                                               object:[SyncManager sharedInstance]];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    else
    {
        //reset cell while reuse.
        cell.accessoryView = nil;
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
    }
    
    SFMTaskModel *model = [self modelFromDataSourceForIndexPath:indexPath];
    cell.textLabel.text = model.taskDescription;
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSString *literalSupportedText = @"- - - -";
    if (model.date) {
        literalSupportedText = [DateUtil getLiteralSupportedDateOnlyStringForDate:model.date];
    }
    cell.detailTextLabel.text = literalSupportedText;
    if ([cell.detailTextLabel.text isEqualToString:[[TagManager sharedInstance] tagByName:kTag_Today]]) {
        cell.detailTextLabel.textColor = [UIColor colorWithHexString:kOrangeColor];
    } else {
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    if ([model.priority isEqualToString:kTaskPriorityHigh])
    {
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HighPriorityImage"]];
    }
    else if ([model.priority isEqualToString:kTaskPriorityLow])
    {
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LowPriorityImage"]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self.dataSource objectForKey:[self sectionTitleForSection:section]] count];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    if ([self isTasksNotFound]) {
        /*
         * There are no records so lets add the label.
         */
        UILabel * noRecordsInfoLabel = [[UILabel alloc]initWithFrame:self.view.bounds];
        noRecordsInfoLabel.tag = 999;
        noRecordsInfoLabel.text = @"No tasks found. Try adding new task.";
        
        noRecordsInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16.0];
        noRecordsInfoLabel.textColor =[UIColor colorWithRed:121.0/255.0
                                                      green:121.0/255.0
                                                       blue:121.0/255.0
                                                      alpha:1.0];
        
        noRecordsInfoLabel.textAlignment = NSTextAlignmentCenter;
        
        noRecordsInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight
        |UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:noRecordsInfoLabel];
        
    }
    return count;
}

#pragma mark - UITableViewDelegate

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [self deleteTaskForIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self editTaskForIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (BOOL)isTasksNotFound {
    
    BOOL status = NO;
    if ([self.dataSource count]) {
        
        NSInteger lowPriorityCount = [[self.dataSource objectForKey:kTaskPriorityLow] count];
        NSInteger normalPriorityCount = [[self.dataSource objectForKey:kTaskPriorityNormal] count];
        NSInteger highPriorityCount = [[self.dataSource objectForKey:kTaskPriorityHigh] count];
        
        if ((lowPriorityCount <1) && (normalPriorityCount <1) && (highPriorityCount <1)) {
            return YES;
        }
    }
    return status;
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
    self.dataSource = nil;
    [self.tableView reloadData];
    [self.addOrEditTaskVC dismissViewControllerAnimated:YES completion:^{
        self.addOrEditTaskVC = nil;
    }];
    
}

- (NSDictionary *)getDataSourceFromDatabase {
 
    return [self convertTasksArrayIntoDataSourceStructure:[TaskHelper fetchAllTask]];
}

- (NSDictionary *)convertTasksArrayIntoDataSourceStructure:(NSArray *)tasks {
    
    NSMutableDictionary *dataSource = [[NSMutableDictionary alloc]initWithCapacity:0];
    NSArray *lowPriorityTasks = [self getSortedTasksForPriority:kTaskPriorityLow fromTasks:tasks];
    [dataSource setObject:lowPriorityTasks forKey:kTaskPriorityLow];
    NSArray *highPriorityTasks = [self getSortedTasksForPriority:kTaskPriorityHigh fromTasks:tasks];
    [dataSource setObject:highPriorityTasks forKey:kTaskPriorityHigh];
    NSArray *normalPriorityTasks = [self getSortedTasksForPriority:kTaskPriorityNormal fromTasks:tasks];
    [dataSource setObject:normalPriorityTasks forKey:kTaskPriorityNormal];
    
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
            title = kTaskPriorityHigh;
            break;
        case 1:
            title = kTaskPriorityNormal;
            break;
        case 2:
            title = kTaskPriorityLow;
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
