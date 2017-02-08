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
#import "TagManager.h"
#import "SFMPageEditManager.h"
#import "SFMPageEditHelper.h"
#import "PageEventModel.h"
#import "PushNotificationHeaders.h"


NSString *const kChildListCellIdentifier1 = @"CellIdentifierDefault";
NSString *const kChildListCellIdentifier2 = @"CellIdentifierExpand";
NSString *const kChildListHeaderIdentifier = @"HeaderIdentifier";
NSString *const kChildListFooterIdentifier = @"FooterIdentifier";


#define kChildListTableViewHeaderHeight 30.0
#define kChildListTableViewFooterHeight 76.0
#define kChildListTableViewRowHeight 100.0
#define kChildListTableViewSectionHeaderHeight 0
#define kChildListTableViewSectionFooterHeight 1

#define CELL_VIEW_TAG 100
#define MULTI_PAGEFIELD_TAG 300
#define TITLE_LABEL_TAG 400
#define IMAGE_VIEW_TAG 500
#define ADD_BUTTON_HEIGHT 30.0f

@interface PageEditChildListViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SFMDetailLayout *detailLayout;
@property (strong, nonatomic) NSMutableDictionary *expandedSectionsDict;

@property (nonatomic, strong)UIPopoverController *popOver;

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
    self.tableView.backgroundColor = [UIColor clearColor];//[UIColor getUIColorFromHexValue:kPageViewMasterBGColor];
    self.tableView.scrollEnabled = NO;
    
    [self addTableViewHeader];
    [self addTableViewFooter];
    
    [self registerForPopOverDismissNotification];
}

//HS 3 Jul2015 Fix for defect - 018329
-(void)viewDidDisappear:(BOOL)animated
{
    self.tableView.editing=false;
}
//Fix ends here

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
   
    NSString *title = [NSString stringWithFormat:@"+ %@",[[TagManager sharedInstance]tagByName:kTag_Add]];
    
     UIButton *addButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 23, 80.0f, ADD_BUTTON_HEIGHT)];
    CGFloat width = [ self getTheWidthForTheString:title withTheHeight:ADD_BUTTON_HEIGHT];
    
    if(width >= 75.0f)
    {
        CGRect frame = addButton.frame;
        frame.size.width = width + 5;
        addButton.frame = frame;
    }
    
    [addButton setBackgroundColor:[UIColor navBarBG]];
    [addButton addTarget:self action:@selector(addNewLine:) forControlEvents:UIControlEventTouchUpInside];

    
    [addButton setTitle:title forState:UIControlStateNormal];
    addButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
//    if([detailFields count])
//    {
//        field  = [detailFields objectAtIndex:0];
//    }
    
    if(([detailRecords count] > indexPath.section) && [detailFields count])
    {
        field  = [detailFields objectAtIndex:0];

        NSDictionary * recordDict = [detailRecords objectAtIndex:indexPath.section];
        SFMRecordFieldData * fieldData = [recordDict objectForKey:field.fieldName];
        
        if (![StringUtil isStringEmpty:fieldData.displayValue]) {
            title = fieldData.displayValue;
        }
    }
    return  title;
}

- (BOOL) isSectionExpanded:(NSInteger)section
{
    BOOL isSectionExpanded = NO;
    NSNumber *sectionNumber = [[NSNumber alloc] initWithInteger:section];
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
            lookUp.lookUpId =  pageField.namedSearch;
            lookUp.objectName = pageField.relatedObjectName;
            lookUp.callerFieldName = pageField.fieldName;
            lookUp.pageField = pageField;
            lookUp.contextObjectName = [self getsourceObjectName:pageField];
            
            break;
        }
    }
    lookUp.delegate = self;
    lookUp.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:lookUp animated:YES completion:^{
    }];
}

//Commenting getInternalValueForLiteralForLookUp cause this method will be triggered only if lookup is triggered for line record before it being created. Hence there is no detail line record present yet.
/* Commenting due to re-opening of 026110
- (SFMRecordFieldData *)getInternalValueForLiteralForLookUp:(NSString *)lietral
{
 
    SFMDetailLayout * layout = [self.sfmPage.process.pageLayout.detailLayouts
                                objectAtIndex:self.selectedIndexPath.section];
    
    NSString *compId = layout.processComponentId;
    compId = self.detailLayout.processComponentId;
    NSLog(@"row:%ld, section;%ld",self.selectedIndexPath.row, self.selectedIndexPath.section);
    NSArray *detailArray = [self.sfmPage.detailsRecord objectForKey:compId];
    NSDictionary *recordDataDict = [detailArray objectAtIndex:self.selectedIndexPath.row];
    
    SFMPageEditManager *pageManager = [[SFMPageEditManager alloc] init];
    
    ValueMappingModel * mappingModel = [[ValueMappingModel alloc] init];
    mappingModel.currentRecord = [NSMutableDictionary dictionaryWithDictionary:recordDataDict];
    mappingModel.headerRecord = self.sfmPage.headerRecord;
    mappingModel.currentObjectName = layout.objectName;
    mappingModel.headerObjectName = self.sfmPage.objectName;
    
    SFMRecordFieldData *recordData = [pageManager getDisplayValueForLiteral:lietral mappingObject:mappingModel];
    
    return recordData;
}
*/

- (SFMRecordFieldData *)filterCriteriaForContextFilter:(NSString *)fieldName forHeaderObject:(NSString *)headerValue {
    
    if([headerValue isEqualToString:kcurrentRecordContextFilter ] || [headerValue length] == 0 || [headerValue isEqualToString:@""]) {
        
        /* commenting to re-opening of 026110
        SFMDetailLayout * layout = [self.sfmPage.process.pageLayout.detailLayouts
                                    objectAtIndex:self.selectedIndexPath.row];
        NSString *compId = layout.processComponentId;
        
        NSArray *detailArray = [self.sfmPage.detailsRecord objectForKey:compId];
        NSDictionary *recordDataDict = [detailArray objectAtIndex:self.selectedIndexPath.row];
        
        SFMRecordFieldData *recordData = [recordDataDict objectForKey:fieldName];
        return recordData;
         */
        return nil;
        
    }
    else {
        
        SFMRecordFieldData *recordData = [self.sfmPage getHeaderFieldDataForName:fieldName];
        return recordData;
    }
    return nil;
}

- (NSString *)getsourceObjectName:(SFMPageField *)pageField {
    
    if ([pageField.sourceObjectField isEqualToString:kcurrentRecordContextFilter] || [pageField.sourceObjectField length] == 0 || [pageField.sourceObjectField isEqualToString:@""] ) {
        
        SFMDetailLayout *detailLayout = [self detaillayout];
        return  detailLayout.objectName;
        
    }
    return self.sfmPage.objectName;
}

-(SFMDetailLayout *)detaillayout
{
    SFMDetailLayout *detailLayout = nil;
    NSArray *detailLayoutArray = self.sfmPage.process.pageLayout.detailLayouts;
    if ([detailLayoutArray count] > self.selectedIndexPath.section) {
        
        detailLayout = [detailLayoutArray objectAtIndex:self.selectedIndexPath.section];
    }
    return detailLayout;
    
}

//9794 : is Billable flag respecting setting 15-16
- (NSString *) getHeaderBillingType {
    
    NSDictionary *hdr_object = self.sfmPage.headerRecord;
    NSString * billingTypeValue = nil;
    SFMRecordFieldData *fieldData = [hdr_object objectForKey:kWorkOrderBillingType];
    billingTypeValue = fieldData.internalValue; //Use display value if u want to check for locale.
    return billingTypeValue;
    
}

- (BOOL) isWebServiceConfiguredForIsBillable {
    
    if ([self.detailLayout.pageEvents count]) {
        
        for (PageEventModel *eventModel in self.detailLayout.pageEvents) {
            
            if ([eventModel.pageEventType isEqualToString:@"After Add Record"] && [StringUtil containsString:@"INTF_WebServicesDef.INTF_WO_SetIsBillable_WS" inString:eventModel.pageTargetCall]) {
                
                return YES;
            }
        }
    }
    return NO;
}

//9794 : is Billable flag respecting setting 15-16
- (void) updateIsBillableToAllTheLinesBasedOnSetting {
    
    if(![self isWebServiceConfiguredForIsBillable])
        return;
        
    NSArray *detailsRecords = [self.sfmPage.detailsRecord allKeys];
    NSDictionary *processComponent = self.sfmPage.process.component;
    NSString *isBillable = [self isBillableAfterRespectingTheSettings];
    
    //component ID
    for (NSString *component in detailsRecords) {
        
        NSArray *detailRecord = [self.sfmPage.detailsRecord objectForKey:component];
        SFProcessComponentModel *componentModel = [processComponent objectForKey:component];
        NSString *detailRecordObjectName = componentModel.objectName;
        if ([detailRecordObjectName isEqualToString:kWorkOrderDetailTableName]) {
            for (NSMutableDictionary *records in detailRecord) {
                
                if([self isBillableFieldHiddenInPageLayout:records]) {
                    SFMRecordFieldData *fieldData = [[SFMRecordFieldData alloc] initWithFieldName:kIsBillableLabel value:isBillable andDisplayValue:isBillable];
                    [records setObject:fieldData forKey:kIsBillableLabel];
                }
                else {
                    SFMRecordFieldData *recordData = [records objectForKey:kIsBillableLabel];
                    recordData.internalValue = isBillable;
                    recordData.displayValue = isBillable;
                }
            }
            
        }
        
    }
}
//9794 : is Billable flag respecting setting 15-16
- (BOOL)isBillableFieldHiddenInPageLayout:(NSDictionary *)dictionary {
    BOOL isBillableHidden = YES;
    
    if ([dictionary objectForKey:kIsBillableLabel]) {
            isBillableHidden = NO;
    }
    return isBillableHidden;
}
//check if value is available for settings

//9794 : is Billable flag respecting setting 15-16
-(NSString *)isBillableAfterRespectingTheSettings
{
    //Check if its work order and setting 15 is valid
    //if(YES) {
    //loop through parts labour expren
    NSString *returnValue = kTrue;
    NSString *setting15Value = [SFMPageEditHelper getSettingValueForKey:@"WORD005_SET015"];
    NSString *setting16Value = nil;
    
    if ([setting15Value isEqualToString:@"Entitlement"]) {
        //Apply Setting16
        setting16Value = [SFMPageEditHelper getSettingValueForKey:@"WORD005_SET016"];;
        
        NSArray *setting16ValueArray = [setting16Value componentsSeparatedByString:@","];
        //check if the header billing type is one of the value in setting 16
        NSString *billingTypeValue = [self getHeaderBillingType];
        
        for (NSString *set16 in setting16ValueArray) {
            if ([set16 isEqualToString:billingTypeValue]) {
                returnValue = kFalse; //return false according to setting 16
            }
        }
    }
    else {
       
        if ([StringUtil isItTrue:setting15Value]) {
            returnValue = kTrue;
        } else {
            returnValue = kFalse;
        }
    }
    return returnValue;
}

- (void) addNewSingleLineItem{
    BOOL status = [self addNewLinesToSfmPage:nil isMultiAddMode:NO];
    if (status) {
        [self addNewSections:1];
        [self expandSection:YES forIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.tableView numberOfSections]-1]];
    }
    

}

- (void) expandSection:(BOOL)shoudExpand forIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *section = [[NSNumber alloc] initWithInteger:indexPath.section];
    NSArray *indexPathArray = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:indexPath.section], nil];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
 
    NSString *imageName = nil;
    if (shoudExpand) {
        PageEditChildLayoutViewController *childViewController = [self childLayoutViewControllerForIndexPath:indexPath];
        if (childViewController != nil)
        {
           [self.expandedSectionsDict setObject:childViewController forKey:section];
           [self addChildViewController:childViewController];
        }
        if ([self.tableView numberOfSections])
        {
            [self.tableView  beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView  endUpdates];
        }
        imageName = @"sfm_down_arrow";
        
        cell.accessoryView = [self accessoryViewForCell:indexPath];
        cell.accessoryView.tag = indexPath.section;
    }
    else {
        
        [self.expandedSectionsDict removeObjectForKey:section];
        NSArray *indexPathArray = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:1 inSection:indexPath.section], nil];
        @try {
            [self.tableView  beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView  endUpdates];
        }
        @catch (NSException *exception) {
            
        }
        imageName = @"sfm_right_arrow";
        cell.accessoryView = nil;
        cell.accessoryView.tag = -1;
    };
    
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:IMAGE_VIEW_TAG];
    imageView.image = [UIImage imageNamed:imageName];
    //cell.imageView.image = [UIImage imageNamed:imageName];

    if ([self.delegate respondsToSelector:@selector(reloadDataForIndexPath:reloadAll:)]) {
        [self.delegate reloadDataForIndexPath:self.selectedIndexPath reloadAll:NO];
    }
    [self.tableView reloadData];
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

/*- (UIButton *) showRemoveButton:(BOOL)shouldShow
{
    UIButton *removeButton = nil;
    if (shouldShow) {
        removeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        [removeButton addTarget:self action:@selector(removeChildLine:) forControlEvents:UIControlEventTouchUpInside];
        [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
        [removeButton setTitleColor:[UIColor getUIColorFromHexValue:kOrangeColor] forState:UIControlStateNormal];
        [removeButton.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueLight size:kFontSize16]];

    }
    return removeButton;
}*/

- (UIButton *)showRemoveButton
{
    UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
    [removeButton addTarget:self action:@selector(removeChildLine:) forControlEvents:UIControlEventTouchUpInside];
    [removeButton setTitle:[[TagManager sharedInstance]tagByName:kTagConflictRemove] forState:UIControlStateNormal];
    [removeButton setTitleColor:[UIColor getUIColorFromHexValue:kOrangeColor] forState:UIControlStateNormal];
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
    PageEditChildLayoutViewController *childViewController = [self.expandedSectionsDict objectForKey:[NSNumber numberWithInteger:indexPath.section]];
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
    
    if ([self isSectionExpanded:indexPath.section]) {
        rowHeight = 50;
    }
    
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
    return [[TagManager sharedInstance]tagByName:kTagConflictRemove];

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
        UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:IMAGE_VIEW_TAG];
        UIImage *rightArrowImage = [UIImage imageNamed:@"sfm_right_arrow.png"];
        UIImage *downArrowImage = [UIImage imageNamed:@"sfm_down_arrow.png"];
        CGRect rightArrowFrame = CGRectMake(20,7, rightArrowImage.size.width, rightArrowImage.size.height);
        CGRect downArrowFrame = CGRectMake(20,10, downArrowImage.size.width, downArrowImage.size.height);

        if (imageView == nil) {
            imageView = [[UIImageView alloc]initWithFrame:rightArrowFrame];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            // titleLabel.backgroundColor = [UIColor redColor];
            imageView.tag = IMAGE_VIEW_TAG;
            [cell.contentView addSubview:imageView];
        }
        imageView.frame = rightArrowFrame;
        imageView.image = [UIImage imageNamed:@"sfm_right_arrow.png"];
        //cell.textLabel.text = [self displayValueForIndexPath:indexPath];

        if ([self isSectionExpanded:indexPath.section]) {
            imageView.frame = downArrowFrame;
            imageView.image = [UIImage imageNamed:@"sfm_down_arrow.png"];
            cell.accessoryView = [self accessoryViewForCell:indexPath];
            cell.accessoryView.tag = indexPath.section;
            MultiPageFieldView  *multiPageFieldView = (MultiPageFieldView *)[cell.contentView viewWithTag:MULTI_PAGEFIELD_TAG];
            [multiPageFieldView removeFromSuperview];
            
            UILabel *titleLabel = (UILabel*)[cell.contentView viewWithTag:TITLE_LABEL_TAG];
            if (titleLabel == nil)
            {
                titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50,10,cell.frame.size.width, 20)];
                titleLabel.backgroundColor = [UIColor clearColor];
                titleLabel.tag = TITLE_LABEL_TAG;
                [cell.contentView addSubview:titleLabel];
            }
            NSString *theTitle = [self displayValueForIndexPath:indexPath];
            titleLabel.text = theTitle;
                
        }
        else
        {
            cell.accessoryView = nil;
            cell.accessoryView.tag = -1;
            MultiPageFieldView  *multiPageFieldView = (MultiPageFieldView *)[cell.contentView viewWithTag:MULTI_PAGEFIELD_TAG];
            if (multiPageFieldView == nil) {
                multiPageFieldView = [[MultiPageFieldView alloc] initWithFrame:CGRectMake(50,30,self.view.frame.size.width -50,50)];
                multiPageFieldView.tag = MULTI_PAGEFIELD_TAG;
               // multiPageFieldView.backgroundColor = [UIColor yellowColor];
                [cell.contentView addSubview:multiPageFieldView];
            }
            SFMPageField *firstPageField = [self pageFieldForIndex:1];
            multiPageFieldView.fieldLabelOne.text = [firstPageField label];
            multiPageFieldView.fieldValueOne.text = [self displayValueForPageField:firstPageField indexPath:indexPath];
            
            // was crashing here, hence the condition..
            if([self.detailLayout.detailSectionFields count] > 2) {
                SFMPageField *secondPageField = [self pageFieldForIndex:2];
                multiPageFieldView.fieldLabelTwo.text = [secondPageField label];
                multiPageFieldView.fieldValueTwo.text = [self displayValueForPageField:secondPageField indexPath:indexPath];
            }
            
            NSString *theTitle = [self displayValueForIndexPath:indexPath];
            UILabel *titleLabel = (UILabel*)[cell.contentView viewWithTag:TITLE_LABEL_TAG];
            if (titleLabel == nil)
            {
                titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50,10,cell.frame.size.width, 20)];
                titleLabel.backgroundColor = [UIColor clearColor];
                titleLabel.tag = TITLE_LABEL_TAG;
                [cell.contentView addSubview:titleLabel];
                titleLabel.text = theTitle;
            }
            else
            {
                titleLabel.text = theTitle;
            }
            //titleLabel.center = imageView.center;
            
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    MultiPageFieldView  *multiPageFieldView = (MultiPageFieldView *)[cell.contentView viewWithTag:MULTI_PAGEFIELD_TAG];
//    CGRect multiPageFieldFrame = CGRectMake(50, 0, self.tableView.bounds.size.width,100);
//    multiPageFieldView.frame = multiPageFieldFrame;
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

    NSInteger numberOfSections = [detailRecords count];
    
    for (int sectionIndex=0; sectionIndex<numberOfSections; sectionIndex++) {
        tableViewHeight += kChildListTableViewSectionHeaderHeight+kChildListTableViewSectionFooterHeight;
        int numberOfRows = 1;
        if ([self isSectionExpanded:sectionIndex]) {
            numberOfRows = 2;
        }
        for(int rowIndex=0; rowIndex<numberOfRows; rowIndex++){
            if (rowIndex == 0) {
                tableViewHeight += kChildListTableViewRowHeight/numberOfRows;
            }
            else{
                tableViewHeight += [self heightOfChildViewControllerForIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];

            }
        }
    }
    
    return tableViewHeight  + numberOfSections + 20 ;
}

- (void)keyboardShownInSelectedIndexPath:(NSIndexPath *)indexPath;
{
    [self.delegate keyboardShownInSelectedIndexPath:self.selectedIndexPath];
}

- (CGFloat)internalOffsetToSelectedIndex
{
    CGFloat internalOffset = 50;
    
    NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
    NSArray * detailRecords = [detailDict objectForKey:self.detailLayout.processComponentId];
    NSInteger recordCount = [detailRecords count];
    internalOffset+=kChildListTableViewRowHeight;
    for(int recordIndex = 0; recordIndex<recordCount; recordIndex++)
    {
        if ([self isSectionExpanded:recordIndex] ) {
            PageEditChildLayoutViewController *childViewController = [self.expandedSectionsDict objectForKey:[NSNumber numberWithInt:recordIndex]];
            if (childViewController.tappedCellIndex!= nil && childViewController.tappedCellIndex.section == recordIndex) {
                internalOffset += [childViewController internalOffsetToSelectedIndex];
                internalOffset+=((kChildListTableViewHeaderHeight+kChildListTableViewFooterHeight)/2)*recordIndex;
                break;
            }
            else{
                internalOffset-=kChildListTableViewSectionFooterHeight;
                internalOffset +=[childViewController heightOfTheView];

            }
            
        }
        else{
            if (recordIndex>0) {
                internalOffset+=(kChildListTableViewHeaderHeight+kChildListTableViewFooterHeight+kChildListTableViewSectionFooterHeight)/recordIndex;
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
        //cell.textLabel.text = [self displayValueForIndexPath:firstRowIndexPath];
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
   BOOL status = [self addNewLinesToSfmPage:modelsArray isMultiAddMode:YES];
    if (status) {
        [self addNewSections:[modelsArray count]];
    }
}

#pragma mark -
#pragma mark Add Line Methods

- (void)addNewSections:(NSInteger)numberOfSections
{
    NSInteger sectionCount = [self.tableView numberOfSections];
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

- (BOOL) addNewLinesToSfmPage:(NSArray *)modelsArray isMultiAddMode:(BOOL) isMultiAddMode
{
    if (self.detailLayout.processComponentId == nil){
        return NO;
    }
    
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
            
            [self updateIsBillableToAllTheLinesBasedOnSetting];
            
            NSInteger recordCount = [records count];
            
            NSIndexPath *indexPathNew = [NSIndexPath indexPathForRow:(recordCount - 1) inSection:self.selectedIndexPath.row];
            [self applyFormFillingInDictionaryAtIndexPath:indexPathNew andRecordField:recordFieldData];
            
        }
    }
    else{
        NSDictionary *childDict = [self createNewChildLineDict:nil];
        [records  addObject:childDict];
        [self updateIsBillableToAllTheLinesBasedOnSetting];

    }
    return YES;
 
}

- (void)applyFormFillingInDictionaryAtIndexPath:(NSIndexPath *)selectedIndexPath
                                 andRecordField:(SFMRecordFieldData *)selectedRecordField  {
    
    /* Check and Apply form fill */
    NSArray *pageFields = [self.detailLayout detailSectionFields];
    for (SFMPageField *pageField in pageFields) {
        if ([pageField.fieldName isEqualToString:selectedRecordField.name]) {
            
            if ([pageField.fieldName isEqualToString:selectedRecordField.name]) {
                
                if (![StringUtil isStringEmpty:pageField.fieldMappingId]) {
                    
                    SFMPageEditManager * manager = [[SFMPageEditManager alloc ] init];
                    [manager applyFormFillOnChildRecordOfIndexPath:selectedIndexPath sfpage:self.sfmPage withPageField:pageField andselectedIndex:selectedRecordField];
                    
                   
                }
                
            }
        }
    }
}

- (NSMutableDictionary *) createNewChildLineDict:(SFMRecordFieldData *)recordFieldData
{
    NSMutableDictionary *chidLineDict = [[NSMutableDictionary alloc] init];
    
    /* Create local Id */
    NSString *localId =  [AppManager generateUniqueId];
    SFMRecordFieldData *localIdDataField = [[SFMRecordFieldData alloc] initWithFieldName:kLocalId value:localId andDisplayValue:localId];
    [chidLineDict setObject:localIdDataField forKey:kLocalId];
    
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
    
    /*Update parent Column name*/
    SFProcessComponentModel  *processComponent = [self.sfmPage.process.component objectForKey:self.detailLayout.processComponentId];
    [chidLineDict setValue:[self parentColumnNameData:processComponent] forKey:processComponent.parentColumnName];
    
    
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
        
        // fix: 017923
        if (![StringUtil isStringEmpty:headerId.internalValue]) {
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
        if (![StringUtil isStringEmpty:aNameField.displayValue]) {
            newField.displayValue = aNameField.displayValue;
        }
        else {
            newField.displayValue = self.sfmPage.nameFieldValue;
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

- (void) updateExpandedSections:(NSInteger)section
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
            NSArray *subViews = [cell.accessoryView subviews];
            for (UIView *view in subViews) {
                view.tag = eachSection.intValue-1;
            }
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
    valueMapModel.headerRecord = self.sfmPage.headerRecord;
    valueMapModel.valueMappingDict = [self.sfmPage.process.valueMappingDict objectForKey:self.detailLayout.processComponentId];
    [manager applyValueMapWithMappingObject:valueMapModel withFieldOrder:[self.sfmPage.process.valueMappingArrayInLayoutOrder objectForKey:self.detailLayout.processComponentId]];
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
        NSString *title = [self titleForLinkedProcess];
        
        CGSize size = [StringUtil getSizeOfText:title withFont:[UIFont fontWithName:kHelveticaNeueLight size:kFontSize16]];
        frame.size.width = size.width;
        accessoryView.frame = frame;
        
        
        UIButton *actionButton = [self showLinkedProcessButton:title];
        actionFrame.size.width = size.width;
        actionButton.frame = actionFrame;
        actionButton.tag = indexPath.section;
        
        [accessoryView addSubview:actionButton];
       
        buttonFrame.origin.x = actionButton.frame.size.width + 10;
    }
    if ([self shouldRemoveChildLine:indexPath]  ) {
        if ([self.detailLayout.linkedProcess count]){
            frame.size.width += 70;
        }
        accessoryView.frame = frame;
        UIButton *removeButton = [self showRemoveButton];
        removeButton.tag = indexPath.section;
        accessoryView.tag = indexPath.section;
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
    [actionButton setTitleColor:[UIColor getUIColorFromHexValue:kOrangeColor] forState:UIControlStateNormal];
    [actionButton.titleLabel setFont:[UIFont fontWithName:kHelveticaNeueLight size:kFontSize16]];
    return actionButton;
}


- (void)showLinkedProcessList:(id)sender
{
    
    [self resignAllFirstResponders];
    UIButton *button = (UIButton *)sender;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[button tag]];

    LinkedProcessViewController *controller = [[LinkedProcessViewController alloc] init];
    controller.linkedProces = self.detailLayout.linkedProcess;
    controller.objectName = self.detailLayout.objectName;
    controller.headerObject = self.sfmPage.objectName;
    controller.recordId = [self getRecordIdForIndexPath:indexPath];
    
    controller.linkedProcessDelegate = self;
    
    self.popOver = [[UIPopoverController alloc] initWithContentViewController:controller];
    [self.popOver setPopoverContentSize:[controller getPopoverContentSize] animated:NO];
    
    
    self.popOver.backgroundColor = [UIColor getUIColorFromHexValue:kActionBgColor];
    
    CGRect frame = CGRectMake(button.frame.origin.x, button.frame.origin.y,
                              button.frame.size.width, button.frame.size.height-20);
    
    [self.popOver presentPopoverFromRect:frame inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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

- (NSString *)titleForLinkedProcess
{
    NSMutableString *title = [NSMutableString new];
    
    NSString *detailName = self.detailLayout.name;
    
    NSString *action = [[TagManager sharedInstance] tagByName:kTagActions];
    
    if ([detailName length] > 0) {
        [title appendFormat:@"%@ %@", detailName, action];
    }
    else{
        [title appendString:action];
    }
    return title;
}

#pragma mark - End

-(void)dealloc
{
    [self deregisterForPopOverDismissNotification];
}

- (void)expandRecordWithIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.row];
    if (![self isSectionExpanded:cellIndexPath.section]) {
        [self expandSection:YES forIndexPath:cellIndexPath];
    }
}

-(void)registerForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissPopoverEditscreen)
                                                 name:POP_OVER_DISMISS
                                               object:nil];
}

-(void)deregisterForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POP_OVER_DISMISS object:nil];
}

- (void)dismissPopoverEditscreen
{
    [self performSelectorOnMainThread:@selector(dismissPopoverIfNeeded) withObject:self waitUntilDone:YES];
}

- (void)dismissPopoverIfNeeded
{
    if ([self.popOver isPopoverVisible] &&
        self.popOver) {
        
        [self.popOver dismissPopoverAnimated:YES];
        self.popOver = nil;
    }
}


- (SFMRecordFieldData *)getInternalValueForLiteral:(NSString *)lietral
{
    if ([StringUtil containsString:kLiteralCurrentRecordHeader inString:lietral])
    {
        SFMPageEditManager *manager = [[SFMPageEditManager alloc] init];
        
        ValueMappingModel * mappingModel = [[ValueMappingModel alloc] init];
        mappingModel.currentRecord = self.sfmPage.headerRecord;
        mappingModel.headerRecord = self.sfmPage.headerRecord;
        mappingModel.currentObjectName = self.sfmPage.objectName;
        mappingModel.headerObjectName = self.sfmPage.objectName;
        
        SFMRecordFieldData *recordData = [manager getDisplayValueForLiteral:lietral mappingObject:mappingModel];
        
        return recordData;
    }
    return nil;
}

- (CGFloat)getTheWidthForTheString:(NSString *)string withTheHeight:(CGFloat )height
{
    NSDictionary *userAttributes = @{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18]};
    CGRect expectedRect = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                            attributes:userAttributes
                                               context:nil];
    return expectedRect.size.width;
    
}

- (SFMPageField *)pageFieldForIndex:(NSUInteger)fieldIndex{
    
    NSArray * detailFields = self.detailLayout.detailSectionFields;
    
    SFMPageField * field  = nil;
//    if([detailFields count] > 0 && detailFields.count>fieldIndex)
    if(detailFields.count>fieldIndex)
    {
        field  = [detailFields objectAtIndex:fieldIndex];
    }
    return field;
}

- (NSString *)displayValueForPageField:(SFMPageField *)pageField indexPath:(NSIndexPath *)indexPath{
    NSString  * title = @"--";
    NSMutableDictionary * detailDict =  self.sfmPage.detailsRecord;
    
    NSArray * detailRecords = [detailDict objectForKey:self.detailLayout.processComponentId];
    if([detailRecords count] > indexPath.section)
    {
        NSDictionary * recordDict = [detailRecords objectAtIndex:indexPath.section];
        SFMRecordFieldData * fieldData = [recordDict objectForKey:pageField.fieldName];
        
        if (![StringUtil isStringEmpty:fieldData.displayValue]) {
            title = fieldData.displayValue;
            if ([pageField.dataType isEqualToString:kSfDTBoolean]) {
                if ([StringUtil isItTrue:fieldData.internalValue]) {
                    //title = kYes;//HS Fix:020290
                    title = [[TagManager sharedInstance]tagByName:kTagYes];
                }else{
                    //title = kNo;
                    title = [[TagManager sharedInstance]tagByName:kTagNo];
                }
                
            }
        }
    }
    return  title;
}

@end
