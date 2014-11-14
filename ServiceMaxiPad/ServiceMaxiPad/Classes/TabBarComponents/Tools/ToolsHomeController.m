//
//  ToolsHomeController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 27/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ToolsHomeController.h"
#import "SyncStatusDetailViewController.h"
#import "StyleManager.h"


//HS test
#import "SFMPageViewController.h"
#import "SFMViewPageManager.h"
//#import "SFMDependentPicklistHelper.h"
#import "SFPicklistDAO.h"
#import "DBCriteria.h"
#import "FactoryDAO.h"
#import "SFMPageLayout.h"
#import "SFMProcess.h"
#import "SFMHeaderLayout.h"
#import "SFMHeaderSection.h"
#import "SFMPageField.h"
#import "ToolsMasterViewController.h"
#import "ViewControllerFactory.h"
#import "TagManager.h"

@interface ToolsHomeController ()

@end

@implementation ToolsHomeController

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
    
   // [self getPicklistValues];
    
//    UIView *view = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]];
//    view.backgroundColor = [UIColor clearColor];
//    self.view = view ;
    
    //self.title = @"Tools";
    
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
//    titleLabel.font = [UIFont navbarTitle];
//    titleLabel.textColor = [UIColor navBarTitleColor];
//    titleLabel.text = @"Tools";
//    self.navigationItem.titleView = titleLabel;
    
    //self.navigationItem.titleView = [UILabel navBarTitleLabel:@"Tools"];
    //self.navigationItem.titleView = [UILabel navBarTitleLabel:@"Sync Status and Manual Sync"];

    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationBar.translucent = NO;
    
    // padmashree, use ViewControllerFactory to get controller object, use tableview to display Tools master ..
    ToolsMasterViewController *masterVC = [ViewControllerFactory createViewControllerByContext:ViewControllerToolsMaster];
    masterVC.smSplitViewController = self;
    
    SyncStatusDetailViewController *detailVC = [ViewControllerFactory createViewControllerByContext:ViewControllerSyncStatusDetail];
    detailVC.smSplitViewController = self;
    
    UINavigationController *detailNavController = [[UINavigationController alloc]initWithRootViewController:detailVC];
    detailNavController.navigationBar.hidden = YES;
    //detailNavController.navigationBar.translucent = NO;
    self.delegate = detailVC;
    self.viewControllers = @[masterVC,detailNavController];
    self.navigationItem.titleView = [UILabel navBarTitleLabel:@"Tools"];//[[TagManager sharedInstance]tagByName:kTagAbout]];
}


- (void)viewWillAppear:(BOOL)animated
{
   // NSLog(@"tools frame = %@",NSStringFromCGRect(self.view.frame));
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//HS added for testing dependent picklist helper dBfunctions
/*- (void)getPicklistValues
{
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc] init];
    SFMViewPageManager *pageManager = [[SFMViewPageManager alloc] initWithObjectName:@"SVMXC__Service_Order__c" recordId:@"3033B2CF-54D2-46B1-A0FA-5195DF531A24"];
    SFMPage *page = [pageManager sfmPage];
    pageViewController.sfmPageView.sfmPage = page;
    //[self.navigationController pushViewController:pageViewController animated:YES];
    
    SFMPageLayout *pageLayout = page.process.pageLayout;
    SFMHeaderLayout *headerLayout = pageLayout.headerLayout;
    SFMHeaderSection *headerSection= [headerLayout.sections objectAtIndex:0];
    SFMPageField *pageField = [headerSection.sectionFields objectAtIndex:1]; //(is array of SFPageFields object)

    
    SFMRecordFieldData *recordField = [page getHeaderFieldDataForName:pageField.fieldName];
    
       //pageField.apiName  = fieldApi name
    //headerSection.sectionFields
    
    
    
    //Get the picklist values for object name and field name
        id <SFPicklistDAO> picklistService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
    DBCriteria *criteria1 = [[DBCriteria alloc]initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:page.objectName];
    
    DBCriteria *criteria2 = [[DBCriteria alloc]initWithFieldName:kfieldname operatorType:SQLOperatorEqual andFieldValue:pageField.fieldName];
    
    //field_name,label,value,valid_for,index_value
    NSArray *criteriaObjects = [[NSArray alloc]initWithObjects:criteria1,criteria2, nil];
    NSArray *fields = [[NSArray alloc]initWithObjects:kfieldname,klabel,kvalue,kvalidFor,kindexValue, nil];
    
    NSArray *picklistValues = [picklistService fetchSFPicklistInfoByFields:fields andCriteria:criteriaObjects andExpression:@"(1 AND 2)"];
    NSLog(@"picklist is %@",picklistValues);
    
                         
    NSArray *dependenPicklistValues  = [SFMDependentPicklistHelper getDependentPicklistValuesForPageField:pageField recordField:recordField objectName:page.objectName fromPicklist:picklistValues];
    
    NSLog(@"final Dependent pickist values are %@",dependenPicklistValues);


    
   // +(NSArray *)getDependentPicklistValuesForPageField:(SFMPageField *)controllerPageField recordField:(SFMRecordFieldData *)recordField objectName:(NSString *)objectName fromPicklist:(NSArray *)picklist
}*/


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)redrawNavigationTitleMessage:(NSString *)title
{
     self.navigationItem.titleView = [UILabel navBarTitleLabel:title];
}

@end
