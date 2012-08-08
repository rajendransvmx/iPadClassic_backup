//
//  SFMResultDetailViewController.m
//  SFMSearch
//
//  Created by Siva Manne on 11/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "SFMResultDetailViewController.h"
#import "SFMFullResultViewController.h"
#import "SFMResultMainViewController.h"
#import "SFMResultMasterViewController.h"
#import "iServiceAppDelegate.h"
#import "SFMPageController.h"
#define TableViewResultViewCellHeight 31
@interface SFMResultDetailViewController ()
@property (nonatomic, retain) NSMutableArray          *configData;
@end
enum  {
    backgroundImage = 1001,
    textLabel1 = 1002,
    textLabel2 = 1003,
    textLabel3 = 1004,
    };
@implementation SFMResultDetailViewController
@synthesize configData;
@synthesize tableDataArray;
@synthesize resultArray;
@synthesize detailTable;
@synthesize detailTableArray;
@synthesize sfmConfigName;
@synthesize splitViewDelegate;
@synthesize masterView;
@synthesize activityIndicator;
@synthesize onlineDataDict;
@synthesize mainView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Result Detail", @"Result Detail");
    }
    return self;
}
- (void) showHelp
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.helpString = @"home.html";  
    [self presentModalViewController:help animated:YES];
    [help release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initilizeToolBar];
    [self createTable];
    
}
-(void) LoadResultDetailViewController
{
    [self initilizeToolBar];
}
-(void) viewDidAppear:(BOOL)animated
{
    [self initilizeToolBar];

}
-(void) initilizeToolBar 
{
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)] autorelease];
       [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(DismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    NSMutableArray * buttons = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.animatedImageView];
    [buttons addObject:syncBarButton];
    [syncBarButton setTarget:self];
    syncBarButton.width =26;
    [syncBarButton release];
    
    UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)];
    [actionButton setImage:[UIImage imageNamed:@"iService-Screen-Help.png"] forState:UIControlStateNormal];
    actionButton.alpha = 1.0;
    [actionButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * helpBarButton = [[UIBarButtonItem alloc] initWithCustomView:actionButton];
    [helpBarButton setTarget:self];
    [helpBarButton setAction:@selector(showHelp)];
    [buttons addObject:helpBarButton];
    [helpBarButton release];
    [actionButton release];
    
    UIToolbar* toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(600, 0, 90, 44)] autorelease];
    [toolbar setItems:buttons];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
         
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
  
    bgImage.frame = CGRectMake(0, -12, bgImage.frame.size.width, bgImage.frame.size.height+12);
     [self.view addSubview:bgImage];
    self.detailTable.backgroundView = bgImage;
    [bgImage release];
     
      // Set title for detail
    UILabel * titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)] autorelease];
    titleLabel.textAlignment = UITextAlignmentCenter;
    if(sfmConfigName == nil)
        titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SRCH_RESULTS];
    else
        titleLabel.text = sfmConfigName;
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLabel;    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return YES;
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void) dealloc
{
    [resultArray release];
    [lastSelectedIndexPath release];
    [onlineDataDict release];
    [activityIndicator release];
    [masterView release];     
    [detailTableArray release];
    [detailTable release];
    [super dealloc];
}
#pragma mark - table view delegate methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
 
    UIView * view = nil;
    UILabel * label ;
    NSString *object_name,*apiHeaderName,*formated_header_objectName;
    int no_of_fields=3;
    view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, TableViewResultViewCellHeight*2)] autorelease];
    UIImageView * sectionImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_section_header_bg.png"]] autorelease];
    sectionImageView.frame = CGRectMake(20, 0, tableView.frame.size.width-40, TableViewResultViewCellHeight);
    UIImageView * imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Header.png"]] autorelease];
    imageView.frame = CGRectMake(40, TableViewResultViewCellHeight, tableView.frame.size.width-80, TableViewResultViewCellHeight);
    
    UILabel * sectionName = [[[UILabel alloc] init] autorelease];
    sectionName.frame = CGRectMake(40, 0, tableView.frame.size.width, TableViewResultViewCellHeight);
    sectionName.font = [UIFont boldSystemFontOfSize:16];     
    NSString *strObjDescription=[[tableDataArray objectAtIndex:section ] objectForKey:@"ObjectDescription"];
    if([strObjDescription isEqualToString:@"(null)"])
        sectionName.text=[[tableDataArray objectAtIndex:section ] objectForKey:@"ObjectName"];//@"";
    else
        sectionName.text=[[tableDataArray objectAtIndex:section ] objectForKey:@"ObjectDescription"];
    sectionName.textColor=[appDelegate colorForHex:@"2d5d83"];
    sectionName.backgroundColor = [UIColor clearColor];
    
    [view addSubview:sectionImageView];
    [view addSubview:imageView];
    [view addSubview:sectionName];

    for(int i=0;i<[[[tableDataArray objectAtIndex:section ] objectForKey:@"TableHeader"]count] && i <no_of_fields;i++)
    {
        label = [[[UILabel alloc] init] autorelease];
         if(no_of_fields)
        label.frame = CGRectMake((60+i*(640/no_of_fields)), TableViewResultViewCellHeight,190, TableViewResultViewCellHeight);
        label.backgroundColor = [UIColor clearColor];      
        label.font = [UIFont boldSystemFontOfSize:16];
        NSString *formated_header= [[[tableDataArray objectAtIndex:section ] objectForKey:@"TableHeader"]objectAtIndex:i];
        if([formated_header rangeOfString:@"."].length > 0)
        {
            NSRange range=[formated_header rangeOfString:@"."];
            apiHeaderName=[formated_header substringFromIndex:range.location+1];
            object_name =[formated_header substringToIndex:range.location];
            formated_header_objectName=[appDelegate.dataBase getLabelFromApiName:apiHeaderName
                                                      objectName:[appDelegate.dataBase getApiNameFromFieldLabel:object_name]];
        }
        label.text=formated_header_objectName;//
        label.textAlignment = UITextAlignmentLeft;
        label.textColor=[UIColor whiteColor];
        label.userInteractionEnabled = TRUE;
        UITapGestureRecognizer * tapObject = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [label addGestureRecognizer:tapObject];
        [tapObject release];

        [view addSubview:label]; 
    }
    return view;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *cellArray = [[tableDataArray objectAtIndex:section] objectForKey:@"Values"];
    if([self.masterView.searchFilterSwitch isOn])
    {
        NSDictionary *sectionDict = [tableDataArray objectAtIndex:section];
        NSString *sectionObjectId = [sectionDict objectForKey:@"ObjectId"];
        int onlineCount = 0;
        NSMutableArray *objectSectionData = [onlineDataDict objectForKey:sectionObjectId];
        onlineCount = [objectSectionData count];
        return [cellArray count] + onlineCount;
    }
    else {
        return [cellArray count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"identifier";
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    UILabel *labelForObjects;
    int no_of_fields=3;
    UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(40, 0, 630, TableViewResultViewCellHeight)] autorelease];
    UIImageView * bgView;
    
    if(lastSelectedIndexPath && (lastSelectedIndexPath.row == indexPath.row) && (lastSelectedIndexPath.section == indexPath.section))
        bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip-Selected.png"]] autorelease];
    else
        bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
    
    [bgView setTag:backgroundImage];
    [bgView setFrame:CGRectMake(0, 0, 630, TableViewResultViewCellHeight)];
    [backgroundView addSubview:bgView];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    else
    {        
        NSArray *subViews = [cell.contentView subviews];
        for(UIView *subView in subViews)
        {
            [subView removeFromSuperview];
        }         
    }
    NSArray *cellArray = [[tableDataArray objectAtIndex:indexPath.section] objectForKey:@"Values"] ;
    [cell clearsContextBeforeDrawing];
    UIButton * button = [[[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-103, 5, 20, 21)] autorelease];
    
    button.userInteractionEnabled = TRUE;
    NSString *objname=[[tableDataArray objectAtIndex:indexPath.section ] objectForKey:@"ObjectName"];
    objname = [appDelegate.dataBase getApiNameFromFieldLabel:objname];
    char *field1;
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement1 =[NSMutableString stringWithFormat:@"Select process_id from SFProcess where object_api_name is  '%@' and process_type is 'VIEWRECORD'",objname]; 
    sqlite3_stmt * labelstmt;
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
    
    
    NSArray *tableHeader = [[tableDataArray objectAtIndex:indexPath.section] objectForKey:@"TableHeader"];
    
    if([self.masterView.searchFilterSwitch isOn])
    {   
        if(indexPath.row < [cellArray count])
        {
            for(int j=0;j<[tableHeader count] && j < no_of_fields;j++)
            {
                if(j == 2)
                {
                    labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,170, TableViewResultViewCellHeight)]; 
                }
                else 
                {
                    labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, TableViewResultViewCellHeight)];                     
                }

//                labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, TableViewResultViewCellHeight)]; 
                labelForObjects.backgroundColor = [UIColor clearColor];      
                labelForObjects.font = [UIFont boldSystemFontOfSize:16];  
                if(indexPath.row < [cellArray count])
                {
                    
                    NSString * fieldName = [tableHeader objectAtIndex:j];
                    NSArray * array = [fieldName componentsSeparatedByString:@"."];
                    
                    NSString * type = [appDelegate.dataBase getfieldTypeForApi:[array objectAtIndex:0] fieldName:[array objectAtIndex:1]];
                    
                    if ([type isEqualToString:@"boolean"])
                    {
                        UIImageView *v1;
                        NSString * value = [[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
                        if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"] ) 
                        {
                            v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                            v1.backgroundColor = [UIColor clearColor];
                            v1.frame = CGRectMake((20+j*(640/no_of_fields))-5,10,180, TableViewResultViewCellHeight/2);
                            v1.contentMode = UIViewContentModeCenter;
                            [backgroundView addSubview:v1];
                        }
                        else
                        {  
                            v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                            v1.backgroundColor = [UIColor clearColor];
                            v1.contentMode = UIViewContentModeCenter;
                            v1.frame = CGRectMake((20+j*(640/no_of_fields))-5,10,180, TableViewResultViewCellHeight/2);
                            [backgroundView addSubview:v1];
                        }
                        
                    }
                    else if([type isEqualToString:@"datetime"])
                    {
                        NSString * value = [[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
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
                        labelForObjects.text = value;
                        
                    }
                    else if([type isEqualToString:@"date"])
                    {
                        NSString * value = [[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
                        NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
                        [formatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate * date = [formatter dateFromString:value];
                        [formatter setDateFormat:DATEFORMAT];
                        value = [formatter stringFromDate:date];
                        labelForObjects.text = value;
                    }
                    else
                    {
                        labelForObjects.text=[[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
                    }
                    labelForObjects.textColor = [appDelegate colorForHex:@"2d5d83"];
                    
                }
                labelForObjects.textAlignment = UITextAlignmentLeft;
                if(processAvailbleForRecord)
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] 
                                      forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(accessoryButtonTapped:)  forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    /* [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button-Gray.png"] 
                     forState:UIControlStateNormal];*/
                    [button setBackgroundImage:nil forState:UIControlStateNormal];
                }
                
                
                [labelForObjects setTag:[self getTagForRow:j]];
                [backgroundView addSubview:labelForObjects];
                [labelForObjects release];
            }
        }
        else 
        {
            //save online dict data array in mutable array of mutable dict
            NSDictionary *sectionDict = [tableDataArray objectAtIndex:indexPath.section];
            NSString *sectionObjectId = [sectionDict objectForKey:@"ObjectId"];
            NSMutableArray *onlineDataArray = [onlineDataDict objectForKey:sectionObjectId]; 
            NSDictionary *mDict = [onlineDataArray  objectAtIndex:(indexPath.row - [cellArray count])];
            for(int j=0;j<[tableHeader count] && j < no_of_fields;j++)
            {
                if(j == no_of_fields-1)
                {
                    labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,170, TableViewResultViewCellHeight)]; 
                }
                else
                {
                    labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, TableViewResultViewCellHeight)]; 
                    
                }

//                labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, TableViewResultViewCellHeight)]; 
                labelForObjects.backgroundColor = [UIColor clearColor];      
                labelForObjects.font = [UIFont boldSystemFontOfSize:16]; 
                NSString * fieldName = [tableHeader objectAtIndex:j];
                NSArray * array = [fieldName componentsSeparatedByString:@"."];
                
                NSString * type = [appDelegate.dataBase getfieldTypeForApi:[array objectAtIndex:0] fieldName:[array objectAtIndex:1]];
                
                if ([type isEqualToString:@"boolean"])
                {
                    UIImageView *v1;
                    NSString * value =[mDict objectForKey:[tableHeader objectAtIndex:j]];
                    if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"] ) 
                    {
                        v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                        v1.backgroundColor = [UIColor clearColor];
                        v1.frame = CGRectMake((20+j*(640/no_of_fields))-5,10,180, TableViewResultViewCellHeight/2);
                        v1.contentMode = UIViewContentModeCenter;
                        [backgroundView addSubview:v1];
                    }
                    else
                    {  
                        v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                        v1.backgroundColor = [UIColor clearColor];
                        v1.contentMode = UIViewContentModeCenter;
                        v1.frame = CGRectMake((20+j*(640/no_of_fields))-5,10,180, TableViewResultViewCellHeight/2);
                        [backgroundView addSubview:v1];
                    }
                }
                else if([type isEqualToString:@"datetime"])
                {
                    NSString * value = [mDict objectForKey:[tableHeader objectAtIndex:j]];
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
                    labelForObjects.text = value;
                    
                }
                else if([type isEqualToString:@"date"])
                {
                    NSString * value = [mDict objectForKey:[tableHeader objectAtIndex:j]];
                    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate * date = [formatter dateFromString:value];
                    [formatter setDateFormat:DATEFORMAT];
                    value = [formatter stringFromDate:date];
                    labelForObjects.text = value;
                }

                else
                {
                    labelForObjects.text=[mDict objectForKey:[tableHeader objectAtIndex:j]];
                }
                labelForObjects.textAlignment = UITextAlignmentLeft;
                if(lastSelectedIndexPath && (lastSelectedIndexPath.row == indexPath.row) && (lastSelectedIndexPath.section == indexPath.section))
                    labelForObjects.textColor = [UIColor whiteColor];
                else
                    labelForObjects.textColor = [appDelegate colorForHex:@"2d5d83"];
                [labelForObjects setTag:[self getTagForRow:j]];
                [backgroundView addSubview:labelForObjects];
                [labelForObjects release];
            }
            
            // Online Image Indicator
            UIImage *onlineImage = [UIImage imageNamed:@"OnlineRecord.png"];
            UIImageView *onlineImgView  = [[[UIImageView alloc] initWithImage:onlineImage] autorelease];
            [onlineImgView setFrame:CGRectMake(0, 2,10, TableViewResultViewCellHeight-4)];
            [backgroundView addSubview:onlineImgView];
            /*[button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button-Gray.png"] 
             forState:UIControlStateNormal];*/
            [button setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
    else 
    {
        for(int j=0;j<[tableHeader count] && j < no_of_fields;j++)
        {
            if(j == no_of_fields-1)
            {
                labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,170, TableViewResultViewCellHeight)]; 
            }
            else 
            {
                labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, TableViewResultViewCellHeight)];                 
            }

//            labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, TableViewResultViewCellHeight)]; 
            labelForObjects.backgroundColor = [UIColor clearColor];      
            labelForObjects.font = [UIFont boldSystemFontOfSize:16];  
            if(indexPath.row < [cellArray count])
            {   
                //Display image for Boolean value - checkbox
                NSString * fieldName = [tableHeader objectAtIndex:j];
                NSArray * array = [fieldName componentsSeparatedByString:@"."];
                
                NSString * type = [appDelegate.dataBase getfieldTypeForApi:[array objectAtIndex:0] fieldName:[array objectAtIndex:1]];
                
                if ([type isEqualToString:@"boolean"])
                {
                    UIImageView *v1;
                    NSString * value = [[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
                    if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"] ) 
                    {
                        v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                        v1.backgroundColor = [UIColor clearColor];
                        v1.frame = CGRectMake((20+j*(640/no_of_fields))-5,10,180, TableViewResultViewCellHeight/2);
                        v1.contentMode = UIViewContentModeCenter;
                        [backgroundView addSubview:v1];
                    }
                    else
                    {  
                        v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                        v1.backgroundColor = [UIColor clearColor];
                        v1.contentMode = UIViewContentModeCenter;
                        v1.frame = CGRectMake((20+j*(640/no_of_fields))-5,10,180, TableViewResultViewCellHeight/2);
                        [backgroundView addSubview:v1];
                    }
                    
                }
                else if([type isEqualToString:@"datetime"])
                {
                    NSString * value = [[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
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
                    labelForObjects.text = value;
                    
                }
                else if([type isEqualToString:@"date"])
                {
                    NSString * value = [[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
                    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate * date = [formatter dateFromString:value];
                    [formatter setDateFormat:DATEFORMAT];
                    value = [formatter stringFromDate:date];
                    labelForObjects.text = value;
                }
                else
                {
                    labelForObjects.text=[[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
                }
                labelForObjects.textColor = [appDelegate colorForHex:@"2d5d83"];
            }
            labelForObjects.textAlignment = UITextAlignmentLeft;
            [labelForObjects setTag:[self getTagForRow:j]];
            [backgroundView addSubview:labelForObjects];
            [labelForObjects release];
        }
        if(processAvailbleForRecord)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] 
                              forState:UIControlStateNormal];
            [button addTarget:self action:@selector(accessoryButtonTapped:)  forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            /* [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button-Gray.png"] 
             forState:UIControlStateNormal];*/
            [button setBackgroundImage:nil forState:UIControlStateNormal];
            
        }
    }
    [backgroundView addSubview:button];
    [cell.contentView addSubview:backgroundView];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewResultViewCellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return TableViewResultViewCellHeight*2;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSLog(@"Sections Data = %d",[tableDataArray count]);
    return [tableDataArray count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *fullDataDict;
    NSArray *cellArray = [[tableDataArray objectAtIndex:indexPath.section] objectForKey:@"Values"];
    NSString *objectId = [[tableDataArray objectAtIndex:indexPath.section] objectForKey:@"ObjectId"];
    NSArray *headerArray =[[tableDataArray objectAtIndex:indexPath.section] objectForKey:@"TableHeader"];
    NSString *objectName = [[tableDataArray objectAtIndex:indexPath.section] objectForKey:@"ObjectName"];
    SFMFullResultViewController *resultController = [[SFMFullResultViewController alloc] initWithNibName:@"SFMFullResultViewController" bundle:nil];
    resultController.fullMainDelegate = self;
    resultController.tableHeaderArray = headerArray;
    
    if(lastSelectedIndexPath && (lastSelectedIndexPath.row == indexPath.row) && (lastSelectedIndexPath.section == indexPath.section))
    {
        NSLog(@"Selected the same cell");
    }
    else
    {
        if(lastSelectedIndexPath != nil)
        {
            UITableViewCell *lastSelectedCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
            UIImageView *bgView = (UIImageView *)[lastSelectedCell viewWithTag:backgroundImage];
            [bgView setImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]];            
            // change the textcolor of lastindex 
            UILabel *txtFieldLabel1 = (UILabel *)[lastSelectedCell viewWithTag:textLabel1];
            UILabel *txtFieldLabel2 = (UILabel *)[lastSelectedCell viewWithTag:textLabel2];
            UILabel *txtFieldLabel3 = (UILabel *)[lastSelectedCell viewWithTag:textLabel3];
            
            [txtFieldLabel1 setTextColor:[appDelegate colorForHex:@"2d5d83"]];
            [txtFieldLabel2 setTextColor:[appDelegate colorForHex:@"2d5d83"]];
            [txtFieldLabel3 setTextColor:[appDelegate colorForHex:@"2d5d83"]];             
            
//            NSLog(@"Tag1 = %d",[txtFieldLabel1 tag]);
//            NSLog(@"Tag2 = %d",[txtFieldLabel2 tag]);
//            NSLog(@"Tag3 = %d",[txtFieldLabel3 tag]);

        }
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *bgView = (UIImageView *)[selectedCell viewWithTag:backgroundImage];
        [bgView setImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip-Selected.png"]];        
        // change the current cell  text color
        lastSelectedIndexPath = [indexPath retain];
        UILabel *txtFieldLabel1 = (UILabel *)[selectedCell viewWithTag:textLabel1];
        UILabel *txtFieldLabel2 = (UILabel *)[selectedCell viewWithTag:textLabel2];
        UILabel *txtFieldLabel3 = (UILabel *)[selectedCell viewWithTag:textLabel3];

//        NSLog(@"Tag1 = %d",[txtFieldLabel1 tag]);
//        NSLog(@"Tag2 = %d",[txtFieldLabel2 tag]);
//        NSLog(@"Tag3 = %d",[txtFieldLabel3 tag]);
        
        [txtFieldLabel1 setTextColor:[UIColor whiteColor]];
        [txtFieldLabel2 setTextColor:[UIColor whiteColor]];
        [txtFieldLabel3 setTextColor:[UIColor whiteColor]];             

    }
    if([self.masterView.searchFilterSwitch isOn])
    {
        if(indexPath.row < [cellArray count])
        {
            fullDataDict = [cellArray objectAtIndex:indexPath.row]; 
            resultController.isOnlineRecord = NO;
            resultController.objectName = objectName;
        }
        else 
        {
            int onlineIndex =  indexPath.row - [cellArray count];
            NSDictionary *rowData = [[onlineDataDict objectForKey:objectId] objectAtIndex:onlineIndex];
            fullDataDict = rowData;
            resultController.isOnlineRecord = YES;
        }
    }
    else 
    {
        fullDataDict = [cellArray objectAtIndex:indexPath.row];
        resultController.isOnlineRecord = NO;
        resultController.objectName = objectName;
//        NSLog(@"Data = %@",fullDataDict);
    }
    
     resultController.modalPresentationStyle = UIModalPresentationFormSheet;
     resultController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;    
     resultController.data = fullDataDict;
     [self.mainView presentModalViewController:resultController animated:YES];
     [resultController release];
}

#pragma mark - Custom Methods
- (int) getTagForRow:(int) row
{
    int tag = textLabel1;
    switch (row) {
        case 0:
            tag = textLabel1;
            break;
        case 1:
            tag = textLabel2;
            break;
        case 2:
            tag = textLabel3;
            break;                        
        default:
            break;
    }
    return tag;
}
- (void) DismissViewController: (id) sender
{
//    NSLog(@"Dismiss SFM Result Detail View Controller");
    if([activityIndicator isAnimating])
        [activityIndicator stopAnimating];
    [splitViewDelegate DismissSplitViewController];
}
- (void) createTable
{
    if(detailTable)
        [detailTable release];
    detailTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 710, 700)];
    detailTable.delegate = self;
    detailTable.dataSource = self;
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
    bgImage.frame = CGRectMake(0, -12, bgImage.frame.size.width, bgImage.frame.size.height+12);
    [self.view addSubview:bgImage];
    self.detailTable.backgroundView = bgImage;
    [bgImage release];
    if(lastSelectedIndexPath)
        [lastSelectedIndexPath release];
    lastSelectedIndexPath = nil;
    [detailTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:detailTable];
}
- (NSArray *) constructTableHeader : (NSArray *)data
{
    NSMutableArray *header = [[NSMutableArray alloc] init];
    
    for(NSDictionary *obj in data)
    {
        [header addObject:[NSString stringWithFormat:@"%@.%@",[obj objectForKey:@"SVMXC__Object_Name2__c"],[obj objectForKey:@"SVMXC__Field_Name__c"]]];
    }
    return [header autorelease];

}
- (NSMutableArray *)getResultsForObject:(NSString *)object withConfigData:(NSDictionary *)dataForObject
{
    int count = 0;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *searchableArray = [dataForObject objectForKey:@"SearchableFields"];
    NSArray *displayArray = [dataForObject objectForKey:@"DisplayFields"];
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    object = [appDelegate.dataBase getApiNameFromFieldLabel:object];
    NSMutableDictionary *uiControls=[[NSMutableDictionary alloc]init];
    NSString *searchString = self.masterView.searchString.text;
    if(searchString == nil)
        searchString = @"";
    [uiControls setObject:self.masterView.searchLimitString.text forKey:@"searchLimitString"];
    [uiControls setObject:self.masterView.searchCriteria.text forKey:@"searchCriteria"];
    [uiControls setObject:self.masterView.searchString.text forKey:@"searchString"];
    [dataForObject setValue:uiControls forKey:@"uiControls"];
    NSMutableArray *result = [[appDelegate.dataBase getResults:object withConfigData:dataForObject] retain];
    for(NSDictionary *dict in result)
    {   
        count++;
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        for(NSDictionary *displaydict in displayArray)
        {
            NSString *key = [NSString stringWithFormat:@"%@.%@",[displaydict objectForKey:@"SVMXC__Object_Name2__c"], [displaydict objectForKey:@"SVMXC__Field_Name__c"]];
            [resultDict setObject:[dict objectForKey:key] forKey:key];
            [resultDict setObject:[dict objectForKey:@"Id"] forKey:@"Id"]; 
            [resultDict setObject:[dict objectForKey:@"local_id"] forKey:@"local_id"]; 
        }
        [results addObject:resultDict];
        if(count == [[[self.masterView searchLimitString] text] intValue])
            break;
    }
    [result release];
    return [results autorelease];
}
- (void) updateResultArray:(int) index
{
    if(tableDataArray)
        [tableDataArray release];
    if(index == -1)
        tableDataArray = [resultArray retain];
    else
        tableDataArray = [[NSArray arrayWithObjects:[resultArray objectAtIndex:index],nil] retain];
    [detailTable reloadData];
}
- (void) showObjects:(NSArray *)sections 
       forAllObjects:(BOOL) makeOnlineSearch
{
    if(resultArray)
        [resultArray release];
    resultArray = [[NSMutableArray alloc] init];
    for(NSDictionary *objectDetails in sections)
    {
        NSString *objectName = [objectDetails objectForKey:@"ObjectName"];
        NSString *ObjectDescription=[objectDetails objectForKey:@"ObjectDescription"];
        NSString *objectId = [objectDetails objectForKey:@"ObjectId"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        //NSArray     *dataForObject  = [[self getConfigDataforObject:object] retain];
        NSArray    *tableHeader    = [[self constructTableHeader:[objectDetails objectForKey:@"DisplayFields"]] retain];
        //[dict setObject:dataForObject forKey:@"ConfigData"];
        //Get the values array and add it to dict
        NSMutableArray *resultValues = [self getResultsForObject:objectName withConfigData:objectDetails];

        NSMutableArray *array = [[NSMutableArray alloc] init];
        [dict setObject:array forKey:@"OnlineResults"];
        [array release];
        [dict setObject:resultValues forKey:@"Values"];
        [dict setObject:tableHeader forKey:@"TableHeader"];
        [dict setObject:objectName forKey:@"ObjectName"];
        [dict setObject:ObjectDescription forKey:@"ObjectDescription"];
        [dict setObject:objectId forKey:@"ObjectId"];
        [resultArray addObject:dict];
        //[dataForObject release];   
        [tableHeader release];
        [dict release];          
    }
    if([self.masterView.searchFilterSwitch isOn] && makeOnlineSearch)
    {
        if([resultArray count] == [[[self.masterView searchLimitString] text] intValue])
        {
            NSLog(@"Offline DB has more or equal number records specified by the limit");
            return;
        }
        //Make a WebService Call 
         appDelegate.sfmSearchTableArray = resultArray;
        NSMutableArray *searchResultData = [[NSMutableArray alloc] init];
        
        NSMutableArray *objectList = [[NSMutableArray alloc] init];
        NSMutableArray *objectResultList = [[NSMutableArray alloc] init];
        for(int i=0;i<[resultArray count]; i++)
        {
            [objectList addObject:[[resultArray objectAtIndex:i] objectForKey:@"ObjectId"]];
        }
        /*
        for(int j=0;j<[resultArray count]; j++)
        {
            NSArray *objectResultsArray = [[resultArray objectAtIndex:j] objectForKey:@"Values"];
            NSMutableArray *objResultArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dict in objectResultsArray)
            {
                NSString *recordId = [dict objectForKey:@"Id"];                
                if(!recordId)
                    recordId = @"";
                [objResultArray addObject:recordId];                                       
            }
            [objectResultList addObject:objResultArray];
            [objResultArray release];
        }
        */
        
        NSString *criteria = self.masterView.searchCriteria.text;
        NSString *userFilterString = self.masterView.searchString.text;
        [ searchResultData addObject:self.masterView.processId];
        [ searchResultData addObject:objectList];
        [ searchResultData addObject:self.masterView.searchLimitString.text];
        //[ searchResultData addObject:objectResultList];
        [ searchResultData addObject:criteria];
        [ searchResultData addObject:userFilterString];
        
        [activityIndicator startAnimating];
        if(appDelegate==nil)
            appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate goOnlineIfRequired];
        appDelegate.wsInterface.didOpComplete = FALSE;
        [appDelegate.wsInterface dataSyncWithEventName:@"SFM_SEARCH" eventType:@"SEARCH_RESULTS" values:searchResultData]; 

        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
        {                
            if (appDelegate.wsInterface.didOpComplete == TRUE)
                break;   
            if (!appDelegate.isInternetConnectionAvailable)
            {
                break;
            }
            if (appDelegate.connection_error)
            {
                break;
            }
            NSLog(@"Retreiving Online Reccords");
        }
        [activityIndicator stopAnimating];
        //[objectResultList release];
        //[objectList release];
        [searchResultData release];
        if(onlineDataDict)
            [onlineDataDict release];
        onlineDataDict = [[NSMutableDictionary alloc] init];
        for(NSDictionary *dict in appDelegate.onlineDataArray)
        {
            NSString *objectID = [dict objectForKey:@"SearchObjectId"];
            NSMutableArray *objectArray = [[onlineDataDict objectForKey:objectID] retain];
            if(!objectArray)
                objectArray = [[NSMutableArray alloc] init];
            NSArray *offlineRecords = [self getOfflineRecordsForObjectID:objectID];
            if(([objectArray count] + [offlineRecords count]) == [[[self.masterView searchLimitString] text] intValue])
            {
                break;
            }
                        
            if([offlineRecords count] == 0)
               [objectArray addObject:dict];
            else
            {
                if(![self isRecordPresentInOfflineResults:offlineRecords record:[dict objectForKey:@"Id"]])
                    [objectArray addObject:dict];
            }
            [onlineDataDict setObject:objectArray forKey:objectID];
            [objectArray release];
        }
    }


	//Enhancement change for showing the number of records.
	[mainView.resultmasterView reloadTableWithOnlineData:onlineDataDict];
}
- (NSArray *) getOfflineRecordsForObjectID:(NSString *) objectID
{
    for(NSDictionary *dict in resultArray)
    {
        NSString *objId = [dict objectForKey:@"ObjectId"];
        if([objId isEqualToString:objectID])
        {
            return [dict objectForKey:@"Values"];
        }
    }
    return nil;
}
- (BOOL) isRecordPresentInOfflineResults:(NSArray *) offlineRecords record:(NSString *) onlineRecordId
{
    for(NSDictionary *dict in offlineRecords)
    {
        NSString *offlineRecordId = [dict objectForKey:@"Id"];
        if([onlineRecordId isEqualToString:offlineRecordId])
            return YES;
    }
    return NO;
}
- (void) accessoryButtonTapped:(id)sender
{
    UITableViewCell *ownerCell = (UITableViewCell*)[[[sender superview] superview] superview];
    NSIndexPath *ownerCellIndexPath;
    if (ownerCell != nil)
    {
        /* Now we will retrieve the index path of the cell which contains the section and the row of the cell */
        ownerCellIndexPath = [self.detailTable indexPathForCell:ownerCell];
//        NSLog(@"Accessory in index path is tapped. Index path = %d", ownerCellIndexPath.row);
    }
       if(lastSelectedIndexPath != nil)
    {
        UITableViewCell *lastSelectedCell = [detailTable cellForRowAtIndexPath:lastSelectedIndexPath];
        UIImageView *bgView = (UIImageView *)[lastSelectedCell viewWithTag:backgroundImage];
        [bgView setImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]];            
        // change the textcolor of lastindex 
        UILabel *txtFieldLabel1 = (UILabel *)[lastSelectedCell viewWithTag:textLabel1];
        UILabel *txtFieldLabel2 = (UILabel *)[lastSelectedCell viewWithTag:textLabel2];
        UILabel *txtFieldLabel3 = (UILabel *)[lastSelectedCell viewWithTag:textLabel3];
        
        [txtFieldLabel1 setTextColor:[appDelegate colorForHex:@"2d5d83"]];
        [txtFieldLabel2 setTextColor:[appDelegate colorForHex:@"2d5d83"]];
        [txtFieldLabel3 setTextColor:[appDelegate colorForHex:@"2d5d83"]];             
    }
    lastSelectedIndexPath = [ownerCellIndexPath retain];

    UIImageView *bgView = (UIImageView *)[ownerCell viewWithTag:backgroundImage];
    [bgView setImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip-Selected.png"]];
    NSDictionary *dict = [tableDataArray objectAtIndex:ownerCellIndexPath.section];
    NSDictionary *dataDict = [[dict objectForKey:@"Values"] objectAtIndex:ownerCellIndexPath.row]; 
    NSString *objectName = [appDelegate.dataBase getApiNameFromFieldLabel:[dict objectForKey:@"ObjectName"]];
     char *field1;
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    NSString *recordId = [dataDict objectForKey:@"Id"];
    queryStatement1 = [NSMutableString stringWithFormat:@"Select local_id FROM '%@' where Id = '%@'",objectName,recordId];    
    if(appDelegate.sfmPageController)
        [appDelegate.sfmPageController release];
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];

    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatement1 UTF8String];
    
    NSString *localId = @"";
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
//            NSLog(@"%s",field1);
            if(field1)
                localId = [NSString stringWithFormat:@"%s", field1];
            else
                localId = @"";
        }
    }

    NSString * queryStatement2 = [NSMutableString stringWithFormat:@"Select process_id FROM SFProcess where process_type = 'VIEWRECORD' and object_api_name = '%@'",objectName];   
    sqlite3_stmt * labelstmt2;
    const char *selectStatement2 = [queryStatement2 UTF8String];
    
    NSString *processId = @"";
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement2,-1, &labelstmt2, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt2) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt2,0);
//            NSLog(@"%s",field1);
            if(field1)
                processId = [NSString stringWithFormat:@"%s", field1];
            else
                processId = @"";
        }
    }
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.objectName = objectName;
    appDelegate.sfmPageController.topLevelId = nil;
    appDelegate.sfmPageController.recordId = localId;    
    //[appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:appDelegate.sfmPageController animated:YES];
    [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
    [appDelegate.sfmPageController release];
    synchronized_sqlite3_finalize(labelstmt);
    synchronized_sqlite3_finalize(labelstmt2);


}
#pragma mark - SFM Full Result View Delegate
- (void) DismissSplitViewControllerByLaunchingSFMProcess
{
    [resultViewController dismissModalViewControllerAnimated:YES];
}
- (void)tapRecognized:(id)sender
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

