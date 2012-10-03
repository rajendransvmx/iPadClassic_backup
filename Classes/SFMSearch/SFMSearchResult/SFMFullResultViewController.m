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
extern void SVMXLog(NSString *format, ...);

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
@synthesize onlineImageView;
@synthesize TitleForResultWindow;
@synthesize conflict;
@synthesize download_on_demand;
@synthesize progressView;
@synthesize progressTitle;
@synthesize display_percentage;
@synthesize download_desc_label;
@synthesize description_label;
@synthesize ProgressBar;
@synthesize ProgressBarViewController;
@synthesize titleBackground;
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
//    SMLog(@"Display Values = %@",data);
    isOndemandRecord=FALSE;
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    [actionButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"] forState:UIControlStateNormal];
    [actionButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SRCH_CLOSE] forState:UIControlStateNormal];
    [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[actionButton titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
    [detailButton setFrame:CGRectMake(509, 10, 20, 21)];
    [download_on_demand setFrame:CGRectMake(500, 10, 20, 20)];
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement1 =[NSMutableString stringWithFormat:@"Select process_id from SFProcess where object_api_name is  '%@' and process_type is 'VIEWRECORD'",[appDelegate.dataBase getApiNameFromFieldLabel:objectName]]; 
    sqlite3_stmt * labelstmt;
    char *field1;
    const char *selectStatement = [queryStatement1 UTF8String];
    BOOL processAvailbleForRecord = NO;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);           
            if(field1 != nil)
            {
                processAvailbleForRecord = YES;
            }
            
        }
        synchronized_sqlite3_finalize(labelstmt);
    }
       
    if(self.isOnlineRecord&&!isOndemandRecord)
    {
        

        BOOL tabel_Exists=[appDelegate.dataBase isTabelExistInDB:@"on_demand_download"];
        NSString * object_api_name = [appDelegate.dataBase getApiNameFromFieldLabel:objectName];
        BOOL isparent=[appDelegate.dataBase isHeaderRecord:object_api_name];
        BOOL recordExists = [appDelegate.dataBase checkForDuplicateId:[appDelegate.dataBase getApiNameFromFieldLabel:objectName] sfId:[data objectForKey:@"Id"]];
        if(tabel_Exists&&recordExists&&isparent)
        {
             [detailButton removeTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [detailButton setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            [detailButton addTarget:self action:@selector(onlineDemandData:) forControlEvents:UIControlEventTouchUpInside];
             [self.view reloadInputViews];
        }
        else if(processAvailbleForRecord &&!recordExists)
        {
            isOndemandRecord = TRUE;
            NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:[data objectForKey:@"Id"] tableName:[appDelegate.dataBase getApiNameFromFieldLabel:objectName]];
            
            conflict=[appDelegate.dataBase checkIfConflictsExistsForEvent:[data objectForKey:@"Id"] objectName:[appDelegate.dataBase getApiNameFromFieldLabel:objectName] local_id:local_id];
                      [detailButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] forState:UIControlStateNormal];
            [onlineImageView setImage:nil];
            if (conflict)
            {
                onlineImageView.frame=CGRectMake(89, 6, 30, 30);
                [onlineImageView setImage:[UIImage imageNamed:@"red.png"]];
                
            }
        }
        [onlineImageView setImage:[UIImage imageNamed:@"OnlineRecord.png"]];
        
    }
    else if(processAvailbleForRecord)
    {
		NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:[data objectForKey:@"Id"] tableName:[appDelegate.dataBase getApiNameFromFieldLabel:objectName]];
		
        conflict=[appDelegate.dataBase checkIfConflictsExistsForEvent:[data objectForKey:@"Id"] objectName:[appDelegate.dataBase getApiNameFromFieldLabel:objectName] local_id:local_id];
        
//        if (!conflict)
//        {
//            conflict = [appDelegate.dataBase checkIfChildConflictexist:[data objectForKey:@"Id"] sfId:[appDelegate.dataBase getApiNameFromFieldLabel:objectName]];
//        }

        [detailButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] forState:UIControlStateNormal];
        [onlineImageView setImage:nil];
        if (conflict)
        {
            onlineImageView.frame=CGRectMake(89, 6, 30, 30);
            [onlineImageView setImage:[UIImage imageNamed:@"red.png"]];

        }
    }
    else
    {
        [detailButton setBackgroundImage:nil forState:UIControlStateNormal];
        [onlineImageView setImage:nil];
    }
    [resultTableView setBackgroundColor:[UIColor clearColor]];
    TitleForResultWindow.font=[UIFont boldSystemFontOfSize:16];
    if([data objectForKey:[tableHeaderArray objectAtIndex:0]])
    {
        if (objectName) 
        {
            TitleForResultWindow.text=[NSString stringWithFormat:@"%@: %@",objectName,[data objectForKey:[tableHeaderArray objectAtIndex:0]]];
        }  
        else
        {
            TitleForResultWindow.text=[NSString stringWithFormat:@"%@",[data objectForKey:[tableHeaderArray objectAtIndex:0]]];
        }
    }
    else 
        TitleForResultWindow.text=@"";

}
-(void)onlineDemandData:(id)sender
{
    NSString *objName = [objectName retain];
    NSString *objNameApiName = [appDelegate.dataBase getApiNameFromFieldLabel:objName];
    NSString *recordId = [data objectForKey:@"Id"];
    [self presentProgressBar:objNameApiName sf_id:recordId reocrd_name:objName];
    
}
- (void) accessoryButtonTapped:(id)sender
{ 
    if(isOnlineRecord && !isOndemandRecord)
        return;
    NSString *objName = [objectName retain];
    objName = [appDelegate.dataBase getApiNameFromFieldLabel:objName];
    char *field1;
    appDelegate.showUI = FALSE;   //btn merge
    if(appDelegate.sfmPageController)
        [appDelegate.sfmPageController release];
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    NSString *recordId = [data objectForKey:@"Id"];
    queryStatement1 = [NSMutableString stringWithFormat:@"Select local_id FROM '%@' where Id = '%@'",objName,recordId];    
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatement1 UTF8String];
    
    NSString *localId = @"";
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
//            SMLog(@"%s",field1);
            if(field1)
                localId = [NSString stringWithFormat:@"%s", field1];
            else
                localId = @"";
        }
    }
    
    NSString * queryStatement2 = [NSMutableString stringWithFormat:@"Select process_id FROM SFProcess where process_type = 'VIEWRECORD' and object_api_name = '%@'",objName];   
    const char *selectStatement2 = [queryStatement2 UTF8String];
    
    NSString *processId =nil;
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement2,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
//            SMLog(@"%s",field1);
            if(field1)
                processId = [NSString stringWithFormat:@"%s", field1];
        }
    }
    if(!processId)
        return;
    appDelegate.sfmPageController.conflictExists = FALSE;
    
    appDelegate.From_SFM_Search=FROM_SFM_SEARCH;
    NSString * sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:[appDelegate.dataBase getApiNameFromFieldLabel:objectName] local_id:localId];
    
    conflict = [appDelegate.dataBase checkIfConflictsExistsForEvent:sfid objectName:[appDelegate.dataBase getApiNameFromFieldLabel:objectName] local_id:localId];
    
//    if (!conflict)
//    {
//        conflict = [appDelegate.dataBase checkIfChildConflictexist:sfid sfId:[appDelegate.dataBase getApiNameFromFieldLabel:objectName]];
//    }

    
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.objectName = [NSString stringWithFormat:@"%@",objectName];
    appDelegate.sfmPageController.topLevelId = nil;
    appDelegate.sfmPageController.recordId = localId;    
    appDelegate.sfmPageController.conflictExists = conflict;
    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [appDelegate.sfmPageController.detailView view];

    [self presentModalViewController:appDelegate.sfmPageController animated:YES];
    [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
    appDelegate.didsubmitModelView = FALSE;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    resultTableView = nil;
    onlineImageView = nil;
    TitleForResultWindow = nil;
    [self setProgressBarViewController:nil];
    [self setProgressBar:nil];
    [self setDescription_label:nil];
    [self setDownload_desc_label:nil];
    [self setDisplay_percentage:nil];
    [self setProgressTitle:nil];
    [self setProgressView:nil];
    [self setTitleBackground:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//	return YES;
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
- (IBAction)dismissView:(id)sender
{
    [ fullMainDelegate LoadResultDetailViewController:isOndemandRecord];
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
    lblObjects =[[UILabel alloc]initWithFrame:CGRectMake(20, 0, 235, TableViewResultViewCellHeight)];
    NSString *objectString = [tableHeaderArray objectAtIndex:indexPath.row];
    NSArray *objectComponents = [objectString componentsSeparatedByString:@"."];
    lblObjects.text = [objectComponents objectAtIndex:([objectComponents count]-1)];
    lblObjects.text = [appDelegate.dataBase getLabelFromApiName:lblObjects.text
                                                     objectName:[appDelegate.dataBase getApiNameFromFieldLabel:[objectComponents objectAtIndex:0]]];
    lblObjects.font = [UIFont boldSystemFontOfSize:16];
    lblObjects.textAlignment=UITextAlignmentLeft;
    [lblObjects setBackgroundColor:[UIColor clearColor]];
    lblObjects.userInteractionEnabled = TRUE;
    lblObjects.tag  = 0;
    UITapGestureRecognizer * tapObject = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    [lblObjects addGestureRecognizer:tapObject];
    [tapObject release];
    [cell addSubview:lblObjects];
    lblValues=[[UILabel alloc]initWithFrame:CGRectMake(275, 0, 235, TableViewResultViewCellHeight)];
    [lblValues setBackgroundColor:[UIColor clearColor]];
    
    //Keerti checkbox
    
    NSString * string = [tableHeaderArray objectAtIndex:indexPath.row];
    NSArray * array = [string componentsSeparatedByString:@"."];
    
    NSString * type = [appDelegate.dataBase getfieldTypeForApi:[array objectAtIndex:0] fieldName:[array objectAtIndex:1]];
    
    if ([type isEqualToString:@"boolean"])
    {
        UIImageView *v1;
        NSString * value = [data objectForKey:[tableHeaderArray objectAtIndex:indexPath.row]];
        lblValues.frame = CGRectMake(275, 15, 235, TableViewResultViewCellHeight);
        if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"] ) 
        {
            v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
            v1.backgroundColor = [UIColor clearColor];
            v1.contentMode = UIViewContentModeCenter;
            [lblValues addSubview:v1];
        }
        else
        {  
            v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
            v1.backgroundColor = [UIColor clearColor];
            v1.contentMode = UIViewContentModeCenter;
            [lblValues addSubview:v1];
        }
        
    }
    else if([type isEqualToString:@"datetime"])
    {
        NSString * value = [data objectForKey:[tableHeaderArray objectAtIndex:indexPath.row]];
        value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
        value = [iOSInterfaceObject getLocalTimeFromGMT:value];
        value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        value = [value stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
        [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate * date = [frm dateFromString:value];
        [frm  setDateFormat:DATETIMEFORMAT];
        value = [frm stringFromDate:date];
        lblValues.text = value;
        
    }
    else if([type isEqualToString:@"date"])
    {
        NSString * value = [data objectForKey:[tableHeaderArray objectAtIndex:indexPath.row]];
        NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * date = [formatter dateFromString:value];
        [formatter setDateFormat:DATEFORMAT];
        value = [formatter stringFromDate:date];
        lblValues.text = value;
    }
    else
    {
        lblValues.text=[data objectForKey:[tableHeaderArray objectAtIndex:indexPath.row]];
    }
    lblValues.font = [UIFont boldSystemFontOfSize:16];
    lblValues.textColor = [appDelegate colorForHex:@"2d5d83"];  
    lblValues.textAlignment=UITextAlignmentLeft;
    lblValues.userInteractionEnabled = TRUE;
    lblValues.tag  = 1;
    UITapGestureRecognizer * tapValues = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    [lblValues addGestureRecognizer:tapValues];
    [tapValues release];

    [cell addSubview:lblValues];  
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
	[TitleForResultWindow release];
    [resultTableView release];
    [tableHeaderArray release];
    [data release];
    [onlineImageView release];
    [ProgressBarViewController release];
    [ProgressBar release];
    [description_label release];
    [download_desc_label release];
    [display_percentage release];
    [progressTitle release];
    [progressView release];
    [titleBackground release];

    [super dealloc];
}
-(void)tapRecognized:(id)sender
{ 
    UITapGestureRecognizer * tap = sender;
    if ([tap.view isKindOfClass:[UILabel  class]])    
    {
        UILabel * label = (UILabel *) tap.view;
        if(label.text == nil)
            return;
        //if the text length is 0 then dont show the popover
        if([label.text length] == 0)
            return;
        
        // content View class
        label_popOver_content = [[LabelPOContentView alloc ] init];
        
        // calculating the size for the popover
        UIFont * font = [UIFont systemFontOfSize:17.0];
        CGSize size =[label.text  sizeWithFont:font];
        
        //subview for the content view
        UITextView * contentView_textView;
        if(size.width > 240)
        {
            label_popOver_content.view.frame = CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 90);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 90)];
        }
        else
        {
            label_popOver_content.view.frame = CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 34);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 34)];  
        }
        
        contentView_textView.text = label.text;
        contentView_textView.font = font;
        contentView_textView.userInteractionEnabled = YES;
        contentView_textView.editable = NO;
        contentView_textView.textAlignment = UITextAlignmentCenter;
        [label_popOver_content.view addSubview:contentView_textView];
        
        CGSize size_po = CGSizeMake(label_popOver_content.view.frame.size.width, label_popOver_content.view.frame.size.height);
        label_popOver = [[UIPopoverController alloc] initWithContentViewController:label_popOver_content];
        [label_popOver setPopoverContentSize:size_po animated:YES];
        
        label_popOver.delegate = self;
        if(label.tag == 0)
        [label_popOver presentPopoverFromRect:CGRectMake(label.frame.size.width/2,0, 10, 10) inView:label permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        else
        if(label.tag == 1)
        [label_popOver presentPopoverFromRect:CGRectMake(0,0, 10, 10) inView:label permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        [contentView_textView release];
        [label_popOver_content release];
        
    }
}
#pragma progress bar
-(void)presentProgressBar:(NSString *)object_name sf_id:(NSString *)sf_id  reocrd_name:(NSString *)record_name
{
    
    if (!appDelegate.isInternetConnectionAvailable)
    {
        //  [appDelegate displayNoInternetAvailable];
        return;
    }
    
    [appDelegate invalidateAllTimers];
    
    Total_calls = 3;
    appDelegate.connection_error = FALSE;
    ProgressBarViewController.layer.cornerRadius = 5;
    ProgressBarViewController.frame = CGRectMake(60,100,420, 200);
    
    [self.view addSubview:ProgressBarViewController];
    
    description_label.numberOfLines = 3;
    description_label.font =  [UIFont systemFontOfSize:14.0];
    description_label.textAlignment = UITextAlignmentCenter;
    
    download_desc_label.font =  [UIFont systemFontOfSize:16.0];
    download_desc_label.textAlignment = UITextAlignmentCenter;
    NSString * download_string = [NSString stringWithFormat:@" Downloading %@ ",record_name];
    download_desc_label.text = download_string;
    ProgressBarViewController.backgroundColor = [appDelegate colorForHex:@"BDEAF9"];;//[UIColor clearColor];
    ProgressBarViewController.layer.borderColor = [UIColor blackColor].CGColor;
    ProgressBarViewController.layer.borderWidth = 1.0f;
    [ProgressBarViewController bringSubviewToFront:ProgressBar];
    [ProgressBarViewController bringSubviewToFront:progressTitle];
    self.progressTitle.text =  @"Data On Demand (DOD): Preparing for DOD download";
    progressTitle.backgroundColor = [UIColor clearColor];
    progressTitle.layer.cornerRadius = 8;
    titleBackground.layer.cornerRadius=5;
    ProgressBar.progress = 0.0;
    temp_percentage = 0;
    // total_progress = 0.0;
    display_percentage.text = @"0%";
    
    if(initial_sync_timer == nil)
        initial_sync_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
    
    BOOL flag = [appDelegate goOnlineIfRequired];
    if ([appDelegate.currentServerUrl Contains:@"null"] || [appDelegate.currentServerUrl length] == 0 || appDelegate.currentServerUrl == nil)
    {
        NSUserDefaults * userdefaults = [NSUserDefaults standardUserDefaults];
        
        appDelegate.currentServerUrl = [userdefaults objectForKey:SERVERURL];
    }
    if(flag)
    {
        appDelegate.dod_req_response_ststus = DOD_REQUEST_SENT;
        appDelegate.Sync_check_in = FALSE;
        appDelegate.dod_status = CONNECTING_TO_SALESFORCE;
        [appDelegate.wsInterface getOnDemandRecords:object_name record_id:sf_id];
        
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1, NO))
        {
            if( appDelegate.dod_req_response_ststus == DOD_RESPONSE_RECIEVED || appDelegate.connection_error || !appDelegate.isInternetConnectionAvailable)
            {
                break;
            }
        }
    }
    
    [initial_sync_timer invalidate];
    initial_sync_timer = nil;
    [ProgressBarViewController removeFromSuperview];
    
    [appDelegate ScheduleIncrementalDatasyncTimer];
    [appDelegate ScheduleIncrementalMetaSyncTimer];
    [appDelegate ScheduleTimerForEventSync];
    [appDelegate scheduleLocationPingTimer];
     [self.view reloadInputViews];
    isOndemandRecord=TRUE;
    
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement1 =[NSMutableString stringWithFormat:@"Select process_id from SFProcess where object_api_name is  '%@' and process_type is 'VIEWRECORD'",[appDelegate.dataBase getApiNameFromFieldLabel:objectName]];
    sqlite3_stmt * labelstmt;
    char *field1;
    const char *selectStatement = [queryStatement1 UTF8String];
    BOOL processAvailbleForRecord = NO;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            if(field1 != nil)
            {
                processAvailbleForRecord = YES;
            }
            
        }
        synchronized_sqlite3_finalize(labelstmt);
    }
    
    if(processAvailbleForRecord)
    {
		NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:[data objectForKey:@"Id"] tableName:[appDelegate.dataBase getApiNameFromFieldLabel:objectName]];
		
        conflict=[appDelegate.dataBase checkIfConflictsExistsForEvent:[data objectForKey:@"Id"] objectName:[appDelegate.dataBase getApiNameFromFieldLabel:objectName] local_id:local_id];
        
        //        if (!conflict)
        //        {
        //            conflict = [appDelegate.dataBase checkIfChildConflictexist:[data objectForKey:@"Id"] sfId:[appDelegate.dataBase getApiNameFromFieldLabel:objectName]];
        //        }
        [detailButton setBackgroundImage:nil forState:UIControlStateNormal];
       //  [detailButton addTarget:nil action:nil forControlEvents:nil];
        
        [detailButton removeTarget:self action:@selector(onlineDemandData:) forControlEvents:UIControlEventTouchUpInside];
        [detailButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] forState:UIControlStateNormal];
       
        [detailButton addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [onlineImageView setImage:nil];
        if (conflict)
        {
            onlineImageView.frame=CGRectMake(89, 6, 30, 30);
            [onlineImageView setImage:[UIImage imageNamed:@"red.png"]];
            
        }
    }

    
}
const int percentage_SFMResult = 30;
const float progress_SFMResult = 0.33;
#pragma mark - timer method to update progressbar
-(void)updateProgressBar:(id)sender
{
    
    if(appDelegate.dod_status == CONNECTING_TO_SALESFORCE && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_SFMResult;
        appDelegate.Sync_check_in = TRUE;
        total_progress =  progress_SFMResult ;
        ProgressBar.progress = 0.33;
        // download_desc_label.text = @"";//
        description_label.text = @"Connecting to Salesforce...";
    }
    else if(appDelegate.dod_status == RETRIEVING_DATA  && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_SFMResult * 2  ;
        appDelegate.Sync_check_in = TRUE;
        total_progress =  progress_SFMResult * 2;
        ProgressBar.progress = 0.66 ;
        //download_desc_label.text = @"";
        description_label.text =@"Retrieving data from Salesforce...";
    }
    else if(appDelegate.dod_status == SAVING_DATA  && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_SFMResult *3 + 10 ;
        appDelegate.Sync_check_in = TRUE;
        total_progress = 1.0;
        ProgressBar.progress = total_progress ;
        //download_desc_label.text = @"";
        description_label.text = @"Saving data for offline use....";
    }
    
    [self fillNumberOfStepsCompletedLabel];
}

-(void)fillNumberOfStepsCompletedLabel
{
    
    NSString * _percentagetext = [[NSString alloc] initWithFormat:@"%d%%", temp_percentage];
    display_percentage.text = _percentagetext;
    [_percentagetext release];
}
@end
