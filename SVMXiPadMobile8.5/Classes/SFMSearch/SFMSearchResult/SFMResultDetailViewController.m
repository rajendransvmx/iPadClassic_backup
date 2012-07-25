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
@property (nonatomic, retain) NSMutableArray          *tableDataArray;
@end

@implementation SFMResultDetailViewController
@synthesize configData;
@synthesize tableDataArray;
@synthesize detailTable;
@synthesize detailTableArray;
@synthesize sfmConfigName;
@synthesize splitViewDelegate;
@synthesize masterView;
@synthesize activityIndicator;
@synthesize onlineDataDict;
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
    
    //Back Button
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
    
    titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SRCH_RESULTS];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLabel;
    [self createTable];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void) dealloc
{
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
    sectionName.text=[[tableDataArray objectAtIndex:section ] objectForKey:@"ObjectName"];
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
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[formated_header substringFromIndex:range.location+1]]);
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[formated_header substringToIndex:range.location]]);
            apiHeaderName=[formated_header substringFromIndex:range.location+1];
            object_name =[formated_header substringToIndex:range.location];
            formated_header_objectName=[appDelegate.dataBase getLabelFromApiName:apiHeaderName
                                                      objectName:[appDelegate.dataBase getApiNameFromFieldLabel:object_name]];
        }
        //label.text=[NSString stringWithFormat:@"%@.%@",object_name,formated_header_objectName];//[[[tableDataArray objectAtIndex:section ] objectForKey:@"TableHeader"]objectAtIndex:i];
        label.text=formated_header_objectName;//
        label.textAlignment = UITextAlignmentLeft;
        label.textColor=[UIColor whiteColor];
        label.userInteractionEnabled = TRUE;
        UITapGestureRecognizer * tapObject = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [label addGestureRecognizer:tapObject];
        [tapObject release];

        [view addSubview:label]; 
    }
    //Create header view and add label as a subview
    return view;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *cellArray = [[tableDataArray objectAtIndex:section] objectForKey:@"Values"];
    if([self.masterView.searchFilterSwitch isOn])
    {
       // NSArray *onlineCellArray = [[tableDataArray objectAtIndex:section] objectForKey:@"OnlineResults"];
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
    UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
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
//    UIButton * button = [[[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-110, 0, TableViewResultViewCellHeight, TableViewResultViewCellHeight)] autorelease];
    UIButton * button = [[[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-103, 5, 20, 21)] autorelease];

    button.userInteractionEnabled = TRUE;
    NSString *objname=[[tableDataArray objectAtIndex:indexPath.section ] objectForKey:@"ObjectName"];
    NSLog(@"objname =%@",objname);
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
    }
    synchronized_sqlite3_finalize(labelstmt);

    NSArray *tableHeader = [[tableDataArray objectAtIndex:indexPath.section] objectForKey:@"TableHeader"];
    
    if([self.masterView.searchFilterSwitch isOn])
    {   
        if(indexPath.row < [cellArray count])
        {
            for(int j=0;j<[tableHeader count] && j < no_of_fields;j++)
            {
                labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, TableViewResultViewCellHeight)]; 
                labelForObjects.backgroundColor = [UIColor clearColor];      
                labelForObjects.font = [UIFont boldSystemFontOfSize:16];  
                if(indexPath.row < [cellArray count])
                {
                    labelForObjects.text=[[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
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
                    [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button-Gray.png"] 
                                      forState:UIControlStateNormal];
                }

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
                labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, TableViewResultViewCellHeight)]; 
                labelForObjects.backgroundColor = [UIColor clearColor];      
                labelForObjects.font = [UIFont boldSystemFontOfSize:16];  
                labelForObjects.text=[mDict objectForKey:[tableHeader objectAtIndex:j]];
                labelForObjects.textAlignment = UITextAlignmentLeft;
                labelForObjects.textColor = [appDelegate colorForHex:@"2d5d83"];
                [backgroundView addSubview:labelForObjects];
                [labelForObjects release];
            }

            // Online Image Indicator
            UIImage *onlineImage = [UIImage imageNamed:@"OnlineRecord.png"];
            UIImageView *onlineImgView  = [[[UIImageView alloc] initWithImage:onlineImage] autorelease];
            [onlineImgView setFrame:CGRectMake(0, 2,10, TableViewResultViewCellHeight-4)];
            [backgroundView addSubview:onlineImgView];
            [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button-Gray.png"] 
                              forState:UIControlStateNormal];
        }
    }
    else 
    {
        for(int j=0;j<[tableHeader count] && j < no_of_fields;j++)
        {
            labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, TableViewResultViewCellHeight)]; 
            labelForObjects.backgroundColor = [UIColor clearColor];      
            labelForObjects.font = [UIFont boldSystemFontOfSize:16];  
            if(indexPath.row < [cellArray count])
            {   labelForObjects.text=[[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
                labelForObjects.textColor = [appDelegate colorForHex:@"2d5d83"];
            }
            labelForObjects.textAlignment = UITextAlignmentLeft;
            
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
            [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button-Gray.png"] 
                              forState:UIControlStateNormal];

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
    NSLog(@"Sections Data = %d",[tableDataArray count]);
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
        NSLog(@"Data = %@",fullDataDict);
    }
    
     resultController.modalPresentationStyle = UIModalPresentationFormSheet;
     resultController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;    
     resultController.data = fullDataDict;
     [self presentModalViewController:resultController animated:YES];
     [resultController release];
}

#pragma mark - Custom Methods
- (void) DismissViewController: (id) sender
{
    NSLog(@"Dismiss SFM Result Detail View Controller");
    if([activityIndicator isAnimating])
        [activityIndicator stopAnimating];
    [splitViewDelegate DismissSplitViewController];
}
/*
- (NSDictionary *) getResultPlist:(NSString *)objectName withConfiguration:(NSArray *)config
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if([objectName isEqualToString:@"SVMXC__Service_Order__c"])
    {
        NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
        queryStatement1 = [NSMutableString stringWithFormat:@"Select Name,SVMXC__Priority__c,SVMXC__Product__c,SVMXC__Order_Status__c,SVMXC__Contact__c FROM SVMXC__Service_Order__c "];
        
        NSArray *tableFields = [[NSArray alloc] initWithObjects:@"Name",@"SVMXC__Priority__c",@"SVMXC__Product__c",@"SVMXC__Order_Status__c",@"SVMXC__Contact__c", nil];
        NSMutableArray *titlesArray = [[NSMutableArray alloc] init];
        NSMutableArray *detailFieldsArray = [[NSMutableArray alloc] init];
        
        sqlite3_stmt * labelstmt;
        const char *selectStatement = [queryStatement1 UTF8String];
        if(appDelegate==nil)
        {
            appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];    
        }
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW){
                NSMutableArray *titles = [[NSMutableArray alloc] init];
                NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
                char *field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                if(field1==NULL)
                    field1="";
                //[detailsaddObject:[NSString stringWithFormat:@"%s",field1]];
                [details setObject:[NSString stringWithFormat:@"%s",field1] forKey:[tableFields objectAtIndex:0]];
                [titles addObject:[NSString stringWithFormat:@"%s",field1]];
                char *field2 = (char *) synchronized_sqlite3_column_text(labelstmt,1);
                if(field2==NULL)
                    field2="";
                //[details addObject:[NSString stringWithFormat:@"%s",field2]];
                [details setObject:[NSString stringWithFormat:@"%s",field2] forKey:[tableFields objectAtIndex:1]];
                [titles addObject:[NSString stringWithFormat:@"%s",field2]];
                char *field3 = (char *) synchronized_sqlite3_column_text(labelstmt,2);
                if(field3==NULL)
                    field3="";
                //[details addObject:[NSString stringWithFormat:@"%s",field3]];
                [details setObject:[NSString stringWithFormat:@"%s",field3] forKey:[tableFields objectAtIndex:2]];
                [titles addObject:[NSString stringWithFormat:@"%s",field3]];
                char *field4 = (char *) synchronized_sqlite3_column_text(labelstmt,3);
                if(field4==NULL)
                    field4="";
                //[details addObject:[NSString stringWithFormat:@"%s",field4]];
                [details setObject:[NSString stringWithFormat:@"%s",field4] forKey:[tableFields objectAtIndex:3]];
                char *field5 = (char *) synchronized_sqlite3_column_text(labelstmt,4);
                if(field5==NULL)
                    field5="";
                //[details addObject:[NSString stringWithFormat:@"%s",field5]];
                [details setObject:[NSString stringWithFormat:@"%s",field5] forKey:[tableFields objectAtIndex:4]];
                NSLog(@"value :_ %s",field1);
                NSLog(@"value :_ %s",field2);
                NSLog(@"value :_ %s",field3);
                NSLog(@"value :_ %s",field4);
                NSLog(@"value :_ %s",field5);
                [titlesArray addObject:titles];
                [detailFieldsArray addObject:details];
                [titles release];
            }
        }else{
            NSLog(@"Failed to fetch the records from database");
        }    
        [dict setObject:detailFieldsArray forKey:@"DetailCellData"];
        [dict setObject:titlesArray forKey:@"Titles"];
        [tableFields release];
    }
    else
    {
        NSBundle *MainBundle = [NSBundle mainBundle];    
        NSString *dataBundlePath = [MainBundle pathForResource:@"Result" ofType:@"plist"];
        NSMutableDictionary *_dictionaries =  [[NSMutableDictionary alloc] initWithContentsOfFile:dataBundlePath];
        NSArray *objectResult = [[[_dictionaries objectForKey:@"Results"] objectForKey:objectName] retain];
        [_dictionaries release];
            
        BOOL found = NO;
        NSMutableArray *_cellTitleArray = [[NSMutableArray alloc] init];
        NSMutableArray *_detailDataArray = [[NSMutableArray alloc] init];
        NSMutableArray *_displayFields = [[NSMutableArray alloc] init];
        NSMutableArray *_searchableFields = [[NSMutableArray alloc] init];
        for(NSDictionary *subConfig in config)
        {
            if([[subConfig objectForKey:@"DisplayField"] boolValue])
                [_displayFields addObject:[subConfig objectForKey:@"Name"]];
            if([[subConfig objectForKey:@"Searchable"] boolValue])
                [_searchableFields addObject:[subConfig objectForKey:@"Name"]];
        }
        for(NSDictionary *obj in objectResult)
        {
            found = NO;
            found = [self isRecordFound:obj withSearchObjects:_searchableFields]; //Pass searchable Fields array
            if(found)
            {
                NSMutableArray *cellTitle = [[NSMutableArray alloc] init];
                for(int i=0;i<[_displayFields count];i++)
                {
                    NSString *fieldKey = [_displayFields objectAtIndex:i];
                    [cellTitle addObject:[obj objectForKey:fieldKey]];
                }
                [_cellTitleArray addObject:cellTitle];
                [cellTitle release];
                [_detailDataArray addObject:obj];
            }
        }
        [dict setObject:_detailDataArray forKey:@"DetailCellData"];
        [dict setObject:_cellTitleArray forKey:@"Titles"];
        [_detailDataArray release];
        [_cellTitleArray release];
        [_displayFields release];
        [_searchableFields release];
    }
    NSLog(@"Dict = %@",dict);
    return [dict autorelease];
}
 */
- (BOOL) isRecordFound:(NSString *)searchField
{
    NSString *searchString = self.masterView.searchString.text;
    if([searchString length] == 0)
        return YES;
    BOOL result = NO;
    //get all the searchable fields
    NSLog(@"Search String = %@",searchString);
    searchField = [searchField lowercaseString];
    searchString = [searchString lowercaseString];
    NSLog(@"Search String = :%@:",self.masterView.searchCriteria.text);
    NSLog(@"Tag = :%@:",[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_STARTS_WITH]);
    if([self.masterView.searchCriteria.text isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_CONTAINS]])
    {
        if([searchField rangeOfString:searchString].length > 0)
        {
            result = YES;
        }
    }
    if([self.masterView.searchCriteria.text isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_EXTACT_MATCH]])
    {
        if([searchField isEqualToString:searchString])
        {
            result = YES;
        }
    }
    if([self.masterView.searchCriteria.text isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_ENDS_WITH]])
    {
        if([searchField hasSuffix:searchString])
        {
            result = YES;
        }
    }
    if([self.masterView.searchCriteria.text isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_STARTS_WITH]])
    {
        if([searchField hasPrefix:searchString])
        {
            result = YES;
        }
    }
    return result;
}
- (void) readDataBasePlist
{
    NSBundle *MainBundle = [NSBundle mainBundle];    
    NSString *dataBundlePath = [MainBundle pathForResource:@"DataBase" ofType:@"plist"];
    //NSLog(@"Path = %@",dataBundlePath);
    NSMutableDictionary *_dictionaries =  [[NSMutableDictionary alloc] initWithContentsOfFile:dataBundlePath];
    NSArray *dbArray = [_dictionaries  objectForKey:@"SFM Search"];
    NSLog(@"Config Name = %@",sfmConfigName);
    if(configData)
        [configData release];
    configData = [[NSMutableArray alloc] init];
    for(NSDictionary *object in dbArray)
    {
        if([[object objectForKey:@"SFM Search Configuration"] isEqualToString:sfmConfigName])
        {
            NSLog(@"SFM Config Objects = %@",object);
            [configData addObjectsFromArray:[object objectForKey:@"Objects"]];            
            break;
        }
    }
    //NSLog(@"Config Data in Plist = %@",configArray);
    [_dictionaries release];
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
    NSLog(@"Config Data = %@",dataForObject);
    NSLog(@"Object Name = %@",object);
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray *searchableArray = [dataForObject objectForKey:@"SearchableFields"];
    NSArray *displayArray = [dataForObject objectForKey:@"DisplayFields"];
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    object = [appDelegate.dataBase getApiNameFromFieldLabel:object];

    NSMutableArray *result = [[appDelegate.dataBase getResults:object withConfigData:dataForObject] retain];
    for(NSDictionary *dict in result)
    {   
        BOOL found = NO;
        for(NSDictionary *searchableDict in searchableArray)
        {
            NSString *value =[dict objectForKey:[NSString stringWithFormat:@"%@.%@",[searchableDict objectForKey:      @"SVMXC__Object_Name2__c"],[searchableDict objectForKey:@"SVMXC__Field_Name__c"]]];
            if([self isRecordFound:value])
            {
                found =YES;
                break;
            }
        }
        if(found)
        {
            NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
            for(NSDictionary *displaydict in displayArray)
            {
                NSString *key = [NSString stringWithFormat:@"%@.%@",[displaydict objectForKey:@"SVMXC__Object_Name2__c"], [displaydict objectForKey:@"SVMXC__Field_Name__c"]];
                [resultDict setObject:[dict objectForKey:key] forKey:key];
                [resultDict setObject:[dict objectForKey:@"Id"] forKey:@"Id"]; 
                [resultDict setObject:[dict objectForKey:@"local_id"] forKey:@"local_id"]; 
            }
            [results addObject:resultDict];
        }
    }
    [result release];
    return [results autorelease];
}
- (void) showObjects:(NSArray *)sections forAllObjects:(BOOL) makeOnlineSearch
{
    NSLog(@"SFM Config = %@",sfmConfigName);
    NSLog(@"Table Array = %@",sections);
    
    if(tableDataArray)
        [tableDataArray release];
    tableDataArray = [[NSMutableArray alloc] init];
    /*
    if(!configData)
        [self readDataBasePlist];
     */
    for(NSDictionary *objectDetails in sections)
    {
        NSString *objectName = [objectDetails objectForKey:@"ObjectName"];

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
        [dict setObject:objectId forKey:@"ObjectId"];
        [tableDataArray addObject:dict];
        //[dataForObject release];   
        [tableHeader release];
        [dict release];          
    }
    if([self.masterView.searchFilterSwitch isOn] && makeOnlineSearch)
    {
        //Make a WebService Call 
        NSLog(@"Process ID = %@",self.masterView.processId);
        NSLog(@"Table Data = %@",tableDataArray);
         appDelegate.sfmSearchTableArray = tableDataArray;
        NSMutableArray *searchResultData = [[NSMutableArray alloc] init];
        
        NSMutableArray *objectList = [[NSMutableArray alloc] init];
        NSMutableArray *objectResultList = [[NSMutableArray alloc] init];
        for(int i=0;i<[tableDataArray count]; i++)
        {
            [objectList addObject:[[tableDataArray objectAtIndex:i] objectForKey:@"ObjectId"]];
        }
        for(int j=0;j<[tableDataArray count]; j++)
        {
            NSArray *objectResultsArray = [[tableDataArray objectAtIndex:j] objectForKey:@"Values"];
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
        
        
        NSString *criteria = self.masterView.searchCriteria.text;
        NSString *userFilterString = self.masterView.searchString.text;
        NSLog(@"User Filter String = %@",userFilterString);
        [ searchResultData addObject:self.masterView.processId];
        [ searchResultData addObject:objectList];
        [ searchResultData addObject:objectResultList];
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
        [objectResultList release];
        [objectList release];
        [searchResultData release];
        NSLog(@"Online Data = %@",appDelegate.onlineDataArray);
        if(onlineDataDict)
            [onlineDataDict release];
        onlineDataDict = [[NSMutableDictionary alloc] init];
        for(NSDictionary *dict in appDelegate.onlineDataArray)
        {
            NSString *objectID = [dict objectForKey:@"SearchObjectId"];
            NSMutableArray *objectArray = [[onlineDataDict objectForKey:objectID] retain];
            if(!objectArray)
                objectArray = [[NSMutableArray alloc] init];
            [objectArray addObject:dict];
            [onlineDataDict setObject:objectArray forKey:objectID];
            [objectArray release];
        }
        NSLog(@"Online Dict = %@",onlineDataDict);
    }

    NSLog(@"Table Data = %@",tableDataArray);
    [detailTable reloadData];
}
- (void) accessoryButtonTapped:(id)sender
{
    UITableViewCell *ownerCell = (UITableViewCell*)[[[sender superview] superview] superview];
    NSIndexPath *ownerCellIndexPath;
    if (ownerCell != nil)
    {
        /* Now we will retrieve the index path of the cell which contains the section and the row of the cell */
        ownerCellIndexPath = [self.detailTable indexPathForCell:ownerCell];
        NSLog(@"Accessory in index path is tapped. Index path = %d", ownerCellIndexPath.row);
    }
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
            NSLog(@"%s",field1);
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
            NSLog(@"%s",field1);
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

