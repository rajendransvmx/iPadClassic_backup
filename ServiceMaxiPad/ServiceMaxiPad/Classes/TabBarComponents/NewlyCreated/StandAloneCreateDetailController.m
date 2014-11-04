//
//  StandAloneCreateDetailController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "StandAloneCreateDetailController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "SFProcessModel.h"
#import "SFMPageViewController.h"
#import "SFMViewPageManager.h"
#import "TagManager.h"
#import "AlertMessageHandler.h"



@interface StandAloneCreateDetailController ()
@property(nonatomic, retain) SMSplitPopover *masterPopoverController;

@end

@implementation StandAloneCreateDetailController
@synthesize detailProcessArray,objectModel;

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
    
    
    self.view.backgroundColor = [UIColor colorWithHexString:kPageViewMasterBGColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
        [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated
{

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
    return [detailProcessArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
        
        UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0,49
                                                                        , self.tableView.frame.size.width, 1)];
        seperatorLine.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColor];
        [cell.contentView addSubview:seperatorLine];
        
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
        UIImage *normalImage = [UIImage imageNamed:@"sfm_right_arrow.png"];
        UIImageView* arrowView = [[UIImageView alloc] initWithImage:normalImage];
        cell.accessoryView = arrowView;
        
    }
    
    SFProcessModel *processModel = [self.detailProcessArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    UIFont *textLabelFont = [UIFont fontWithName:kHelveticaNeueMedium size:16.0];
    UIFont *detailLabelFont = [UIFont fontWithName:kHelveticaNeueLight size:16.0];
    
    cell.textLabel.font = textLabelFont;
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#434343"];
    cell.detailTextLabel.font = detailLabelFont;
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#797979"];


    cell.textLabel.text = processModel.processName;
    cell.detailTextLabel.text  = processModel.processDescription;
    
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

-(void)loadDetailViewControllerForIndex:(NSInteger)index
{
    SFProcessModel *processModel = [self.detailProcessArray objectAtIndex:index];
    
    if (processModel.objectApiName.length < 1) {
        processModel.objectApiName = self.objectModel.objectName;
    }
    PageEditViewController *editController = [[PageEditViewController alloc] initWithProcessId:processModel.sfID andObjectName:processModel.objectApiName ];
    editController.editViewControllerDelegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editController];

    [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
    
}
#pragma mark - SMSplitViewControllerDelegate

- (void)splitViewController:(SMSplitViewController *)splitViewController willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover
{
    barButtonItem.title = @"New Item";
    //splitViewController.navigationItem.rightBarButtonItem = barButtonItem;
    splitViewController.navigationItem.leftBarButtonItem = barButtonItem;
    self.masterPopoverController = popover;
}

- (void)splitViewController:(SMSplitViewController *)splitViewController willShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem
{
    splitViewController.navigationItem.leftBarButtonItem = nil;
}


- (void)reloaData
{
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    [self.tableView reloadData];
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

#pragma mark - PageEditViewControllerDelegate delegates
- (void)reloadData {
    
}


- (void)loadSFMViewPageLayoutForRecordId:(NSString *)recordId andObjectName:(NSString *)objectName
{
    SFMPageViewController *pageViewController = [[SFMPageViewController alloc] init];
    SFMViewPageManager *pageManager = [[SFMViewPageManager alloc] initWithObjectName:objectName recordId:recordId];
    if (recordId) {
        pageManager.recordId = recordId;
    }
    NSError *error = nil;
    BOOL isValidProcess = [pageManager isValidProcess:pageManager.processId error:&error];
    if (isValidProcess) {
        pageViewController.sfmPageView = [pageManager sfmPageView];
        [self.navigationController pushViewController:pageViewController animated:YES];
    }
    else
    {
        if (error) {
            AlertMessageHandler *alertHandler = [AlertMessageHandler sharedInstance];
            NSString * button = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
            
            [alertHandler showCustomMessage:[error localizedDescription] withDelegate:nil title:[[TagManager sharedInstance] tagByName:kTagAlertIpadError] cancelButtonTitle:nil andOtherButtonTitles:[[NSArray alloc] initWithObjects:button, nil]];
        }
    }
    
}
#pragma mark End

@end
