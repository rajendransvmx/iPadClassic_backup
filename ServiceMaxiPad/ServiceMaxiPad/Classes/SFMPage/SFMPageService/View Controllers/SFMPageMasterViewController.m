//
//  SFMPageMasterViewController.m
//  ServiceMaxMobile
//
//  Created by Aparna on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageMasterViewController.h"
#import "StyleGuideConstants.h"
#import "SFMPageMasterSectionView.h"
#import "StringUtil.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "SFMPageDetailViewController.h"
#import "SFMPageLayoutViewController.h"
#import "SFMPageHeaderLayoutViewController.h"
#import "SFMHeaderSection.h"
#import "ViewControllerFactory.h"
#import "SFMPageHeaderLayoutViewController.h"
#import "SFMPageChildLayoutViewController.h"
#import "SFMDebriefViewController.h"
#import "StyleManager.h"
#import "SFMPageShowAllViewController.h"
#import "SFMPageHistoryViewController.h"
#import "SLAClockViewController.h"
#import "DocumentsViewController.h"
#import "ImagesVideosViewController.h"
#import "SFMPageHelper.h"

typedef enum SFMPageMasterSectionType : NSUInteger
{
    SFMPageMasterSectionTypeHeader = 0,
    SFMPageMasterSectionTypeChild = 1,
    SFMPageMasterSectionTypeHistory = 2,
    SFMPageMasterSectionTypeAttachment = 3
}
SFMPageMasterSectionType;



@interface SFMPageMasterViewController ()<SFMPageMasterSectionViewDelegate>

@property(nonatomic, assign) NSInteger selectedSection;
@property(nonatomic, strong) SFMPageLayout *pageLayout;
@property(nonatomic, strong) SLAClockViewController *slaViewController;

@end

@implementation SFMPageMasterViewController

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
    
    self.selectedSection = -1;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];;
    self.pageLayout = self.sfmPageView.sfmPage.process.pageLayout;
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.selectedSection == -1) {
        SFMPageMasterSectionView *pageHeaderSectionView = (SFMPageMasterSectionView *)[self.tableView headerViewForSection:0];
        [self tappedOnButton:pageHeaderSectionView.rightButton withIndex:0];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 
#pragma mark UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
    if ([StringUtil isStringEmpty:title]) {
       title = [[TagManager sharedInstance]tagByName:kTagInformation];
    }
    cell.textLabel.text = title;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger rowCount = 0;
    SFMHeaderLayout *headerLayout = self.pageLayout.headerLayout;
    NSArray *detailsArray = self.pageLayout.detailLayouts;
    switch (section) {
        case SFMPageMasterSectionTypeHeader:/*Header section*/
            rowCount = [headerLayout.sections count];
            break;
            
        case SFMPageMasterSectionTypeChild:/*Line Items*/
            rowCount = [detailsArray count];
            break;
            
        case SFMPageMasterSectionTypeHistory:/*Additional Info*/
            if (headerLayout.enableAccountHistory ) {
                rowCount++;
            }
            if (headerLayout.enableProductHistory) {
                rowCount++;
            }
            break;
            
        case SFMPageMasterSectionTypeAttachment:/*Attachments*/
            if (headerLayout.enableAttachment) {
                rowCount = 2;
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
            case SFMPageMasterSectionTypeHeader:/*Header section*/
                if ([headerLayout.sections count]>0) {
                    headerTitle = self.sfmPageView.sfmPage.objectLabel;
                }
                break;
                
            case SFMPageMasterSectionTypeChild:/*Line Items*/
                if ([detailsArray count]>0) {
               headerTitle = [tagManager tagByName:kTagSfmLeftPaneLine];
                    //headerTitle = @"Line Items ";
                }
                break;
                
            case SFMPageMasterSectionTypeHistory:/*Additional Info*/
                if (headerLayout.enableAccountHistory || headerLayout.enableProductHistory ) {
                    headerTitle = @"History";
                }
                break;
                
            case SFMPageMasterSectionTypeAttachment:/*Attachments*/
                if (headerLayout.enableAttachment) {
                    headerTitle = [tagManager tagByName:kTagSfmLeftPaneAttachments];
                }
                break;
                
            default:
                break;
        }
        return headerTitle;
}


#pragma mark -
#pragma mark UITableViewDelegate Methods
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
        headerView.rightButton.hidden = NO;
        int numberOfRows = [self.tableView numberOfRowsInSection:section];
        /*Hide Show All button for Attachment and if number of rows less than 2*/
        if (section == 3 || numberOfRows<2) {
            headerView.rightButton.hidden = YES;
        }
    }
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
            if (section != self.selectedSection) {
                [self setShowAllSection:YES sender:pageSectionView.rightButton index:section];
            }else
            {
                [self setShowAllSection:NO sender:pageSectionView.rightButton index:section];

            }
            
            
        }
    }
    return pageSectionView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFMPageMasterSectionView *headerSectionView = (SFMPageMasterSectionView *)[self.tableView headerViewForSection:indexPath.section];
    [self setShowAllSection:YES sender:headerSectionView.rightButton index:indexPath.section];
    if (self.selectedSection != -1 ) {
        
        SFMPageMasterSectionView *headerSectionView = (SFMPageMasterSectionView *)[self.tableView headerViewForSection:self.selectedSection];
        
        [self setShowAllSection:YES sender:headerSectionView.rightButton index:self.selectedSection];
    }

    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self setDetailButtonTitle:selectedCell.textLabel.text];
    [self setDetailChildViewControllerForIndexPath:indexPath];
    
    

}

#pragma mark -
#pragma mark SFMPageHeaderSectionViewDelegate Method
- (void) tappedOnButton:(id)sender withIndex:(NSUInteger)index
{
    if (self.selectedSection != -1 ) {
        
        SFMPageMasterSectionView *headerSectionView = (SFMPageMasterSectionView *)[self.tableView headerViewForSection:self.selectedSection];

        [self setShowAllSection:YES sender:headerSectionView.rightButton index:self.selectedSection];

    }
    [self setShowAllSection:NO sender:sender index:index];
    self.selectedSection = index;
    
    NSString *sectionName = [self titleForHeaderInSection:index];
    [self setDetailButtonTitle: sectionName];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    [self loadShowAllViewControllerForSection:self.selectedSection];

}


#pragma mark -
#pragma mark Private Methods

- (void)setSfmPageView:(SFMPageViewModel *)sfmPageView
{
    _sfmPageView = sfmPageView;
    self.pageLayout = _sfmPageView.sfmPage.process.pageLayout;
}


- (void) setShowAllSection:(BOOL)isAllSectionShown
                      sender:(id)sender
                       index:(NSInteger) index
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

- (void) setDetailButtonTitle:(NSString *)title
{
    SFMPageDetailViewController *detailViewController = (SFMPageDetailViewController *)[self.smSplitViewController detailViewController];
    [detailViewController setContentWithItem:title];

}

- (void)setDetailChildViewControllerForIndexPath:(NSIndexPath *)indexPath
{
    SFMPageDetailViewController *detailViewController = (SFMPageDetailViewController *)[self.smSplitViewController detailViewController];
    [detailViewController setPageDetailChildViewController: [self detailChildViewControllerForIndexPath:indexPath]];
}


- (NSString *) rowTitleForIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = nil;
    TagManager *tagManager = [TagManager sharedInstance];
    SFMHeaderLayout *headerLayout = self.pageLayout.headerLayout;
    
    NSArray *headerSections = headerLayout.sections;
    NSArray *detailSections = self.pageLayout.detailLayouts;
    
    switch (indexPath.section) {
        case SFMPageMasterSectionTypeHeader:/*Header section*/
            if ([headerSections count]>indexPath.row) {
                title = [[headerSections objectAtIndex:indexPath.row] title];
            }
            if ([StringUtil isStringEmpty:title]) {
                title = [[TagManager sharedInstance]tagByName:kTagInformation];
            }

            break;
            
        case SFMPageMasterSectionTypeChild:/*Line Items*/
            if ([detailSections count]>indexPath.row) {
                title = [[detailSections objectAtIndex:indexPath.row] name];
            }
            if ([StringUtil isStringEmpty:title]) {
                title = [[TagManager sharedInstance]tagByName:kTagInformation];
            }

            break;
            
        case SFMPageMasterSectionTypeHistory:/*Additional Info*/
            if (headerLayout.enableProductHistory &&  headerLayout.enableAccountHistory) {
                if (indexPath.row == 0) {
                    title = [tagManager tagByName:kTagSfmLeftPaneAccountHistory];
                }
                else if (indexPath.row == 1) {
                    title = @"Product History and Records";//[tagManager tagByName:kTagSfmLeftPaneProductHistory];
                }
            }
            else if(headerLayout.enableProductHistory)
            {
                title = @"Product History and Records";//[tagManager tagByName:kTagSfmLeftPaneProductHistory];
            }
            else if(headerLayout.enableAccountHistory){
                title = [tagManager tagByName:kTagSfmLeftPaneAccountHistory];
                
            }
            break;
            
        case SFMPageMasterSectionTypeAttachment:/*Attachments*/
            if (headerLayout.enableAttachment) {
                if (indexPath.row == 0 ) {
                    title = [tagManager tagByName:kTagDocuments];
                }
                else if (indexPath.row == 1) {
                    //title = [tagManager tagByName:kTagPhotosVideos];
                    title = @"Images and Video";
                }
            }
            break;
        default:
            break;
    }
    
    return title;
}


- (UIViewController *) detailChildViewControllerForIndexPath:(NSIndexPath *)indexPath
{
    id viewController = nil;
    
    switch (indexPath.section) {
            
            /*Header*/
        case SFMPageMasterSectionTypeHeader:
            viewController = [self headerViewControllerForIndexPath:indexPath];
            break;
            
            /*Child*/
        case SFMPageMasterSectionTypeChild:
            viewController = [self childLineViewControllerForIndexPath:indexPath];
            break;
            
            /*History*/
        case SFMPageMasterSectionTypeHistory:
            viewController = [self historyViewControllerForIndexPath:indexPath];
            break;
            
            /*Attachment*/
        case SFMPageMasterSectionTypeAttachment:
            viewController = [self attachmentViewControllerForIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    return viewController;
}


- (UIViewController *) headerViewControllerForIndexPath:(NSIndexPath *)indexPath{
    id viewController = nil;
    SFMHeaderLayout *headerLayout = self.pageLayout.headerLayout;
    NSArray *headerSections = [headerLayout sections];
    if ([headerSections count]>indexPath.row) {
        SFMHeaderSection *headerSection= [headerSections objectAtIndex:indexPath.row];
        if(headerSection.isSLAClock){
//            if(self.slaViewController == nil)
//            {
                viewController = [ViewControllerFactory createViewControllerByContext:ViewControllerPageViewSLAClock];
                self.slaViewController = viewController;

//            }
            [self.slaViewController setSlaClock:self.sfmPageView.slaClock];
            viewController = self.slaViewController;
        }
        else{
            viewController = (SFMPageHeaderLayoutViewController *)[ViewControllerFactory createViewControllerByContext:ViewControllerPageViewHeader];
            [viewController setSelectedSection:indexPath.row];
            [viewController setSfmPageView:self.sfmPageView];
            [viewController setPageFields:headerSection.sectionFields];
        }
    }
    return viewController;
}


- (UIViewController *)childLineViewControllerForIndexPath:(NSIndexPath *)indexPath
{
    id viewController =(SFMDebriefViewController *) [ViewControllerFactory createViewControllerByContext:ViewControllerSFMDebrief];
    [viewController setSfmPageView:self.sfmPageView];
    [viewController setSelectedSection:indexPath.row];
    return viewController;

}

- (UIViewController *) historyViewControllerForIndexPath:(NSIndexPath *)indexPath
{
    id viewController =(SFMPageHistoryViewController *) [ViewControllerFactory createViewControllerByContext:ViewControllerSFMHistory];
    if ([self isAccountHistory:indexPath])
    {
        [viewController setHistoryInfo:self.sfmPageView.accountHistory];
        [viewController setHistoryInfoType:HistoryTypeAccount];
    }
    else if ([self isProductHistory:indexPath])
    {
        [viewController setHistoryInfo:self.sfmPageView.productHistory];
        [viewController setHistoryInfoType:HistoryTypeProduct];
    }
    return viewController;
    
}

- (UIViewController *)attachmentViewControllerForIndexPath:(NSIndexPath *)indexPath
{
    id viewController = nil;
    if ([[self rowTitleForIndexPath:indexPath] isEqualToString:[[TagManager sharedInstance] tagByName:kTagDocuments]])
    {
        viewController = (DocumentsViewController *) [ViewControllerFactory createViewControllerByContext:ViewControllerAttachmentDocuments];
        ((DocumentsViewController*)viewController).parentId = [SFMPageHelper getSfIdForLocalId:self.sfmPageView.sfmPage.recordId objectName:self.sfmPageView.sfmPage.objectName];
        ((DocumentsViewController*)viewController).parentSFObjectName = self.sfmPageView.sfmPage.objectName;
        ((DocumentsViewController*)viewController).parentObjectName = [SFMPageHelper getObjectLabelForObjectName:self.sfmPageView.sfmPage.objectName];
    }
    else if ([[self rowTitleForIndexPath:indexPath] isEqualToString:@"Images and Video"])
    {
        viewController = (ImagesVideosViewController *) [ViewControllerFactory createViewControllerByContext:ViewControllerAttachmentImagesAndVideos];
        ((ImagesVideosViewController*)viewController).parentId = [SFMPageHelper getSfIdForLocalId:self.sfmPageView.sfmPage.recordId objectName:self.sfmPageView.sfmPage.objectName];
        ((ImagesVideosViewController*)viewController).parentSFObjectName = self.sfmPageView.sfmPage.objectName;
        ((ImagesVideosViewController*)viewController).parentObjectName = [SFMPageHelper getObjectLabelForObjectName:self.sfmPageView.sfmPage.objectName];
    }
    return viewController;
}

- (NSArray *)allHeaderViewControllers
{
    SFMHeaderLayout *headerLayout = self.pageLayout.headerLayout;
    NSArray *headerSections = headerLayout.sections;
    
    NSMutableArray *allViewControllers = [[NSMutableArray alloc] init];
    for (int index = 0; index<[headerSections count]; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:self.selectedSection];
        id viewController = [self detailChildViewControllerForIndexPath:indexPath];
        if ([viewController respondsToSelector:@selector(shouldScrollContent)]) {
            [viewController setShouldScrollContent:NO ];
        }
        [allViewControllers addObject: viewController];
    }
    return allViewControllers;
}

- (NSArray *)allChildLineViewControllers
{
    NSArray *detailSections = self.pageLayout.detailLayouts;
    NSMutableArray *allViewControllers = [[NSMutableArray alloc] init];
    for (int index = 0; index<[detailSections count]; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:self.selectedSection];
        SFMDebriefViewController *viewController = (SFMDebriefViewController *)[self detailChildViewControllerForIndexPath:indexPath];
        viewController.shouldScrollContent = NO;
        [allViewControllers addObject: viewController];
    }
    return allViewControllers;
}

- (NSArray *) allHistoryViewControllers
{
    NSMutableArray *allViewControllers = [[NSMutableArray alloc] init];
    SFMHeaderLayout *headerLayout = self.pageLayout.headerLayout;
    
    if (headerLayout.enableProductHistory &&  headerLayout.enableAccountHistory) {
        for (int index = 0; index<2; index++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:self.selectedSection];
            
            SFMPageHistoryViewController *viewController =  (SFMPageHistoryViewController*)[self detailChildViewControllerForIndexPath:indexPath];
            viewController.shouldScrollContent = NO;
            [allViewControllers addObject:viewController];
            
        }
    }
    else if(headerLayout.enableProductHistory ||  headerLayout.enableAccountHistory) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.selectedSection];
        
        SFMPageHistoryViewController *viewController =  (SFMPageHistoryViewController*)[self detailChildViewControllerForIndexPath:indexPath];
        viewController.shouldScrollContent = NO;
        [allViewControllers addObject:viewController];
    }
    return allViewControllers;
}

- (void) loadShowAllViewControllerForSection:(int)selectedSection
{
    SFMPageShowAllViewController *showAllViewController = [ViewControllerFactory createViewControllerByContext:ViewControllerPageViewShowAll];
    
    NSArray *allViewControllers = nil;
    switch (selectedSection) {
        case SFMPageMasterSectionTypeHeader:/*Header section*/
            allViewControllers = [self allHeaderViewControllers];
            break;
            
        case SFMPageMasterSectionTypeChild:/*Line Items*/
            allViewControllers = [self allChildLineViewControllers];
            for (id viewController in allViewControllers) {
                [viewController setDebriefDelagte:showAllViewController];
            }
            
            break;
            
        case SFMPageMasterSectionTypeHistory:/*Additional Info*/
            allViewControllers = [self allHistoryViewControllers];
            
            break;
            
        case SFMPageMasterSectionTypeAttachment:/*Attachments*/
             //TODO:
            break;
            
        default:
            break;
    }
    showAllViewController.selectedSectionViewControllers = allViewControllers;
    SFMPageDetailViewController *detailViewController = (SFMPageDetailViewController *)[self.smSplitViewController detailViewController];
    [detailViewController setPageDetailChildViewController: showAllViewController];
    
}

- (BOOL)isAccountHistory:(NSIndexPath *)indexPath
{
    BOOL result = NO;
    
    NSString *title = [[TagManager sharedInstance] tagByName:kTagSfmLeftPaneAccountHistory];
    
    if([[self rowTitleForIndexPath:indexPath] isEqualToString:title])
    {
        result = YES;
    }
    return result;
}

- (void)resetData
{
    self.selectedSection = -1;
    SFMPageMasterSectionView *pageHeaderSectionView = (SFMPageMasterSectionView *)[self.tableView headerViewForSection:0];
    [self tappedOnButton:pageHeaderSectionView.rightButton withIndex:0];
    [self.tableView reloadData];
}

- (BOOL)isProductHistory:(NSIndexPath *)indexPath
{
    BOOL result = NO;
    
    if([[self rowTitleForIndexPath:indexPath] isEqualToString:@"Product History and Records"])
    {
        result = YES;
    }
    return result;
}

@end