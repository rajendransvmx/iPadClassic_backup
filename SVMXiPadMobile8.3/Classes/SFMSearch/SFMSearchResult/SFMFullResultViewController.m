//
//  SFMFullResultViewController.m
//  SFMSearch
//
//  Created by Siva Manne on 12/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "SFMFullResultViewController.h"
#import "iServiceAppDelegate.h"

@interface SFMFullResultViewController ()

@end

@implementation SFMFullResultViewController
@synthesize data;
@synthesize tableHeaderArray;
@synthesize actionButton,detailButton;
@synthesize isOnlineRecord;
@synthesize fullMainDelegate;
@synthesize objectName;
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
    CGRect leftFrame = CGRectMake(40, positionY, 200, 60);
    CGRect rightFrame = CGRectMake(240, 40, 200, 60);
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
    //NSArray *allKeys = [data allKeys];
    
    //for(id field in allKeys)
    for(id field in tableHeaderArray)
    {
        UILabel *leftlabel = [[UILabel alloc] initWithFrame:leftFrame];
        [leftlabel setFrame:leftFrame];
        leftlabel.text = field;
        leftlabel.textColor=[UIColor blackColor];//[appDelegate colorForHex:@"2d5d83"];
        leftlabel.backgroundColor=[UIColor clearColor];
        [self.view addSubview:leftlabel]; 
        positionY += 50;
        leftFrame = CGRectMake(40,positionY,200,60);
        [leftlabel release];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:rightFrame];
        [rightLabel setFrame:rightFrame];
        rightLabel.text = [data objectForKey:field];
        rightLabel.textColor=[appDelegate colorForHex:@"2d5d83"];
        rightLabel.backgroundColor=[UIColor clearColor];
        [self.view addSubview:rightLabel]; 
        rightFrame = CGRectMake(240,positionY,200,60);
        [rightLabel release];
        if(appDelegate.sfmPageController.processId==NULL)
        {
            
        }
            
    }
}


- (void) accessoryButtonTapped:(id)sender
{ 

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
    
    NSString *processId = @"";
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement2,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            NSLog(@"%s",field1);
            if(field1)
                processId = [NSString stringWithFormat:@"%s", field1];
            else
                processId = @"";
        }
    }
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.objectName = objectName;
    
    //appDelegate.sfmPageController.recordId = [NSString stringWithFormat:@"%s", field1];
    //appDelegate.sfmPageController.activityDate = [array2 objectAtIndex:(ownerCellIndexPath.row)];
    //appDelegate.sfmPageController.accountId = @"";
    appDelegate.sfmPageController.topLevelId = nil;
    appDelegate.sfmPageController.recordId = localId;    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
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
-(void) dealloc
{
    [objectName release];
    [tableHeaderArray release];
    [data release];
    [super dealloc];
}
@end
