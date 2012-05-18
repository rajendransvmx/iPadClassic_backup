//
//  SFMFullResultViewController.m
//  SFMSearch
//
//  Created by Siva Manne on 12/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "SFMFullResultViewController.h"
#import "iServiceAppDelegate.h"
#define TableViewResultViewCellHeight 50

@interface SFMFullResultViewController ()

@end

@implementation SFMFullResultViewController
@synthesize data;
@synthesize tableHeaderArray;
@synthesize actionButton,detailButton;
@synthesize isOnlineRecord;
@synthesize fullMainDelegate;
@synthesize objectName;
@synthesize resultTableView;
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
    NSLog(@"Display Values = %@",data);
    int positionY = 40;
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    [actionButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"] forState:UIControlStateNormal];
    [detailButton setFrame:CGRectMake(500, 0, 40, 40)];
    
    if(self.isOnlineRecord)
    {
        [detailButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button-Gray.png"] forState:UIControlStateNormal];
    }
    else 
    {
        [detailButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] forState:UIControlStateNormal];
    }
    [resultTableView setBackgroundColor:[UIColor clearColor]];
    //NSArray *allKeys = [data allKeys];
    
    //for(id field in allKeys)
}


- (void) accessoryButtonTapped:(id)sender
{ 
    if(isOnlineRecord)
        return;
    objectName = [appDelegate.dataBase getApiNameFromFieldLabel:objectName];
    char *field1;
    appDelegate.showUI = FALSE;   //btn merge
    if(appDelegate.sfmPageController)
        [appDelegate.sfmPageController release];
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    NSString *recordId = [data objectForKey:@"Id"];
    queryStatement1 = [NSMutableString stringWithFormat:@"Select local_id FROM '%@' where Id = '%@'",objectName,recordId];    
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatement1 UTF8String];
    
    NSString *localId = @"";
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            NSLog(@"%s",field1);
            if(field1)
                localId = [NSString stringWithFormat:@"%s", field1];
            else
                localId = @"";
        }
    }
    
    NSString * queryStatement2 = [NSMutableString stringWithFormat:@"Select process_id FROM SFProcess where process_type = 'VIEWRECORD' and object_api_name = '%@'",objectName];   
    const char *selectStatement2 = [queryStatement2 UTF8String];
    
    NSString *processId =nil;
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement2,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            NSLog(@"%s",field1);
            if(field1)
                processId = [NSString stringWithFormat:@"%s", field1];
        }
    }
    if(!processId)
        return;
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.objectName = objectName;
    
    //appDelegate.sfmPageController.recordId = [NSString stringWithFormat:@"%s", field1];
    //appDelegate.sfmPageController.activityDate = [array2 objectAtIndex:(ownerCellIndexPath.row)];
    //appDelegate.sfmPageController.accountId = @"";
    appDelegate.sfmPageController.topLevelId = nil;
    appDelegate.sfmPageController.recordId = localId;    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [appDelegate.sfmPageController.detailView view];
    [self presentModalViewController:appDelegate.sfmPageController animated:YES];
    [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
    appDelegate.didsubmitModelView = FALSE;
    [appDelegate.sfmPageController release];

    [ fullMainDelegate DismissSplitViewControllerByLaunchingSFMProcess];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    resultTableView = nil;

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
- (IBAction)dismissView:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableHeaderArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *lblObjects,*lblValues;
    NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    else
    {
        NSArray *subLabelViews = [cell subviews];
        for(UIView *txtView in subLabelViews)
        {
            [txtView removeFromSuperview];
        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    lblObjects =[[UILabel alloc]initWithFrame:CGRectMake(20, 0, 200, TableViewResultViewCellHeight)];
    lblObjects.text= [tableHeaderArray objectAtIndex:indexPath.row];
    lblObjects.textAlignment=UITextAlignmentLeft;
    [lblObjects setBackgroundColor:[UIColor clearColor]];
    [cell addSubview:lblObjects];
    lblValues=[[UILabel alloc]initWithFrame:CGRectMake(250, 0, 500, TableViewResultViewCellHeight)];
    [lblValues setBackgroundColor:[UIColor clearColor]];
    lblValues.text=[data objectForKey:[tableHeaderArray objectAtIndex:indexPath.row]];
    lblObjects.textColor = [appDelegate colorForHex:@"2d5d83"];  
    lblValues.textAlignment=UITextAlignmentLeft;
    [cell addSubview:lblValues];    
    [lblObjects release];
    [lblValues release];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewResultViewCellHeight;
}


-(void) dealloc
{
    [resultTableView release];
    [tableHeaderArray release];
    [data release];
    [super dealloc];
}
@end
