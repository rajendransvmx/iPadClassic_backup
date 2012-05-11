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
#define TableViewResultViewCellHeight 50
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
@synthesize onlineDataArray;
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
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 31)] autorelease];
       [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(DismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    UIButton * helpButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 31)] autorelease];
    [helpButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    [helpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem * addButton = [[[UIBarButtonItem alloc] initWithCustomView:helpButton] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
     appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
  
    bgImage.frame = CGRectMake(0, -12, bgImage.frame.size.width, bgImage.frame.size.height+12);
     [self.view addSubview:bgImage];
    self.detailTable.backgroundView = bgImage;
    [bgImage release];
     
      // Set title for detail
    UILabel * titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)] autorelease];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    titleLabel.text = @"SFM Search Result";
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
    [onlineDataArray release];
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
       int no_of_fields=3;
    view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 100)] autorelease];
    UIImageView * imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_section_header_bg.png"]] autorelease];
    imageView.frame = CGRectMake(0, 48, tableView.frame.size.width, 48);
    
    UILabel * sectionName = [[[UILabel alloc] init] autorelease];
    sectionName.frame = CGRectMake(0, 0, tableView.frame.size.width, 48);
    sectionName.backgroundColor = [UIColor lightGrayColor];  
    sectionName.font = [UIFont boldSystemFontOfSize:18];     
    sectionName.text=[[tableDataArray objectAtIndex:section ] objectForKey:@"ObjectName"];
    sectionName.textColor=[appDelegate colorForHex:@"2d5d83"];
    
    [view addSubview:imageView];
    [view addSubview:sectionName];
    for(int i=0;i<[[[tableDataArray objectAtIndex:section ] objectForKey:@"TableHeader"]count] && i <no_of_fields;i++)
    {
        label = [[[UILabel alloc] init] autorelease];
         if(no_of_fields)
        label.frame = CGRectMake((5+i*(640/no_of_fields)), 48,210, 48);
        label.backgroundColor = [UIColor clearColor];      
        label.font = [UIFont boldSystemFontOfSize:18];  
        label.text=[[[tableDataArray objectAtIndex:section ] objectForKey:@"TableHeader"]objectAtIndex:i];
        label.textAlignment = UITextAlignmentLeft;
        label.textColor=[appDelegate colorForHex:@"2d5d83"];
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
        for(NSDictionary *dict in onlineDataArray)
        {
            NSString *objectId = [dict objectForKey:@"SearchObjectId"];
            if([objectId isEqualToString:sectionObjectId])
                onlineCount++;
        }
        return [cellArray count] + onlineCount;
    }
    else {
        return [cellArray count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"identifier";
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    UILabel *labelForObjects;
    int no_of_fields=3;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    else
    {
        NSArray *subLabelViews = [cell subviews];
        for(UIView *txtView in subLabelViews)
        {
            [txtView removeFromSuperview];
        }
    }
    NSArray *cellArray = [[tableDataArray objectAtIndex:indexPath.section] objectForKey:@"Values"] ;
    [cell clearsContextBeforeDrawing];
    UIButton * button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
    NSString *objname=[[tableDataArray objectAtIndex:indexPath.section ] objectForKey:@"ObjectName"];
    NSLog(@"objname =%@",objname);
    char *field1;
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement1 =[NSMutableString stringWithFormat:@"Select process_id from SFProcess where object_api_name is  '%@' and process_type is 'VIEWRECORD'",objname]; 
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatement1 UTF8String];
        
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW){
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);           
            appDelegate.sfmPageController.processId=[NSString stringWithFormat:@"%s",field1];
             NSLog(@"%@",appDelegate.sfmPageController.processId);
                      
        }
    }

    NSArray *tableHeader = [[tableDataArray objectAtIndex:indexPath.section] objectForKey:@"TableHeader"];
    
    if([self.masterView.searchFilterSwitch isOn])
    {   
        if(indexPath.row < [cellArray count])
        {
            for(int j=0;j<[tableHeader count] && j < no_of_fields;j++)
            {
                labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, 48)]; 
                labelForObjects.backgroundColor = [UIColor clearColor];      
                labelForObjects.font = [UIFont boldSystemFontOfSize:18];  
                if(indexPath.row < [cellArray count])
                    labelForObjects.text=[[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
                labelForObjects.textAlignment = UITextAlignmentLeft;
                [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] 
                                  forState:UIControlStateNormal];
                [button addTarget:self action:@selector(accessoryButtonTapped:)  forControlEvents:UIControlEventTouchUpInside];

                [cell addSubview:labelForObjects];
                [labelForObjects release];
            }
        }
        else 
        {
            //save online dict data array in mutable array of mutable dict
            NSMutableArray *onlineDataCopy = onlineDataArray ; 
            NSDictionary *sectionDict = [tableDataArray objectAtIndex:indexPath.section];
            NSString *sectionObjectId = [sectionDict objectForKey:@"ObjectId"];
            for(NSMutableDictionary *mDict in onlineDataCopy)
            {
                NSString *searchObjectId = [mDict objectForKey:@"SearchObjectId"];
                NSString *isVisited = [mDict objectForKey:@"isVisited"];
                if(!isVisited)
                {
                    if([searchObjectId isEqualToString:sectionObjectId])
                    {
                        for(int j=0;j<[tableHeader count] && j < no_of_fields;j++)
                        {
                            labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, 48)]; 
                            labelForObjects.backgroundColor = [UIColor clearColor];      
                            labelForObjects.font = [UIFont boldSystemFontOfSize:18];  
                            labelForObjects.text=[mDict objectForKey:[tableHeader objectAtIndex:j]];
                            labelForObjects.textAlignment = UITextAlignmentLeft;
                            
                            [cell addSubview:labelForObjects];
                            [labelForObjects release];
                        }

                        //Save the data in Dict
                        [mDict setObject:@"1" forKey:@"isVisited"];
                        // Online Image Indicator
                        UIImage *onlineImage = [UIImage imageNamed:@"OnlineRecord.png"];
                        UIImageView *onlineImgView  = [[[UIImageView alloc] initWithImage:onlineImage] autorelease];
                        [onlineImgView setFrame:CGRectMake(0, 0,10, 50)];
                        [cell addSubview:onlineImgView];
                        [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button-Gray.png"] 
                                          forState:UIControlStateNormal];
                        break;
                    }
                }
            }
            onlineDataArray = onlineDataCopy;
        }
    }
    else 
    {
        for(int j=0;j<[tableHeader count] && j < no_of_fields;j++)
        {
            labelForObjects=[[UILabel alloc]initWithFrame:CGRectMake((20+j*(640/no_of_fields)),0,210, 48)]; 
            labelForObjects.backgroundColor = [UIColor clearColor];      
            labelForObjects.font = [UIFont boldSystemFontOfSize:18];  
            if(indexPath.row < [cellArray count])
                labelForObjects.text=[[cellArray  objectAtIndex:indexPath.row] objectForKey:[tableHeader objectAtIndex:j]];
            labelForObjects.textAlignment = UITextAlignmentLeft;
            
            [cell addSubview:labelForObjects];
            [labelForObjects release];
        }
        [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] 
                          forState:UIControlStateNormal];
        [button addTarget:self action:@selector(accessoryButtonTapped:)  forControlEvents:UIControlEventTouchUpInside];
    }
    cell.accessoryView = button;
    cell.backgroundColor = [UIColor clearColor];

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
    SFMFullResultViewController *resultViewController = [[SFMFullResultViewController alloc] initWithNibName:@"SFMFullResultViewController" bundle:nil];
    resultViewController.fullMainDelegate = self;
    if([self.masterView.searchFilterSwitch isOn])
    {
        if(indexPath.row < [cellArray count])
        {
            fullDataDict = [cellArray objectAtIndex:indexPath.row]; 
            resultViewController.isOnlineRecord = NO;
        }
        else 
        {
            int count = 0;
            int onlineIndex = [cellArray count] - indexPath.row;
            //fullDataDict = [onlineDataArray objectAtIndex:(count-indexPath.row)];
            for(NSDictionary *dict in onlineDataArray)
            {
                NSString *searchObjectId = [dict objectForKey:@"SearchObjectId"];
                if( ([searchObjectId isEqualToString:objectId]) && (count == onlineIndex))
                {
                    fullDataDict = dict;
                    resultViewController.isOnlineRecord = YES;
                    break;
                }
            }
        }
    }
    else 
    {
        fullDataDict = [cellArray objectAtIndex:indexPath.row];
        resultViewController.isOnlineRecord = NO;
        NSLog(@"Data = %@",fullDataDict);
    }
    
     resultViewController.modalPresentationStyle = UIModalPresentationFormSheet;
     resultViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;    
    resultViewController.data = fullDataDict;
     [self presentModalViewController:resultViewController animated:YES];
     [resultViewController release];
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
    if([self.masterView.searchCriteria.text isEqualToString:@"Contains"])
    {
        if([searchField rangeOfString:searchString].length > 0)
        {
            result = YES;
        }
    }
    if([self.masterView.searchCriteria.text isEqualToString:@"Exact Match"])
    {
        if([searchField isEqualToString:searchString])
        {
            result = YES;
        }
    }
    if([self.masterView.searchCriteria.text isEqualToString:@"Ends With"])
    {
        if([searchField hasSuffix:searchString])
        {
            result = YES;
        }
    }
    if([self.masterView.searchCriteria.text isEqualToString:@"Starts With"])
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
    detailTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 710, self.view.frame.size.height)];
    detailTable.delegate = self;
    detailTable.dataSource = self;
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
    bgImage.frame = CGRectMake(0, -12, bgImage.frame.size.width, bgImage.frame.size.height+12);
    [self.view addSubview:bgImage];
    self.detailTable.backgroundView = bgImage;
    [bgImage release];
    [self.view addSubview:detailTable];
}
- (NSArray *) constructTableHeader : (NSArray *)data
{
    NSMutableArray *header = [[NSMutableArray alloc] init];
    
    for(NSDictionary *obj in data)
    {
        [header addObject:[obj objectForKey:@"SVMXC__Field_Name__c"]];
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
    NSMutableArray *result = [[appDelegate.dataBase getResults:object withConfigData:dataForObject] retain];
    for(NSDictionary *dict in result)
    {   
        BOOL found = NO;
        for(NSDictionary *searchableDict in searchableArray)
        {
            NSString *value = [dict objectForKey:[searchableDict objectForKey:@"SVMXC__Field_Name__c"]];
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
                NSString *key = [displaydict objectForKey:@"SVMXC__Field_Name__c"];
                [resultDict setObject:[dict objectForKey:key] forKey:key];
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
        NSMutableArray *searchResultData = [[NSMutableArray alloc] init];
        
        NSMutableArray *objectList = [[NSMutableArray alloc] init];
        NSMutableArray *objectResultList = [[NSMutableArray alloc] init];
        for(int i=0;i<[tableDataArray count]; i++)
        {
            [objectList addObject:[[tableDataArray objectAtIndex:i] objectForKey:@"ObjectId"]];
        }
        //NSArray  *objectList = [NSArray arrayWithObjects:@"a0a70000000fse8",@"a0a70000000fse9",@"a0a70000000fseB", nil];
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
        
        /*
        NSArray  *subResultList1 = [NSArray arrayWithObjects:@"a0s70000001H8hk", nil];
        NSArray  *subResultList2 = [NSArray arrayWithObjects:@"", nil];
        NSArray  *subResultList3 = [NSArray arrayWithObjects:@"5007000000Ly2Tz", nil];
        NSArray  *subResultList4 = [NSArray arrayWithObjects:@"", nil];
        NSArray  *resultList = [NSArray arrayWithObjects:subResultList1,subResultList2,subResultList3,subResultList4, nil];
       */
        
        NSString *criteria = self.masterView.searchCriteriaString;
        NSString *userFilterString = self.masterView.searchData;
        // NSString *userFilterString = @"acc";
        [ searchResultData addObject:self.masterView.processId];
        [ searchResultData addObject:objectList];
        [ searchResultData addObject:objectResultList];
        //[ searchResultData addObject:resultList];
        [ searchResultData addObject:criteria];
        [ searchResultData addObject:userFilterString];
        
        [activityIndicator startAnimating];
        if(appDelegate==nil)
            appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.wsInterface dataSyncWithEventName:@"SFM_SEARCH" eventType:@"SEARCH_RESULTS" values:searchResultData]; 
        appDelegate.wsInterface.didOpComplete = FALSE;
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
        {                
            if (appDelegate.wsInterface.didOpComplete == TRUE)
                break;   
            if (!appDelegate.isInternetConnectionAvailable)
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
        onlineDataArray = [appDelegate.onlineDataArray retain];
    }

    NSLog(@"Table Data = %@",tableDataArray);
    /*
    for(int i=0; i<[tableDataArray count]; i++)
    {
        NSDictionary *dict = [tableDataArray objectAtIndex:i];
        NSString *objName = [dict objectForKey:@"ObjectName"];
        NSMutableArray *onlineResults = [dict objectForKey:@"OnlineResults"];
        NSArray *headerInfo = [dict objectForKey:@"TableHeader"];
        for(NSDictionary *onlineDict in appDelegate.onlineDataArray)
        {
            NSString *objectId = [onlineDict objectForKey:@"SearchObjectId"];
            if([objName isEqualToString:@"Case"])
            {
                [onlineResults addObject:onlineDict];
            }
        }
        //if object id is same as online results add the record to online and update tabledata
    }
     */
    NSLog(@"Table Data = %@",tableDataArray);
    [detailTable reloadData];
}
- (void) accessoryButtonTapped:(id)sender
{
   
    UITableViewCell *ownerCell = (UITableViewCell*)[sender superview];
    NSIndexPath *ownerCellIndexPath;
    if (ownerCell != nil)
    {
        /* Now we will retrieve the index path of the cell which contains the section and the row of the cell */
        ownerCellIndexPath = [self.detailTable indexPathForCell:ownerCell];
        NSLog(@"Accessory in index path is tapped. Index path = %d", ownerCellIndexPath.row);
    }
     char *field1;
    appDelegate.showUI = FALSE;   //btn merge
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        [appDelegate.SFMPage release];
        appDelegate.SFMPage = nil;
    }   
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement1 = [NSMutableString stringWithFormat:@"Select local_id FROM SVMXC__Service_Order__c "];    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatement1 UTF8String];
     NSMutableArray *array=[[NSMutableArray alloc]init ];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW){
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            NSLog(@"%s",field1);
            [array addObject:[NSString stringWithFormat:@"%s", field1]];
             
                  }
    }
    
    NSMutableString * queryStatement2 = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement2 = [NSMutableString stringWithFormat:@"Select ActivityDate FROM Event"];    
    sqlite3_stmt * labelstmt2;
    const char *selectStatement2 = [queryStatement2 UTF8String];
    NSMutableArray *array2=[[NSMutableArray alloc]init ];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement2,-1, &labelstmt2, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(labelstmt2) == SQLITE_ROW){
            field1 = (char *) synchronized_sqlite3_column_text(labelstmt2,0);
            NSLog(@"%s",field1);
            [array2 addObject:[NSString stringWithFormat:@"%s", field1]];
            
        }
    }

    
    NSArray * keys = [NSArray arrayWithObjects:PROCESSID, RECORDID, OBJECTAPINAME, ACTIVITYDATE, ACCOUNTID, nil];
  NSArray * objects = [NSArray arrayWithObjects:@"IPAD-012", [array objectAtIndex:(ownerCellIndexPath.row)], @"SVMXC__Service_Order__c",[array2 objectAtIndex:(ownerCellIndexPath.row)],@"", nil];
    NSDictionary * _dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    appDelegate.sfmPageController.processId = @"IPAD-012";
    
    appDelegate.sfmPageController.objectName = @"SVMXC__Service_Order__c";
    
    //appDelegate.sfmPageController.recordId = [NSString stringWithFormat:@"%s", field1];
    appDelegate.sfmPageController.activityDate = [array2 objectAtIndex:(ownerCellIndexPath.row)];
    appDelegate.sfmPageController.accountId = @"";
    appDelegate.sfmPageController.topLevelId = nil;
    appDelegate.sfmPageController.recordId = [array objectAtIndex:(ownerCellIndexPath.row)];    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [appDelegate.sfmPageController.detailView view];
    [self presentModalViewController:appDelegate.sfmPageController animated:YES];
    [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
    
    
    //sahana - offline
    appDelegate.didsubmitModelView = FALSE;
    
    [appDelegate.sfmPageController release];

}
#pragma mark - SFM Full Result View Delegate
- (void) DismissSplitViewControllerByLaunchingSFMProcess
{
    NSLog(@"Launch SFM Process");

    
    if(appDelegate){
        appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    appDelegate.showUI = FALSE;   //btn merge
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    
    
    appDelegate.sfmPageController.processId = @"IPAD-012";
    
    appDelegate.sfmPageController.objectName = @"SVMXC__Service_Order__c";
    
    
    appDelegate.sfmPageController.accountId = @"";
    appDelegate.sfmPageController.topLevelId = nil;
    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [appDelegate.sfmPageController.detailView view];
    [self presentModalViewController:appDelegate.sfmPageController animated:YES];
    [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
    
    
    //sahana - offline
    appDelegate.didsubmitModelView = FALSE;
    
    [appDelegate.sfmPageController release];
}
@end

