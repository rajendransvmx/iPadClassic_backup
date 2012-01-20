//
//  TaskViewController.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 17/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TaskViewController.h"

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

    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    iOSObject = [[iOSInterfaceObject alloc] initWithCaller:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
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
    NSLog(@"%@", tasks);
    return [tasks count];
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
    [cell setTask:[[tasks objectAtIndex:indexPath.row] objectAtIndex:1]];
    
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
    
   /* if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
    [self addNewTask:task];
}

- (void) addNewTask:(NSMutableArray*)task;
{
   /* if (!appDelegate.isInternetConnectionAvailable)
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }*/

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
    
      /* while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, FALSE)) //radha 12 August 2011
    {
        if (!appDelegate.isInternetConnectionAvailable)
        {
            [appDelegate displayNoInternetAvailable];
            return;
        }

        NSLog(@"TaskViewController addNewTask in while loop");
        if (didGetId)
            break;
    }*/
    NSLog(@"%@", task);
    NSLog(@"%@", resultId);
    NSLog(@"%@", [task objectAtIndex:1]);

    if (resultId != nil)
        [task addObject:resultId];
    NSLog(@"%@", task);

   // [tasks addObject:task];
    NSLog(@"%@", tasks);

    [objects release];
    [cObj release];
    
    //Shrinivas
    [appDelegate.calDataBase insertTasksIntoDB:task WithDate:activityDate];
    NSString *Id = [appDelegate.calDataBase retreiveCurrentTaskIdCreated];
    [task addObject:activityDate];
    [task addObject:Id];
    [tasks addObject:task];     
    [pool drain];
    [self.tableView reloadData];
}

- (void) didCreateObjects:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
{
   /* if (!appDelegate.isInternetConnectionAvailable)
        return;*/
    
    NSArray * arr = (NSArray*)result;
    
    NSLog(@"%@", [arr objectAtIndex:0]);
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
   /* if (appDelegate.isInternetConnectionAvailable)
        return YES;
    else
        return NO; */
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", tasks);
    NSLog(@"%@", [tasks objectAtIndex:indexPath.row]);
    //NSArray * array = [[[NSArray alloc] initWithObjects:[[tasks objectAtIndex:indexPath.row] objectAtIndex:2], nil] autorelease];
    [appDelegate.calDataBase deleteTaskFromDB:[[tasks objectAtIndex:indexPath.row] objectAtIndex:3]];
    [tasks removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
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

