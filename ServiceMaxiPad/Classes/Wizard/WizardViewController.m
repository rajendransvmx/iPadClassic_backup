//
//  WizardViewController.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 09/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   WizardViewController.m
 *  @class  WizardViewController
 *
 *  @brief
 *
 *   This is a viewcontroller which has the business logic to disply wizard.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "WizardViewController.h"
#import "SFWizardModel.h"
#import "SFProcessModel.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "TagManager.h"
#import "SFMCustomActionHelper.h"
#import "SFCustomActionURLService.h"
#import "SNetworkReachabilityManager.h"
#import "SFMCustomActionWebServiceHelper.h"
#import "MBProgressHUD.h"

@interface WizardViewController ()

@property(assign)CGFloat cellHeight;

@property (nonatomic, strong)MBProgressHUD *HUD;

@end

@implementation WizardViewController
@synthesize wizardsArray;
@synthesize viewProcessArray;


#pragma mark - apllication lifecycle method

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
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    _tableView = nil;
}

#pragma mark = tableview datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = [self getNumberOfRowsInSection:section];
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"wizardcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UILabel  *textLabel = nil;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    //Remove all subview of cell contentview
    
    for (UIView *eachView in  cell.contentView.subviews) {
        
        [eachView removeFromSuperview];
    }
    
    //add textlabel and set title
    textLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,0,300,40)];
    textLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:textLabel];
    
    [textLabel setNumberOfLines:2];
    textLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:16.0];
    textLabel.textColor = [UIColor colorWithHexString:kOrangeColor];
    
    //Add one pixel seperator line to each cell
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(10,39
                                                                    , 295, 1)];
    seperatorLine.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColor];
    [cell.contentView addSubview:seperatorLine];
    
    NSInteger tempSection = indexPath.section;
    
    if (self.shouldShowTroubleShooting && indexPath.section == 0) {
        textLabel.text = [[TagManager sharedInstance]tagByName:kTagSfmTroubleShooting];
    }
    //if there is viewprocess display it in last section
    else {
        if (self.shouldShowTroubleShooting) {
                tempSection = indexPath.section - 1;
        }
        if ([self.viewProcessArray count] > 0 && tempSection == [wizardsArray count] ) {
       
            SFProcessModel *processModel;
            processModel = [self.viewProcessArray objectAtIndex:indexPath.row];
            textLabel.text = processModel.processName;
            
            textLabel.enabled = YES;
            cell.userInteractionEnabled = YES;
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];

            
            //if the cell is last row of the section remove seperator line
            if (indexPath.row == [self.viewProcessArray count] - 1) {
                
                [seperatorLine removeFromSuperview];
            }
        }
        else { //For the section except last section display wizard component name
            
            SFWizardModel *wizard = [self.wizardsArray objectAtIndex:tempSection];
            WizardComponentModel *wizardComponent = [wizard.wizardComponents objectAtIndex:indexPath.row];
            textLabel.text = wizardComponent.actionName;
            
            if (wizardComponent.isEntryCriteriaMatching){
                if ([wizardComponent.actionType isEqualToString:@"OTHERS"]) {
                    /* Before making request checking for internet connectivity */
                    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]){
                        textLabel.enabled = YES;
                        cell.userInteractionEnabled = YES;
                        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
                        if ([wizardComponent.customActionType isEqualToString:@"Web-Service"])  {
                            cell.accessoryView = [self setIcon:[UIColor colorWithHexString:kOrangeColor]];
                        }else{
                            cell.accessoryView = nil;
                        }
                    }else{
                        if ([wizardComponent.customActionType isEqualToString:@"Web-Service"])  {
                            textLabel.enabled = NO;
                            cell.userInteractionEnabled = NO;
                            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                            cell.accessoryView = [self setIcon:[UIColor colorWithHexString:kTextFieldFontColor]];
                        }else{
                            textLabel.enabled = YES;
                            cell.userInteractionEnabled = YES;
                            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
                            cell.accessoryView = nil;
                        }
                    }
                }else{
                    textLabel.enabled = YES;
                    cell.userInteractionEnabled = YES;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
                    cell.accessoryView = nil;
                }
            }
            else{
                textLabel.enabled = NO;
                cell.userInteractionEnabled = NO;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.accessoryView = nil;
            }
            
            //if the cell is last row of the section remove seperator line
            if (indexPath.row == [wizard.wizardComponents count] - 1) {
                
                [seperatorLine removeFromSuperview];
            }
        }
    }
    cell.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
    return cell;
}

-(UIImageView *)setIcon:(UIColor *)color
{
    UIImage *icon = [UIImage imageNamed:@"wizardComponentIcon"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    [imageView setTintColor:[UIColor redColor]];
    CGRect rect = CGRectMake(0, 0, icon.size.width, icon.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, icon.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    imageView.image = flippedImage;
    return imageView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = [self getNumberOfSections];
    
    return sectionCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]])
    {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
        
        //Remove all subview of cell contentview
        
        for (UIView *eachView in  headerView.contentView.subviews) {
            
            [eachView removeFromSuperview];
        }
        
        //add titlelabe and set title
        UILabel  *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,0,310, view.frame.size.height)];
        titleLabel.backgroundColor = [UIColor clearColor];
        [headerView.contentView addSubview:titleLabel];
        if (self.shouldShowTroubleShooting && section == 0) {
            titleLabel.text = [[TagManager sharedInstance]tagByName:kTagSfmTroubleShooting];
        }
        else {
            
            if (self.shouldShowTroubleShooting) {
                section = section - 1;
            }
        
        if ([self.viewProcessArray count] > 0 && section == [wizardsArray count]) {
            
            titleLabel.text = [[TagManager sharedInstance]tagByName:kTag_ViewProcess];
        } else {
            if ([self.wizardsArray count] > 0) {
                
                SFWizardModel *wizard = [self.wizardsArray objectAtIndex:section];
                titleLabel.text = wizard.wizardName;
            }
        }
        }
        titleLabel.textColor = [UIColor colorWithHexString:@"#434343"];
        titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:16];

        //add line
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 24,310,1)];
        lineView.backgroundColor = [UIColor colorWithHexString:kHeaderSeperatorLineColor];
        [headerView.contentView addSubview:lineView];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.shouldShowTroubleShooting && indexPath.section == 0) {
        [self showTroubleShooting];
    }
    else {
        NSInteger section = 0;
        
        if (self.shouldShowTroubleShooting) {
            section = indexPath.section - 1;
        }
        else {
            section = indexPath.section;
        }
        if ([self.viewProcessArray count] > 0 && section == [wizardsArray count]) { //View process
            
            [self.delegate viewProcessTapped:[viewProcessArray objectAtIndex:indexPath.row]];
        }
        else if ([self.wizardsArray count] > section)
        {
            SFWizardModel *wizard = [self.wizardsArray objectAtIndex:section];
            if ([wizard.wizardComponents count] > indexPath.row) {
                WizardComponentModel *wizardComponent = [wizard.wizardComponents objectAtIndex:indexPath.row];
                //HS 21Nov for DODUpdate
                if ([wizardComponent.actionType isEqualToString:@"DODUpdate"])
                {
                    [self.delegate updateDODRecordFromSalesforce];
                }
                else if ([wizardComponent.actionType isEqualToString:@"Reschedule"])
                {
                    //Reschedule event
                    [self.delegate rescheduleEvent];
                }else if([wizardComponent.actionType isEqualToString:@"OTHERS"])//Here we are checking for custome URL
                {
                    /* Before making request checking for internet connectivity */
                    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]){
                        if ([[wizardComponent.customActionType uppercaseString] isEqualToString:@"URL"]) {
                            /* load url with params */
                            [self.delegate makeCustomUrlCall:wizardComponent];
                        }else if ([[wizardComponent.customActionType uppercaseString] isEqualToString:@"WEB-SERVICE"]) {
                            /* checking network reachablity and making webservice call */
                            if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
                                [self.delegate makeWebserviceCall:wizardComponent];
                        }
                    }else{
                        
                    }
                }
                else
                {
                    [self.delegate editProcessTapped:wizardComponent.processId];
                }
                
                //HS 21Nov ends here
                //[self.delegate editProcessTapped:wizardComponent.processId];//HS 21 Nov
            }
        }
    }
    if ([self.sideMenu hasShownSideBar]) {
        [self.sideMenu dismissAnimated:YES];
    }
    
}

- (NSInteger)getNumberOfSections
{
    NSInteger sectionCount = [self.wizardsArray count];
    
    if ([self.viewProcessArray count] > 0) {
        
        sectionCount = [self.wizardsArray count] + 1; //Last section to show view process.
    }
    if ( self.shouldShowTroubleShooting){
        sectionCount = sectionCount + 1;
    }
    return sectionCount;
}

- (NSInteger)getNumberOfRowsInSection:(NSInteger)section
{
    if (self.shouldShowTroubleShooting && section == 0) {
        return 1;
    }
    else if (self.shouldShowTroubleShooting) {
        section = section - 1;
    }
    if ([self.viewProcessArray count] > 0 && section == [wizardsArray count]) {
        
        return [self.viewProcessArray count]; //last section to display view process
    }
    return [[[self.wizardsArray objectAtIndex:section] wizardComponents] count];
}

- (void)showTroubleShooting
{
    [self.delegate loadTroublShootingViewForProduct];
}


- (void)reloadTableView {
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.tableView reloadData];
                       
                   });
}


@end
