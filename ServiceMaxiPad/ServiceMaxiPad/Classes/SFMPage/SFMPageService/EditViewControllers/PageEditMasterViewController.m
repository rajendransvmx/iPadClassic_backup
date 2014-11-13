//
//  PageEditMasterViewController.m
//  ServiceMaxMobile
//
//  Created by shravya on 29/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   PageEditMasterViewController.m
 *  @class  PageEditMasterViewController
 *
 *  @brief SFM edit Root View controller
 *
 *   Responsible as the master for SFM edit view controller
 *
 *
 *  @author Krishna shanbhag
 *  @author Shravya S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "PageEditMasterViewController.h"
#import "StringUtil.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "TagManager.h"
#import "ViewControllerFactory.h"
#import "PageEditDetailViewController.h"

#import "ChildEditViewController.h"
#import "BadgeTableViewCell.h"

@interface PageEditMasterViewController ()

@end

@implementation PageEditMasterViewController

#pragma mark - Init methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithSFPage:(SFMPage *)sfPage {
    self = [super initWithNibName:@"PageEditMasterViewController"   bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.masterTableView.backgroundColor = [UIColor clearColor];
    self.selectedSection = -1;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];
    self.view.clipsToBounds = YES;
}

#pragma mark - Memory management 

- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Table View Data source and delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    BadgeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[BadgeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
        cell.textLabel.highlightedTextColor = [UIColor colorWithHexString:kWhiteColor];
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithHexString:kMasterSelectionColor]];
        [cell setSelectedBackgroundView:bgColorView];
        
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithHexString:kOrangeColor];
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize18];
    NSString *title = [self rowTitleForIndexPath:indexPath];
    //If empty string then show information instead leaving blank
    //TODO : localize it
    if ([StringUtil isStringEmpty:title]) {
        title = [[TagManager sharedInstance]tagByName:kTagInformation];
    }
    cell.textLabel.text = title;
    cell.badgeNumber = 0;
   
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3; //Header + child + attachments so always 3
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger rowCount = 0;
    SFMHeaderLayout *headerLayout = self.pageLayout.headerLayout;
    NSArray *detailsArray = self.pageLayout.detailLayouts;
    switch (section) {
            
        /*Header section*/
        case SFMEditPageMasterSectionTypeHeader:
            rowCount = [headerLayout.sections count];
            break;
        
        /*Line Items*/
        case SFMEditPageMasterSectionTypeChild:
            rowCount = [detailsArray count];
            break;
        
        /*Attachments*/
        case SFMEditPageMasterSectionTypeAttachment:
            if (headerLayout.enableAttachment)
            {
                rowCount = 2; //photos/videos and document.
            }
            break;
            
        default:
            break;
    }
    return rowCount;
}

- (NSString *) titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = nil;
    SFMHeaderLayout *headerLayout = self.pageLayout.headerLayout;
    NSArray *detailsArray = self.pageLayout.detailLayouts;
    TagManager *tagManager = [TagManager sharedInstance];
    
    switch (section) {
            
        /*Header section*/
        case SFMEditPageMasterSectionTypeHeader:
            if ([headerLayout.sections count]>0) {
                headerTitle = self.sfmPage.objectLabel;
            }
            break;
            
        /*Line Items*/
        case SFMEditPageMasterSectionTypeChild:
            if ([detailsArray count]>0) {
                
                //TODO : localization
                //headerTitle = [tagManager tagByName:kTagSfmLeftPaneLine];
                headerTitle = [tagManager tagByName:kTagSfmLeftPaneLine];
            }
            break;
            
        case SFMEditPageMasterSectionTypeAttachment:/*Attachments*/
            if (headerLayout.enableAttachment) {
                headerTitle = [tagManager tagByName:kTagSfmLeftPaneAttachments];
            }
            break;
            
        default:
            break;
    }
    return headerTitle;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[SFMPageMasterSectionView class]])
    {
        SFMPageMasterSectionView *headerView = (SFMPageMasterSectionView *)view;
        
        headerView.sectionTitle.text = [self titleForHeaderInSection:section];
        [headerView.rightButton.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueLight size:kFontSize14]];
        NSInteger noOfRows = [self.masterTableView numberOfRowsInSection:section];
        
        //Do not show "show all" if there is a single row. and also for attachments.
        if (section == 2 || noOfRows == 1) {
            headerView.rightButton.hidden = YES;
            
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFMPageMasterSectionView *headerSectionView = (SFMPageMasterSectionView *)[self.masterTableView headerViewForSection:indexPath.section];
    [self setShowAllSection:YES sender:headerSectionView.rightButton];
    if (self.selectedSection != -1 ) {
        
        SFMPageMasterSectionView *headerSectionView = (SFMPageMasterSectionView *)[self.masterTableView headerViewForSection:self.selectedSection];
        
        [self setShowAllSection:YES sender:headerSectionView.rightButton];
    }
    
    UITableViewCell *selectedCell = [self.masterTableView cellForRowAtIndexPath:indexPath];
    [self setPotraitDetailButtonTitle:selectedCell.textLabel.text];
    [self setDetailChildVCForIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    SFMPageMasterSectionView *pageSectionView = nil;
   
    if ([self titleForHeaderInSection:section] != nil) {
        static NSString *headerViewIdentifier = @"Header Identifier";
        pageSectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewIdentifier];
        if (pageSectionView == nil) {
            
            pageSectionView = [[SFMPageMasterSectionView alloc] initWithReuseIdentifier:headerViewIdentifier];
            pageSectionView.delegate = self;
            pageSectionView.tintColor = [UIColor clearColor];
            
            pageSectionView.sectionTitle.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
            [pageSectionView.rightButton setTitle:[[TagManager sharedInstance] tagByName:kTagShowAllButtonText] forState:UIControlStateNormal];

            pageSectionView.index = section;
            if (section != self.selectedSection ) {
                [self setShowAllSection:YES sender:pageSectionView.rightButton];
            }else
            {
                [self setShowAllSection:NO sender:pageSectionView.rightButton];
                
            }
        }
    }
    return pageSectionView;
}


#pragma mark - Private methods
/**
 * @name  <rowTitleForIndexPath>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Get title for row at index path>
 *
 * \par
 *  < Depicts the value or Title to be displayed in a table view cell >
 *  If the value got is null then return the value as Information
 *
 * @param  Indexpath
 * Title for which indexpath is represented.
 * @param  ...
 *
 * @bug Localize the Information string
 *
 * @return Description of the return value
 *
 */
- (NSString *) rowTitleForIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = nil;
    TagManager *tagManager = [TagManager sharedInstance];
    SFMHeaderLayout *headerLayout = self.pageLayout.headerLayout;
    
    NSArray *headerSections = headerLayout.sections;
    NSArray *detailSections = self.pageLayout.detailLayouts;
    
    switch (indexPath.section) {
            
        /*Header section*/
        case SFMEditPageMasterSectionTypeHeader:
            if ([headerSections count]>indexPath.row) {
                title = [[headerSections objectAtIndex:indexPath.row] title];
            }
            if ([StringUtil isStringEmpty:title]) {
                title = [[TagManager sharedInstance]tagByName:kTagInformation];
            }
            
            break;

        /*Line Items*/
        case SFMEditPageMasterSectionTypeChild:
            if ([detailSections count]>indexPath.row) {
                title = [[detailSections objectAtIndex:indexPath.row] name];
            }
            if ([StringUtil isStringEmpty:title]) {
                title = [[TagManager sharedInstance]tagByName:kTagInformation];
            }
            
            break;
        
        /*Attachments*/
        case SFMEditPageMasterSectionTypeAttachment:
            if (headerLayout.enableAttachment) {
                if (indexPath.row == 0 ) {
                    title = [tagManager tagByName:kTagPhotosVideos];
                }
                else if (indexPath.row == 1) {
                    title = [tagManager tagByName:kTagDocuments];
                }
            }
            break;
        default:
            break;
    }
    
    return title;
}
/**
 * @name  <setShowAllSection>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Show all section>
 *
 * \par
 *  < Altering the state of show all button >
 *
 *
 * @param  isAllSectionShown
 * If yes, set as enabled and change the state accordingly.
 * @param  ...
 *
 * @return Description of the return value
 *
 */
- (void) setShowAllSection:(BOOL)isAllSectionShown
                    sender:(id)sender
{
    if (isAllSectionShown) {
        [sender setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateNormal];
        [sender setEnabled:YES];
    }
    else{
        [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [sender setEnabled:NO];
        
    }
}

- (ChildEditViewController *) detailChildViewControllerForIndexPath:(NSIndexPath *)indexPath
{
    id viewController = nil;
    
    switch (indexPath.section) {
            
            /*Header*/
        case SFMEditPageMasterSectionTypeHeader:
            viewController = [self headerViewControllerForIndexPath:indexPath];
            break;
            
            /*Child*/
        case SFMEditPageMasterSectionTypeChild:
            viewController = [self childLineViewControllerForIndexPath:indexPath];
            [viewController setDelegate:(PageEditDetailViewController *)[self.containerViewControlerDelegate detailViewController]];
            break;
            
            /*Attachment*/
        case SFMEditPageMasterSectionTypeAttachment:
            viewController = [self attachmentViewControllerForIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    return viewController;
}


- (ChildEditViewController *) headerViewControllerForIndexPath:(NSIndexPath *)indexPath{
    ChildEditViewController *viewController = nil;
    SFMHeaderLayout *headerLayout = self.pageLayout.headerLayout;
    NSArray *headerSections = [headerLayout sections];
    if ([headerSections count]>indexPath.row) {

        //TODO : change it to required VC, change from ChildEditViewController to ViewControllerPageViewHeader.
        
        viewController = (ChildEditViewController *)[ViewControllerFactory createViewControllerByContext:ViewControllerSFMEditHeader];
        
//        viewController.view.backgroundColor = [UIColor clearColor];
        [viewController setSelectedIndexPath:indexPath];
        [viewController setSfmPage:self.sfmPage];
        
    }
    return viewController;
}


- (ChildEditViewController *) childLineViewControllerForIndexPath:(NSIndexPath *)indexPath
{
    //TODO : change it to required VC, change from ChildEditViewController to childLineViewController/ViewControllerSFMDebrief.
    
    ChildEditViewController * viewController =(ChildEditViewController *) [ViewControllerFactory createViewControllerByContext:ViewControllerSFMEditChildLineList];
    
    viewController.view.backgroundColor = [UIColor colorWithHexString:kPageViewMasterBGColor];
    [viewController loadDataWithSfmPage:self.sfmPage forIndexPath:indexPath];
    return viewController;
    
}

- (ChildEditViewController *)attachmentViewControllerForIndexPath:(NSIndexPath *)indexPath
{
    //TODO : change it to required VC, change from ChildEditViewController to attachmentVC.
    
    id viewController =(ChildEditViewController *) [ViewControllerFactory createViewControllerByContext:ViewControllerSFMEditAttachment];
    [viewController setSelectedIndexPath:indexPath];
    [viewController setSfmPage:self.sfmPage];
    
    return viewController;
}

- (NSArray *)allHeaderViewControllers
{
    //Iff show all on the header is pressed
    SFMHeaderLayout *headerLayout = self.pageLayout.headerLayout;
    NSArray *headerSections = headerLayout.sections;
    
    NSMutableArray *allViewControllers = [[NSMutableArray alloc] init];
    
    for (int index = 0; index<[headerSections count]; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:self.selectedSection];
        id viewController = [self detailChildViewControllerForIndexPath:indexPath];
        [viewController setSelectedIndexPath:indexPath];
        [viewController setSfmPage:self.sfmPage];
        
        [allViewControllers addObject:viewController];
    }
    return allViewControllers;
}

- (NSArray *)allChildLineViewControllers
{
    //Iff show all on the child lines are pressed
    NSArray *detailSections = self.pageLayout.detailLayouts;
    NSMutableArray *allViewControllers = [[NSMutableArray alloc] init];
    
    for (int index = 0; index<[detailSections count]; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:self.selectedSection];
        id viewController = [self detailChildViewControllerForIndexPath:indexPath];
        [viewController setSelectedIndexPath:indexPath];
        [viewController setSfmPage:self.sfmPage];
        
        [allViewControllers addObject:viewController];
    }
    return allViewControllers;
}

- (NSArray *) loadShowAllViewControllerForSection:(int)selectedSection
{
//    ChildEditViewController *showAllViewController = [ViewControllerFactory createViewControllerByContext:ViewControllerPageViewShowAll];
    
    NSArray *allViewControllers = nil;
    switch (selectedSection) {
        
        case SFMEditPageMasterSectionTypeHeader:/*Header section*/
            allViewControllers = [self allHeaderViewControllers];
            break;
            
        case SFMEditPageMasterSectionTypeChild:/*Line Items*/
            allViewControllers = [self allChildLineViewControllers];
            break;
            
        case SFMEditPageMasterSectionTypeAttachment:/*Attachments*/
            break;
            
        default:
            break;
    }
    return allViewControllers;
//Add view controllers to the detail view.
}
- (void)reloadData {
    
    self.pageLayout = self.sfmPage.process.pageLayout;
    
    
    //By default Show all is not selected
    self.selectedSection = -1;
    
    //If you want to select first show all then uncomment this
    
    //SFMPageMasterSectionView *pageHeaderSectionView = (SFMPageMasterSectionView *)[self.masterTableView headerViewForSection:0];
    //[self tappedOnButton:pageHeaderSectionView.rightButton withIndex:0];
  
    [self.masterTableView reloadData];
    
    //Select first row of first section by default.
    [self.masterTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:0];
    [self.masterTableView.delegate tableView:self.masterTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
}

- (void) setPotraitDetailButtonTitle:(NSString *)title
{
    PageEditDetailViewController *detailViewController = (PageEditDetailViewController *)[self.containerViewControlerDelegate detailViewController];
    //Extra space for button title to look properly
    NSString *titleString = [NSString stringWithFormat:@" %@",title];
    [detailViewController setContentWithItem:titleString];
    
}


#pragma mark - Set view controllers to detail view.
- (void)setDetailChildVCForIndexPath:(NSIndexPath *)indexPath
{
    PageEditDetailViewController *detailViewController = (PageEditDetailViewController *)[self.containerViewControlerDelegate detailViewController];
    
    [detailViewController addChildViewControllersToData:@[[self detailChildViewControllerForIndexPath:indexPath]]];
    
    [detailViewController reloadData];
}

- (void)setShowAllDetailChildVCsForIndexPath:(int)section
{
    PageEditDetailViewController *detailViewController = (PageEditDetailViewController *)[self.containerViewControlerDelegate detailViewController];
    
    [detailViewController addChildViewControllersToData:[self loadShowAllViewControllerForSection:section]];
    
    [detailViewController reloadData];
}

#pragma mark - SFMPageMasterSectionViewDelegate

//Check if show all or any other button are pressed
- (void) tappedOnButton:(id)sender withIndex:(NSUInteger)index {
    
    
    if (self.selectedSection != -1 ) {
        
        SFMPageMasterSectionView *headerSectionView = (SFMPageMasterSectionView *)[self.masterTableView headerViewForSection:self.selectedSection];
        
        [self setShowAllSection:YES sender:headerSectionView.rightButton];
        
    }
    [self setShowAllSection:NO sender:sender];
    self.selectedSection = index;
    
        NSString *sectionName = [self titleForHeaderInSection:index];
        [self setPotraitDetailButtonTitle: sectionName];
    
    [self.masterTableView deselectRowAtIndexPath:[self.masterTableView indexPathForSelectedRow] animated:NO];
    
    [self setShowAllDetailChildVCsForIndexPath:self.selectedSection];
}

@end
