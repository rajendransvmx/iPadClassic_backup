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
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    [actionButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"] forState:UIControlStateNormal];
    [actionButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SRCH_CLOSE] forState:UIControlStateNormal];
    [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[actionButton titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
    [detailButton setFrame:CGRectMake(509, 10, 20, 21)];
    
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
    
    
    if(self.isOnlineRecord)
    {
        /*[detailButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button-Gray.png"] forState:UIControlStateNormal];*/
        [detailButton setBackgroundImage:nil forState:UIControlStateNormal];
        [onlineImageView setImage:[UIImage imageNamed:@"OnlineRecord.png"]];
    }
    else if(processAvailbleForRecord)
    {
        [detailButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] forState:UIControlStateNormal];
        [onlineImageView setImage:nil];
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


- (void) accessoryButtonTapped:(id)sender
{ 
    if(isOnlineRecord)
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
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.objectName = [NSString stringWithFormat:@"%@",objectName];
    
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
    //[appDelegate.sfmPageController release];
    
    //[ fullMainDelegate DismissSplitViewControllerByLaunchingSFMProcess];
    //[self dismissModalViewControllerAnimated:YES];
    //[objName release];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    resultTableView = nil;
    onlineImageView = nil;
    TitleForResultWindow = nil;
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
    [ fullMainDelegate LoadResultDetailViewController];
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
    
    //Keerthi checkbox
    
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
@end
