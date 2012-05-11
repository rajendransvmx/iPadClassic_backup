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
@synthesize actionButton,detailButton;
@synthesize isOnlineRecord;
@synthesize fullMainDelegate;
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
    NSArray *allKeys = [data allKeys];
    
    for(id field in allKeys)
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
    [ fullMainDelegate DismissSplitViewControllerByLaunchingSFMProcess];
    [self dismissModalViewControllerAnimated:YES];
//    UITableViewCell *ownerCell = (UITableViewCell*)[sender superview];
//    NSIndexPath *ownerCellIndexPath;
//    if (ownerCell != nil)
//    {
//        /* Now we will retrieve the index path of the cell which contains the section and the row of the cell */
//        ownerCellIndexPath = [self.detailTable indexPathForCell:ownerCell];
//        NSLog(@"Accessory in index path is tapped. Index path = %d", ownerCellIndexPath.row);
//    }
    
    /*
    NSString *filedName=@"";
    char *field,*filedForName;
    NSLog(@"Display Values = %@",data);
    for(NSString *objName in data){
       if([objName isEqualToString:@"Name"])
        filedName=[data objectForKey:@"Name"];
        }
    NSMutableString * queryForGettingObject = [[NSMutableString alloc]initWithCapacity:0];
    queryForGettingObject = [NSMutableString stringWithFormat:@"Select local_id FROM SVMXC__Service_Order__c where Name = '%@'",filedName];    
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryForGettingObject UTF8String];

    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW){
            filedForName = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            NSLog(@"%s",filedForName);
            appDelegate.sfmPageController.recordId = [NSString stringWithFormat:@"%s", filedForName];
            
        }
    }

    NSLog(@"Field Value %@",filedName);
    
    
    if(appDelegate){
     appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
 
    appDelegate.showUI = FALSE;   //btn merge
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];

    if ([appDelegate.SFMPage retainCount] > 0)
    {
        [appDelegate.SFMPage release];
        appDelegate.SFMPage = nil;
    }   

    
    NSMutableString * queryForActivityDate = [[NSMutableString alloc]initWithCapacity:0];
    queryForActivityDate = [NSMutableString stringWithFormat:@"Select ActivityDate FROM Event where Subject = '%@'",filedName];    
    sqlite3_stmt * labelstmtForActivityDate;
    const char *selectStatementForActivityDate = [queryForActivityDate UTF8String];

    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementForActivityDate,-1, &labelstmtForActivityDate, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(labelstmtForActivityDate) == SQLITE_ROW){
            field = (char *) synchronized_sqlite3_column_text(labelstmtForActivityDate,0);
            NSLog(@"%s",field);          
            appDelegate.sfmPageController.activityDate =[NSString stringWithFormat:@"%s", field];
        }
    }

    
    appDelegate.sfmPageController.processId = @"IPAD-012";
    
    appDelegate.sfmPageController.objectName = @"SVMXC__Service_Order__c";

    NSLog(@"%s",field);

    appDelegate.sfmPageController.accountId = @"";
    appDelegate.sfmPageController.topLevelId = nil;
       NSLog(@"%s",filedForName);
        
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [appDelegate.sfmPageController.detailView view];
    [self presentModalViewController:appDelegate.sfmPageController animated:YES];
    [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
    
    
    //sahana - offline
    appDelegate.didsubmitModelView = FALSE;
    
    [appDelegate.sfmPageController release];
    */
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
    [data release];
    [super dealloc];
}
@end
