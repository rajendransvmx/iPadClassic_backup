//
//  SearchDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "SearchProcessObjectsDAO.h"
#import "SFMSearchObjectModel.h"
#import "FactoryDAO.h"
#import "SFMSearchFieldModel.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "SFMSearchFieldDAO.h"
#import "SFMSearchDataHandler.h"
#import "SFMRecordFieldData.h"
#import "Utility.h"
#import "TransactionObjectModel.h"
#import "SFMPageViewController.h"
#import "SFMViewPageManager.h"
#import "AlertMessageHandler.h"
#import "SFMRecordFieldData.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "DateUtil.h"
#import "SFMOnlineSearchManager.h"
#import "DODViewController.h"
#import "ViewControllerFactory.h"


#define SRCH_ROW_HEIGHT 60.0
#define SRCH_SECTION_HEIGHT 50.0

@interface SearchDetailViewController ()<DownloadOnDemandDelegate,UIPopoverControllerDelegate>

@property(nonatomic, retain) SMSplitPopover *masterPopoverController;
@property (nonatomic,retain) NSMutableArray *expandedViewControllers;
@property (nonatomic,retain) SFMSearchDataHandler *dataHandler;
@property (nonatomic,retain) SFMOnlineSearchManager *onlineSearchHandler;

@property (nonatomic, strong) UIPopoverController *dodPopoverController;

@end

@implementation SearchDetailViewController
{
    int resultsCount;
}
#pragma mark - Init methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}
#pragma mark - View life cycle.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.expandedViewControllers = [[NSMutableArray alloc]init];
    self.searchDetailTableView.separatorColor = [UIColor colorWithHexString:@"#D7D7D7"];
    self.searchDetailTableView.backgroundColor = [UIColor clearColor];

    //[self expandAllSections]; //*** uncomment this if the sections has to be expanded when search is loaded
    [self addTableViewFooter];  //Include online items button in table footer.
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private methods

/**
 * @name  <performSearchFor:>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Background data fetch for selected search text>
 *
 * \par
 *  < Search data to be fetched from background thread and displayed when data is got. >
 *
 *
 * @param  searchText
 * Search text on which the search has to be performed.
 * @param  ...
 *
 * @return void
 *
 */
-(void)performSearchFor:(NSString*)searchText
{
    @synchronized([self class])
    {
        {
            [self performSelectorInBackground:@selector(getDataForSearchProcess:) withObject:searchText];
        }
    }
}
/**
 * @name  <fillUpSearchFieldsIntoObject:>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Get all search field objects>
 *
 * \par
 *  < Get all search field objects from SFMSearchFieldService table:SFM_Search_Field and fill it to the model object >
 *
 *
 * @param  Indexpath
 * Title for which indexpath is represented.
 * @param  ...
 *
 * @return Description of the return value
 *
 */
- (void)fillUpSearchFieldsIntoObject:(SFMSearchObjectModel *)searchObject {
    
    @autoreleasepool {
        
        /*Get all fields for given search object */
        id service = [FactoryDAO serviceByServiceType:ServiceTypeSFMSearchField];
        
        NSArray *searchFieldArray = [service getAllFieldsForSearchObject:searchObject];
        
        /* Distribute the field based on type */
        if ([searchFieldArray count] > 0) {
            
            NSMutableArray *displayFields = [[NSMutableArray alloc] init];
            NSMutableArray *sortFields = [[NSMutableArray alloc] init];
            NSMutableArray *searchFieldList = [[NSMutableArray alloc] init];
            
            for (SFMSearchFieldModel *searchField in searchFieldArray) {
                
                NSLog(@"searchField.fieldType : %@",searchField.fieldType);
                if ([searchField.fieldType isEqualToString:kSearchFieldTypeSearch]) {
                    [searchFieldList addObject:searchField];
                }
                else if ([searchField.fieldType isEqualToString:kSearchFieldTypeResult ]){
                    [displayFields addObject:searchField];
                }
                else if ([searchField.fieldType isEqualToString:kSearchFieldTypeOrderBy ]){
                    [sortFields addObject:searchField];
                }
            }
            searchObject.displayFields = displayFields;
            searchObject.searchFields = searchFieldList;
            searchObject.sortFields = sortFields;
        }
    }
}
- (void)getDataForSearchProcess:(NSString *)searchKeyWord {
    
    NSArray *searchObjects = nil;
    @synchronized([self class])
    {
        @autoreleasepool
        {
            /* Loading results */
            if (self.searchProcess.searchObjects != nil)
            {
                for (SFMSearchObjectModel *object in self.searchProcess.searchObjects)
                {
                    [self fillUpSearchFieldsIntoObject:object];
                }
                searchObjects =  self.searchProcess.searchObjects;
            }
            if (self.dataHandler == nil) {
                self.dataHandler = [[SFMSearchDataHandler alloc] init];
            }
            
            self.dataList = [self.dataHandler searchResultsForSearchObjects:self.searchProcess.searchObjects withSearchString:searchKeyWord];
        }
    }
    
    [self performSelectorOnMainThread:@selector(reloadInitialData:) withObject:searchObjects waitUntilDone:NO];
}

- (void)reloadInitialData:(NSArray*)data
{
    @autoreleasepool
    {
        [self showAnimator:NO];
        self.searchProcess.searchObjects = [NSArray arrayWithArray:data];
        [self.searchDetailTableView reloadData];
    }
    
}
- (NSDictionary*)getDisplayDetailsFor:(NSIndexPath*)indexPath
{
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    
    SFMSearchObjectModel *srchObj = [self.searchProcess.searchObjects objectAtIndex:indexPath.section];
    NSArray *list = [self.dataList objectForKey:srchObj.objectId];
    
    NSUInteger index = (NSUInteger)indexPath.row;
    TransactionObjectModel *objectData = [list objectAtIndex:index];
    
    
    SFMSearchFieldModel *field1 = nil;
    SFMSearchFieldModel *field2  = nil;
    
    if ([srchObj.displayFields count] > 0) {
        field1 =  [srchObj.displayFields objectAtIndex:0];
    }
    
    if ([srchObj.displayFields count] > 1) {
        field2 =  [srchObj.displayFields objectAtIndex:1];
    }
    
    SFMRecordFieldData *fldValue1 = (SFMRecordFieldData *)[objectData valueForField:[field1 getDisplayField]];
    SFMRecordFieldData *fldValue2 = (SFMRecordFieldData *)[objectData valueForField:[field2 getDisplayField]];
    
    NSString *titleString = [self getDisplayStringForValue:fldValue1.displayValue withType:field1.displayType];
    [dataDict setObject:titleString forKey:@"title"];
    
    NSString *descriptionString = [self getDisplayStringForValue:fldValue2.displayValue withType:field2.displayType];
    [dataDict setObject:descriptionString forKey:@"description"];
    
    return dataDict;
}

- (NSString *) getDisplayStringForValue:(NSString *)value withType:(NSString *)displayType {
    if ([Utility isStringEmpty:value] && ![value isKindOfClass:[NSNumber class]]) {
        return @"";
    }
    
    if([displayType isEqualToString:kSfDTDateTime]) {

        value = [DateUtil getUserReadableDateForDateBaseDate:value];
    }
    else if ([displayType isEqualToString:kSfDTDate]) {
            
            value = [DateUtil getUserReadableDateForDBDateTime:value];
    }
    
    else if ([displayType isEqualToString:kSfDTBoolean]) {
        
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *numValue = (NSNumber *)value;
            value = [numValue stringValue];
        }
        BOOL istrue = [Utility isItTrue:value];
        value = istrue ? kYes : kNo;
    }
    else
    {
        if ([value isKindOfClass:[NSNumber class]]) {
            
            NSNumber *numValue = (NSNumber *)value;
            value = [numValue stringValue];
        }
    }
    return value;
}
- (NSString *)titleForSection:(NSInteger)section
{
    SFMSearchObjectModel *srchObj = [self.searchProcess.searchObjects objectAtIndex:section];
    
    NSArray *list = [self.dataList objectForKey:srchObj.objectId];
    
    NSString *displayStr = [NSString stringWithFormat:@"%@ (%d)",srchObj.name,((int)list.count)];
    
    return displayStr;
}
- (void) selectedProcess:(SFMSearchProcessModel *)processObject
{
    self.searchProcess = processObject;
    [self getSearchProcessObjectsFor:processObject];
    
    [self performSearchFor:nil];
    self.searchBar.text = @"";
    
    [self.masterPopoverController dismissPopoverAnimated:YES];
    [self.searchDetailTableView reloadData];
    //fetch the details for the selected process and reload the detail table
}
- (NSArray *) getSearchProcessObjectsFor:(SFMSearchProcessModel*)processObject {
    
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFMSearchProcessObject];
    
    if ([daoService conformsToProtocol:@protocol(SearchProcessObjectsDAO)]) {
        self.searchProcess.searchObjects = [NSMutableArray arrayWithArray:[daoService getAllObjectApiNamesFor:processObject]];
    }
    return self.searchProcess.searchObjects;
}

- (void) addTableViewFooter {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 36, 200, 44)];
    button.backgroundColor = [UIColor navBarBG];
    [button setTitle:@"Include Online Items" forState:UIControlStateNormal]; //TODO tag the title for button
    [button addTarget:self action:@selector(includeOnlineResultsBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    self.searchDetailTableView.tableFooterView = view;
}
- (IBAction)includeOnlineResultsBtnClicked:(id)sender {
    [self doOnlineSearch];
}
- (void) expandAllSections {
    
    for (int i=0; i<self.searchProcess.searchObjects.count; i++) {
        [self.expandedViewControllers addObject:[NSNumber numberWithInt:i]];
    }
}
- (void)reloadData
{
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    //[self.tableView reloadData];
}


#pragma mark - SMSplitViewControllerDelegate

- (void)splitViewController:(SMSplitViewController *)splitViewController willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover
{
    barButtonItem.title = @"Lists"; //Tags are not there.
    splitViewController.navigationItem.leftBarButtonItem = barButtonItem;
    self.masterPopoverController = popover;
}

- (void)splitViewController:(SMSplitViewController *)splitViewController willShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem
{
    splitViewController.navigationItem.leftBarButtonItem = nil;
}
#pragma mark - Tableview delagate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    //resultsCount = 0; // reset while table starts reloading
    return self.searchProcess.searchObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SFMSearchObjectModel *srchObj = [self.searchProcess.searchObjects objectAtIndex:section];
    NSArray *list = [self.dataList objectForKey:srchObj.objectId];
    
    // Update the results count
    //resultsCount += list.count;
    //    [self.lblItemsCount setText:[NSString stringWithFormat:@"%d %@",resultsCount,@"items found"]];

    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
        
        UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(10, (SRCH_ROW_HEIGHT - 1), self.searchDetailTableView.frame.size.width - 20, 1)];
        seperatorView.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColor];

        cell.textLabel.textColor = [UIColor colorWithHexString:kEditableTextFieldColor];
        cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
        
        cell.detailTextLabel.textColor = [UIColor colorWithHexString:kTextFieldFontColor];
        cell.detailTextLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize16];
        
        [cell.contentView addSubview:seperatorView];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImage *normalImage = [UIImage imageNamed:@"sfm_right_arrow"];
    UIImageView* arrowView = [[UIImageView alloc] initWithImage:normalImage];
    cell.accessoryView = arrowView;
    
    NSDictionary *displayData = [self getDisplayDetailsFor:indexPath];
    
    cell.textLabel.text = [displayData objectForKey:@"title"];
    cell.detailTextLabel.text = [displayData objectForKey:@"description"];

    if (![self isCellExpandedForSection:indexPath.section]) {
        cell.hidden = YES;
    }
    else
    {
        cell.hidden = NO;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![self isCellExpandedForSection:indexPath.section])
        return 0;
    
    return SRCH_ROW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SRCH_SECTION_HEIGHT;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    SFMSearchSection *sectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SectionIdentifier"];
    if (nil == sectionView) {
        sectionView = [[SFMSearchSection alloc] initWithReuseIdentifier:@"SectionIdentifier"];
    }
    
    sectionView.contentView.backgroundColor = [UIColor whiteColor];
    sectionView.section = section;
    sectionView.delegate = self;
    
//    SFMSearchObjectModel *object = self.searchProcess.searchObjects[section];
    
    NSString *text = [self titleForSection:section]; // [object name]; //@"Work Orders (7)";//[self titleForSection:section];
    sectionView.titleLabel.text = text;
    sectionView.titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
    sectionView.titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    
    /**/
    
    if ([sectionView.titleLabel respondsToSelector:@selector(setAttributedText:)])
    {
        // iOS6 and above : Use NSAttributedStrings
        UIFont *boldFont = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
        UIFont *regularFont = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
        UIColor *foregroundColor = [UIColor blackColor];
        
        // Create the attributes
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               regularFont, NSFontAttributeName,
                               foregroundColor, NSForegroundColorAttributeName, nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  boldFont, NSFontAttributeName,
                                  foregroundColor, NSForegroundColorAttributeName, nil];
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attrs];
        [attributedText setAttributes:subAttrs range:[[text lowercaseString] rangeOfString:[self.searchBar.text lowercaseString]]];
        
        // Set it in our UILabel and we are done!
        [sectionView.titleLabel setAttributedText:attributedText];
    }
    
    /**/
    
   // [sectionView.contentView setBackgroundColor:[UIColor navBar]];
    //sectionView.accessoryImageView.backgroundColor = [UIColor yellowColor];
    
    if([self isCellExpandedForSection:section])
        sectionView.accessoryImageView.image = [UIImage imageNamed:@"sfm_down_arrow.png"];
    else
        sectionView.accessoryImageView.image = [UIImage imageNamed:@"sfm_right_arrow.png"];

    return sectionView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footerIdentifier"];
    if (view == nil) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"footerIdentifier"];
    }
    return view;
}
- (void) loadViewProcessForObjectName:(NSString *)objectName andLocalId:(NSString *)localID {

    SFMPageViewController *pageViewController = [[SFMPageViewController alloc]init];
    SFMViewPageManager *pageManager = [[SFMViewPageManager alloc] initWithObjectName:objectName recordId:localID];
    
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFMSearchObjectModel *srchObj = [self.searchProcess.searchObjects objectAtIndex:indexPath.section];
    NSArray *list = [self.dataList objectForKey:srchObj.objectId];
    
    TransactionObjectModel *objectData = [list objectAtIndex:indexPath.row];
    
    SFMRecordFieldData *localField = (SFMRecordFieldData *)[objectData valueForField:kLocalId];
    
    [self loadViewProcessForObjectName:srchObj.targetObjectName andLocalId:localField.internalValue];
    
    
    /*
     * DOD implementation testing. uncomment locally.
     */
    
    /*
    [self showDoDViewWithSeachObject:srchObj
                   transactionObject:objectData
                   fromTableViewCell:[tableView cellForRowAtIndexPath:indexPath]];
     */
}


#pragma mark -
#pragma mark SectionViewDelegate Methods

- (void) didTapOnSection:(int)section
{
    SFMSearchSection *sectionView = (SFMSearchSection*)[self.searchDetailTableView headerViewForSection:section];
    if (![self isCellExpandedForSection:section])
    {
        //NSLog(@"Expand the section");
        
        sectionView.accessoryImageView.image = [UIImage imageNamed:@"sfm_right_arrow.png"];
        
        [self.expandedViewControllers addObject:[NSNumber numberWithInt:section]];
    }
    else
    {
        sectionView.accessoryImageView.image = [UIImage imageNamed:@"sfm_down_arrow.png"];
        [self.expandedViewControllers removeObject:[NSNumber numberWithInt:section]];
    }
    [self.searchDetailTableView beginUpdates];
    [self.searchDetailTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.searchDetailTableView endUpdates];
}
- (BOOL) isCellExpandedForSection:(NSInteger)section
{
    BOOL isCellExpanded = NO;
    if ([self.expandedViewControllers containsObject:[NSNumber numberWithInteger:section]])
    {
        isCellExpanded = YES;
    }
    return isCellExpanded;
}
- (void) tableView:(UITableView *)tableView didExpandCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDetailTableView reloadData];
}
- (void) tableView:(UITableView *)tableView didCollapseCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDetailTableView reloadData];
}
#pragma mark - Search delegates
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar*)searchBar
{
    //Enabling search key even if the the text is empty.
    UITextField *searchBarTextField = nil;
    for (UIView *subView in self.searchBar.subviews){
        for (UIView *secondLeveSubView in subView.subviews){
            if ([secondLeveSubView isKindOfClass:[UITextField class]])
            {
                searchBarTextField = (UITextField *)secondLeveSubView;
                break;
            }
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self performSearchFor:searchBar.text];
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self showAnimator:YES];
    [self performSearchFor:searchBar.text];
    [searchBar resignFirstResponder];
}

/**
 * @name  <showAnimator>
 *
 * @author Krishna Shanbhag
 *
 * @brief <Show animator (activity indicator)>
 *
 * \par
 *  < Animator HUD shown or hidden using this method >
 *
 *
 * @param  show
 * Animator HUD is shown/hidden based on this BOOLEAN value.
 * @param  ...
 *
 * @return void
 *
 */
- (void)showAnimator:(BOOL)show {
    if (show) {
      
        if (!self.loadingHUD) {
            self.loadingHUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        }
        [self.view.window addSubview:self.loadingHUD];
        self.loadingHUD.mode = MBProgressHUDModeIndeterminate;
        self.loadingHUD.labelText = [[TagManager sharedInstance]tagByName:kTagLoading];
        [self.loadingHUD show:YES];
    }
    else {
        if (self.loadingHUD) {
            [self.loadingHUD hide:YES];
            self.loadingHUD = nil;
        }
    }
    
}



#pragma mark - Online Search Handler

- (void)doOnlineSearch {
    if (self.onlineSearchHandler == nil) {
        self.onlineSearchHandler = [[SFMOnlineSearchManager alloc] init];
        self.onlineSearchHandler.viewControllerDelegate = self;
    }
    /*Cancel all previous */
    
    /* Show activity Indicator */
 
    [self performOnlineSeachInBackground];
    
}

- (void)performOnlineSeachInBackground{
 
    @synchronized([self class]) {
        @autoreleasepool {
             /* Get selected process */
            [self.onlineSearchHandler performOnlineSearchWithSearchProcess:self.searchProcess andSearchText:self.searchBar.text];
        }
        
    }
}
#pragma mark End

#pragma mark - SFMOnlineSearchManagerDelegate methods
- (void)onlineSearchSuccessfullwithResponse:(NSMutableDictionary *)dataDictionary
                           forSearchProcess:(SFMSearchProcessModel*)searchProcess
                              andSearchText:(NSString *)searchText {
    
     @synchronized([self class]) {
         self.dataList = dataDictionary;
         [self performSelectorOnMainThread:@selector(reloadInitialData:) withObject:self.searchProcess.searchObjects waitUntilDone:NO];
     }
}
- (void)onlineSearchFailedwithError:(NSError *)error
                   forSearchProcess:(SFMSearchProcessModel*)searchProcess{
    @synchronized([self class]) {
        
    }
}


#pragma mark End

- (void)dealloc {
    
    _dodPopoverController = nil;
}

#pragma mark - Download on demand methods.
- (void)showDoDViewWithSeachObject:(SFMSearchObjectModel *)searchModel
                 transactionObject:(TransactionObjectModel *)transactionModel
                 fromTableViewCell:(UITableViewCell *)cell
{
    DODViewController *dodVC = [ViewControllerFactory createViewControllerByContext:ViewControllerDOD];
    [dodVC setupDODWithDelegate:self
                   searchObject:searchModel
           andTransactionObject:transactionModel];
    
    self.dodPopoverController = [[UIPopoverController alloc]initWithContentViewController:dodVC];
    
    self.dodPopoverController.delegate = self;
    self.dodPopoverController.popoverContentSize = CGSizeMake(320, 320);
    [self.dodPopoverController presentPopoverFromRect:cell.textLabel.frame inView:cell permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
}


#pragma mark - End
#pragma mark - Popover delegate methods.
//- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
//    return NO;
//}

#pragma mark - End
@end
