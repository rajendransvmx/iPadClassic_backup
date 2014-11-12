//
//  PageEditChildListViewController.m
//  ServiceMaxMobile
//
//  Created by Aparna on 06/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PageEditChildListViewController.h"
#import "DebriefSectionView.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "SFMRecordFieldData.h"
#import "StringUtil.h"
#import "TagManager.h"
#import "TagConstant.h"
#import "PageEditChildLayoutViewController.h"
#import "ViewControllerFactory.h"
#import "SFMLookUpViewController.h"
#import "AppManager.h"
#import "SFMPageField.h"
#import "SFProcessComponentModel.h"
#import "StringUtil.h"

NSString *const kChildListCellIdentifier1 = @"CellIdentifierDefault";
NSString *const kChildListCellIdentifier2 = @"CellIdentifierExpand";
NSString *const kChildListHeaderIdentifier = @"HeaderIdentifier";
NSString *const kChildListFooterIdentifier = @"FooterIdentifier";


#define kChildListTableViewHeaderHeight 30.0
#define kChildListTableViewFooterHeight 76.0
#define kChildListTableViewRowHeight 50.0
#define kChildListTableViewSectionHeaderHeight 0
#define kChildListTableViewSectionFooterHeight 1

#define CELL_VIEW_TAG 100

@interface PageEditChildListViewController ()

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) SFMDetailLayout *detailLayout;
@property (retain, nonatomic) NSMutableDictionary *expandedSectionsDict;

@property (nonatomic, retain)UIPopoverController *popOver;

@end

@implementation PageEditChildListViewController


#pragma mark -
#pragma mark Initializaion/View loading methods

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
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];//[UIColor colorWithHexString:kPageViewMasterBGColor];
    self.tableView.scrollEnabled = NO;
    
    [self addTableViewHeader];
    [self addTableViewFooter];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Private Methods

- (void) addTableViewFooter
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, kChildListTableViewFooterHeight)];
    UIButton *addButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 23, 80, 30)];
    [addButton setBackgroundColor:[UIColor navBarBG]];
    [addButton addTarget:self action:@selector(addNewLine:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:@"+ Add" forState:UIControlStateNormal];
    [footerView addSubview:addButton];
    self.tableView.tableFooterView = footerView;
}

- (void) addTableViewHeader
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, kChildListTableViewHeaderHeight)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.bounds.size.width-10, kChildListTableViewHeaderHeight)];
    [headerView addSubview:headerLabel];
    headerLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
    
    self.tableView.tableHeaderView = headerView;
}

- (void) setTableViewHeaderTitle
{
    SFMPageLayout *pageLayout = self.sfmPage.process.pageLayout;
    NSArray *detailLayouts =pageLayout.detailLayouts;
    SFMDetailLayout *detailLayout= [detailLayouts objectAtIndex:self.selectedIndexPath.row];
    UIView *headerView = [self.tableView tableHeaderView];
    NSArray *subviews = [headerView subviews];
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *headerLabel = (UILabel *)view;
            headerLabel.text =  detailLayout.name;

        }
    }
}

- (void) loadDataWithSfmPage:(SFMPage *)sfmPage
                forIndexPath:(NSIndexPath *)indexPath
{
    [super loadDataWithSfmPage:sfmPage forIndexPath:indexPath];
    
    SFMPageLayout *pageLayout = self.sfmPage.process.pageLayout;
    NSArray *detailLayouts =pageLayout.detailLayouts;

    if ([detailLayouts count]> self.selectedIndexPath.row) {
        self.detailLayout= [detailLayouts objectAtIndex:self.selectedIndexPath.row];
    }
    self.expandedSectionsDict = [[NSMutableDictionary alloc] init];
    [self setTableViewHeaderTitle];
    
    if (!self.detailLayout.allowNewLines) {
        self.tableView.tableFooterView = nil;
    }
}


- (NSString *) displayValueForIndexPath:(NSIndexPath *)indexPath
{
   
    NSString  * title = @"--";
    NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
    
    NSArray * detailFields = self.detailLayout.detailSectionFields;
    NSArray * detailRecords = [detailDict objectForKey:self.detailLayout.processComponentId];
    
    SFMPageField * field  = nil;
    if([detailFields count] > 0)
    {
        field  = [detailFields objectAtIndex:0];
    }
    
    if([detailRecords count] > indexPath.section)
    {
        NSDictionary * recordDict = [detailRecords objectAtIndex:indexPath.section];
        SFMRecordFieldData * fieldData = [recordDict objectForKey:field.fieldName];
        
        if (![StringUtil isStringEmpty:fieldData.displayValue]) {
            title = fieldData.displayValue;
        }
    }
    return  title;
}

- (BOOL) isSectionExpanded:(int)section
{
    BOOL isSectionExpanded = NO;
    NSNumber *sectionNumber = [[NSNumber alloc] initWithInt:section];
    if ([[self.expandedSectionsDict allKeys] containsObject:sectionNumber]) {
        isSectionExpanded = YES;
    }
    return isSectionExpanded;
}


- (void)addNewLine:(id)sender
{
    if (self.detailLayout.allowMultiAddConfig) {
        [self showLookupViewController];

    }
    else{
        [self addNewSingleLineItem];

    }
}

- (void)showLookupViewController
{
    SFMLookUpViewController * lookUp = [[SFMLookUpViewController alloc] initWithNibName:@"SFMLookUpViewController" bundle:nil];
    lookUp.selectionMode = multiSelectionMode;
    
    SFMDetailLayout *detailLayout = [self detailLayout];
    lookUp.objectName = detailLayout.multiAddSearhObject;
    for (SFMPageField *pageField in detailLayout.detailSectionFields) {
        if ([pageField.fieldName isEqualToString:detailLayout.multiAddSearchField]) {
            lookUp.lookUpId = pageField.namedSearch;
            lookUp.callerFieldName = detailLayout.multiAddSearchField;
            break;
        }
    }
    lookUp.delegate = self;
    lookUp.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:lookUp animated:YES completion:^{
    }];
}

- (void) addNewSingleLineItem{
    [self addNewLinesToSfmPage:nil isMultiAddMode:NO];
    [self addNewSections:1];
    [self expandSection:YES forIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.tableView numberOfSections]-1]];

}

- (void) expandSection:(BOOL)shoudExpand forIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *section = [[NSNumber alloc] initWithInt:indexPath.section];
    NSArray *indexPathArray = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:indexPath.section], nil];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
 
    NSString *imageName = nil;
    if (shoudExpand) {
        PageEditChildLayoutViewController *childViewController = [self childLayoutViewControllerForIndexPath:indexPath];
        [self.expandedSectionsDict setObject:childViewController forKey:section];
        [self addChildViewController:childViewController];
        [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        imageName = @"sfm_down_arrow";
       /* UIButton *removeButton = [self showRemoveButton:[self shouldRemoveChildLine:indexPath]];
        
        CGSize size = [StringUtil getSizeOfText:@"Parts Actions" withFont:[UIFont fontWithName:kHelveticaNeueLight size:kFontSize16]];
        
        UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, 50)];
        [actionButton setTitle:@"Parts Actions" forState:UIControlStateNormal];
        [actionButton setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateNormal];
        [actionButton.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueLight size:kFontSize16]];
        
        UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width+70, 50)];
        [accessoryView addSubview:actionButton];
        [accessoryView addSubview:removeButton];*/
        
        cell.accessoryView = [self accessoryViewForCell:indexPath];
        cell.accessoryView.tag = indexPath.section;
        //cell.accessoryView.backgroundColor = [UIColor yellowColor];
    }
    else {
        
        [self.expandedSectionsDict removeObjectForKey:section];
        NSArray *indexPathArray = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:indexPath.section], nil];

        [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];

        imageName = @"sfm_right_arrow";
        cell.accessoryView = nil;
        cell.accessoryView.tag = -1;
    };
    cell.imageView.image = [UIImage imageNamed:imageName];
    
    if ([self.delegate respondsToSelector:@selector(reloadDataForIndexPath:reloadAll:)]) {
        [self.delegate reloadDataForIndexPath:self.selectedIndexPath reloadAll:NO];
    }
}

- (BOOL) shouldRemoveChildLine:(NSIndexPath *)indexPath{
    BOOL shouldDelete = NO;
    /*Delete lines always allowed for locally created records*/
    if (self.detailLayout.allowDeleteLines || [self isLocallyCreatedRecord:indexPath]) {
        shouldDelete = YES;
    }
    return shouldDelete;
}

- (BOOL) isLocallyCreatedRecord:(NSIndexPath *)indexPath
{
    BOOL isLocalRecord = NO;
    NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
    NSArray * detailRecords = [detailDict objectForKey:self.detailLayout.processComponentId];
    NSDictionary *detailRecordDict = [detailRecords objectAtIndex:indexPath.section];
    SFMRecordFieldData *idRecordField = [detailRecordDict objectForKey:kId];
    if (idRecordField == nil || [StringUtil isStringEmpty:idRecordField.internalValue]) {
        isLocalRecord = YES;
    }
    return isLocalRecord;
}

- (UIButton *) showRemoveButton:(BOOL)shouldShow
{
    UIButton *removeButton = nil;
    if (shouldShow) {
        removeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        [removeButton addTarget:self action:@selector(removeChildLine:) forControlEvents:UIControlEventTouchUpInside];
        [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
        [removeButton setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateNormal];
        [removeButton.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueLight size:kFontSize16]];

    }
    return removeButton;
}

- (UIButton *)showRemoveButton
{
    UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
    [removeButton addTarget:self action:@selector(removeChildLine:) forControlEvents:UIControlEventTouchUpInside];
    [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
    [removeButton setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateNormal];
    [removeButton.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueLight size:kFontSize16]];
    
    return removeButton;
}

- (BOOL) isRemoveButtonShownForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryView == nil)
    {
        return NO;
    }
    return YES;

}

- (PageEditChildLayoutViewController*)childLayoutViewControllerForIndexPath:(NSIndexPath *)indexPath
{
    PageEditChildLayoutViewController *childViewController = [self.expandedSectionsDict objectForKey:[NSNumber numberWithInt:indexPath.section]];
    if (childViewController == nil) {
        childViewController = [ViewControllerFactory createViewControllerByContext:ViewControllerSFMEditChildLayout];
        childViewController.sfmPage = self.sfmPage;
        childViewController.selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.section inSection:self.selectedIndexPath.row];
        childViewController.delegate = self;
    }
    return childViewController;
}


- (CGFloat) heightOfChildViewControllerForIndexPath:(NSIndexPath *)indexPath
{
    CGFloat viewHeight = 0;
    PageEditChildLayoutViewController *childViewController = [self childLayoutViewControllerForIndexPath:indexPath];
    if ([childViewController conformsToProtocol:@protocol(PageEditDetailViewControllerDelegate)]) {
        viewHeight = [childViewController heightOfTheView];
    }
    return viewHeight;

}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = kChildListTableViewRowHeight;
    if (indexPath.row == 1) {
        rowHeight = [self heightOfChildViewControllerForIndexPath:indexPath];
    }
    
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kChildListTableViewSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kChildListTableViewSectionFooterHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18];
    headerView.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    self.selectedCellIndexPath = indexPath;
    if ([self isSectionExpanded:indexPath.section]) {
        [self expandSection:NO forIndexPath:indexPath];
    }
    else{
        [self expandSection:YES forIndexPath:indexPath];

    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kChildListFooterIdentifier];
    if (footerView == nil) {
        footerView = [[UIView alloc]init];
        UIImageView *lineSeparator = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timing-line"]];
        lineSeparator.frame = CGRectMake(50, 0, self.tableView.frame.size.width-50, 1);
        [footerView addSubview:lineSeparator];
    }
    
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return ([self shouldRemoveChildLine:indexPath] && (![self isRemoveButtonShownForIndexPath:indexPath]) && (indexPath.row==0));
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Remove";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if ([self removeChildLineFromIndexPath:indexPath]) {
            [self updateExpandedSections:indexPath.section];

            [self removeTableViewSection:indexPath];
        }
    }
    
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark -
#pragma mark UITableViewDatasSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isSectionExpanded:section]) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    if (indexPath.row == 0) {
        cellIdentifier = kChildListCellIdentifier1;
    }
    else{
        cellIdentifier = kChildListCellIdentifier2;
    }
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18];

    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"sfm_right_arrow.png"];
        cell.textLabel.text = [self displayValueForIndexPath:indexPath];

        if ([self isSectionExpanded:indexPath.section]) {
            cell.imageView.image = [UIImage imageNamed:@"sfm_down_arrow.png"];
            cell.accessoryView = [self showRemoveButton:[self shouldRemoveChildLine:indexPath]];
            cell.accessoryView.tag = indexPath.section;
        }
        else
        {
            cell.accessoryView = nil;
            cell.accessoryView.tag = -1;

        }
    }
    else  if(indexPath.row == 1){
        if ([self isSectionExpanded:indexPath.section]) {
            [[cell.contentView viewWithTag:CELL_VIEW_TAG] removeFromSuperview];
            [cell.textLabel removeFromSuperview];
        UIViewController *viewController = [self childLayoutViewControllerForIndexPath:indexPath];
        viewController.view.frame = CGRectMake(40, 0, self.tableView.bounds.size.width-40, [self heightOfChildViewControllerForIndexPath:indexPath]);
        viewController.view.tag = CELL_VIEW_TAG;
        [cell.contentView addSubview:viewController.view];
        
        cell.imageView.image = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
    NSArray * detailRecords = [detailDict objectForKey:self.detailLayout.processComponentId];
    return [detailRecords count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)heightOfTheView
{
    CGFloat tableViewHeight = 0;
    
    /*Tableview header and footer height*/
    tableViewHeight = kChildListTableViewHeaderHeight;
    if (self.detailLayout.allowNewLines) {
        tableViewHeight +=kChildListTableViewFooterHeight;
    }
    /*Calculate height of each row*/
    NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
    NSArray * detailRecords = [detailDict objectForKey:self.detailLayout.processComponentId];

    int numberOfSections = [detailRecords count];
    
    for (int sectionIndex=0; sectionIndex<numberOfSections; sectionIndex++) {
        tableViewHeight += kChildListTableViewSectionHeaderHeight+kChildListTableViewSectionFooterHeight;
        int numberOfRows = 1;
        if ([self isSectionExpanded:sectionIndex]) {
            numberOfRows = 2;
        }
        for(int rowIndex=0; rowIndex<numberOfRows; rowIndex++){
            if (rowIndex == 0) {
                tableViewHeight += kChildListTableViewRowHeight;
            }
            else{
                tableViewHeight += [self heightOfChildViewControllerForIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];

            }
        }
    }
    
    return tableViewHeight;
}

- (void)keyboardShownInSelectedIndexPath:(NSIndexPath *)indexPath;
{
    [self.delegate keyboardShownInSelectedIndexPath:self.selectedIndexPath];
}

- (CGFloat)internalOffsetToSelectedIndex
{
    CGFloat internalOffset = 40;
    
    NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
    NSArray * detailRecords = [detailDict objectForKey:self.detailLayout.processComponentId];
    int recordCount = [detailRecords count];
    
    for(int recordIndex = 0; recordIndex<recordCount; recordIndex++)
    {
        internalOffset+=kChildListTableViewRowHeight;

        if ([self isSectionExpanded:recordIndex] ) {
            PageEditChildLayoutViewController *childViewController = [self.expandedSectionsDict objectForKey:[NSNumber numberWithInt:recordIndex]];
            if (childViewController.tappedCellIndex!= nil && childViewController.tappedCellIndex.section == recordIndex) {
                internalOffset += [childViewController internalOffsetToSelectedIndex];
                break;
            }
            else{
                internalOffset +=[childViewController heightOfTheView];

            }
            
        }
    }
    return internalOffset;
}


- (void)willRemoveViewFromSuperView {
    NSArray *expandedViewControllers = [self.expandedSectionsDict allValues];
    for (PageEditChildLayoutViewController *childVC in expandedViewControllers) {
        [childVC willRemoveViewFromSuperView];
    }
}

- (void) reloadDataForIndexPath:(NSIndexPath *)indexPath reloadAll:(BOOL)reloadAllSections{
    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
    NSIndexPath *firstRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.row];
    [indexPathArray addObject:firstRowIndexPath];
    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:firstRowIndexPath];
    if (cell != nil) {
        cell.textLabel.text = [self displayValueForIndexPath:firstRowIndexPath];
    }
    
}

- (void)resignAllFirstResponders {
    NSArray *expandedViewControllers = [self.expandedSectionsDict allValues];
    for (PageEditChildLayoutViewController *childVC in expandedViewControllers) {
        [childVC resignAllFirstResponders];
    }
}
#pragma mark -
#pragma mark Orientation Handling

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self reloadExpandedSections];
}


- (void) reloadExpandedSections
{
   /* NSArray *expandedSections = [self.expandedSectionsDict allKeys];
    for (NSNumber *section in expandedSections) {
        NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
        [indexPathArray addObject:[NSIndexPath indexPathForRow:1 inSection:section.intValue]];
//        [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section.intValue] withRowAnimation:UITableViewRowAnimationNone];
        
    }*/
    [self.tableView reloadData];
    
    
}

#pragma mark -
#pragma mark -PageEditControlDelegate Delegate Methods
-(void)valuesForField:(NSArray *)modelsArray forIndexPath:(NSIndexPath *)indexPath selectionMode:(NSInteger)selectionMode
{
    [self addNewLinesToSfmPage:modelsArray isMultiAddMode:YES];
    [self addNewSections:[modelsArray count]];
}

#pragma mark -
#pragma mark Add Line Methods

- (void)addNewSections:(int)numberOfSections
{
    int sectionCount = [self.tableView numberOfSections];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc]init];

    for (int i=0; i<numberOfSections; i++) {
        [indexSet addIndex:sectionCount+i];
    }
    if (numberOfSections>0) {
        [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        if ([self.delegate respondsToSelector:@selector(reloadDataForIndexPath:reloadAll:)]) {
            [self.delegate reloadDataForIndexPath:self.selectedIndexPath reloadAll:NO];
        }

    }
}

- (void) addNewLinesToSfmPage:(NSArray *)modelsArray isMultiAddMode:(BOOL) isMultiAddMode
{
    if ((self.detailLayout.processComponentId != nil) && ([modelsArray count]> 0)) {
    }
    if (self.sfmPage.detailsRecord == nil) {
        self.sfmPage.detailsRecord = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *records =  [self.sfmPage.detailsRecord objectForKey:self.detailLayout.processComponentId];
    if (records == nil) {
        records = [[NSMutableArray alloc] init];
        [self.sfmPage.detailsRecord setObject:records forKey:self.detailLayout.processComponentId];
    }
    
    if (isMultiAddMode) {
        for(SFMRecordFieldData *recordFieldData in modelsArray)
        {
            NSDictionary *childDict = [self createNewChildLineDict:recordFieldData];
            [records   addObject:childDict];
        }
    }
    else{
        NSDictionary *childDict = [self createNewChildLineDict:nil];
        [records  addObject:childDict];

    }
}

- (NSMutableDictionary *) createNewChildLineDict:(SFMRecordFieldData *)recordFieldData
{
    NSMutableDictionary *chidLineDict = [[NSMutableDictionary alloc] init];
    
    /* Create local Id */
    NSString *localId =  [AppManager generateUniqueId];
    SFMRecordFieldData *localIdDataField = [[SFMRecordFieldData alloc] initWithFieldName:kLocalId value:localId andDisplayValue:localId];
    [chidLineDict setObject:localIdDataField forKey:kLocalId];
    
    /*Update parent Column name*/
    SFProcessComponentModel  *processComponent = [self.sfmPage.process.component objectForKey:self.detailLayout.processComponentId];
    [chidLineDict setValue:[self parentColumnNameData:processComponent] forKey:processComponent.parentColumnName];

    
    /* Create fields */
    NSArray *fields = self.detailLayout.detailSectionFields;
    for (SFMPageField *aField in fields) {
        if (aField.fieldName != nil) {
            SFMRecordFieldData *valueField = [[SFMRecordFieldData alloc] initWithFieldName:aField.fieldName value:nil andDisplayValue:nil];
            if ([recordFieldData.name isEqualToString:aField.fieldName]) {
                valueField.internalValue = recordFieldData.internalValue;
                valueField.displayValue = recordFieldData.displayValue;
            }
            
            [chidLineDict setObject:valueField forKey:aField.fieldName];
        }
    }
    
    
    
    SFMRecordFieldData *aField = [chidLineDict objectForKey:kLocalId];
    if (aField.internalValue != nil) {
        if (self.sfmPage.newlyCreatedRecordIds == nil) {
            self.sfmPage.newlyCreatedRecordIds = [[NSMutableDictionary alloc] init];
        }
        
        NSMutableArray *idsArray =  [self.sfmPage.newlyCreatedRecordIds objectForKey:self.detailLayout.processComponentId];
        if (idsArray == nil) {
            idsArray = [[NSMutableArray alloc] init];
            [self.sfmPage.newlyCreatedRecordIds setObject:idsArray forKey:self.detailLayout.processComponentId];
        }
        [idsArray addObject:aField.internalValue];
    }
    [self applyValueMapping:chidLineDict];
    return chidLineDict;
}

- (SFMRecordFieldData *)parentColumnNameData:(SFProcessComponentModel *)processComponent {
    SFMRecordFieldData *newField = nil;
    if (processComponent.parentColumnName.length > 1) {
        NSString *parentColumnId  = nil;
        SFMRecordFieldData *headerId = [self.sfmPage.headerRecord objectForKey:kId];
        if (headerId.internalValue != nil) {
            parentColumnId = headerId.internalValue;
        }
        else{
            parentColumnId = self.sfmPage.recordId;
        }
        
        newField = [[SFMRecordFieldData alloc] init];
        newField.name = processComponent.parentColumnName;
        newField.internalValue = parentColumnId;
        newField.displayValue = parentColumnId;
        
        SFMRecordFieldData *aNameField = [self.sfmPage.headerRecord objectForKey:self.sfmPage.nameFieldValue];
        if (aNameField.displayValue != nil) {
            newField.displayValue = aNameField.displayValue;
        }
    }
    return newField;
}



#pragma mark -
#pragma mark Remove Line Methods
- (BOOL)removeChildLineFromIndexPath:(NSIndexPath *)indexPath{
    
    BOOL isDeleted = NO;
    NSMutableArray *detailRecords = [self.sfmPage.detailsRecord objectForKey: self.detailLayout.processComponentId];
    if ([detailRecords count]>indexPath.section) {
        
        /*Add deleted ids to deleted records list*/
        if (self.sfmPage.deletedRecordIds == nil) {
            self.sfmPage.deletedRecordIds = [[NSMutableDictionary alloc] init];
        }
        
        NSMutableArray *idsArray = [self.sfmPage.deletedRecordIds objectForKey:self.detailLayout.processComponentId];
        if (idsArray == nil) {
            idsArray = [[NSMutableArray alloc] init];
            [self.sfmPage.deletedRecordIds setObject:idsArray forKey:self.detailLayout.processComponentId];
        }
        
        /*For existing (sync) record, add sfid to the deleted records list*/
        NSDictionary *detailRecordDict = [detailRecords objectAtIndex:indexPath.section];
        SFMRecordFieldData *idRecordField = [detailRecordDict objectForKey:kId];
        
        /*For non-sync record, add local id to the deleted records list*/
        if ((idRecordField == nil) || (idRecordField.internalValue.length < 2)) {
            idRecordField = [detailRecordDict objectForKey:kLocalId];
        }
        NSString *recordId = idRecordField.internalValue;
        
        if (recordId != nil) {
            [idsArray addObject:recordId];
        }
        
        /*Delete the child line item from sfmpage*/
        [detailRecords removeObjectAtIndex:indexPath.section];
        
        isDeleted= YES;
    }
    return isDeleted;
}


- (void)removeChildLine:(id)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[sender tag]];
    [self expandSection:NO forIndexPath:indexPath];
    [self updateExpandedSections:indexPath.section];

    if ([self removeChildLineFromIndexPath:indexPath]) {
        [self removeTableViewSection:indexPath];
    }
    else{
        [self expandSection:YES forIndexPath:indexPath];
    }
}

- (void) removeTableViewSection:(NSIndexPath *)indexPath
{
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    if ([self.delegate respondsToSelector:@selector(reloadDataForIndexPath:reloadAll:)]) {
        [self.delegate reloadDataForIndexPath:self.selectedIndexPath reloadAll:NO];
    }
}

- (void) updateExpandedSections:(int)section
{
    NSMutableArray *allExpandedSections = [[NSMutableArray alloc]initWithArray:[self.expandedSectionsDict allKeys]];
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [allExpandedSections sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    
    for (NSNumber *eachSection in allExpandedSections) {
        if (eachSection.intValue>section) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:eachSection.intValue]];
            
            PageEditChildLayoutViewController *childViewController = [self.expandedSectionsDict objectForKey:eachSection];
            [self.expandedSectionsDict setObject:childViewController forKey:[[NSNumber alloc]initWithInt:eachSection.intValue-1]];
            cell.accessoryView.tag = eachSection.intValue-1;
            [self.expandedSectionsDict removeObjectForKey:eachSection];
        }
    }
    
}

#pragma mark -
#pragma mark Value Mapping Methods

-(void)applyValueMapping:(NSMutableDictionary *)childDict
{
    SFMPageEditManager * manager = [[SFMPageEditManager alloc ] init];
    ValueMappingModel * valueMapModel = [[ValueMappingModel alloc] init];
    valueMapModel.currentRecord = childDict;
    valueMapModel.currentObjectName = self.detailLayout.objectName;
    valueMapModel.valueMappingDict = [self.sfmPage.process.valueMappingDict objectForKey:self.detailLayout.processComponentId];
    [manager applyValueMapWithMappingObject:valueMapModel];
}
#pragma mark - END

#pragma mark - Linked Process
- (UIView *)accessoryViewForCell:(NSIndexPath *)indexPath
{
    //Default Frame
    CGRect frame = CGRectMake(0, 0, 60, 50);
    UIView *accessoryView = [[UIView alloc] initWithFrame:frame];
    accessoryView.backgroundColor = [UIColor clearColor];
    
    CGRect buttonFrame = frame;
    CGRect actionFrame = frame;
    
    if ([self.detailLayout.linkedProcess count])
    {
        CGSize size = [StringUtil getSizeOfText:@"Parts Actions" withFont:[UIFont fontWithName:kHelveticaNeueThin size:kFontSize16]];
        frame.size.width = size.width + 60;
        accessoryView.frame = frame;
        
        UIButton *actionButton = [self showLinkedProcessButton:@"Parts Actions"];
        actionFrame.size.width = size.width;
        actionButton.frame = actionFrame;
      //  [accessoryView addSubview:actionButton];
       
        buttonFrame.origin.x = actionButton.frame.size.width + 10;
    }
    if ([self shouldRemoveChildLine:indexPath]  ) {
        UIButton *removeButton = [self showRemoveButton];
        removeButton.frame = buttonFrame;
        [accessoryView addSubview:removeButton];
    }
    return accessoryView;
}

- (UIButton *)showLinkedProcessButton:(NSString *)title
{
    UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [actionButton addTarget:self action:@selector(showLinkedProcessList:) forControlEvents:UIControlEventTouchUpInside];
    [actionButton setTitle:title forState:UIControlStateNormal];
    [actionButton setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateNormal];
    [actionButton.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueLight size:kFontSize16]];
    return actionButton;
}


- (void)showLinkedProcessList:(id)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[sender tag]];
    
    UIButton *button = (UIButton *)sender;
    
    LinkedProcessViewController *controller = [[LinkedProcessViewController alloc] init];
    controller.linkedProces = self.detailLayout.linkedProcess;
    controller.objectName = self.detailLayout.objectName;
    controller.headerObject = self.sfmPage.objectName;
    controller.recordId = [self getRecordIdForIndexPath:indexPath];
    controller.preferredContentSize = [controller getPopoverContentSize];
    
    controller.linkedProcessDelegate = self;
    
    self.popOver = [[UIPopoverController alloc] initWithContentViewController:controller];
    self.popOver.popoverLayoutMargins = UIEdgeInsetsMake(135, 200, 0, 100);
    [self.popOver setPopoverContentSize:[controller getPopoverContentSize]];
    
    [self.popOver presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:0 animated:YES];
}

- (void)showLinkedProcess:(id)processInfo
{
    if ([self.delegate respondsToSelector:@selector(loadLinkedSFMProcessForProcessInfo:)]) {
        [self dismissPopover];
        [self.delegate loadLinkedSFMProcessForProcessInfo:processInfo];
    }
}

- (void)dismissPopover
{
    if ([self.popOver isPopoverVisible] || self.popOver != nil) {
        [self.popOver dismissPopoverAnimated:NO];
        self.popOver = nil;
    }
}

- (NSString *)getRecordIdForIndexPath:(NSIndexPath *)indexPath
{
    NSString *recordId = nil;
    NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
    
    NSArray * detailRecords = [detailDict objectForKey:self.detailLayout.processComponentId];
    
    if([detailRecords count] > indexPath.section)
    {
        NSDictionary * recordDict = [detailRecords objectAtIndex:indexPath.section];
        SFMRecordFieldData * fieldData = [recordDict objectForKey:kLocalId];
        
        if (![StringUtil isStringEmpty:fieldData.internalValue]) {
            recordId = fieldData.internalValue;
        }
    }
    return  recordId;
}

#pragma mark - End

@end
