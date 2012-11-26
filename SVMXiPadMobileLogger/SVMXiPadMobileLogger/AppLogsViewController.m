//
//  AppLogsViewController.m
//  SVMXiPadMobileLogger
//
//  Created by Siva Manne on 07/11/12.
//  Copyright (c) 2012 Siva Manne. All rights reserved.
//

#import "AppLogsViewController.h"
#import "DetailViewController.h"

@interface AppLogsViewController ()
{
    NSMutableArray *_logFiles;
}
@end

@implementation AppLogsViewController
@synthesize detailViewController;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if(!_logFiles)
        _logFiles = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];
    NSArray *filesList = [self listFileAtPath:saveDirectory];
    for(NSString *logFile in filesList)
    {
        if([logFile rangeOfString:@".txt"].length)
        {
            [_logFiles addObject:logFile];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_logFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [_logFiles objectAtIndex:indexPath.row];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *fileName = _logFiles[indexPath.row];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *saveDirectory = [paths objectAtIndex:0];
        NSString *filePath = [saveDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
        BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        BOOL fileRemoved = NO;
        if(isFileExist)
        {
            if([[NSFileManager defaultManager] isDeletableFileAtPath:filePath])
                fileRemoved = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            
        }
        if(fileRemoved)
        {
            [_logFiles removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    detailViewController.isLogFromFileSystem = 0;
    detailViewController.detailItem = _logFiles[indexPath.row];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [paths objectAtIndex:0];
    NSString *filePath = [saveDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", _logFiles[indexPath.row]]];
    NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataWritingFileProtectionMask error:nil];
    NSString* newStr = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    detailViewController.detailData = newStr;
    [newStr release];

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}
#pragma mark -
-(NSArray *)listFileAtPath:(NSString *)path
{
    int count;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}
@end
