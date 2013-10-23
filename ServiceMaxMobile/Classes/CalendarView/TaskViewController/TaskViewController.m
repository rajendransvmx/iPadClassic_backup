//
//  TaskViewController.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 17/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TaskViewController.h"
#import "Utility.h"
void SMXLog(const char *methodContext,NSString *message);

@implementation TaskViewController

@synthesize tasks;
@synthesize calendar;


#pragma mark -
#pragma mark View lifecycle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        tasks = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //8485
    if (![Utility notIOS7] &&[self.view isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self.view;
        UIEdgeInsets xx =  tableView.separatorInset;
        xx.left = 5;
        tableView.separatorInset =xx;
    }

    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    SMLog(@"%@", tasks);
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	if (tasks != nil && [tasks count] > 0)
	{
		rowCount = [tasks count];
	}
    return rowCount;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TaskViewCell";
    
    TaskViewCell *cell = (TaskViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [self createNewTaskCell];
    }
    selectedRow = indexPath.row;
    // Configure the cell...
    cell.imageView.image = [self getImageForPriority:[[tasks objectAtIndex:indexPath.row] objectAtIndex:0]];
    cell.imageView.isAccessibilityElement = YES;
    [cell setTask:[[tasks objectAtIndex:indexPath.row] objectAtIndex:1]];
    cell.backgroundColor = [UIColor clearColor]; //8485
    return cell;
}

- (TaskViewCell *) createNewTaskCell
{
	NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"TaskViewCell" owner:self options:nil];
	NSEnumerator * nibEnumerator = [nibContents objectEnumerator];
	TaskViewCell * customCell = nil;
	NSObject* nibItem = nil;
    
	while ( (nibItem = [nibEnumerator nextObject]) != nil)
	{
		if ( [nibItem isKindOfClass: [TaskViewCell class]])
		{
			customCell = (TaskViewCell*) nibItem;
			if ([customCell.reuseIdentifier isEqualToString:@"TaskViewCell"])
				break; // we have a winner
			else
				customCell = nil;
		}
	}
	return customCell;
}

- (UIImage *)getImageForPriority:(NSString *)priority
{
    NSString * high = [appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_PRIORITY_HIGH];
    NSString * low = [appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_PRIORITY_LOW];
    NSString * normal = [appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_PRIORITY_NORMAL];

    if ([priority isKindOfClass:[NSString class]])
    {
        if ([priority isEqualToString:low])
            return [UIImage imageNamed:@"low-priority-task.png"];
        if ([priority isEqualToString:normal])
            return [UIImage imageNamed:@"medium-priority-task.png"];
        if ([priority isEqualToString:high])
            return [UIImage imageNamed:@"high-priority-task.png"];
    }

    return [UIImage imageNamed:@"medium-priority-task.png"];;
}

- (void) AddTaskWithText:(NSMutableArray *)task
{
    if (task == nil) return;
    
   /* if (![appDelegate isInternetConnectionAvailable])
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
    [self addNewTask:task];
}

- (void) addNewTask:(NSMutableArray*)task;
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    // Obtain new time / day of event and update it on sfdc
    ZKSObject *cObj = [[ZKSObject alloc] initWithType:@"Task"];

    NSString * activityDate = [calendar getTodayString];

    NSString * priority = [task objectAtIndex:0];
    NSString * subject = [task objectAtIndex:1];
    // Note that activity date has to be set to Today
    [cObj setFieldValue:activityDate field:TASKACTIVITYDATE];
    [cObj setFieldValue:priority field:TASKPRIORITY];
    [cObj setFieldValue:subject field:TASKSUBJECT];

    NSArray *objects = [[NSArray alloc] initWithObjects:cObj, nil];
    
    didGetId = FALSE;
    //[iOSObject create:objects];
    
    SMLog(@"%@", task);
    SMLog(@"%@", resultId);
    SMLog(@"%@", [task objectAtIndex:1]);

    if (resultId != nil)
        [task addObject:resultId];
    SMLog(@"%@", task);

    SMLog(@"%@", tasks);

    [objects release];
    [cObj release];
    
    NSString * local_id = [AppDelegate GetUUID];

    BOOL success = [appDelegate.calDataBase insertTasksIntoDB:task WithDate:activityDate local_id:local_id];
    
    if (success)
    {
		//Sync_Override
        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:local_id SF_id:@"" record_type:MASTER operation:INSERT object_name:@"Task" sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:@"" className:@"" synctype:AGRESSIVESYNC headerLocalId:local_id requestData:nil finalEntry:NO];
        [appDelegate setAgrressiveSync_flag];
		//RADHA Defect Fix 5542
		appDelegate.shouldScheduleTimer = YES;
        [appDelegate callDataSync];
    }
    
    [task addObject:activityDate];
    [task addObject:local_id];
    [tasks addObject:task];     
    [pool drain];
    [self.tableView reloadData];
}

- (void) didCreateObjects:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
{
    NSArray * arr = (NSArray*)result;
    
    SMLog(@"%@", [arr objectAtIndex:0]);
    NSString * str = (NSString*) [arr objectAtIndex:0];
    
    resultId = [[NSString alloc] initWithFormat:@"%@", (NSString*)str];
    if (result == nil)
        resultId = @"";
    didGetId = TRUE;
}

- (void) refreshWithTasks:(NSMutableArray *)_tasks
{
    if (tasks)
    {
        [tasks removeAllObjects];
        [tasks release];
    }
    tasks = [_tasks retain];
    // if ((tasks != nil) && ([tasks count] > 0))
        [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSString * local_id = [[[tasks objectAtIndex:indexPath.row] objectAtIndex:3] retain];
    NSString * sf_id =  [appDelegate.databaseInterface   getSfid_For_LocalId_From_Object_table:@"Task" local_id:local_id];
    
    
    [appDelegate.calDataBase deleteTaskFromDB:[[tasks objectAtIndex:indexPath.row] objectAtIndex:3]];
     [tasks removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
      
    //sahana 26/Feb
    //sahana delete Task
    if(![sf_id isEqualToString:@""] && [sf_id length] != 0)
    {
		//Sync_Override
        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:local_id SF_id:sf_id  record_type:DETAIL operation:DELETE object_name:@"Task" sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:@"" className:@"" synctype:AGRESSIVESYNC headerLocalId:local_id requestData:nil finalEntry:NO];
        [appDelegate setAgrressiveSync_flag];

		//RADHA Defect Fix 5542
		appDelegate.shouldScheduleTimer = YES;
        [appDelegate callDataSync];
    }
    
    //[iOSObject delete:array];
}

- (void) didDeleteObjects:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc 
{
    
    [super dealloc];
}


@end

