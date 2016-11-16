//
//  StandAloneCreateMasterController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "StandAloneCreateMasterController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import  "SFProcessService.h"
#import  "SFProcessModel.h"
#import "SFObjectService.h"
#import "DBCriteria.h"
#import "DatabaseConstant.h"

#import "StandAloneCreateDetailController.h"
#import "CalenderHelper.h"
#import "NoDynamicTypeTableViewCell.h"
#import "ProductIQManager.h"

@interface StandAloneCreateMasterController ()
@property(nonatomic,strong)NSMutableArray *standAloneObjects;
@property(nonatomic,strong)NSMutableArray *standAloneUniqueObjects;

@property(nonatomic,strong)NSMutableDictionary *standAloneProcessDict;

@end

@implementation StandAloneCreateMasterController

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self getStandAloneObjects];
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    
//
//}


-(void)getStandAloneObjects
{
    SFProcessService *processService = [[SFProcessService alloc]init];
    
    if ([processService conformsToProtocol:@protocol(SFProcessDAO)])
    {
        NSString *eventType = [CalenderHelper getEventTypeFromMobileDeviceSettings];
        NSString *objectNameToExclude = kEventObject;
        if ([eventType isEqualToString:kSalesforceEvent]) {
            objectNameToExclude = kServicemaxEventObject;
        }
        
        NSArray *fieldNames = @[ksfId,kprocessName,kprocessDescription,kobjectApiName];
        DBCriteria *creteriaObject = [[DBCriteria alloc]initWithFieldName:ktype operatorType:SQLOperatorEqual andFieldValue:kProcessTypeStandAloneCreate];
        DBCriteria *creteriaObjectTwo = [[DBCriteria alloc]initWithFieldName:kobjectApiName operatorType:SQLOperatorNotEqual andFieldValue:objectNameToExclude];
        
       // self.standAloneObjects =  (NSMutableArray *)[processService fetchSFProcessByFields:fieldNames andCriteria:creteriaObject];
        self.standAloneObjects = (NSMutableArray*)[processService fetchSFProcessByFields:fieldNames andlistOfCriteria:@[creteriaObject,creteriaObjectTwo]];
          
        // get distinct object_Api_name and add in array
        NSMutableArray *array = [[NSMutableArray alloc]init];
        self.standAloneUniqueObjects = array;
        
        NSMutableSet *filteredSet = [NSMutableSet set];
        for (id obj in self.standAloneObjects) {
            NSString *objectApiName = [obj objectApiName];
            if (![filteredSet containsObject:objectApiName]) {
                [self.standAloneUniqueObjects addObject:obj];
                [filteredSet addObject:objectApiName];
            }
        }
        
        
        
        //Getting Label here from SFObject for UI
        NSMutableArray *actualStandAloneObjects = [[NSMutableArray alloc]init];
        
        for (int i = 0; i<[self.standAloneUniqueObjects  count]; i++) {
            SFObjectService *objectService = [[SFObjectService alloc]init];
            NSArray *standAloneObs = nil;
            if ([objectService conformsToProtocol:@protocol(SFObjectDAO)])
            {
                SFProcessModel *processModel = [self.standAloneUniqueObjects objectAtIndex:i];
                //NSString *object  = [self.standAloneUniqueObjects  objectAtIndex:i];
                
                DBCriteria *creteria = [[DBCriteria alloc]initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:processModel.objectApiName];
                
                standAloneObs = [objectService fetchRecordsByFields:@[kobjectName,klabel] andCriteria:creteria];
                
                if (standAloneObs != nil && [standAloneObs count] > 0) {
                    SFObjectModel *objModel = [standAloneObs objectAtIndex:0];

                    [actualStandAloneObjects addObject:objModel];
                    
                }
                
            }
        }
        
        self.standAloneUniqueObjects =  actualStandAloneObjects;
        //sorting Unique Objects based on label
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:klabel ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [self.standAloneUniqueObjects sortedArrayUsingDescriptors:descriptors];
        
        self.standAloneUniqueObjects = (NSMutableArray *)sortedArray;
        
        
    }
   
    
    //making Process Dict of key as Label and value is SFProcess Model
    [self getStandAloneProcessDict];
    
    [self.tableView reloadData];
    
}

-(void)getStandAloneProcessDict
{
    // we have 2 array
    //self.standAloneObjects which contains all objects with Processname and description
    //self.standAloneUniqueObjects contains only objects with label and objectname
    
    NSMutableArray *allObjects = [[NSMutableArray alloc]initWithCapacity:1];
    allObjects  = self.standAloneObjects;
    
    NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
    
    
    for (SFObjectModel *objectModel in self.standAloneUniqueObjects )
    {
        
        NSArray *filteredArray = [allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectApiName ==[c] %@",objectModel.objectName]];
        
        //Sort the filtered Array
        //sorting Unique Objects based on label
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:kprocessName ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [filteredArray sortedArrayUsingDescriptors:descriptors];
        filteredArray = sortedArray;
        //sorting ends here
        
        [finalDict setObject:filteredArray forKey:objectModel.label];
        
    }
    
    self.standAloneProcessDict = finalDict;
  //  SXLogInfo(@"Final Dict is %@",self.standAloneProcessDict);
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
    return [self.standAloneUniqueObjects count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    
    NoDynamicTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[NoDynamicTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        cell.textLabel.textColor = [UIColor colorFromHexString:kOrangeColor];
        cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize16];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    SFObjectModel *processModel = [self.standAloneUniqueObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = processModel.label;
    
    return cell;
}


#pragma mark UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self loadDetailViewControllerForIndex:indexPath.row];
}


- (void)loadDetailViewControllerForIndex:(NSInteger)index
{
    SFObjectModel *Object = [self.standAloneUniqueObjects objectAtIndex:index];
    
    BOOL isProductIQEnabled = [[ProductIQManager sharedInstance] isProductIQEnabledForStandaAloneObject:Object];

    StandAloneCreateDetailController *detailController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    detailController.shouldProductIQEnabled = isProductIQEnabled;
    detailController.detailProcessArray = [self.standAloneProcessDict objectForKey:Object.label];
    detailController.objectModel = Object;
    self.smSplitViewController.delegate = detailController;
    [detailController reloaData];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
